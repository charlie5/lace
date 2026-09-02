private
package lace.Dice.random
--
-- The task safe random number source shared by the dice implementations.
--
is

   procedure draw (Value : out Positive;   Sides : in Positive);
   --
   -- A uniform value in 1 .. Sides.

   procedure reset;
   procedure reset (Initiator : in Integer);


end lace.Dice.random;
