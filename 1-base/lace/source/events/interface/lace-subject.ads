with
     lace.Event,
     lace.Observer;

limited
with
     lace.Event.Logger;


package lace.Subject
--
-- Provides an interface for an event subject.
--
is
   pragma remote_Types;

   type Item  is limited interface;
   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;

   type fast_View  is access all Item'Class with Asynchronous;
   type fast_Views is array (Positive range <>) of fast_View;


   --------------
   --- Containers
   --

   type Observer_views is array (Positive range <>) of Observer.view;


   --------------
   --- Attributes
   --

   function Name (Self : in Item) return Event.subject_Name is abstract;

   function next_Sequence (Self : in out Item;   for_observer_Name : in String) return Event.sequence_Id is abstract;
   --
   -- Takes the next send sequence id for the named observer.

   procedure restore_Sequence (Self : in out Item;   for_observer_Name : in String) is abstract;
   --
   -- Returns an id taken via 'next_Sequence' whose delivery failed, so the next delivery reuses it.
   -- Sound only while no later id has been taken for the same observer, which requires deliveries
   -- to a given observer to be serialised.


   -------------
   --- Observers
   --

   procedure register   (Self : access Item;   the_Observer : in Observer.view;
                                               of_Kind      : in Event.Kind) is abstract;

   procedure deregister (Self : in out Item;   the_Observer : in Observer.view;
                                               of_Kind      : in Event.Kind) is abstract;

   function  Observers      (Self : in Item;   of_Kind      : in Event.Kind) return Observer_views is abstract;
   function  observer_Count (Self : in Item)                                 return Natural        is abstract;


   --------------
   --- Operations
   --


   --- Emit
   --

   procedure emit (Self : access Item;   the_Event : in Event.item'Class) is abstract;
   --
   -- Communication errors are ignored.

   function  emit (Self : access Item;   the_Event : in Event.item'Class) return Observer_views is abstract;
   --
   -- Observers who cannot be communicated with are returned.


   procedure use_event_Emitter (Self : in out Item) is abstract;
   --
   -- Delegate event emission to a task to prevent blocking. Useful for handling lag with DSA.


   --- Send
   --

   procedure send (Self : access Item;   the_Event   : in Event.item'Class;
                                         to_Observer : in Observer.view) is abstract;
   --
   -- Communication errors are ignored.


   procedure use_event_Sender (Self : in out Item) is abstract;
   --
   -- Delegate 'send' to a task to prevent blocking. Useful for handling lag with DSA.


   -----------
   --- Logging
   --

   procedure Logger_is (Now : in Event.Logger.view);
   function  Logger    return    Event.Logger.view;


end lace.Subject;
