package openGL.Model.circle
--
--  Provides an abstract model of a circle.
--
is
   type Item is abstract new Model.item with private;


   -- Sites begin at 'middle right' and proceed in an anti-clockwise direction.
   --
   function vertex_Sites (Radius : in Real;
                          Sides  : in Positive := 24) return Vector_2_array;


private

   type Item is abstract new Model.item with
      record
         Radius : Real := 1.0;
         Sides  : Positive range 3 .. 360;
      end record;

   Normal : constant Vector_3 := [0.0, 0.0, 1.0];

end openGL.Model.circle;
