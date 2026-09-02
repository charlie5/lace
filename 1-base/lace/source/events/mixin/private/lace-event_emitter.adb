with
     lace.Observer,
     lace.Event.utility,
     lace.Event.Containers,

     system.RPC,

     ada.Containers.indefinite_Holders,
     ada.Containers.Vectors,
     ada.Text_IO,
     ada.Exceptions,
     ada.unchecked_Deallocation;


package body lace.event_Emitter
is

   ---------------
   --- Containers.
   --

   package string_Holders is new ada.Containers.indefinite_Holders (Element_type => String);
   subtype string_Holder  is string_Holders.Holder;


   package emitter_Vectors is new ada.Containers.Vectors (Positive,
                                                          Emitter_view);
   subtype emitter_Vector  is emitter_Vectors.Vector;


   use type lace.Observer.view;

   package observer_Vectors is new ada.Containers.Vectors (Positive,
                                                           lace.Observer.view);
   subtype observer_Vector  is observer_Vectors.Vector;


   ------------------
   --- Safe emitters.
   --

   protected
   type safe_Emitters
   is
      procedure add (new_Emitter : in     Emitter_view);
      procedure get (an_Emitter  :    out Emitter_view);

   private
      all_Emitters : emitter_Vector;
   end safe_Emitters;

   type safe_Emitters_view is access all safe_Emitters;


   -----------------
   --- Safe reports.
   --
   -- Each emitter reports its observer here when a delivery ends, successfully
   -- or not, which reopens the observer's channel for the next delivery.
   --

   protected
   type safe_Reports
   is
      procedure add   (the_Observer  : in     lace.Observer.view);
      procedure fetch (the_Observers :    out observer_Vector);

   private
      Completed : observer_Vector;
   end safe_Reports;

   type safe_Reports_view is access all safe_Reports;


   ------------
   --- Emitter.
   --

   task
   type Emitter
   is
      entry emit (Self         : in Emitter_view;
                  the_Event    : in lace.Event.item'Class;
                  To           : in lace.Observer.view;
                  from_Subject : in String;
                  Subject      : in lace.Subject.view;
                  Reports      : in safe_Reports_view;
                  Emitters     : in safe_Emitters_view);
   end Emitter;



   task
   body Emitter
   is
      Myself       : Emitter_view;
      Event        : lace.Event.Containers.event_Holder;
      the_Observer : lace.Observer.view;
      subject_Name : string_Holder;
      the_Subject  : lace.Subject.view;
      the_Reports  : safe_Reports_view;
      emitter_Pool : safe_Emitters_view;

   begin
      loop
         begin
            select
               accept emit (Self         : in Emitter_view;
                            the_Event    : in lace.Event.item'Class;
                            To           : in lace.Observer.view;
                            from_Subject : in String;
                            Subject      : in lace.Subject.view;
                            Reports      : in safe_Reports_view;
                            Emitters     : in safe_Emitters_view)
               do
                  Myself       := Self;
                  the_Observer := To;
                  the_Subject  := Subject;

                  the_Reports  := Reports;
                  emitter_Pool := Emitters;

                  Event       .replace_Element (the_Event);
                  subject_Name.replace_Element (from_Subject);
               end emit;
            or
               terminate;
            end select;

            declare
               observer_Name : constant String := the_Observer.Name;     -- Fails when the observer is dead, so no id is taken.

               Sequence : constant lace.Event.sequence_Id
                 := the_Subject.next_Sequence (for_observer_Name => observer_Name);
            begin
               the_Observer.receive (Event.Reference,
                                     from_Subject => subject_Name.Element,
                                     Sequence     => Sequence);

            exception
               when system.RPC.communication_Error
                  | storage_Error =>
                  the_Subject.restore_Sequence (for_observer_Name => observer_Name);     -- Sound ~ deliveries are serialised per observer,
                  raise;                                                                 -- so no later id exists for this observer.
            end;

            the_Reports .add (the_Observer);                             -- Reopen the observer's channel.
            emitter_Pool.add (Myself);                                   -- Return the emitter to the safe pool.

         exception
            when E : others =>
               if the_Reports /= null
               then
                  the_Reports .add (the_Observer);                       -- Reopen the observer's channel and return the emitter
                  emitter_Pool.add (Myself);                             -- to the safe pool before logging, which may itself fail.
               end if;

               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.put_Line ("Error detected in 'lace.event_Emitter.Emitter' task.");
               ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
               ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");

               begin
                  ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name & "'.");

               exception
                  when others =>
                     ada.Text_IO.put_Line ("Observer: unavailable ~ the observer is dead.");
               end;

               ada.Text_IO.put_Line ("Continuing.");
               ada.Text_IO.new_Line (2);
         end;
      end loop;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Emitter.Emitter' task.");
         ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
         ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");

         begin
            ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name & "'.");

         exception
            when others =>
               ada.Text_IO.put_Line ("Observer: unavailable ~ the observer is dead.");
         end;

         ada.Text_IO.new_Line (2);
   end Emitter;


   -------------------
   --- Emit delegator.
   --

   task
   body emit_Delegator
   is
      the_Subject      :         lace.Subject.view;
      the_subject_Name :         string_Holder;

      the_Emitters     : aliased safe_Emitters;
      the_Reports      : aliased safe_Reports;
      emitter_Count    :         Natural         := 0;

      the_Events       :         safe_Events_view;
      new_Events       :         event_Vector;
      Done             :         Boolean         := False;

      use type ada.Exceptions.Exception_Id;

      procedure free is new ada.unchecked_Deallocation (Emitter,
                                                        Emitter_view);

      --------------------------------------------------------------------------
      --- Channels ~ deliveries to a given observer are serialised via a channel,
      ---            so a failed delivery's sequence id can be safely reissued.
      --

      type Channel is
         record
            Observer : lace.Observer.view;
            Busy     : Boolean := False;
            Pending  : event_Vector;
         end record;

      package channel_Vectors is new ada.Containers.Vectors (Positive, Channel);

      Channels : channel_Vectors.Vector;


      function channel_Index (for_Observer : in lace.Observer.view) return Positive
      is
      begin
         for i in 1 .. Natural (Channels.Length)
         loop
            if Channels (i).Observer = for_Observer
            then
               return i;
            end if;
         end loop;

         Channels.append (Channel' (Observer => for_Observer,
                                    Busy     => False,
                                    Pending  => event_Vectors.empty_Vector));
         return Positive (Channels.Length);
      end channel_Index;


      function all_Channels_are_idle return Boolean
      is
      begin
         for Each of Channels
         loop
            if Each.Busy or else not Each.Pending.is_Empty
            then
               return False;
            end if;
         end loop;

         return True;
      end all_Channels_are_idle;


      procedure shutdown
      is
         the_Emitter : Emitter_view;
      begin
         -- Await busy emitters, so none can touch 'the_Emitters' or 'the_Reports' after this task exits.
         --
         while emitter_Count > 0
         loop
            the_Emitters.get (the_Emitter);

            if the_Emitter = null
            then
               delay 0.001;     -- A busy emitter has yet to return to the pool.
            else
               free (the_Emitter);
               emitter_Count := emitter_Count - 1;
            end if;
         end loop;
      end shutdown;


   begin
      accept start (Subject : in lace.Subject.view;
                    Events  : in safe_Events_view)
      do
         the_Subject := Subject;
         the_Events  := Events;

         the_subject_Name.replace_Element (Subject.Name);
      end start;


      loop
         select
            accept stop
            do
               Done := True;
            end stop;

         else
            null;
         end select;


         -- Queue each new event on the channel of every target observer.
         --
         the_Events.get (new_Events);

         for each_Event of new_Events
         loop
            declare
               use lace.Event.utility;

               the_Observers : constant lace.Subject.Observer_views := the_Subject.Observers (of_Kind => Kind_of (each_Event));
            begin
               for each_Observer of the_Observers
               loop
                  Channels (channel_Index (each_Observer)).Pending.append (each_Event);
               end loop;
            end;
         end loop;


         -- Reopen the channels of completed deliveries.
         --
         declare
            freed_Observers : observer_Vector;
         begin
            the_Reports.fetch (freed_Observers);

            for each_Observer of freed_Observers
            loop
               Channels (channel_Index (each_Observer)).Busy := False;
            end loop;
         end;


         -- Dispatch one pending delivery per idle channel.
         --
         for i in 1 .. Natural (Channels.Length)
         loop
            declare
               the_Emitter : Emitter_view;
            begin
               if         not Channels (i).Busy
                 and then not Channels (i).Pending.is_Empty
               then
                  the_Emitters.get (the_Emitter);

                  if the_Emitter = null
                  then
                     the_Emitter   := new Emitter;
                     emitter_Count := emitter_Count + 1;
                  end if;

                  the_Emitter.emit (Self         => the_Emitter,
                                    the_Event    => Channels (i).Pending.first_Element,
                                    To           => Channels (i).Observer,
                                    from_Subject => the_subject_Name.Element,
                                    Subject      => the_Subject,
                                    Reports      => the_Reports 'unchecked_Access,
                                    Emitters     => the_Emitters'unchecked_Access);

                  Channels (i).Pending.delete_First;
                  Channels (i).Busy := True;
               end if;

            exception
               when E : others =>
                  if          the_Emitter /= null
                     and then ada.Exceptions.exception_Identity (E) = tasking_Error'Identity
                  then
                     free (the_Emitter);                       -- The dead task never engaged ~ discard it and
                     emitter_Count := emitter_Count - 1;       -- retry the delivery with a fresh emitter.
                  end if;

                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line ("Error detected in 'lace.event_Emitter.emit_Delegator'.");
                  ada.Text_IO.put_Line ("Subject '" & the_subject_Name.Element & "'.");
                  ada.Text_IO.put_Line ("Continuing.");
                  ada.Text_IO.new_Line (2);
            end;
         end loop;


         exit when          Done
                   and then the_Events.is_Empty
                   and then all_Channels_are_idle;

         delay 0.001;
      end loop;

      shutdown;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Emitter.emit_Delegator' for subject '" & the_subject_Name.Element & "'.");
         ada.Text_IO.new_Line (2);

         shutdown;
   end emit_Delegator;


   ----------------
   --- Safe events.
   --

   protected
   body safe_Events
   is

      procedure add (new_Event : in lace.Event.item'Class)
      is
      begin
         all_Events.append (new_Event);
      end add;



      procedure get (the_Events : out event_Vector)
      is
      begin
         the_Events := all_Events;
         all_Events.clear;
      end get;



      function is_Empty return Boolean
      is
      begin
         return all_Events.is_Empty;
      end is_Empty;

   end safe_Events;


   ------------------
   --- Safe emitters.
   --

   protected
   body safe_Emitters
   is

      procedure add (new_Emitter : in Emitter_view)
      is
      begin
         all_Emitters.append (new_Emitter);
      end add;



      procedure get (an_Emitter : out Emitter_view)
      is
      begin
         if all_Emitters.is_Empty
         then
            an_Emitter := null;
         else
            an_Emitter := all_Emitters.last_Element;
            all_Emitters.delete_Last;
         end if;
      end get;

   end safe_Emitters;


   -----------------
   --- Safe reports.
   --

   protected
   body safe_Reports
   is

      procedure add (the_Observer : in lace.Observer.view)
      is
      begin
         Completed.append (the_Observer);
      end add;



      procedure fetch (the_Observers : out observer_Vector)
      is
      begin
         the_Observers := Completed;
         Completed.clear;
      end fetch;

   end safe_Reports;


   -----------------------
   --- event_Emitter item.
   --

   procedure define (Self : in out Item;   Subject : in lace.Subject.view)
   is
   begin
      Self.Delegator.start (Subject => Subject,
                            Events  => Self.Events'unchecked_Access);
   end define;



   procedure destroy (Self : in out Item)
   is
   begin
      Self.Delegator.stop;

      while not Self.Delegator'Terminated     -- Await the delegator, which uses 'Self.Events' until it exits.
      loop
         delay 0.001;
      end loop;
   end destroy;



   procedure add (Self : in out Item;   new_Event : in lace.Event.item'Class)
   is
   begin
      Self.Events.add (new_Event);
   end add;


end lace.event_Emitter;
