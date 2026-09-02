with
     ada.Numerics.float_Random;


package body lace.Dice.random
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



   procedure draw (Value : out Positive;   Sides : in Positive)
   is
      Chance : Float;
   begin
      safe_Generator.roll (Chance);

      Value := Integer'Min (Sides,     -- 'Chance' can be 1.0, so clamp to the side count.
                            Integer (Float'Floor (Chance * Float (Sides))) + 1);
   end draw;



   procedure reset
   is
   begin
      safe_Generator.reset;
   end reset;



   procedure reset (Initiator : in Integer)
   is
   begin
      safe_Generator.reset (Initiator);
   end reset;


begin
   reset;
end lace.Dice.random;
