with
     ada.Containers;


package lace.Event
--
--  The base class for all derived event types.
--
is
   pragma Pure;

   type Item is tagged private;


   subtype  subject_Name is String;
   subtype observer_Name is String;


   procedure destruct (Self : in out Item) is null;


   type Kind is new String;
   --
   --  Uniquely identifies each derived event class.
   --
   --  Each derived event class will have its own Kind.
   --
   --  Maps to the extended name of 'ada.Tags.Tag_type' value of each derived
   --  event class (see 'Conversions' section in 'lace.Event.utility').

   function Hash (the_Kind : in Kind) return ada.Containers.Hash_type;



private

   type sequence_Id is range 0 .. 2**32 - 1;


   type Item is tagged
      record
         s_Id : sequence_Id;
      end record;

end lace.Event;
