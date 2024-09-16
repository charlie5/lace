with
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


   package sender_Vectors  is new ada.Containers.Vectors (Positive,
                                                          Sender_view);
   subtype sender_Vector  is sender_Vectors.Vector;



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
                  Senders      : in safe_Senders_view);
   end Sender;



   task body Sender
   is
      Myself       : Sender_view;
      Event        : event_Holder;
      the_Observer : lace.Observer.view;
      subject_Name : string_Holder;
      sender_Pool  : safe_Senders_view;
   begin
      loop
         begin
            select
               accept send (Self         : in Sender_view;
                            the_Event    : in lace.Event.item'Class;
                            To           : in lace.Observer.view;
                            from_Subject : in String;
                            Senders      : in safe_Senders_view)
               do
                  Event       .replace_Element (the_Event);
                  subject_Name.replace_Element (from_Subject);

                  Myself       := Self;
                  the_Observer := To;

                  sender_Pool  := Senders;
               end send;
            or
               terminate;
            end select;

            the_Observer.receive (Event.Reference,
                                  from_Subject => subject_Name.Element);
            sender_Pool.add      (Myself);                                   -- Return the sender to the safe pool.

         exception
            when E : others =>
               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.put_Line ("Error detected in 'lace.event_Sender.Sender' task.");
               ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
               ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");
               ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name    & "'.");
               ada.Text_IO.put_Line ("Continuing.");
               ada.Text_IO.new_Line (2);
               sender_Pool.add      (Myself);                                -- Return the sender to the safe pool.
         end;
      end loop;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Sender.Sender' task.");
         ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
         ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");
         ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name    & "'.");
         ada.Text_IO.new_Line (2);
   end Sender;




   -------------------
   --- Send delegator.
   --

   task body send_Delegator
   is
      the_subject_Name :         string_Holder;
      the_Senders      : aliased safe_Senders;

      the_Pairs        :         safe_Pairs_view;
      new_Pairs        :         pair_Vector;

      Done             :         Boolean     := False;


      procedure shutdown
      is
         procedure free is new ada.unchecked_Deallocation (Sender,
                                                           Sender_view);
         the_Sender : Sender_view;
      begin
         loop
            the_Senders.get (the_Sender);
            exit when the_Sender = null;

            free (the_Sender);
         end loop;
      end shutdown;


   begin
      accept start (Subject : in lace.Subject.view;
                    Pairs   : in safe_Pairs_view)
      do
         the_Pairs := Pairs;
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
                   and the_Pairs.is_Empty;

         the_Pairs.get (new_Pairs);

         for each_Pair of new_Pairs
         loop
            declare
               the_Sender : Sender_view;
            begin
               the_Senders.get (the_Sender);

               if the_Sender = null
               then
                  the_Sender := new Sender;
               end if;

               the_Sender.send (Self         => the_Sender,
                                the_Event    => each_Pair.Event.Element,
                                To           => each_Pair.Observer,
                                from_Subject => the_subject_Name.Element,
                                Senders      => the_Senders'unchecked_Access);
            exception
               when E : others =>
                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
                  ada.Text_IO.new_Line;
                  ada.Text_IO.put_Line ("Error detected in 'lace.event_Sender.send_Delegator'.");
                  ada.Text_IO.put_Line ("Subject  '" & the_subject_Name.Element & "'.");
                  ada.Text_IO.put_Line ("Observer '" & each_Pair.Observer.Name  & "'.");
                  ada.Text_IO.put_Line ("Event    '" & each_Pair.Event'Image    & "'.");
                  ada.Text_IO.put_Line ("Continuing.");
                  ada.Text_IO.new_Line (2);
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
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Sender.send_Delegator' for subject '" & the_subject_Name.Element & "'.");
         ada.Text_IO.new_Line (2);

         shutdown;
   end send_Delegator;




   ---------------
   --- Safe Pairs.
   --

   protected body safe_Pairs
   is

      procedure add (new_Pair : in event_observer_Pair)
      is
      begin
         all_Pairs.append (new_Pair);
      end add;



      procedure get (the_Pairs : out pair_Vector)
      is
      begin
         the_Pairs := all_Pairs;
         all_Pairs.clear;
      end get;



      function is_Empty return Boolean
      is
      begin
         return all_Pairs.is_Empty;
      end is_Empty;

   end safe_Pairs;




   -----------------
   --- Safe senders.
   --

   protected body safe_Senders
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




   ----------------------
   --- event_Sender item.
   --

   procedure define (Self : in out Item;   Subject : in lace.Subject.view)
   is
   begin
      Self.Delegator.start (Subject => Subject,
                            Pairs   => Self.Pairs'unchecked_Access);
   end define;



   procedure destroy (Self : in out Item)
   is
   begin
       Self.Delegator.stop;
   end destroy;



   procedure add (Self : in out Item;   new_Event    : in lace.Event.item'Class;
                                        for_Observer : in lace.Observer.view;
                                        from_Subject : in lace.Subject.view)
   is
      use event_Holders;
   begin
      Self.Pairs.add (event_observer_Pair' (Event    => to_Holder (new_Event),
                                            Observer => for_Observer));
   end add;


end lace.event_Sender;
