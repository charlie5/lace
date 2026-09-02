with
     lace.Event.Logger,
     lace.Event.utility,

     ada.unchecked_Deallocation;


package body lace.Event.make_Observer
is
   use type Event.Logger.view;


   procedure destroy (Self : in out Item)
   is
   begin
      Self.Responses.destroy;
   end destroy;


   -------------
   --- Responses
   --

   overriding
   procedure add (Self : access Item;   the_Response : in Response.view;
                                        to_Kind      : in Event.Kind;
                                        from_Subject : in Event.subject_Name)
   is
   begin
      Self.Responses.add (Self, the_Response, to_Kind, from_Subject);
      Self.sequence_Id_Map.add (from_Subject);
   end add;



   overriding
   procedure rid (Self : access Item;   the_Response : in Response.view;
                                        to_Kind      : in Event.Kind;
                                        from_Subject : in Event.subject_Name)
   is
   begin
      Self.Responses.rid (Self, the_Response, to_Kind, from_Subject);

   exception
      when storage_Error =>
         null;   -- The observer is dead.
   end rid;


   --------------
   --- Operations
   --

   overriding
   procedure receive (Self : access Item;   the_Event    : in Event.item'Class;
                                            from_Subject : in Event.subject_Name;
                                            Sequence     : in sequence_Id)
   is
      use lace.Event.utility;

      function my_Name return String
      is (Observer.item'Class (Self.all).Name);

      the_Response   : Response.view;
      subject_Known  : Boolean;
      response_Count : Natural;
   begin
      Self.sequence_Id_Map.add (from_Subject);

      Self.Responses.find (from_Subject,
                           to_Kind (the_Event'Tag),
                           the_Response,
                           subject_Known,
                           response_Count);

      if not subject_Known
      then
         if Observer.Logger /= null
         then
            Observer.Logger.log (  my_Name
                                 & " has no responses for events from "
                                 & from_Subject
                                 & ".");
         else
            raise program_Error with   my_Name
                                     & " has no responses for events from "
                                     & from_Subject
                                     & ".";
         end if;

         return;
      end if;

      if the_Response = null
      then
         if Observer.Logger /= null
         then
            Observer.Logger.log (  "[Warning] ~ Observer "
                                 & my_Name
                                 & " has no response to "
                                 & Name_of (the_Event)
                                 & " from "
                                 & from_Subject
                                 & ".");
            Observer.Logger.log ("            count of responses =>" & response_Count'Image);

         else
            raise program_Error with   "Observer "
                                     & my_Name
                                     & " has no response to "
                                     & Name_of (the_Event)
                                     & " from "
                                     & from_Subject
                                     & ".";
         end if;

         return;
      end if;

      the_Response.respond (the_Event);     -- Dispatched outside the protected action, so a response may add or rid responses.

      if Observer.Logger /= null
      then
         Observer.Logger.log_Response (the_Response,
                                       Observer.view (Self),
                                       the_Event,
                                       from_Subject);
      end if;
   end receive;



   overriding
   procedure respond (Self : access Item)
   is
   begin
      null;   -- This is a null operation since there can never be any deferred events for an 'instant' observer.
   end respond;


   ------------------
   --- Safe Responses
   --

   protected
   body safe_Responses
   is
      procedure destroy
      is
         use subject_Maps_of_event_responses;

         procedure free is new ada.unchecked_Deallocation (event_response_Map,
                                                           event_response_Map_view);

         Cursor  : subject_Maps_of_event_responses.Cursor := my_Responses.First;
         the_Map : event_response_Map_view;
      begin
         while has_Element (Cursor)
         loop
            the_Map := Element (Cursor);
            free (the_Map);

            next (Cursor);
         end loop;

         my_Responses.clear;     -- Rid the dangling views, so a repeated destroy is harmless.
      end destroy;


      -------------
      --- Responses
      --

      procedure add (Self         : access Item'Class;
                     the_Response : in     Response.view;
                     to_Kind      : in     Event.Kind;
                     from_Subject : in     Event.subject_Name)
      is
      begin
         if not my_Responses.contains (from_Subject)
         then
            my_Responses.insert (from_Subject,
                                 new event_response_Map);
         end if;

         my_Responses.Element (from_Subject).insert (to_Kind,
                                                     the_Response);
         if Observer.Logger /= null
         then
            Observer.Logger.log_new_Response (the_Response,
                                              Observer.item'Class (Self.all),
                                              to_Kind,
                                              from_Subject);
         end if;
      end add;



      procedure rid (Self         : access Item'Class;
                     the_Response : in     Response.view;
                     to_Kind      : in     Event.Kind;
                     from_Subject : in     Event.subject_Name)
      is
      begin
         my_Responses.Element (from_Subject).delete (to_Kind);

         if my_Responses.Element (from_Subject).is_Empty
         then
            Self.sequence_Id_Map.rid (from_Subject);
         end if;

         if Observer.Logger /= null
         then
            Observer.Logger.log_rid_Response (the_Response,
                                              Observer.item'Class (Self.all),
                                              to_Kind,
                                              from_Subject);
         end if;
      end rid;



      function Contains (Subject : in Event.subject_Name) return Boolean
      is
      begin
         return my_Responses.Contains (Subject);
      end Contains;



      function Element (Subject : in Event.subject_Name) return event_response_Map
      is
      begin
         return my_Responses.Element (Subject).all;
      end Element;


      --------------
      --- Operations
      --

      procedure find (from_Subject   : in     Event.subject_Name;
                      to_Kind        : in     Event.Kind;
                      the_Response   :    out Response.view;
                      subject_Known  :    out Boolean;
                      response_Count :    out Natural)
      is
         use event_response_Maps;
      begin
         subject_Known := my_Responses.contains (from_Subject);

         if not subject_Known
         then
            the_Response   := null;
            response_Count := 0;
            return;
         end if;

         declare
            the_Responses :          event_response_Map    renames my_Responses.Element (from_Subject).all;
            Cursor        : constant event_response_Maps.Cursor := the_Responses.find (to_Kind);
         begin
            response_Count := Natural (the_Responses.Length);

            if has_Element (Cursor)
            then
               the_Response := Element (Cursor);
            else
               the_Response := null;
            end if;
         end;
      end find;

   end safe_Responses;


end lace.Event.make_Observer;
