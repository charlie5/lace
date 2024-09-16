with
     lace.Event,
     lace.Subject,
     lace.Observer;


private
with
     ada.Containers.Vectors,
     ada.Containers.indefinite_Holders;


package lace.event_Sender with remote_Types
is

   type Item is tagged limited private;


   procedure define   (Self : in out Item;   Subject   : in lace.Subject.view);
   procedure destruct (Self : in out Item);

   procedure add      (Self : in out Item;   new_Event    : in lace.Event.item'Class;
                                             for_Observer : in lace.Observer.view;
                                             from_Subject : in lace.Subject.view);


private

   use type lace.Event.item'Class;
   package event_Holders  is new ada.Containers.indefinite_Holders (Element_type => lace.Event.item'Class);
   subtype event_Holder   is event_Holders.Holder;



   type event_observer_Pair is
      record
         Event    : event_Holder;
         Observer : lace.Observer.view;
      end record;



   -----------
   --- Sender.
   --

   type Sender;
   type Sender_view is access Sender;



   -------------------------------
   --- event_observer_Pair_Vector.
   --

   package pair_Vectors is new ada.Containers.Vectors (Positive,
                                                       event_observer_Pair);
   subtype pair_Vector  is pair_Vectors.Vector;



   ---------------
   --- Safe pairs.
   --

   protected
   type safe_Pairs
   is
      procedure add (new_Pair  : in     event_observer_Pair);
      procedure get (the_pairs :    out pair_Vector);

      function  is_Empty return Boolean;

   private
      all_Pairs : pair_Vector;
   end safe_Pairs;

   type safe_Pairs_view is access all safe_Pairs;



   -------------------
   --- Send delegator.
   --

   task
   type send_Delegator
   is
      entry start (Subject : in lace.Subject.view;
                   Pairs   : in safe_Pairs_view);
      entry stop;
   end send_Delegator;



   ---------
   --- Item.
   --

   type Item is tagged limited
      record
         Pairs     : aliased safe_Pairs;
         Delegator :         send_Delegator;
      end record;


end lace.event_Sender;
