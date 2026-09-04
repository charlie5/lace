with
     ada.Numerics.float_Random,
     ada.Numerics.discrete_Random;


package body any_Math.any_Random
is
   use ada.Numerics;

   package Integer_random is new ada.Numerics.discrete_Random (Integer);
   package Boolean_random is new ada.Numerics.discrete_Random (Boolean);


   protected Generators
   --
   -- Serialises access to the generators, which are not task safe.
   --
   is
      procedure reset;

      procedure get (Roll         :    out Float);
      procedure get (Lower, Upper : in     Integer;   Roll : out Integer);
      procedure get (Roll         :    out Boolean);

   private
      real_Generator    : float_Random  .Generator;
      integer_Generator : Integer_random.Generator;
      boolean_Generator : Boolean_random.Generator;
   end Generators;


   protected body Generators
   is
      procedure reset
      is
      begin
         float_Random  .reset (   real_Generator);
         Integer_random.reset (integer_Generator);
         Boolean_random.reset (boolean_Generator);
      end reset;


      procedure get (Roll : out Float)
      is
      begin
         Roll := float_Random.Random (real_Generator);
      end get;


      procedure get (Lower, Upper : in Integer;   Roll : out Integer)
      is
      begin
         Roll := Integer_random.Random (integer_Generator, Lower, Upper);
      end get;


      procedure get (Roll : out Boolean)
      is
      begin
         Roll := Boolean_random.Random (boolean_Generator);
      end get;
   end Generators;



   function random_Boolean return Boolean
   is
      Roll : Boolean;
   begin
      Generators.get (Roll);
      return Roll;
   end random_Boolean;



   function random_Real (Lower : in Real := 0.0;
                         Upper : in Real := 1.0) return Real
   is
      Roll : Float;
   begin
      Generators.get (Roll);
      return Lower + Real (Roll) * (Upper - Lower);
   end random_Real;



   function random_Integer (Lower : in Integer := Integer'First;
                            Upper : in Integer := Integer'Last) return Integer
   is
      Roll : Integer;
   begin
      Generators.get (Lower, Upper, Roll);
      return Roll;
   end random_Integer;


begin
   Generators.reset;
end any_Math.any_Random;
