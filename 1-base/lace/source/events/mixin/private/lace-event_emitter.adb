with
     lace.Event.utility,
     lace.Event.Containers,
     lace.event_Courier,

     ada.Text_IO,
     ada.Exceptions;


package body lace.event_Emitter
is
   package Couriers is new lace.event_Courier (courier_Name   => "lace.event_Emitter.Emitter",
                                               delegator_Name => "lace.event_Emitter.emit_Delegator");
   use Couriers;


   -------------------
   --- Emit delegator.
   --

   task
   body emit_Delegator
   is
      the_Subject      :         lace.Subject.view;
      the_subject_Name :         string_Holder;

      the_Pool         : aliased safe_Pool;
      the_Reports      : aliased safe_Reports;
      courier_Count    :         Natural       := 0;

      the_Events       :         safe_Events_view;
      new_Events       :         event_Vector;
      Done             :         Boolean       := False;

      Channels         :         channel_Vector;

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
                  declare
                     Index : constant Positive := channel_Index (Channels, each_Observer);
                  begin
                     Channels (Index).Pending.append (lace.Event.Containers.event_Holders.to_Holder (each_Event));
                  end;
               end loop;
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
                   and then the_Events.is_Empty
                   and then all_Channels_are_idle (Channels);

         delay 0.001;
      end loop;

      drain (the_Pool, courier_Count);

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line ("Fatal error detected in 'lace.event_Emitter.emit_Delegator' for subject '" & the_subject_Name.Element & "'.");
         ada.Text_IO.new_Line (2);

         drain (the_Pool, courier_Count);
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
