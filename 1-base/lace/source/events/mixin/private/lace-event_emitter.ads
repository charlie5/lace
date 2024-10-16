with
     lace.Event;


private
with
     lace.Subject,
     lace.event.Containers,
     ada.Containers.indefinite_Holders,
     ada.Containers.indefinite_Vectors;


private
package lace.event_Emitter with remote_Types
is

   type Item is tagged limited private;


   procedure define  (Self : in out Item;   Subject   : in lace.Subject.view);
   procedure destroy (Self : in out Item);

   procedure add     (Self : in out Item;   new_Event : in lace.Event.item'Class);
                                            --  Sequence  : in event.sequence_Id);



private

   ------------
   --- Emitter.
   --

   type Emitter;
   type Emitter_view is access Emitter;



   ---------------
   --- Containers.
   --
   --  use type Event.item'Class;
   --  package event_Holders is new ada.Containers.Indefinite_Holders (Event.item'Class);
   --  subtype event_Holder  is event_Holders.Holder;

   use type lace.Event.item'Class;
   package event_Vectors is new ada.Containers.indefinite_Vectors (Positive,
                                                                   lace.Event.item'Class);
   subtype event_Vector  is event_Vectors.Vector;



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



   -------------------
   --- Emit delegator.
   --

   task
   type emit_Delegator
   is
      entry start (Subject : in lace.Subject.view;
                   Events  : in safe_Events_view);
      entry stop;
   end emit_Delegator;



   ---------
   --- Item.
   --

   type Item is tagged limited
      record
         Events    : aliased safe_Events;
         Delegator :         emit_Delegator;
      end record;


end lace.event_Emitter;
