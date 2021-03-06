package openGL.Geometry.lit_colored
--
--  Supports per-vertex site, color and lighting.
--
is

   type Item is new openGL.Geometry.item with private;

   function new_Geometry return access Geometry.lit_colored.item'class;


   ----------
   --  Vertex
   --

   type Vertex is
      record
         Site   : Vector_3;
         Normal : Vector_3;
         Color  : lucid_Color;
      end record;

   type Vertex_array is array (Index_t range <>) of aliased Vertex;


   --------------
   --  Attributes
   --

   procedure Vertices_are   (Self : in out Item;   Now : in Vertex_array);


private

   type Item is new Geometry.item with
      record
         null;
      end record;

end openGL.Geometry.lit_colored;
