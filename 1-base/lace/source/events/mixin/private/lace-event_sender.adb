with
     system.RPC,

     ada.Text_IO,
     ada.Exceptions,
     ada.unchecked_Deallocation;


package body lace.event_Sender
is

   ---------------
   --- Containers.
   --

   package string_Holders is new ada.Containers.indefinite_Holders (Element_type => String);
   subtype string_Holder  is string_Holders.Holder;


   package sender_Vectors is new ada.Containers.Vectors (Positive,
                                                         Sender_view);
   subtype sender_Vector  is sender_Vectors.Vector;


   use type lace.Observer.view;

   package observer_Vectors is new ada.Containers.Vectors (Positive,
                                                           lace.Observer.view);
   subtype observer_Vector  is observer_Vectors.Vector;


   package pending_Vectors is new ada.Containers.Vectors (Positive,
                                                          event_Holder,
                                                          event_Holders."=");
   subtype pending_Vector  is pending_Vectors.Vector;


   -----------------
   --- Safe senders.
   --

   protected
   type safe_Senders
   is
      procedure add (new_Sender : in     Sender_view);
      procedure get (a_Sender   :    out Sender_view);

   private
      all_Senders : sender_Vector;
   end safe_Senders;

   type safe_Senders_view is access all safe_Senders;


   -----------------
   --- Safe reports.
   --
   -- Each sender reports its observer here when a delivery ends, successfully
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


   -----------
   --- Sender.
   --

   task
   type Sender
   is
      entry send (Self         : in Sender_view;
                  the_Event    : in lace.Event.item'Class;
                  To           : in lace.Observer.view;
                  from_Subject : in String;
                  Subject      : in lace.Subject.view;
                  Reports      : in safe_Reports_view;
                  Senders      : in safe_Senders_view);
   end Sender;



   task
   body Sender
   is
      Myself       : Sender_view;
      Event        : event_Holder;
      the_Observer : lace.Observer.view;
      subject_Name : string_Holder;
      the_Subject  : lace.Subject.view;
      the_Reports  : safe_Reports_view;
      sender_Pool  : safe_Senders_view;

   begin
      loop
         begin
            select
               accept send (Self         : in Sender_view;
                            the_Event    : in lace.Event.item'Class;
                            To           : in lace.Observer.view;
                            from_Subject : in String;
                            Subject      : in lace.Subject.view;
                            Reports      : in safe_Reports_view;
                            Senders      : in safe_Senders_view)
               do
                  Myself       := Self;
                  the_Observer := To;
                  the_Subject  := Subject;

                  the_Reports  := Reports;
                  sender_Pool  := Senders;

                  Event       .replace_Element (the_Event);
                  subject_Name.replace_Element (from_Subject);
               end send;
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

            the_Reports.add (the_Observer);                              -- Reopen the observer's channel.
            sender_Pool.add (Myself);                                    -- Return the sender to the safe pool.

         exception
            when E : others =>
               if the_Reports /= null
               then
                  the_Reports.add (the_Observer);                        -- Reopen the observer's channel and return the sender
                  sender_Pool.add (Myself);                              -- to the safe pool before logging, which may itself fail.
               end if;

               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.put_Line ("Error detected in 'lace.event_Sender.Sender' task.");
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
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Sender.Sender' task.");
         ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
         ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");

         begin
            ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name & "'.");

         exception
            when others =>
               ada.Text_IO.put_Line ("Observer: unavailable ~ the observer is dead.");
         end;

         ada.Text_IO.new_Line (2);
   end Sender;


   -------------------
   --- Send delegator.
   --

   task
   body send_Delegator
   is
      the_Subject      :         lace.Subject.view;
      the_subject_Name :         string_Holder;

      the_Senders      : aliased safe_Senders;
      the_Reports      : aliased safe_Reports;
      sender_Count     :         Natural     := 0;

      the_send_Details :         safe_send_Details_view;
      new_send_Details :         send_Details_Vector;

      Done             :         Boolean     := False;

      use type ada.Exceptions.Exception_Id;

      procedure free is new ada.unchecked_Deallocation (Sender,
                                                        Sender_view);

      --------------------------------------------------------------------------
      --- Channels ~ deliveries to a given observer are serialised via a channel,
      ---            so a failed delivery's sequence id can be safely reissued.
      --

      type Channel is
         record
            Observer : lace.Observer.view;
            Busy     : Boolean := False;
            Pending  : pending_Vector;
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
                                    Pending  => pending_Vectors.empty_Vector));
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
         the_Sender : Sender_view;
      begin
         -- Await busy senders, so none can touch 'the_Senders' or 'the_Reports' after this task exits.
         --
         while sender_Count > 0
         loop
            the_Senders.get (the_Sender);

            if the_Sender = null
            then
               delay 0.001;     -- A busy sender has yet to return to the pool.
            else
               free (the_Sender);
               sender_Count := sender_Count - 1;
            end if;
         end loop;
      end shutdown;


   begin
      accept start (Subject      : in lace.Subject.view;
                    send_Details : in safe_send_Details_view)
      do
         the_Subject      := Subject;
         the_send_Details := send_Details;

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


         -- Queue each new event on the channel of its target observer.
         --
         the_send_Details.get (new_send_Details);

         for Each of new_send_Details
         loop
            Channels (channel_Index (Each.Observer)).Pending.append (Each.Event);
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
               the_Sender : Sender_view;
            begin
               if         not Channels (i).Busy
                 and then not Channels (i).Pending.is_Empty
               then
                  the_Senders.get (the_Sender);

                  if the_Sender = null
                  then
                     the_Sender   := new Sender;
                     sender_Count := sender_Count + 1;
                  end if;

                  the_Sender.send (Self         => the_Sender,
                                   the_Event    => Channels (i).Pending.first_Element.Element,
                                   To           => Channels (i).Observer,
                                   from_Subject => the_subject_Name.Element,
                                   Subject      => the_Subject,
                                   Reports      => the_Reports'unchecked_Access,
                                   Senders      => the_Senders'unchecked_Access);

                  Channels (i).Pending.delete_First;
                  Channels (i).Busy := True;
               end if;

            exception
               when E : others =>
                  if          the_Sender /= null
                     and then ada.Exceptions.exception_Identity (E) = tasking_Error'Identity
                  then
                     free (the_Sender);                        -- The dead task never engaged ~ discard it and
                     sender_Count := sender_Count - 1;         -- retry the delivery with a fresh sender.
                  end if;

                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line ("Error detected in 'lace.event_Sender.send_Delegator'.");
                  ada.Text_IO.put_Line ("Subject '" & the_subject_Name.Element & "'.");
                  ada.Text_IO.put_Line ("Continuing.");
                  ada.Text_IO.new_Line (2);
            end;
         end loop;


         exit when          Done
                   and then the_send_Details.is_Empty
                   and then all_Channels_are_idle;

         delay 0.001;
      end loop;

      shutdown;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Sender.send_Delegator' for subject '" & the_subject_Name.Element & "'.");
         ada.Text_IO.new_Line (2);

         shutdown;
   end send_Delegator;


   ------------------------
   --- Safe 'send_Details'.
   --

   protected
   body safe_send_Details
   is

      procedure add (new_send_Details : in send_Details)
      is
      begin
         all_the_send_Details.append (new_send_Details);
      end add;



      procedure get (all_send_Details : out send_Details_Vector)
      is
      begin
         all_send_Details := all_the_send_Details;
         all_the_send_Details.clear;
      end get;



      function is_Empty return Boolean
      is
      begin
         return all_the_send_Details.is_Empty;
      end is_Empty;

   end safe_send_Details;


   -----------------
   --- Safe senders.
   --

   protected
   body safe_Senders
   is

      procedure add (new_Sender : in Sender_view)
      is
      begin
         all_Senders.append (new_Sender);
      end add;



      procedure get (a_Sender : out Sender_view)
      is
      begin
         if all_Senders.is_Empty
         then
            a_Sender := null;
         else
            a_Sender := all_Senders.last_Element;
            all_Senders.delete_Last;
         end if;
      end get;

   end safe_Senders;


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


   ----------------------
   --- event_Sender item.
   --

   procedure define (Self : in out Item;   Subject : in lace.Subject.view)
   is
   begin
      Self.Delegator.start (Subject      => Subject,
                            send_Details => Self.send_Details'unchecked_Access);
   end define;



   procedure destroy (Self : in out Item)
   is
   begin
      Self.Delegator.stop;

      while not Self.Delegator'Terminated     -- Await the delegator, which uses 'Self.send_Details' until it exits.
      loop
         delay 0.001;
      end loop;
   end destroy;



   procedure add (Self : in out Item;   new_Event    : in lace.Event.item'Class;
                                        for_Observer : in lace.Observer.view)
   is
      use event_Holders;
   begin
      Self.send_Details.add (send_Details' (Event    => to_Holder (new_Event),
                                            Observer => for_Observer));
   end add;


end lace.event_Sender;
