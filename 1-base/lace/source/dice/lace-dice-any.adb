with
     ada.Numerics.float_Random;


package body lace.Dice.any
is
   ------------------------------------------------------------------
   --- The generator is shared by every task, so guard it with a lock.
   --

   protected safe_Generator
   is
      procedure roll  (Chance    :    out Float);
      procedure reset;
      procedure reset (Initiator : in     Integer);

   private
      the_Generator : ada.Numerics.float_Random.Generator;
   end safe_Generator;


   protected
   body safe_Generator
   is
      procedure roll (Chance : out Float)
      is
      begin
         Chance := ada.Numerics.float_Random.Random (the_Generator);
      end roll;


      procedure reset
      is
      begin
         ada.Numerics.float_Random.reset (the_Generator);
      end reset;


      procedure reset (Initiator : in Integer)
      is
      begin
         ada.Numerics.float_Random.reset (the_Generator,
                                          Initiator);
      end reset;
   end safe_Generator;


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
      the_Roll : Integer := 0;
      Chance   : Float;
   begin
      for Each in 1 .. Self.roll_Count
      loop
         safe_Generator.roll (Chance);

         the_Roll :=   the_Roll
                     + Integer'Min (Self.side_Count,     -- 'Chance' can be 1.0, so clamp to the side count.
                                    Integer (Float'Floor (Chance * Float (Self.side_Count))) + 1);
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
      safe_Generator.reset (Initiator => Now);
   end Seed_is;


begin
   safe_Generator.reset;
end lace.Dice.any;
