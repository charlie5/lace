with
     Ahven,
     float_Math.Algebra.linear.d3;

-- with ada.Text_IO; use ada.Text_IO;


package body math_Tests.linear_Algebra_3d
is

   use
        Ahven,
        float_Math,
        float_Math.Algebra.linear;


   function almost_Equal (Left, Right : in Real) return Boolean
   is
      Tolerance : constant := 0.000_001;
   begin
      return abs (Left - Right) <= Tolerance;
   end almost_Equal;



   function almost_Equal (Left, Right : in Vector_3) return Boolean
   is
   begin
      return          almost_Equal (Left (1), Right (1))
             and then almost_Equal (Left (2), Right (2))
             and then almost_Equal (Left (3), Right (3));
   end almost_Equal;



   function almost_Equal (Left, Right : in Quaternion) return Boolean
   is
   begin
      return          almost_Equal (Left.R,     Right.R)
             and then almost_Equal (Left.V (1), Right.V (1))
             and then almost_Equal (Left.V (2), Right.V (2))
             and then almost_Equal (Left.V (3), Right.V (3));
   end almost_Equal;



   procedure translation_Matrix_Test
   is
      use float_Math.Algebra.linear.d3;

      From : constant Vector_3 := [0.0, 0.0, 0.0];
      To   :          Vector_3;

   begin
      To := From * to_translation_Matrix ([1.0, 0.0, 0.0]);

      assert (To (1) = 1.0,  Image (To) & "  translation (a) failed !");
      assert (To (2) = 0.0,  Image (To) & "  translation (b) failed !");
      assert (To (3) = 0.0,  Image (To) & "  translation (c) failed !");

      To := From * to_translation_Matrix ([0.0, 1.0, 0.0]);

      assert (To (1) = 0.0,  Image (To) & "  translation (d) failed !");
      assert (To (2) = 1.0,  Image (To) & "  translation (e) failed !");
      assert (To (3) = 0.0,  Image (To) & "  translation (f) failed !");


      To := From * to_translation_Matrix ([-1.0, 0.0, 0.0]);

      assert (To (1) = -1.0,  Image (To) & "  translation (g) failed !");
      assert (To (2) =  0.0,  Image (To) & "  translation (h) failed !");
      assert (To (3) =  0.0,  Image (To) & "  translation (i) failed !");

      To := From * to_translation_Matrix ([0.0, -1.0, 0.0]);

      assert (To (1) =  0.0,  Image (To) & "  translation (j) failed !");
      assert (To (2) = -1.0,  Image (To) & "  translation (k) failed !");
      assert (To (3) =  0.0,  Image (To) & "  translation (l) failed !");


      To := From * to_translation_Matrix ([1.0, 1.0, 0.0]);

      assert (To (1) =  1.0,  Image (To) & "  translation (m) failed !");
      assert (To (2) =  1.0,  Image (To) & "  translation (n) failed !");
      assert (To (3) =  0.0,  Image (To) & "  translation (o) failed !");

      To := From * to_translation_Matrix ([-1.0, -1.0, 0.0]);

      assert (To (1) = -1.0,  Image (To) & "  translation (p) failed !");
      assert (To (2) = -1.0,  Image (To) & "  translation (q) failed !");
      assert (To (3) =  0.0,  Image (To) & "  translation (r) failed !");
   end translation_Matrix_Test;



   procedure rotation_Matrix_Test
   is
      use float_Math.Algebra.linear.d3;

      From : constant Vector_3 := [1.0, 0.0, 0.0];
      To   :          Vector_3;

   begin
      To := From * z_Rotation_from (to_Radians (90.0));

      assert (almost_Equal (To, [0.0, 1.0, 0.0]),
              Image (To, 16) & "  rotation (90) failed !");

      To := From * z_Rotation_from (to_Radians (-90.0));

      assert (almost_Equal (To, [0.0, -1.0, 0.0]),
              Image (To, 16) & "  rotation (-90) failed !");

      To := From * z_Rotation_from (to_Radians (180.0));

      assert (almost_Equal (To, [-1.0, 0.0, 0.0]),
              Image (To, 16) & "  rotation (180) failed !");

      To := From * z_Rotation_from (to_Radians (-180.0));

      assert (almost_Equal (To, [-1.0, 0.0, 0.0]),
              Image (To, 16) & "  rotation (-180) failed !");

      To := From * z_Rotation_from (to_Radians (270.0));

      assert (almost_Equal (To, [0.0, -1.0, 0.0]),
              Image (To, 16) & "  rotation (270) failed !");

      To := From * z_Rotation_from (to_Radians (-270.0));

      assert (almost_Equal (To, [0.0, 1.0, 0.0]),
              Image (To, 16) & "  rotation (-270) failed !");
   end rotation_Matrix_Test;



   procedure transform_Test
   is
      use float_Math.Algebra.linear.d3;

      From : constant Vector_3 := [1.0, 0.0, 0.0];
      To   :          Vector_3;

      Transform : Transform_3d := (rotation    => z_Rotation_from (to_Radians (90.0)),
                                   translation => [0.0, 0.0, 0.0]);

   begin
      To := From * Transform;

      assert (almost_Equal (To, [0.0, 1.0, 0.0]),
              Image (To, 16) & "  transform () failed !");

      Transform.Translation := [1.0, 0.0, 0.0];
      To                    := From * Transform;

      assert (almost_Equal (To, [1.0, 1.0, 0.0]),
              Image (To, 16) & "  transform () failed !");
   end transform_Test;



   procedure quaternion_interpolation_Test
   is
      use float_Math.Algebra.linear.d3;

      Initial : constant Quaternion := to_Quaternion (z_Rotation_from (to_Radians ( 90.0)));
      Desired : constant Quaternion := to_Quaternion (z_Rotation_from (to_Radians (180.0)));

   begin
