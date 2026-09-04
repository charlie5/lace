with
     Ahven,
     float_Math.Random;


package body math_Tests.Random
is

   use
        Ahven,
        float_Math,
        float_Math.Random;


   procedure random_Integer_Test
   is
   begin
      for i in 1 .. 1_000
      loop
         declare
            Full  : constant Integer := random_Integer;                   -- The default bounds are the whole of Integer.
            Small : constant Integer := random_Integer (-3, 3);
            pragma Unreferenced (Full);
         begin
            assert (Small in -3 .. 3,   "random_Integer (-3, 3) gave" & Small'Image & " ... failed !");
         end;
      end loop;

      assert (random_Integer (5, 5) = 5,   "random_Integer (5, 5) should be 5 ... failed !");
   end random_Integer_Test;



   procedure random_Real_Test
   is
   begin
      for i in 1 .. 1_000
      loop
         declare
            Unit  : constant Real := random_Real;
            Ranged : constant Real := random_Real (2.0, 3.0);
         begin
            assert (Unit   in 0.0 .. 1.0,   "random_Real gave " & Image (Unit) & " ... failed !");
            assert (Ranged in 2.0 .. 3.0,   "random_Real (2.0, 3.0) gave " & Image (Ranged) & " ... failed !");
         end;
      end loop;
   end random_Real_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Random Tests");

      Framework.add_test_Routine (T, random_Integer_Test'Access, "random_Integer Test");
      Framework.add_test_Routine (T, random_Real_Test   'Access, "random_Real Test");
   end initialize;

end math_Tests.Random;
