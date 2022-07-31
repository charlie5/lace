
with
     ada.Numerics.discrete_Random;


package body lace.Dice.d6
is

   subtype d6_Range  is Positive range 1 .. 6;
   package d6_Random is new ada.Numerics.discrete_Random (d6_Range);

   the_d6_Generator : d6_Random.Generator;



   procedure Seed_is (Now : Integer)
   is
   begin
      d6_Random.reset (the_d6_Generator, Initiator => Now);
   end Seed_is;



   --------
   -- Forge
   --

   function to_Dice (Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.d6.item
   is
   begin
      return (roll_count => Rolls,
              modifier   => Modifier);
   end to_Dice;



   -------------
   -- Attributes
   --

   overriding
   function  side_Count (Self : in Item) return Positive
   is
   begin
      return 6;
   end side_Count;



   overriding
   function  Roll (Self : in Item) return Natural
   is
      use d6_Random;

      the_Roll : Integer := 0;
   begin
      for Each in 1 .. self.roll_Count loop
         the_Roll := the_Roll + Random (the_d6_Generator);
      end loop;

      return Natural'Max (the_Roll + self.Modifier,
                          0);
   end Roll;



begin
   d6_Random.reset (the_d6_Generator);
end lace.Dice.d6;
