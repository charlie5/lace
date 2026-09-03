private
with
     openGL.Model.hexagon;


package openGL.Model.hexagon_Column
--
-- Models a column with six sides.
--
-- The column's axis is Y, so its hexagonal caps lie in the XZ plane.
--
is
   type Item is abstract new Model.item with private;



private

   type Item is abstract new Model.item with
      record
         Radius : Real := 1.0;
         Height : Real := 1.0;
      end record;


   Normal : constant Vector_3 := [0.0, 1.0, 0.0];     -- The normal of the upper cap.


   subtype Sites   is hexagon.Sites;
   type    Normals is array (hexagon.site_Id) of Vector_3;

   function cap_Sites      (Radius : in Real)                 return Sites;
   --
   -- The cap vertices, in the XZ plane, beginning at 'middle right' and proceeding
   -- anti-clockwise when seen from above.

   function facet_Normals  (Sites  : in hexagon_Column.Sites) return Normals;
   --
   -- The normal of each flat shaft facet, which runs from the vertex of the same id to the next.

   function vertex_Normals (Sites  : in hexagon_Column.Sites) return Normals;
   --
   -- The normal at each vertex of a rounded shaft.


end openGL.Model.hexagon_Column;
