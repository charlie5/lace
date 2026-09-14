with
     lace.Event,
     lace.Observer;

private
with
     lace.Subject,
     lace.Event.Containers,
     ada.Containers.indefinite_Vectors;


private
package lace.event_Emitter with remote_Types
is
   type Item is tagged limited private;


   ---------
   --- Forge
   --

   procedure define  (Self : in out Item;   Subject   : in lace.Subject.view);
   procedure destroy (Self : in out Item);


   --------------
   --- Operations
   --

   procedure add     (Self : in out Item;   new_Event : in lace.Event.item'Class);

   procedure retire  (Self : in out Item;   the_Observer : in lace.Observer.view);
   --
   -- Drops the observer's pending deliveries and awaits any in flight, so that no
   -- delivery reaches it after this returns. Called by a subject deregistering it.



private

   ---------------
   --- Containers.
   --

   use type lace.Event.item'Class;

   package event_Vectors is new ada.Containers.indefinite_Vectors (Positive,
                                                                   lace.Event.item'Class);
   subtype event_Vector  is     event_Vectors.Vector;


   ----------------
   --- Safe events.
   --

   protected
   type safe_Events
   is
      procedure add (new_Event  : in     lace.Event.item'Class);
      procedure get (the_Events :    out event_Vector);

      function is_Empty return Boolean;

   private
      all_Events : event_Vector;
   end safe_Events;

   type safe_Events_view is access all safe_Events;


   type safe_Retirements_view is access all lace.Event.Containers.safe_Retirements;


   -------------------
   --- Emit delegator.
   --

   task
   type emit_Delegator
   is
      entry start (Subject     : in lace.Subject.view;
                   Events      : in safe_Events_view;
                   Retirements : in safe_Retirements_view);
      entry stop;
   end emit_Delegator;


   ---------
   --- Item.
   --

   type Item is tagged limited
      record
         Events      : aliased safe_Events;
         Retirements : aliased lace.Event.Containers.safe_Retirements;
         Delegator   :         emit_Delegator;
      end record;


end lace.event_Emitter;
