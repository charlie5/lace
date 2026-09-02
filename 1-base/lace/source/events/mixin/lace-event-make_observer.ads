with
     lace.Response,
     lace.Observer;

private
with
     lace.Event.Containers,
     ada.Containers.indefinite_hashed_Maps,
     ada.Strings.Hash;


generic
   type T is abstract tagged limited private;

package lace.Event.make_Observer
--
-- Makes a user class T into an event Observer.
--
is
   pragma remote_Types;

   type Item is abstract limited new T
                                 and Observer.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   procedure destroy (Self : in out Item);


   -------------
   --- Responses
   --

   overriding
   procedure add (Self : access Item;   the_Response : in Response.view;
                                        to_Kind      : in Event.Kind;
                                        from_Subject : in Event.subject_Name);
   overriding
   procedure rid (Self : access Item;   the_Response : in Response.view;
                                        to_Kind      : in Event.Kind;
                                        from_Subject : in Event.subject_Name);


   --------------
   --- Operations
   --

   overriding
   procedure receive (Self : access Item;   the_Event    : in Event.item'Class;
                                            from_Subject : in Event.subject_Name;
                                            Sequence     : in sequence_Id);
   overriding
   procedure respond (Self : access Item);



private

   -- pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   -----------------------
   --- Event response maps
   --

   use type Response.view;

   package event_response_Maps     is new ada.Containers.indefinite_hashed_Maps (Key_type        => Event.Kind,
                                                                                 Element_type    => Response.view,
                                                                                 Hash            => Event.Hash,
                                                                                 equivalent_Keys => "=");
   subtype event_response_Map      is event_response_Maps.Map;
   type    event_response_Map_view is access all event_response_Map;


   -----------------------------------
   --- Subject maps of event responses
   --

   package subject_Maps_of_event_responses
   is new ada.Containers.indefinite_hashed_Maps (Key_type        => Event.subject_Name,
                                                 Element_type    => event_response_Map_view,
                                                 Hash            => ada.Strings.Hash,
                                                 equivalent_Keys => "=");
   subtype subject_Map_of_event_responses is subject_Maps_of_event_responses.Map;


   ------------------
   --- Safe Responses
   --

   protected
   type safe_Responses
   is
      procedure destroy;


      -------------
      --- Responses
      --

      procedure add (Self         : access Item'Class;
                     the_Response : in     Response.view;
                     to_Kind      : in     Event.Kind;
                     from_Subject : in     Event.subject_Name);

      procedure rid (Self         : access Item'Class;
                     the_Response : in     Response.view;
                     to_Kind      : in     Event.Kind;
                     from_Subject : in     Event.subject_Name);

      function  Contains (Subject : in Event.subject_Name) return Boolean;
      function  Element  (Subject : in Event.subject_Name) return event_response_Map;


      --------------
      --- Operations
      --

      procedure find (from_Subject   : in     Event.subject_Name;
                      to_Kind        : in     Event.Kind;
                      the_Response   :    out Response.view;
                      subject_Known  :    out Boolean;
                      response_Count :    out Natural);
      --
      -- Looks up the response for an event kind. The caller dispatches the response
      -- outside the protected action, so a response may itself add or rid responses.

   private
      my_Responses : subject_Map_of_event_responses;
   end safe_Responses;


   -----------------
   --- Observer Item
   --

   type Item is abstract limited new T
                                 and Observer.item
   with
      record
         Responses       : safe_Responses;
         sequence_Id_Map : Containers.safe_sequence_Id_Map;     -- Contains the next expected sequence ID from each subject.
      end record;


end lace.Event.make_Observer;
