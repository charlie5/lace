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


   procedure define  (Self : in out Item;   Subject   : in lace.Subject.view);
   procedure destroy (Self : in out Item);

   procedure add     (Self : in out Item;   new_Event    : in lace.Event.item'Class;
                                            for_Observer : in lace.Observer.view;
                                            from_Subject : in lace.Subject.view);


private

   use type lace.Event.item'Class;
   package event_Holders  is new ada.Containers.indefinite_Holders (Element_type => lace.Event.item'Class);
   subtype event_Holder   is event_Holders.Holder;



   type send_Details is
      record
         Event    : event_Holder;
         Observer : lace.Observer.view;
         Sequence : lace.event.sequence_Id;
      end record;



   -----------
   --- Sender.
   --

   type Sender;
   type Sender_view is access Sender;



   --------------------------
   --- 'send_Details' Vector.
   --

   package send_Details_Vectors is new ada.Containers.Vectors (Positive,
                                                               send_Details);
   subtype send_Details_Vector  is send_Details_Vectors.Vector;



   ------------------------
   --- Safe 'send_Detail's.
   --

   protected
   type safe_send_Details
   is
      procedure add (new_send_Details : in     send_Details);
      procedure get (all_send_Details :    out send_Details_Vector);

      function  is_Empty return Boolean;

   private
      all_the_send_Details : send_Details_Vector;
   end safe_send_Details;

   type safe_send_Details_view is access all safe_send_Details;



   -------------------
   --- Send delegator.
   --

   task
   type send_Delegator
   is
      entry start (Subject      : in lace.Subject.view;
                   send_Details : in safe_send_Details_view);
      entry stop;
   end send_Delegator;



   ---------
   --- Item.
   --

   type Item is tagged limited
      record
         send_Details : aliased safe_send_Details;
         Delegator    :         send_Delegator;
      end record;


end lace.event_Sender;
