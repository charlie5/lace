private
with
     lace.Event.Containers,
     ada.Containers.Vectors,
     ada.Containers.indefinite_hashed_Maps,
     ada.Strings.Hash;


generic
   type T is abstract new lace.event.make_Observer.item with private;

package lace.event.make_Observer.deferred
--
--  Makes a user class T into a deferred event Observer.
--
is
   pragma remote_Types;

   type Item is abstract limited new T with private;
   type View is access all Item'Class;


   overriding
   procedure destroy (Self : in out Item);


   -------------
   -- Operations
   --

   overriding
   procedure receive (Self : access Item;   the_Event    : in Event.item'Class;
                                            from_Subject : in Event.subject_Name;
                                            Sequence     : in sequence_Id);
   overriding
   procedure respond (Self : access Item);



private

   --  pragma Suppress (Container_Checks);     -- Suppress expensive tamper checks.


   type event_sequence_Pair is
      record
         Event    : Containers.event_Holder;
         Sequence : sequence_Id;
      end record;


   ----------------
   -- Event Vectors
   --
   package event_Vectors     is new ada.Containers.Vectors (Positive, event_sequence_Pair);
   subtype event_Vector      is event_Vectors.Vector;
   type    event_Vector_view is access all event_Vector;


   --------------
   -- Safe Events
   --
   protected
   type safe_Events
   is
      procedure add   (the_Event  : in     Event.item'Class;
                       Sequence   : in     sequence_Id);
      procedure fetch (all_Events :    out event_Vector);
   private
      the_Events : event_Vector;
   end safe_Events;

   type safe_Events_view is access all safe_Events;


   ------------------------------
   -- Subject Maps of safe Events
   --
   use type event_Vector;
   package subject_Maps_of_safe_events is new ada.Containers.indefinite_hashed_Maps (Key_type        => Event.subject_Name,
                                                                                     Element_type    => safe_Events_view,
                                                                                     Hash            => ada.Strings.Hash,
                                                                                     equivalent_Keys => "=");
   subtype subject_Map_of_safe_events  is subject_Maps_of_safe_events.Map;


   -----------------------
   -- Subject Events Pairs
   --
   type String_view is access all String;

   type subject_events_Pair is
      record
         Subject : String_view;
         Events  : event_Vector;
      end record;

   type subject_events_Pairs is array (Positive range <>) of subject_events_Pair;


   ----------------------------------
   -- safe Subject Map of safe Events
   --
   protected
   type safe_subject_Map_of_safe_events
   is
      procedure add   (the_Event    : in Event.item'Class;
                       Sequence     : in sequence_Id;
                       from_Subject : in String);

      function  fetch            return subject_events_Pairs;
      procedure fetch (all_Events : out subject_events_Pairs;
                       Count      : out Natural);

      procedure free;

   private
      the_Map : subject_Map_of_safe_events;
   end safe_subject_Map_of_safe_events;


   ----------------
   -- Observer Item
   --
   type Item is abstract limited new T with
      record
         pending_Events : safe_subject_Map_of_safe_events;
      end record;

end lace.event.make_Observer.deferred;
