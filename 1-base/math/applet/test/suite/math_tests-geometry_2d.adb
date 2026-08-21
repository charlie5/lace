with
     Ahven,

     float_Math.Geometry.d2.Hexagon,
     float_Math.Geometry.d2;


package body math_Tests.Geometry_2d
is

   use
        Ahven,
        float_Math;


   function almost_Equal (Left, Right : in Real) return Boolean
   is
      Tolerance : constant := 0.000_001;
   begin
      return abs (Left - Right) <= Tolerance;
   end almost_Equal;



   function almost_Equal (Left, Right : in Real;   Tolerance : in Real) return Boolean
   is
   begin
      return abs (Left - Right) <= Tolerance;
   end almost_Equal;



   function almost_Equal (Left, Right : in Geometry.d2.Site) return Boolean
   is
      Tolerance : constant := 0.000_01;
   begin
      return          almost_Equal (Left (1), Right (1), Tolerance)
             and then almost_Equal (Left (2), Right (2), Tolerance);
   end almost_Equal;



   procedure Polygon_is_convex_Test
   is
      use float_Math.Geometry.d2;

      the_Poly : Polygon := (vertex_Count => 4,
                             vertices     => [[-1.0, -1.0],
                                              [ 1.0, -1.0],
                                              [ 1.0,  1.0],
                                              [-1.0,  1.0]]);
   begin
      assert (is_Convex (the_Poly),
              "T1 => " & Image (the_Poly) & " should be convex ... failed !");

      the_Poly.Vertices (3) := [0.0, 0.0];
      assert (is_Convex (the_Poly),
              "T2 => " & Image (the_Poly) & " should be convex ... failed !");

      the_Poly.Vertices (3) := [0.0, 0.1];
      assert (is_Convex (the_Poly),
              "T3 => " & Image (the_Poly) & " should be convex ... failed !");

      the_Poly.Vertices (3) := [0.0, -0.1];
      assert (not is_Convex (the_Poly),
              "T4 => " & Image (the_Poly) & " should not be convex ... failed !");
   end Polygon_is_convex_Test;



   procedure triangle_Area_Test
   is
      use float_Math.Geometry.d2;

      the_Tri : Triangle := (vertices => [[0.0, 0.0],
                                          [1.0, 0.0],
                                          [1.0, 1.0]]);
   begin
      assert (almost_Equal (Area (the_Tri), 0.5),
              "T1 =>  & Image (the_Tri) &  area should be 0.5 ... failed !   " & Image (Area (the_Tri), 12));


      the_Tri := (vertices => [[-0.110_736_43,    -0.179_634_809],
                               [-0.055_368_214_8,  0.410_182_595],
                               [-0.027_684_107_4,  0.705_091_298]]);
      assert (Area (the_Tri) >= 0.0,
              "T2 =>  & Image (the_Tri) &  area should be positive ... failed !");


      the_Tri := (vertices => [[-1.0, -1.0],
                               [ 1.0, -1.0],
                               [ 1.0, -0.999_999]]);
      assert (Area (the_Tri) > 0.0,
              "T3 =>  & Image (the_Tri) &  area should be positive ... failed !");

      the_Tri := (vertices => [[-0.110_736_43,    -0.179_634_809],
                               [-0.027_684_107_4,  0.705_091_298],
                               [-0.055_368_214_8,  0.410_182_595]]);
      assert (Area (the_Tri) >= 0.0,
              "T4 =>  & Image (the_Tri) &  area should be positive ... failed !");

      -- tbd: Add tests for degenerate triangles.
   end triangle_Area_Test;



   procedure hexagon_Measures_Test
   is
      use float_Math.Geometry.d2;

      sqrt_3    : constant := 1.732_050_808;
      Tolerance : constant := 0.000_01;

      Radii : constant array (Positive range <>) of Real := [1.0, 2.5];
   begin
      for the_Radius of Radii
      loop
         declare
            the_Hex : constant Hexagon.item := Hexagon.to_Hexagon (circumRadius => the_Radius);
            Suffix  : constant String       := " for circumradius" & the_Radius'Image & " ... failed !";
         begin
            assert (almost_Equal (Hexagon.circumRadius (the_Hex),  the_Radius,  Tolerance),
                    "T1 => circumradius should be" & the_Radius'Image & Suffix);

            assert (almost_Equal (Hexagon.side_Length (the_Hex),  the_Radius,  Tolerance),
                    "T2 => side length should equal the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.maximal_Diameter (the_Hex),  2.0 * the_Radius,  Tolerance),
                    "T3 => maximal diameter should be twice the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.inRadius (the_Hex),  sqrt_3 / 2.0 * the_Radius,  Tolerance),
                    "T4 => inradius should be sqrt(3)/2 times the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.minimal_Diameter (the_Hex),  sqrt_3 * the_Radius,  Tolerance),
                    "T5 => minimal diameter should be sqrt(3) times the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.Perimeter (the_Hex),  6.0 * the_Radius,  Tolerance),
                    "T6 => perimeter should be 6 times the side length" & Suffix);

            assert (almost_Equal (Hexagon.Area (the_Hex),  1.5 * sqrt_3 * the_Radius ** 2,  Tolerance),
                    "T7 => area should be 3*sqrt(3)/2 times the circumradius squared" & Suffix);

            assert (almost_Equal (Hexagon.horizontal_Distance (the_Hex),  1.5 * the_Radius,  Tolerance),
                    "T8 => horizontal center distance should be 1.5 times the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.vertical_Distance (the_Hex),  sqrt_3 * the_Radius,  Tolerance),
                    "T9 => vertical center distance should be sqrt(3) times the circumradius" & Suffix);

            assert (almost_Equal (Hexagon.Angle (the_Hex, at_Vertex => 1),  2.094_395_102,  Tolerance),
                    "T10 => vertex angle should be 120 degrees in radians" & Suffix);
         end;
      end loop;
   end hexagon_Measures_Test;



   procedure hexagon_Vertices_Test
   is
      use float_Math.Geometry.d2;

      half_sqrt_3 : constant := 0.866_025_404;

      the_Hex : constant Hexagon.item := Hexagon.to_Hexagon (circumRadius => 1.0);

      expected_Sites : constant Sites (1 .. 6) := [[ 1.0,          0.0],
                                                   [ 0.5,  half_sqrt_3],
                                                   [-0.5,  half_sqrt_3],
                                                   [-1.0,          0.0],
                                                   [-0.5, -half_sqrt_3],
                                                   [ 0.5, -half_sqrt_3]];
   begin
      for Which in Hexagon.vertex_Id
      loop
         assert (almost_Equal (Hexagon.Site (the_Hex, of_Vertex => Which),
                               expected_Sites (Which)),
                   "T1 => vertex"
                 & Which'Image
                 & " site should be "
                 & expected_Sites (Which)'Image
                 & " ... failed !   "
                 & Hexagon.Site (the_Hex, of_Vertex => Which)'Image);
      end loop;

      assert (Hexagon.next_Vertex  (to_Vertex => 3) = 4,   "T2 => next vertex of 3 should be 4 ... failed !");
      assert (Hexagon.next_Vertex  (to_Vertex => 6) = 1,   "T3 => next vertex of 6 should wrap to 1 ... failed !");
      assert (Hexagon.prior_Vertex (to_Vertex => 4) = 3,   "T4 => prior vertex of 4 should be 3 ... failed !");
      assert (Hexagon.prior_Vertex (to_Vertex => 1) = 6,   "T5 => prior vertex of 1 should wrap to 6 ... failed !");
   end hexagon_Vertices_Test;



   procedure hexagon_Grid_Test
   is
      use float_Math.Geometry.d2;

      in_Radius : constant := 0.866_025_404;     -- The inradius for a circumradius of 1.
      sqrt_3    : constant := 1.732_050_808;     -- The vertical distance between adjacent centers.

      the_Grid : constant Hexagon.Grid := Hexagon.to_Grid (Rows => 2,  Cols => 2,  circumRadius => 1.0);
   begin
      assert (almost_Equal (Hexagon.hex_Center (the_Grid, Coords => (Row => 1, Col => 1)),
                            [1.0, in_Radius]),
              "T1 => center of hex (1, 1) ... failed !   " & Hexagon.hex_Center (the_Grid, (1, 1))'Image);

      assert (almost_Equal (Hexagon.hex_Center (the_Grid, Coords => (Row => 1, Col => 2)),
                            [2.5, 2.0 * in_Radius]),
              "T2 => center of hex (1, 2) ... failed !   " & Hexagon.hex_Center (the_Grid, (1, 2))'Image);

      assert (almost_Equal (Hexagon.hex_Center (the_Grid, Coords => (Row => 2, Col => 1)),
                            [1.0, in_Radius + sqrt_3]),
              "T3 => center of hex (2, 1) ... failed !   " & Hexagon.hex_Center (the_Grid, (2, 1))'Image);

      assert (almost_Equal (Hexagon.hex_Center (the_Grid, Coords => (Row => 2, Col => 2)),
                            [2.5, 2.0 * in_Radius + sqrt_3]),
              "T4 => center of hex (2, 2) ... failed !   " & Hexagon.hex_Center (the_Grid, (2, 2))'Image);

      assert (almost_Equal (Hexagon.vertex_Site (the_Grid, hex_Id => (Row => 1, Col => 1),  Which => 1),
                            [2.0, in_Radius]),
              "T5 => vertex 1 of hex (1, 1) ... failed !   "
              & Hexagon.vertex_Site (the_Grid, (1, 1), 1)'Image);

      assert (almost_Equal (Hexagon.vertex_Site (the_Grid, hex_Id => (Row => 2, Col => 2),  Which => 3),
                            [2.0, 3.0 * in_Radius + sqrt_3]),
              "T6 => vertex 3 of hex (2, 2) ... failed !   "
              & Hexagon.vertex_Site (the_Grid, (2, 2), 3)'Image);
   end hexagon_Grid_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Geometry (2D) Tests");

      Framework.add_test_Routine (T, Polygon_is_convex_Test'Access, "Polygon is convex Test");
      Framework.add_test_Routine (T, triangle_Area_Test    'Access, "Triangle area Test");
      Framework.add_test_Routine (T, hexagon_Measures_Test 'Access, "Hexagon measures Test");
      Framework.add_test_Routine (T, hexagon_Vertices_Test 'Access, "Hexagon vertices Test");
      Framework.add_test_Routine (T, hexagon_Grid_Test     'Access, "Hexagon grid Test");
   end initialize;


end math_Tests.Geometry_2d;
