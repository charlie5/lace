with
     ada.Numerics.float_Random;


package body lace.Dice.any
is
   the_float_Generator : ada.Numerics.float_Random.Generator;



   procedure Seed_is (Now : Integer)
   is
   begin
      ada.Numerics.float_Random.reset (the_float_Generator,
                                       Initiator => Now);
   end Seed_is;



   --------
   -- Forge
   --
   function to_Dice (Sides    : in Positive := 6;
                     Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.any.item
   is
   begin
      return (side_Count => Sides,
              roll_Count => Rolls,
              Modifier   => Modifier);
   end to_Dice;



   -------------
   -- Attributes
   --

   overriding
   function side_Count (Self : in Item) return Positive
   is
   begin
      return Self.Side_Count;
   end side_Count;



   overriding
   function Roll (Self : in Item) return Natural
   is
      use ada.Numerics.float_Random;

      the_Roll : Integer := 0;
   begin
      for Each in 1 .. Self.roll_Count
      loop
         the_Roll :=   the_Roll
                     + Integer (  Random (the_float_Generator)
                                * Float  (Self.side_Count)
                                + 0.5);
      end loop;

      return the_Roll + self.Modifier;
   end Roll;


begin
   ada.Numerics.float_Random.reset (the_float_Generator);
end lace.Dice.any;
