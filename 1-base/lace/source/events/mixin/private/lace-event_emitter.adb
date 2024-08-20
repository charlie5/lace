with
     lace.Observer,
     lace.Event.utility,

     ada.Text_IO,
     ada.Exceptions,
     ada.unchecked_Deallocation,
     ada.Containers.Vectors,
     ada.Containers.indefinite_Holders;


package body lace.event_Emitter
is

   ---------------
   --- Containers.
   --

   package string_Holders is new ada.Containers.indefinite_Holders (Element_type => String);
   subtype string_Holder  is string_Holders.Holder;


   package event_Holders is new ada.Containers.indefinite_Holders (Element_type => lace.Event.item'Class);
   subtype event_Holder  is event_Holders.Holder;


   package emitter_Vectors is new ada.Containers.Vectors (Positive,
                                                          Emitter_view);
   subtype emitter_Vector  is emitter_Vectors.Vector;



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
                  Emitters     : in safe_Emitters_view);
   end Emitter;



   task body Emitter
   is
      Myself       : Emitter_view;
      Event        : event_Holder;
      the_Observer : lace.Observer.view;
      subject_Name : string_Holder;
      emitter_Pool : safe_Emitters_view;
   begin
      loop
         begin
            select
               accept emit (Self         : in Emitter_view;
                            the_Event    : in lace.Event.item'Class;
                            To           : in lace.Observer.view;
                            from_Subject : in String;
                            Emitters     : in safe_Emitters_view)
               do
                  Event       .replace_Element (the_Event);
                  subject_Name.replace_Element (from_Subject);

                  Myself       := Self;
                  the_Observer := To;

                  emitter_Pool := Emitters;
               end emit;
            or
               terminate;
            end select;

            the_Observer.receive (Event.Reference,
                                  from_Subject => subject_Name.Element);
            emitter_Pool.add     (Myself);                                   -- Return the emitter to the safe pool.

         exception
            when E : others =>
               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.put_Line ("Error detected in 'lace.event_Emitter.Emitter' task.");
               ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
               ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");
               ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name    & "'.");
               ada.Text_IO.put_Line ("Continuing.");
               ada.Text_IO.new_Line (2);
               emitter_Pool.add     (Myself);                                -- Return the emitter to the safe pool.
         end;
      end loop;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Emitter.Emitter' task.");
         ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
         ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");
         ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name    & "'.");
         ada.Text_IO.new_Line (2);
   end Emitter;




   -------------------
   --- Emit delegator.
   --

   task body emit_Delegator
   is
      the_Subject      :         lace.Subject.view;
      the_subject_Name :         string_Holder;

      the_Emitters     : aliased safe_Emitters;

      the_Events       :         safe_Events_view;
      new_Events       :         event_Vector;
      Done             :         Boolean     := False;


      procedure shutdown
      is
         procedure free is new ada.unchecked_Deallocation (Emitter,
                                                           Emitter_view);
         the_Emitter : Emitter_view;
      begin
         loop
            the_Emitters.get (the_Emitter);
            exit when the_Emitter = null;

            free (the_Emitter);
         end loop;
      end shutdown;


   begin
      accept start (Subject : in lace.Subject.view;
                    Events  : in safe_Events_view)
      do
         the_Subject  := Subject;
         the_Events   := Events;

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


         exit when     Done
                   and the_Events.is_Empty;

         the_Events.get (new_Events);

         for each_Event of new_Events
         loop
            declare
               use lace.Event.utility;

               the_Observers : constant lace.Subject.Observer_views := the_Subject.Observers (of_Kind => Kind_of (each_Event));
            begin
               for each_Observer of the_Observers
               loop
                  declare
                     the_Emitter : Emitter_view;
                  begin
                     the_Emitters.get (the_Emitter);

                     if the_Emitter = null
                     then
                        the_Emitter := new Emitter;
                     end if;

                     the_Emitter.emit (Self         => the_Emitter,
                                       the_Event    => each_Event,
                                       To           => each_Observer,
                                       from_Subject => the_subject_Name.Element,
                                       Emitters     => the_Emitters'unchecked_Access);
                  exception
                     when E : others =>
                        ada.Text_IO.new_Line;
                        ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
                        ada.Text_IO.new_Line;
                        ada.Text_IO.put_Line ("Error detected in 'lace.event_Emitter.emit_Delegator'.");
                        ada.Text_IO.put_Line ("Subject '" & the_subject_Name.Element & "'.");
                        ada.Text_IO.put_Line ("Event   '" & each_Event'Image         & "'.");
                        ada.Text_IO.put_Line ("Continuing.");
                        ada.Text_IO.new_Line (2);
                  end;
               end loop;
            end;
         end loop;

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

   protected body safe_Events
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

   protected body safe_Emitters
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




   -----------------------
   --- event_Emitter item.
   --

   procedure define (Self : in out Item;   Subject : in lace.Subject.view)
   is
   begin
      Self.Delegator.start (Subject => Subject,
                            Events  => Self.Events'unchecked_Access);
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
       Self.Delegator.stop;
   end destruct;



   procedure add (Self : in out Item;   new_Event : lace.Event.item'Class)
   is
   begin
      Self.Events.add (new_Event);
   end add;


end lace.event_Emitter;
