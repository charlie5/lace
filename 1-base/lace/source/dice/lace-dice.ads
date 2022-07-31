package lace.Dice with Pure
--
-- Provides an abstract model of any sided dice.
--
is
   type Item is abstract tagged private;


   type an_Extent is
      record
         Min, Max : Integer;
      end record;



   -- Attributes
   --
   function side_Count (Self : in Item)       return Positive is abstract;
   function Roll       (Self : in Item)       return Natural  is abstract;
   function Extent     (Self : in Item'Class) return an_Extent;
   function Image      (Self : in Item'Class) return String;



private

   type Item is abstract tagged
      record
         roll_Count : Positive;
         Modifier   : Integer;
      end record;

end lace.Dice;

