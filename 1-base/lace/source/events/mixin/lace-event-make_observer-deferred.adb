with
     lace.Event.Logger,
     lace.Event.utility,

     ada.Text_IO,
     ada.unchecked_Deallocation;


package body lace.Event.make_Observer.deferred
is
   use type Event.Logger.view;


   overriding
   procedure destroy (Self : in out Item)
   is
   begin
      make_Observer.destroy (make_Observer.item (Self));   -- Destroy base class.
      Self.pending_Events.free;
   end destroy;


   --------------
   --- Operations
   --

   overriding
   procedure receive (Self : access Item;   the_Event    : in Event.item'Class;
                                            from_Subject : in Event.subject_Name;
                                            Sequence     : in sequence_Id)
   is
   begin
      Self.pending_Events.add (the_Event,
                               Sequence,
                               from_Subject);
      Self.has_pending_Events := True;     -- After the add, never before. See the declaration.
   end receive;



   overriding
   procedure respond (Self : access Item)
   is
      use Event_Vectors;

      function my_Name return String
      is (Observer.item'Class (Self.all).Name);
      --
      -- Only the warnings below ever look at the name, and 'Name' rebuilds a 'String' from
      -- an unbounded one. Fetched eagerly, as a constant, every observer paid for that on
      -- every respond ~ once per sprite per frame in a game world ~ and discarded it unread.


      procedure actuate (the_Responses     : in event_response_Map;
                         the_Events        : in Event_Vector;
                         from_subject_Name : in Event.subject_Name)
      is
         Cursor : Event_Vectors.Cursor := the_Events.First;
      begin
         while has_Element (Cursor)
         loop
            declare
               use
                    event_response_Maps,
                    Event.utility,
                    ada.Containers;

               use type Observer.view;

               the_Event    : constant Event.item'Class           := Element (Cursor).Event.Element;
               the_Sequence : constant sequence_Id                := Element (Cursor).Sequence;
               Response     : constant event_response_Maps.Cursor := the_Responses.find (to_Kind (the_Event'Tag));

            begin
               -- put_Line ("observer " & my_Name & " from " & from_subject_Name & "     seq" & the_Sequence'Image & "     exp seq " & Self.sequence_Id_Map.Element (from_subject_Name)'Image);

               if the_Sequence = Self.sequence_Id_Map.Element (from_subject_Name)
               then
                  Self.sequence_Id_Map.increment (from_subject_Name);

                  if has_Element (Response)
                  then
                     Element (Response).respond (the_Event);

                     if Observer.Logger /= null
                     then
                        Observer.Logger.log_Response (Element (Response),
                                                      Observer.view (Self),
                                                      the_Event,
                                                      from_subject_Name);
                     end if;

                  elsif Self.Responses.relay_Target /= null
                  then
                     -- Event relaying awaits re-implementation, so warn and drop the event.
                     --
                     if Observer.Logger /= null
                     then
                        Observer.Logger.log ("[Warning] ~ Relayed events are currently disabled.");
                     else
                        ada.Text_IO.put_Line ("[Warning] ~ Relayed events are currently disabled.");
                     end if;

                  else
                     if Observer.Logger /= null
                     then
                        Observer.Logger.log (  "[Warning] ~ Observer "
                                             & my_Name
                                             & " has no response to "
                                             & Name_of (the_Event)
                                             & " from "
                                             & from_subject_Name
                                             & ".");
                        Observer.Logger.log ("            Count of responses =>"
                                             & the_Responses.Length'Image);

                     else
                        raise program_Error with   "Observer "
                                                 & my_Name
                                                 & " has no response to "
                                                 & Name_of (the_Event)
                                                 & " from "
                                                 & from_subject_Name
                                                 & ".";
                     end if;
                  end if;

               else
                  Self.receive (the_Event    => the_Event,             -- Return the event to the event queue for later processing,
                                from_Subject => from_subject_Name,     -- after the missing sequence event has arrived.
                                Sequence     => the_Sequence);
               end if;
            end;

            next (Cursor);
         end loop;
      end actuate;


   begin
      if not Self.has_pending_Events
      then
         return;     -- Nothing is queued, so do not take the lock to discover it.
      end if;

      Self.has_pending_Events := False;     -- Before the drain. See the declaration.

      declare
         the_subject_Events : constant subject_events_Pairs := Self.pending_Events.fetch;
      begin
         for i in the_subject_Events'Range
         loop
            declare
               function  less_than (L, R : in event_sequence_Pair) return Boolean
               is
                  (L.Sequence < R.Sequence);

               package   Sorter     is new event_Vectors.generic_Sorting ("<" => less_than);
               procedure deallocate is new ada.unchecked_Deallocation (String, String_view);

               subject_Name : String_view  := the_subject_Events (i).Subject;
               the_Events   : event_Vector := the_subject_Events (i).Events;
            begin
               if Self.Responses.contains (subject_Name.all)
               then
                  Self.sequence_Id_Map.add (subject_Name.all);

                  Sorter.sort (the_Events);
                  actuate     (Self.Responses.Element (subject_Name.all),
                               the_Events,
                               subject_Name.all);

               else
                  declare
                     Message : constant String :=   "*** Warning *** ~ "
                                                  & my_Name
                                                  & " has no responses for events from "
                                                  & subject_Name.all
                                                  & ".";
                  begin
                     if Observer.Logger /= null
                     then
                        Observer.Logger.log (Message);
                     else
                        raise program_Error with Message;
                     end if;
                  end;
               end if;

               deallocate (subject_Name);
            end;
         end loop;

      end;
   end respond;


   ---------------
   --- Safe Events
   --

   protected
   body safe_Events
   is
      procedure add (the_Event : in Event.item'Class;
                     Sequence  : in sequence_Id)
      is
         use Containers.event_Holders;
      begin
         the_Events.append (event_sequence_Pair' (to_Holder (the_Event),
                                                  Sequence));
      end add;



      procedure fetch (all_Events : out Event_Vector)
      is
      begin
         all_Events := the_Events;
         the_Events.clear;
      end fetch;
   end safe_Events;


   -----------------------------------
   --- safe Subject Map of safe Events
   --

   protected
   body safe_subject_Map_of_safe_events
   is
      procedure add (the_Event    : in Event.item'Class;
                     Sequence     : in sequence_Id;
                     from_Subject : in String)
      is
      begin
         if not the_Map.contains (from_Subject)
         then
            the_Map.insert (from_Subject,
                            new safe_Events);
         end if;

         the_Map.Element (from_Subject).add (the_Event,
                                             Sequence);
      end add;



      function fetch return subject_events_Pairs
      is
         use subject_Maps_of_safe_events;

         Result : subject_events_Pairs (1 .. Natural (the_Map.Length));

         Cursor : subject_Maps_of_safe_events.Cursor := the_Map.First;
         Index  : Natural := 0;
      begin
         while has_Element (Cursor)
         loop
            declare
               the_Events : event_Vector;
            begin
               Element (Cursor).fetch (the_Events);

               Index          := Index + 1;
               Result (Index) := (Subject => new String' (Key (Cursor)),
                                  Events  => the_Events);
            end;

            next (Cursor);
         end loop;

         return Result;
      end fetch;



      procedure fetch (all_Events : out subject_events_Pairs;
                       Count      : out Natural)
      is
         use subject_Maps_of_safe_events;

         Cursor : subject_Maps_of_safe_events.Cursor := the_Map.First;
         Index  : Natural := 0;
      begin
         while has_Element (Cursor)
         loop
            declare
               the_Events : event_Vector;
            begin
               Element (Cursor).fetch (the_Events);

               Index              := Index + 1;
               all_Events (Index) := (Subject => new String' (Key (Cursor)),
                                      Events  => the_Events);
            end;

            next (Cursor);
         end loop;

         Count := Index;
      end fetch;



      procedure free
      is
         use subject_Maps_of_safe_events;

         procedure deallocate is new ada.unchecked_Deallocation (safe_Events,
                                                                 safe_Events_view);

         Cursor     : subject_Maps_of_safe_events.Cursor := the_Map.First;
         the_Events : safe_Events_view;
      begin
         while has_Element (Cursor)
         loop
            the_Events := Element (Cursor);
            deallocate (the_Events);

            next (Cursor);
         end loop;

         the_Map.clear;     -- Rid the dangling views, so a repeated free is harmless.
      end free;

   end safe_subject_Map_of_safe_events;


end lace.Event.make_Observer.deferred;
