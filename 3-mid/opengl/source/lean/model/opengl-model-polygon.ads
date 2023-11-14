package openGL.Model.polygon
--
--  Provides an abstract class for polygon models.
--
is
   type Item is abstract new Model.item with null record;



private

   Normal : constant Vector_3 := [0.0, 0.0, 1.0];

end openGL.Model.polygon;
