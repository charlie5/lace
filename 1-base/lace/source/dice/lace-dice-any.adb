with
     lace.Dice.random;


package body lace.Dice.any
is

   ---------
   --- Forge
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


   --------------
   --- Attributes
   --

   overriding
   function side_Count (Self : in Item) return Positive
   is
   begin
      return Self.side_Count;
   end side_Count;



   overriding
   function Roll (Self : in Item) return Natural
   is
      the_Roll  : Integer := 0;
      the_Value : Positive;
   begin
      for Each in 1 .. Self.roll_Count
      loop
         random.draw (the_Value, Sides => Self.side_Count);
         the_Roll := the_Roll + the_Value;
      end loop;

      return Natural'Max (the_Roll + Self.Modifier,
                          0);
   end Roll;


   --------------
   --- Operations
   --

   procedure Seed_is (Now : in Integer)
   is
   begin
      random.reset (Initiator => Now);
   end Seed_is;


end lace.Dice.any;
