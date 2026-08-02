package lace.Dice.any
--
-- Provide a model of many sided dice.
--
is
   type Item is new Dice.item with private;


   ---------
   --- Forge
   --

   function to_Dice (Sides    : in Positive := 6;
                     Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.any.item;


   --------------
   --- Attributes
   --

   overriding
   function side_Count (Self : in Item) return Positive;

   overriding
   function Roll       (Self : in Item) return Natural;


   --------------
   --- Operations
   --

   procedure Seed_is (Now : in Integer);
   --
   -- If the seed is not set, a random seed will be used.



private

   type Item is new Dice.item with
      record
         side_Count : Positive;
      end record;


end lace.Dice.any;
