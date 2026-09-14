with
     lace.Observer,

     ada.Strings.Hash,
     ada.Containers.Vectors,
     ada.Containers.indefinite_hashed_Maps,
     ada.Containers.indefinite_Holders;


package lace.Event.Containers
--
-- Common containers.
--
is
   pragma remote_Types;
   pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   -----------------
   --- Event holder.
   --

   package event_Holders is new ada.Containers.indefinite_Holders (Event.item'Class);
   subtype event_Holder  is     event_Holders.Holder;


   ----------------------------
   --- Name map of sequence Id.
   --

   package name_Maps_of_sequence_Id is new ada.Containers.indefinite_hashed_Maps (String,
                                                                                  Event.sequence_Id,
                                                                                  ada.Strings.Hash,
                                                                                  "=");
   subtype name_Map_of_sequence_Id  is     name_Maps_of_sequence_Id.Map;


   -------------------------
   --- Safe sequence Id map.
   --

   protected
   type safe_sequence_Id_Map
   is
      procedure add (Name : in String);
      procedure rid (Name : in String);

      procedure get_Next  (Id       :    out Event.sequence_Id;
                           for_Name : in     String);
      procedure increment (for_Name : in     String);
      procedure decrement (for_Name : in     String);

      function  Element   (for_Name : in     String) return Event.sequence_Id;

   private
      the_Map : name_Map_of_sequence_Id;
   end safe_sequence_Id_Map;



   -------------------
   --- Observer vector.
   --

   use type lace.Observer.view;

   package observer_Vectors is new ada.Containers.Vectors (Positive,
                                                           lace.Observer.view);
   subtype observer_Vector  is     observer_Vectors.Vector;


   ---------------------
   --- Safe retirements.
   --
   -- A subject retires an observer here when deregistering it: the delivery
   -- delegator drops the observer's pending deliveries, awaits any in flight and
   -- reports it retired, so no delivery reaches the observer once 'deregister' returns.
   --

   protected
   type safe_Retirements
   is
      procedure request (the_Observer  : in     lace.Observer.view);
      procedure fetch   (the_Observers :    out observer_Vector);
      --
      -- The observers requested since the last fetch.

      procedure retired (the_Observer  : in     lace.Observer.view);
      procedure check   (the_Observer  : in     lace.Observer.view;
                         is_Retired    :    out Boolean);
      --
      -- Whether the observer has been reported retired, forgetting the report if so.

   private
      Requested : observer_Vector;
      Completed : observer_Vector;
   end safe_Retirements;


end lace.Event.Containers;
