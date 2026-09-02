with
     lace.event_Courier,

     ada.Text_IO,
     ada.Exceptions;


package body lace.event_Sender
is
   package Couriers is new lace.event_Courier (courier_Name   => "lace.event_Sender.Sender",
                                               delegator_Name => "lace.event_Sender.send_Delegator");
   use Couriers;


   -------------------
   --- Send delegator.
   --

   task
   body send_Delegator
   is
      the_Subject      :         lace.Subject.view;
      the_subject_Name :         string_Holder;

      the_Pool         : aliased safe_Pool;
      the_Reports      : aliased safe_Reports;
      courier_Count    :         Natural       := 0;

      the_send_Details :         safe_send_Details_view;
      new_send_Details :         send_Details_Vector;
      Done             :         Boolean       := False;

      Channels         :         channel_Vector;

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
            declare
               Index : constant Positive := channel_Index (Channels, Each.Observer);
            begin
               Channels (Index).Pending.append (Each.Event);
            end;
         end loop;


         reopen_Channels   (Channels, the_Reports);
         dispatch_Channels (Channels,
                            from_Subject  => the_subject_Name.Element,
                            Subject       => the_Subject,
                            Reports       => the_Reports'unchecked_Access,
                            Pool          => the_Pool   'unchecked_Access,
                            courier_Count => courier_Count);

         exit when          Done
                   and then the_send_Details.is_Empty
                   and then all_Channels_are_idle (Channels);

         delay 0.001;
      end loop;

      drain (the_Pool, courier_Count);

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Sender.send_Delegator' for subject '" & the_subject_Name.Element & "'.");
         ada.Text_IO.new_Line (2);

         drain (the_Pool, courier_Count);
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
      use Event.Containers.event_Holders;
   begin
      Self.send_Details.add (send_Details' (Event    => to_Holder (new_Event),
                                            Observer => for_Observer));
   end add;


end lace.event_Sender;
