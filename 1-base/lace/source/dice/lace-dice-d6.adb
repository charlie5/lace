with
     ada.Numerics.discrete_Random;


package body lace.Dice.d6
is
   subtype d6_Range  is Positive range 1 .. 6;
   package d6_Random is new ada.Numerics.discrete_Random (d6_Range);


   ------------------------------------------------------------------
   --- The generator is shared by every task, so guard it with a lock.
   --

   protected safe_Generator
   is
      procedure roll  (Value     :    out d6_Range);
      procedure reset;
      procedure reset (Initiator : in     Integer);

   private
      the_Generator : d6_Random.Generator;
   end safe_Generator;


   protected
   body safe_Generator
   is
      procedure roll (Value : out d6_Range)
      is
      begin
         Value := d6_Random.Random (the_Generator);
      end roll;



      procedure reset
      is
      begin
         d6_Random.reset (the_Generator);
      end reset;



      procedure reset (Initiator : in Integer)
      is
      begin
         d6_Random.reset (the_Generator,
                          Initiator);
      end reset;
   end safe_Generator;


   ---------
   --- Forge
   --

   function to_Dice (Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.d6.item
   is
   begin
      return (roll_Count => Rolls,
              Modifier   => Modifier);
   end to_Dice;


   --------------
   --- Attributes
   --

   overriding
   function side_Count (Self : in Item) return Positive
   is
   begin
      return 6;
   end side_Count;



   overriding
   function Roll (Self : in Item) return Natural
   is
      the_Roll  : Integer := 0;
      the_Value : d6_Range;
   begin
      for Each in 1 .. Self.roll_Count
      loop
         safe_Generator.roll (the_Value);
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
      safe_Generator.reset (Initiator => Now);
   end Seed_is;


begin
   safe_Generator.reset;
end lace.Dice.d6;
