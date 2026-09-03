package body openGL.Model.hexagon_Column
is

   function cap_Sites (Radius : in Real) return Sites
   is
      flat_Sites : constant hexagon.Sites := hexagon.vertex_Sites (Radius);     -- In the XY plane.
      the_Sites  :          Sites;
   begin
      for i in the_Sites'Range
      loop
         the_Sites (i) := [flat_Sites (i) (1),      -- Turn the XY hexagon into the XZ plane, keeping
                           0.0,                     -- it anti-clockwise when seen from above (+Y).
                          -flat_Sites (i) (2)];
      end loop;

      return the_Sites;
   end cap_Sites;



   function facet_Normals (Sites : in hexagon_Column.Sites) return Normals
   is
      use linear_Algebra;

      the_Normals : Normals;
      Next        : hexagon.site_Id;
   begin
      for i in the_Normals'Range
      loop
         Next            := (if i = Sites'Last then Sites'First
                                               else i + 1);
         the_Normals (i) := Normalised (Sites (i) + Sites (Next));     -- The direction of the facet's mid-edge.
      end loop;

      return the_Normals;
   end facet_Normals;



   function vertex_Normals (Sites : in hexagon_Column.Sites) return Normals
   is
      use linear_Algebra;

      the_Normals : Normals;
   begin
      for i in the_Normals'Range
      loop
         the_Normals (i) := Normalised (Sites (i));
      end loop;

      return the_Normals;
   end vertex_Normals;


end openGL.Model.hexagon_Column;
