with
     Ahven,

     cached_Rotation,

     float_Math.Algebra.linear.d2,
     float_Math.fast_Rotation,

     ada.Numerics.generic_elementary_Functions;


package body math_Tests.linear_Algebra_2d
is

   use
        Ahven,
        float_Math;


   function almost_Equal (Left, Right : in Real) return Boolean
   is
      Tolerance : constant := 0.000_000_1;
   begin
      return abs (Left - Right) <= Tolerance;
   end almost_Equal;



   procedure translation_Matrix_Test
   is
      use float_Math.Algebra.linear.d2;

      From : constant Vector_2 := [0.0, 0.0];
      To   : Vector_2;

   begin
      To := From * to_translation_Transform ([1.0, 0.0]);

      assert (To (1) = 1.0,  Image (To) & "  translation () failed !");
      assert (To (2) = 0.0,  Image (To) & "  translation () failed !");

      To := From * to_translation_Transform ([0.0, 1.0]);

      assert (To (1) = 0.0,  Image (To) & "  translation () failed !");
      assert (To (2) = 1.0,  Image (To) & "  translation () failed !");


      To := From * to_translation_Transform ([-1.0, 0.0]);

      assert (To (1) = -1.0,  Image (To) & "  translation () failed !");
      assert (To (2) =  0.0,  Image (To) & "  translation () failed !");

      To := From * to_translation_Transform ([0.0, -1.0]);

      assert (To (1) =  0.0,  Image (To) & "  translation () failed !");
      assert (To (2) = -1.0,  Image (To) & "  translation () failed !");


      To := From * to_translation_Transform ([1.0, 1.0]);

      assert (To (1) =  1.0,  Image (To) & "  translation () failed !");
      assert (To (2) =  1.0,  Image (To) & "  translation () failed !");

      To := From * to_translation_Transform ([-1.0, -1.0]);

      assert (To (1) = -1.0,  Image (To) & "  translation () failed !");
      assert (To (2) = -1.0,  Image (To) & "  translation () failed !");
   end translation_Matrix_Test;



   procedure rotation_Matrix_Test
   is
      use float_Math.Algebra.linear.d2;

      From : constant Vector_2 := [1.0, 0.0];
      To   : Vector_2;

   begin
      To := From * to_rotation_Matrix (to_Radians (90.0));

      assert (almost_Equal (To (1),  0.0),   Image (To, 16) & "  rotation (90a) failed !");
      assert (almost_Equal (To (2),  1.0),   Image (To, 16) & "  rotation (90b) failed !");

      To := From * to_rotation_Matrix (to_Radians (-90.0));

      assert (almost_Equal (To (1),  0.0),   Image (To, 16) & "  rotation (-90a) failed !");
      assert (almost_Equal (To (2), -1.0),   Image (To, 16) & "  rotation (-90b) failed !");


      To := From * to_rotation_Matrix (to_Radians (180.0));

      assert (almost_Equal (To (1), -1.0),   Image (To, 16) & "  rotation (180a) failed !");
      assert (almost_Equal (To (2),  0.0),   Image (To, 16) & "  rotation (180b) failed !");

      To := From * to_rotation_Matrix (to_Radians (-180.0));

      assert (almost_Equal (To (1), -1.0),   Image (To, 16) & "  rotation (-180a) failed !");
      assert (almost_Equal (To (2),  0.0),   Image (To, 16) & "  rotation (-180b) failed !");


      To := From * to_rotation_Matrix (to_Radians (270.0));

      assert (almost_Equal (To (1),  0.0),   Image (To, 16) & "  rotation (270a) failed !");
      assert (almost_Equal (To (2), -1.0),   Image (To, 16) & "  rotation (270b) failed !");

      To := From * to_rotation_Matrix (to_Radians (-270.0));

      assert (almost_Equal (To (1),  0.0),   Image (To, 16) & "  rotation (-270) failed !");
      assert (almost_Equal (To (2),  1.0),   Image (To, 16) & "  rotation (-270) failed !");
   end rotation_Matrix_Test;



   procedure transform_Test
   is
      use float_Math.Algebra.linear.d2;

      From : constant Vector_2 := [1.0, 0.0];
      To   : Vector_2;

      Transform : Transform_2d := to_Transform_2d (rotation    => to_Radians (90.0),
                                                   translation => [0.0, 0.0]);

   begin
      To := From * Transform;

      assert (almost_Equal (To (1),  0.0),   Image (To, 16) & "  transform (a) failed !");
      assert (almost_Equal (To (2),  1.0),   Image (To, 16) & "  transform (b) failed !");


      Transform.Translation := [1.0, 0.0];
      To                    := From * Transform;

      assert (almost_Equal (To (1),  1.0),   Image (To, 16) & "  transform (c) failed !");
      assert (almost_Equal (To (2),  1.0),   Image (To, 16) & "  transform (d) failed !");
   end transform_Test;



   procedure inverse_transform_Test
   is
      use float_Math.Algebra.linear.d2;

      Transform : constant Transform_2d := to_Transform_2d (rotation    => to_Radians (90.0),
                                                            translation => [1.0, 2.0]);
      From      : constant Vector_2     := [3.0, 4.0];
      Moved     : constant Vector_2     := From * Transform;
      Tolerance : constant              := 0.000_01;
      Back      :          Vector_2;
   begin
      Back := inverse_Transform (Transform, Moved);
      assert (abs (Back (1) - From (1)) <= Tolerance and abs (Back (2) - From (2)) <= Tolerance,
              Image (Back, 16) & "  inverse_Transform failed !");

      Back := Moved * Invert (Transform);
      assert (abs (Back (1) - From (1)) <= Tolerance and abs (Back (2) - From (2)) <= Tolerance,
              Image (Back, 16) & "  Invert failed !");
   end inverse_transform_Test;



   -----------------
   --- Fast rotation
   --

   slot_Count : constant := 10_000;     -- As 'any_Math.any_fast_Rotation' instantiates it.

   type degree_List is array (Positive range <>) of Degrees;
   type   real_List is array (Positive range <>) of Real;
   type  count_List is array (Positive range <>) of Natural;


   function rotation_Tolerance (Angle : in Real) return Real
   is (  Pi / Real (slot_Count)                  -- Half a slot: the lookup takes the nearest.
       + 8.0 * Pi * Real'Model_Epsilon           -- The sampled angle carries its own rounding.
       + abs Angle * Real'Model_Epsilon);        -- Reducing a large angle rounds away this much.


   function worst_Difference (Left, Right : in Matrix_2x2) return Real
   is
      Worst : Real := 0.0;
   begin
      for Row in 1 .. 2
      loop
         for Col in 1 .. 2
         loop
            Worst := Real'Max (Worst, abs (Left (Row, Col) - Right (Row, Col)));
         end loop;
      end loop;

      return Worst;
   end worst_Difference;


   --- The same cache at double precision. No 'long_Math' child reaches it, so it is
   --- instantiated here over a matrix of this test's own.
   --
   type wide_Matrix is array (1 .. 2, 1 .. 2) of Long_Float;

   function to_wide_Matrix (m11, m12,
                            m21, m22 : in Long_Float) return wide_Matrix
   is ([[m11, m12],
        [m21, m22]]);

   package wide_Functions is new ada.Numerics.generic_elementary_Functions (Long_Float);

   package wide_Rotation is new cached_Rotation (Float_type                 => Long_Float,
                                                 Matrix_2x2_type            => wide_Matrix,
                                                 float_elementary_Functions => wide_Functions,
                                                 to_Matrix_2x2              => to_wide_Matrix,
                                                 slot_Count                 => slot_Count);

   function wide_Exact (Angle : in Long_Float) return wide_Matrix
   is
      C : constant Long_Float := wide_Functions.Cos (Angle);
      S : constant Long_Float := wide_Functions.Sin (Angle);
   begin
      return [[C, -S],
              [S,  C]];                 -- The cache's own convention, untransposed.
   end wide_Exact;

   function wide_Tolerance (Angle : in Long_Float) return Long_Float
   is (  Pi / Long_Float (slot_Count)
       + 8.0 * Pi * Long_Float'Model_Epsilon
       + abs Angle * Long_Float'Model_Epsilon);

   function worst_Difference (Left, Right : in wide_Matrix) return Long_Float
   is
      Worst : Long_Float := 0.0;
   begin
      for Row in 1 .. 2
      loop
         for Col in 1 .. 2
         loop
            Worst := Long_Float'Max (Worst, abs (Left (Row, Col) - Right (Row, Col)));
         end loop;
      end loop;

      return Worst;
   end worst_Difference;



   procedure fast_rotation_Test
   --
   -- The cached matrix agrees with 'to_rotation_Matrix'. That settles the convention: the cache
   -- builds column-vector matrices and 'any_fast_Rotation' transposes them, so a sign slipped
   -- on either side would show here.
   --
   is
      use float_Math.Algebra.linear.d2;

      Turned : constant degree_List := [0.0, 30.0, 90.0, 180.0, 270.0, 359.0];
   begin
      for Each of Turned
      loop
         declare
            Angle : constant Radians    := to_Radians (Each);
            Fast  : constant Matrix_2x2 := fast_Rotation.to_Rotation (Angle);
            Exact : constant Matrix_2x2 := to_rotation_Matrix (Angle);
         begin
            assert (worst_Difference (Fast, Exact) <= rotation_Tolerance (Angle),
                    "fast rotation of" & Each'Image & " degrees is out by"
                    & Real'Image (worst_Difference (Fast, Exact)) & " ... failed !");
         end;
      end loop;
   end fast_rotation_Test;



   procedure fast_rotation_accuracy_Test
   --
   -- Across a revolution either side of zero, every entry is within half a slot of the exact
   -- rotation.
   --
   is
      use float_Math.Algebra.linear.d2;

      Steps : constant := 4_000;
   begin
      for i in -Steps .. Steps
      loop
         declare
            Angle : constant Radians    := Real (i) / Real (Steps) * 2.0 * Pi;
            Fast  : constant Matrix_2x2 := fast_Rotation.to_Rotation (Angle);
            Exact : constant Matrix_2x2 := to_rotation_Matrix (Angle);
         begin
            assert (worst_Difference (Fast, Exact) <= rotation_Tolerance (Angle),
                    "fast rotation of" & Angle'Image & " radians is out by"
                    & Real'Image (worst_Difference (Fast, Exact)) & " ... failed !");
         end;
      end loop;
   end fast_rotation_accuracy_Test;



   procedure fast_rotation_revolution_Test
   --
   -- A rotation is periodic, so adding whole revolutions must not change the matrix.
   --
   -- The table once held its first slot a second time, as its last, which slipped the wrap by
   -- one slot every revolution: after a thousand turns an entry was out by 0.56, a rotation
   -- wrong by some 36 degrees.
   --
   is
      Angles : constant real_List  := [0.0, 0.75, 2.0, 4.0];
      Turns  : constant count_List := [1, 10, 100, 1_000];
   begin
      for Angle of Angles
      loop
         for R of Turns
         loop
            declare
               Turned : constant Real       := Angle + Real (R) * 2.0 * Pi;
               Here   : constant Matrix_2x2 := fast_Rotation.to_Rotation (Angle);
               There  : constant Matrix_2x2 := fast_Rotation.to_Rotation (Turned);
            begin
               assert (worst_Difference (Here, There) <= rotation_Tolerance (Turned),
                       "fast rotation of" & Angle'Image & " after" & R'Image
                       & " revolutions is out by" & Real'Image (worst_Difference (Here, There))
                       & " ... failed !");
            end;
         end loop;
      end loop;
   end fast_rotation_revolution_Test;



   procedure fast_rotation_large_angle_Test
   --
   -- An angle carrying many revolutions is still answered, and to the accuracy its own
   -- representation allows. Past that the answer is at least a rotation, its rows staying
   -- unit vectors.
   --
   -- The index arithmetic once overflowed above about 1.35e6 radians, and raised.
   --
   is
      use float_Math.Algebra.linear.d2;

      Beyond : constant real_List := [1.0e3, 1.0e4, 1.0e5];
      Far    : constant real_List := [1.0e6, 2.0e6, 1.0e9];
   begin
      for Angle of Beyond
      loop
         declare
            Fast  : constant Matrix_2x2 := fast_Rotation.to_Rotation (Angle);
            Exact : constant Matrix_2x2 := to_rotation_Matrix (Angle);
         begin
            assert (worst_Difference (Fast, Exact) <= rotation_Tolerance (Angle),
                    "fast rotation of" & Angle'Image & " is out by"
                    & Real'Image (worst_Difference (Fast, Exact)) & " ... failed !");
         end;
      end loop;

      for Angle of Far
      loop
         declare
            Fast : constant Matrix_2x2 := fast_Rotation.to_Rotation (Angle);
         begin
            assert (abs (Fast (1, 1) * Fast (1, 1) + Fast (1, 2) * Fast (1, 2) - 1.0) <= 0.000_01,
                    "fast rotation of" & Angle'Image & " has a first row which is not a unit"
                    & " vector ... failed !");

            assert (abs (Fast (2, 1) * Fast (2, 1) + Fast (2, 2) * Fast (2, 2) - 1.0) <= 0.000_01,
                    "fast rotation of" & Angle'Image & " has a second row which is not a unit"
                    & " vector ... failed !");
         end;
      end loop;
   end fast_rotation_large_angle_Test;



   procedure cached_rotation_long_float_Test
   --
   -- The cache at double precision, where the index arithmetic differs: the reduction rounds
   -- less away, and the angle past which it must fall back to 'Remainder' is far further off.
   --
   is
      Steps : constant := 2_000;
      Turns : constant count_List := [1, 10, 100, 1_000];
   begin
      for i in -Steps .. Steps
      loop
         declare
            Angle : constant Long_Float := Long_Float (i) / Long_Float (Steps) * 20.0;
            Fast  : constant wide_Matrix := wide_Rotation.to_Rotation (Angle);
         begin
            assert (worst_Difference (Fast, wide_Exact (Angle)) <= wide_Tolerance (Angle),
                    "Long_Float rotation of" & Angle'Image & " is out by"
                    & Long_Float'Image (worst_Difference (Fast, wide_Exact (Angle)))
                    & " ... failed !");
         end;
      end loop;

      for R of Turns
      loop
         declare
            Angle  : constant Long_Float  := 0.75;
            Turned : constant Long_Float  := Angle + Long_Float (R) * 2.0 * Pi;
            Here   : constant wide_Matrix := wide_Rotation.to_Rotation (Angle);
            There  : constant wide_Matrix := wide_Rotation.to_Rotation (Turned);
         begin
            assert (worst_Difference (Here, There) <= wide_Tolerance (Turned),
                    "Long_Float rotation after" & R'Image & " revolutions is out by"
                    & Long_Float'Image (worst_Difference (Here, There)) & " ... failed !");
         end;
      end loop;

      declare
         Fast : constant wide_Matrix := wide_Rotation.to_Rotation (2.0e6);
      begin
         assert (abs (Fast (1, 1) * Fast (1, 1) + Fast (1, 2) * Fast (1, 2) - 1.0) <= 1.0e-12,
                 "Long_Float rotation of 2.0e6 has a first row which is not a unit vector"
                 & " ... failed !");
      end;
   end cached_rotation_long_float_Test;



   --------------------
   --- Matrix arithmetic
   --
   -- 'any_Math' writes these out rather than inheriting them from the generic array
   -- operations, so the tests below pin the orientation and the index order.
   --

   function worst_Difference (Left, Right : in Vector_2) return Real
   is (Real'Max (abs (Left (1) - Right (1)),
                 abs (Left (2) - Right (2))));


   A_2x2 : constant Matrix_2x2 := [[ 0.3, -0.7],
                                   [ 1.1,  0.5]];
   B_2x2 : constant Matrix_2x2 := [[-0.2,  0.9],
                                   [ 0.4, -1.3]];
   C_2x2 : constant Matrix_2x2 := [[ 1.7,  0.1],
                                   [-0.6,  0.8]];
   V_2   : constant Vector_2   := [0.3, -0.7];


   procedure matrix_2x2_product_Test
   --
   -- Identity, associativity, and that a vector times a matrix is the row-vector product.
   --
   is
      written_out : constant Vector_2 := [V_2 (1) * A_2x2 (1, 1) + V_2 (2) * A_2x2 (2, 1),
                                          V_2 (1) * A_2x2 (1, 2) + V_2 (2) * A_2x2 (2, 2)];
   begin
      assert (A_2x2 * Identity_2x2 = A_2x2,
              "a 2x2 times the identity should be itself ... failed !");

      assert (Identity_2x2 * A_2x2 = A_2x2,
              "the identity times a 2x2 should be itself ... failed !");

      assert (worst_Difference ((A_2x2 * B_2x2) * C_2x2, A_2x2 * (B_2x2 * C_2x2)) <= 0.000_01,
              "the 2x2 matrix product should be associative ... failed !");

      assert (worst_Difference (V_2 * (A_2x2 * B_2x2), (V_2 * A_2x2) * B_2x2) <= 0.000_01,
              "a vector through a 2x2 product should match it through each in turn ... failed !");

      assert (worst_Difference (V_2 * A_2x2, written_out) <= 0.000_001,
              "a vector times a 2x2 should be the row-vector product ... failed !");

      assert (worst_Difference (V_2 * Identity_2x2, V_2) <= 0.000_001,
              "a vector times the identity should be itself ... failed !");
   end matrix_2x2_product_Test;



   procedure matrix_2x2_transpose_Test
   is
   begin
      assert (Transpose (Transpose (A_2x2)) = A_2x2,
              "transposing a 2x2 twice should give it back ... failed !");

      for Row in 1 .. 2
      loop
         for Col in 1 .. 2
         loop
            assert (Transpose (A_2x2) (Row, Col) = A_2x2 (Col, Row),
                    "a transposed 2x2 entry should be the one across the diagonal ... failed !");
         end loop;
      end loop;

      assert (   worst_Difference (Transpose (A_2x2 * B_2x2),
                                   Transpose (B_2x2) * Transpose (A_2x2))
              <= 0.000_01,
              "transposing a 2x2 product should reverse the order ... failed !");
   end matrix_2x2_transpose_Test;



   procedure matrix_2x2_inverse_Test
   --
   -- The closed form, which replaced the decomposition inherited from the generic arrays.
   --
   is
      Singular : constant Matrix_2x2 := [[1.0, 2.0],
                                         [2.0, 4.0]];     -- Twice the first row.
      Raised   : Boolean    := False;
      Answered : Matrix_2x2 := Identity_2x2;
   begin
      assert (worst_Difference (A_2x2 * Inverse (A_2x2), Identity_2x2) <= 0.000_01,
              "a 2x2 times its inverse should be the identity ... failed !");

      assert (worst_Difference (Inverse (Inverse (A_2x2)), A_2x2) <= 0.000_01,
              "inverting a 2x2 twice should give it back ... failed !");

      assert (worst_Difference (Inverse (Identity_2x2), Identity_2x2) <= 0.000_001,
              "the identity's inverse should be the identity ... failed !");

      begin
         Answered := Inverse (Singular);
      exception
         when Constraint_Error =>
            Raised := True;
      end;

      assert (Raised,
              "inverting a singular 2x2 should raise Constraint_Error, but it answered"
              & Answered (1, 1)'Image & " ... failed !");
   end matrix_2x2_inverse_Test;



   procedure transform_2d_invert_Test
   --
   -- 'Invert' inverts the linear part rather than transposing it, so a transform carrying
   -- scale is undone correctly. Transposing answers something which is not the inverse.
   --
   is
      use float_Math.Algebra.linear.d2;

      T : constant Transform_2d := (Rotation    => [[2.0, 0.4],      -- Scale and shear.
                                                    [0.0, 0.5]],
                                    Translation => [3.0, -4.0]);
   begin
      assert (worst_Difference ((V_2 * T) * Invert (T), V_2) <= 0.000_01,
              "Invert should undo a transform carrying scale ... failed !");

      assert (worst_Difference (inverse_Transform (T, V_2 * T), V_2) <= 0.000_01,
              "inverse_Transform should undo a transform carrying scale ... failed !");
   end transform_2d_invert_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Linear Algebra (2D) Tests");

      Framework.add_test_Routine (T, translation_Matrix_Test'Access, "translation_Matrix_Test");
      Framework.add_test_Routine (T,    rotation_Matrix_Test'Access,    "rotation_Matrix_Test");
      Framework.add_test_Routine (T,          transform_Test'Access,          "transform_Test");
      Framework.add_test_Routine (T,  inverse_transform_Test'Access,  "inverse_transform_Test");
      Framework.add_test_Routine (T,      fast_rotation_Test'Access,      "fast_rotation_Test");
      Framework.add_test_Routine (T, fast_rotation_accuracy_Test    'Access, "fast_rotation_accuracy_Test");
      Framework.add_test_Routine (T, fast_rotation_revolution_Test  'Access, "fast_rotation_revolution_Test");
      Framework.add_test_Routine (T, fast_rotation_large_angle_Test 'Access, "fast_rotation_large_angle_Test");
      Framework.add_test_Routine (T, cached_rotation_long_float_Test'Access, "cached_rotation_long_float_Test");
      Framework.add_test_Routine (T, matrix_2x2_product_Test        'Access, "matrix_2x2_product_Test");
      Framework.add_test_Routine (T, matrix_2x2_transpose_Test      'Access, "matrix_2x2_transpose_Test");
      Framework.add_test_Routine (T, matrix_2x2_inverse_Test        'Access, "matrix_2x2_inverse_Test");
      Framework.add_test_Routine (T, transform_2d_invert_Test       'Access, "transform_2d_invert_Test");
   end initialize;


end math_Tests.linear_Algebra_2d;
