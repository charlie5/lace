with
     ada.Containers;


package lace.Event
--
-- The base class for all derived event types.
--
is
   pragma Pure;

   type Item is tagged null record;


   subtype  subject_Name is String;
   subtype observer_Name is String;


   type Kind is new String;
   --
   -- Uniquely identifies each derived event class.
   --
   -- Each derived event class will have its own Kind.
   --
   -- Maps to the extended name of 'ada.Tags.Tag_type' value of each derived
   -- event class (see 'Conversions' section in 'lace.Event.utility').

   type sequence_Id is mod 2**32;     -- Wraps at the last id, matching the observers' expected sequence wrap.


   ---------
   --- Forge
   --

   procedure destruct (Self : in out Item) is null;


   --------------
   --- Attributes
   --

   function Hash (the_Kind : in Kind) return ada.Containers.Hash_type;


end lace.Event;
