with
     Ahven,
     float_Math.Geometry.d3.Modeller.Forge;


package body math_Tests.Geometry_3d
is

   use
        Ahven,
        float_Math,
        float_Math.Geometry.d3;


   procedure box_Model_Test
   is
      use float_Math.Geometry.d3.Modeller.Forge;

      the_Box : constant a_Model := to_Box_Model (half_Extents => [1.0, 2.0, 3.0]);
   begin
      assert (the_Box.Site_Count = 8,    "box should have 8 sites ... failed !");
      assert (the_Box. Tri_Count = 12,   "box should have 12 triangles ... failed !");

      for Each of the_Box.Sites
      loop
         assert (        abs Each (1) = 1.0
                 and abs Each (2) = 2.0
                 and abs Each (3) = 3.0,
                 "box corner " & Image (Each) & " does not honour the half extents ... failed !");
      end loop;
   end box_Model_Test;



   procedure bounding_Sphere_Test
   is
      use float_Math.Geometry.d3.Modeller;

      the_Modeller : Item;
   begin
      the_Modeller.add_Triangle ([0.0, 0.0, 0.0],
                                 [1.0, 0.0, 0.0],
                                 [0.0, 1.0, 0.0]);

      assert (the_Modeller.bounding_Sphere_Radius = 1.0,   "initial bounding radius should be 1 ... failed !");

      the_Modeller.add_Triangle ([0.0, 0.0, 0.0],
                                 [5.0, 0.0, 0.0],
                                 [0.0, 5.0, 0.0]);

      assert (the_Modeller.bounding_Sphere_Radius = 5.0,   "bounding radius should grow to 5 ... failed !");

      the_Modeller.clear;

      begin
         declare
            Unused : constant a_Model := the_Modeller.Model;
         begin
            fail ("Model of an empty modeller should raise Constraint_Error ... failed !");
         end;
      exception
         when Constraint_Error => null;
      end;
   end bounding_Sphere_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Geometry (3D) Tests");

      Framework.add_test_Routine (T, box_Model_Test      'Access, "Box model Test");
      Framework.add_test_Routine (T, bounding_Sphere_Test'Access, "Bounding sphere Test");
   end initialize;

end math_Tests.Geometry_3d;
