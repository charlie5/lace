package body openGL.Model.circle
is

   function vertex_Sites (Radius : in Real;
                          Sides  : in Positive := 24) return Vector_2_array
   is
      use linear_Algebra_2d;

      the_Site :          Vector_2                   := [Radius, 0.0];
      Rotation : constant Matrix_2x2                 := to_rotation_Matrix (to_Radians (360.0 / Degrees (Sides)));
      Result   :          Vector_2_array (1 .. Sides);

   begin
      for i in Result'Range
      loop
         Result (i) := the_Site;
         the_Site   := the_Site * Rotation;
      end loop;

      return Result;
   end vertex_Sites;


end openGL.Model.circle;
