with
     lace.Subject,
     lace.Observer;


private
with
     lace.event_Emitter,
     lace.event_Sender,
     lace.event.Containers,

     ada.Containers.Vectors,
     ada.Containers.indefinite_hashed_Maps;


generic
   type T is abstract tagged limited private;

package lace.event.make_Subject
--
--  Makes a user class T into an event Subject.
--
is
   pragma remote_Types;

   type Item is abstract limited new T
                                 and Subject.item with private;
   type View is access all Item'Class;

   procedure destroy (Self : in out Item);



   -------------
   -- Attributes
   --

   overriding
   function Observers      (Self : in Item;   of_Kind : in Event.Kind) return Subject.Observer_views;

   overriding
   function observer_Count (Self : in Item) return Natural;

   overriding
   function next_Sequence (Self : in out Item;   for_Observer : in Observer.view) return event.sequence_Id;


   -------------
   -- Operations
   --

   overriding
   procedure   register (Self : access Item;   the_Observer : in Observer.view;
                                               of_Kind      : in Event.Kind);
   overriding
   procedure deregister (Self : in out Item;   the_Observer : in Observer.view;
                                               of_Kind      : in Event.Kind);


   -- Emit
   --

   overriding
   procedure emit (Self : access Item;   the_Event : in Event.item'Class);

   overriding
   function  emit (Self : access Item;   the_Event : in Event.item'Class)
                   return subject.Observer_views;

   overriding
   procedure use_event_Emitter (Self : in out Item);



   -- Send
   --
   overriding
   procedure send (Self : access Item;   the_Event   : in Event.item'Class;
                                         to_Observer : in Observer.view);

   overriding
   procedure use_event_Sender (Self : in out Item);



private

   --  pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   --------------------------
   -- Event observer vectors.
   --
   use type Observer.view;

   package event_Observer_Vectors     is new ada.Containers.Vectors (Positive, Observer.view);
   subtype event_Observer_Vector      is event_Observer_Vectors.Vector;
   type    event_Observer_Vector_view is access all event_Observer_Vector;



   --------------------------------------
   -- Event kind Maps of event observers.
   --
   package event_kind_Maps_of_event_observers is new ada.Containers.indefinite_hashed_Maps (Event.Kind,
                                                                                            event_Observer_Vector_view,
                                                                                            Event.Hash,
                                                                                            "=");
   subtype event_kind_Map_of_event_observers  is event_kind_Maps_of_event_observers.Map;



   ------------------
   -- Safe observers.
   --
   protected
   type safe_Observers
   is
      procedure destruct;

      procedure add (the_Observer : in Observer.view;
                     of_Kind      : in Event.Kind);

      procedure rid (the_Observer : in Observer.view;
                     of_Kind      : in Event.Kind);

      function  fetch_Observers (of_Kind : in Event.Kind) return Subject.Observer_views;
      function  observer_Count return Natural;

   private
      the_Observers : event_kind_Map_of_event_observers;
   end safe_Observers;



   ----------------
   -- Subject Item.
   --
   type event_Emitter_view is access all event_Emitter.item'Class;
   type event_Sender_view  is access all event_Sender .item'Class;

   type Item is abstract limited new T
                                 and Subject.item
   with
      record
         safe_Observers  : make_Subject.safe_Observers;
         sequence_Id_Map : Containers.safe_sequence_Id_Map;     -- Contains the next send sequence ID for each observer.
         Emitter         : event_Emitter_view;
         Sender          : event_Sender_view;
      end record;

end lace.event.make_Subject;