--        put_Line (Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, 0.0)))));
--        put_Line (Degrees'Image (to_Degrees (Angle (Initial))));

      assert (almost_Equal (Interpolated (Initial, Desired,   0.0), Initial),   "almost_Equal (Interpolated (Initial, Desired, 0.0), Initial) ... failed !");
      assert (almost_Equal (Interpolated (Initial, Desired, 100.0), Desired),   "almost_Equal (Interpolated (Initial, Desired, 1.0), Desired) ... failed !");

--        new_Line;
--        put_Line ("0.01   " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.01))))));
--        put_Line ("0.1    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.1))))));
--        put_Line ("0.2    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.2))))));
--        put_Line ("0.3    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.3))))));
--        put_Line ("0.4    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.4))))));
--        put_Line ("0.5    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.5))))));
--        put_Line ("0.6    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.6))))));
--        put_Line ("0.7    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.7))))));
--        put_Line ("0.8    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.8))))));
--        put_Line ("0.9    " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.9))))));
--        put_Line ("0.99   " & Degrees'Image (to_Degrees (Angle (Interpolated (Initial, Desired, to_Percentage (0.99))))));

--        put_Line (Degrees'Image (to_Degrees (to_Radians (90.0))));

      assert (almost_Equal (Angle (Interpolated (Initial, Desired, 50.0)),
                            to_Radians (135.0)),
              "Angle (Interpolated (Initial, Desired, 0.5)) = to_Radians (135.0) ... failed !");
   end quaternion_interpolation_Test;



   procedure inverse_transform_Test
   is
      use float_Math.Algebra.linear.d3;

      From      : constant Vector_3 := [1.0, 1.0, 1.0];
      To        :          Vector_3;

      Transform : constant Matrix_4x4 := to_transform_Matrix (Rotation    => z_Rotation_from (to_Radians (90.0)),
                                                              Translation => [5.0, 5.0, 5.0]);
   begin
      To := From * Transform;
      To := To   * inverse_Transform (Transform);

      assert (almost_Equal (To, From),
              Image (To, 16) & "  inverse_Transform failed !");
   end inverse_transform_Test;



   procedure rotation_Convention_Test
   is
      use float_Math.Algebra.linear.d3;

      Quarter : constant Radians  := to_Radians (90.0);
      From    : constant Vector_3 := [1.0, 0.0, 0.0];
      Any     : constant Vector_3 := [0.2, 0.5, -0.8];
      Mixed   : constant Matrix_3x3 := xyz_Rotation (0.3, -0.7, 1.1);
   begin
      -- Every constructor is row-vector convention: 'Site * Rotation' turns counter-clockwise.
      --
      assert (almost_Equal (From * to_Rotation ([0.0, 0.0, 1.0], Quarter),                  [0.0, 1.0, 0.0]),   "axis/angle rotation failed !");
      assert (almost_Equal (From * to_Matrix (to_Quaternion ([0.0, 0.0, 1.0], Quarter)),    [0.0, 1.0, 0.0]),   "quaternion rotation failed !");
      assert (almost_Equal (From * to_Rotation (Euler' [0.0, 0.0, Quarter]),                [0.0, 1.0, 0.0]),   "euler rotation failed !");
      assert (almost_Equal ([0.0, 1.0, 0.0] * x_Rotation_from (Quarter),                    [0.0, 0.0, 1.0]),   "x rotation failed !");
      assert (almost_Equal ([0.0, 0.0, 1.0] * y_Rotation_from (Quarter),                    [1.0, 0.0, 0.0]),   "y rotation failed !");
      assert (almost_Equal ([0.0, 0.0, 1.0] * z_Up_to_y_Up,                                 [0.0, 1.0, 0.0]),   "z_Up_to_y_Up failed !");
      assert (almost_Equal ([0.0, 1.0, 0.0] * y_Up_to_z_Up,                                 [0.0, 0.0, 1.0]),   "y_Up_to_z_Up failed !");

      -- Euler angles apply X first, then Y, then Z.
      --
      assert (almost_Equal (Any * to_Rotation (Euler' [0.3, -0.7, 1.1]),
                            Any * x_Rotation_from (0.3) * y_Rotation_from (-0.7) * z_Rotation_from (1.1)),
              "euler order failed !");

      -- Matrix <-> quaternion round trips.
      --
      assert (almost_Equal (Any * to_Matrix (to_Quaternion (Mixed)),  Any * Mixed),   "matrix -> quaternion -> matrix failed !");

      declare
         Quat : Quaternion;
      begin
         set_from_Matrix_3x3 (Quat, Mixed);
         assert (almost_Equal (Quat, to_Quaternion (Mixed)),   "set_from_Matrix_3x3 failed !");
      end;

      -- A zero axis is the identity rotation.
      --
      assert (to_Rotation ([0.0, 0.0, 0.0], 1.0) = Identity_3x3,   "zero axis rotation failed !");
   end rotation_Convention_Test;



   procedure transform_Consistency_Test
   is
      use float_Math.Algebra.linear.d3;

      Point : constant Vector_3     := [0.5, -1.5, 2.0];
      T1    : constant Transform_3d := (Rotation    => z_Rotation_from (to_Radians (90.0)),
                                        Translation => [1.0, 2.0, 3.0]);
      T2    : constant Transform_3d := (Rotation    => x_Rotation_from (to_Radians (30.0)),
                                        Translation => [-4.0, 0.5, 0.0]);
   begin
      assert (almost_Equal (Point * T1,               Point * to_transform_Matrix (T1)),   "Transform_3d and Matrix_4x4 disagree !");
      assert (almost_Equal ((Point * T1) * Invert (T1),                    Point),        "Invert (Transform_3d) failed !");
      assert (almost_Equal (inverse_Transform (T1, Point * T1),            Point),        "inverse_Transform (Transform_3d) failed !");
      assert (almost_Equal ((Point * T1) * T2,        Point * (T1 * T2)),                  "Transform_3d composition failed !");
      assert (almost_Equal ((Point * T1) * T2,        Point * (to_transform_Matrix (T1) * to_transform_Matrix (T2))),
              "Transform_3d and Matrix_4x4 composition disagree !");
   end transform_Consistency_Test;



   procedure angle_Test
   is
      use float_Math.Algebra.linear.d3;

      Origin : constant Vector_3 := [0.0, 0.0, 0.0];
   begin
      assert (almost_Equal (Angle ([1.0, 0.0, 0.0], Origin, [ 2.0, 0.0, 0.0]),  0.0),                 "parallel angle failed !");
      assert (almost_Equal (Angle ([1.0, 0.0, 0.0], Origin, [ 0.0, 1.0, 0.0]),  to_Radians ( 90.0)),  "right angle failed !");
      assert (almost_Equal (Angle ([1.0, 0.0, 0.0], Origin, [-1.0, 0.0, 0.0]),  to_Radians (180.0)),  "opposite angle failed !");

      assert (almost_Equal (Angle (to_Quaternion ([0.0, 0.0, 1.0], 1.2)),  1.2),   "quaternion angle failed !");
      assert (almost_Equal (Angle (Quaternion' (R => -1.000_001, V => [0.0, 0.0, 0.0])),  2.0 * Pi),
              "quaternion angle clamp failed !");

      assert (max_Axis ([-5.0, -3.0, -4.0, -9.0]) = 2,   "max_Axis failed !");
   end angle_Test;



   procedure quaternion_Vector_product_Test
   is
      use float_Math.Algebra.linear.d3;

      Quat   : constant Quaternion := to_Quaternion ([0.3, 0.4, 0.5], 1.2);
      Vector : constant Vector_3   := [1.0, 2.0, 3.0];
      Pure   : constant Quaternion := (R => 0.0, V => Vector);
   begin
      assert (almost_Equal (Quat   * Vector,  Quat * Pure),   "Quaternion * Vector_3 failed !");
      assert (almost_Equal (Vector * Quat,    Pure * Quat),   "Vector_3 * Quaternion failed !");
   end quaternion_Vector_product_Test;



   procedure look_at_Test
   is
      use float_Math.Algebra.linear.d3;

      Eye  : constant Vector_3   := [0.0, 0.0, 5.0];
      View : constant Matrix_4x4 := Look_at (Eye, Center => [0.0, 0.0, 0.0],
                                                  Up     => [0.0, 1.0, 0.0]);
   begin
      assert (almost_Equal (Eye             * View,  [0.0, 0.0,  0.0]),   "Look_at eye failed !");
      assert (almost_Equal ([1.0, 0.0, 0.0] * View,  [1.0, 0.0, -5.0]),   "Look_at site failed !");
      assert (almost_Equal ([0.0, 0.0, 1.0] * inverse_Rotation (get_Rotation (View)),  [0.0, 0.0, 1.0]),
              "Look_at camera orientation failed !");
   end look_at_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Linear Algebra (3D) Tests");

      Framework.add_test_Routine (T,       translation_Matrix_Test'Access,       "translation_Matrix_Test");
      Framework.add_test_Routine (T,          rotation_Matrix_Test'Access,          "rotation_Matrix_Test");
      Framework.add_test_Routine (T,                transform_Test'Access,                "transform_Test");
      Framework.add_test_Routine (T,        inverse_transform_Test'Access,        "inverse_transform_Test");
      Framework.add_test_Routine (T, quaternion_interpolation_Test'Access, "quaternion_interpolation_Test");
      Framework.add_test_Routine (T,      rotation_Convention_Test'Access,      "rotation_Convention_Test");
      Framework.add_test_Routine (T,    transform_Consistency_Test'Access,    "transform_Consistency_Test");
      Framework.add_test_Routine (T,                    angle_Test'Access,                    "angle_Test");
      Framework.add_test_Routine (T, quaternion_Vector_product_Test'Access, "quaternion_Vector_product_Test");
      Framework.add_test_Routine (T,                  look_at_Test'Access,                  "look_at_Test");
   end initialize;


end math_Tests.linear_Algebra_3d;
