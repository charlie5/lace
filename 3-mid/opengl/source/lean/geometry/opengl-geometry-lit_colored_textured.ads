with
     openGL.Geometry.texturing;


package openGL.Geometry.lit_colored_textured
--
--  Supports 'per-vertex' site, color, texture and lighting.
--
is
   package textured_Geometry is new texturing.Mixin;


   --  type Item is new openGL.Geometry.item with private;
   type Item is new textured_Geometry.item with private;
   type View is access all Item'Class;

   function new_Geometry (texture_is_Alpha : in Boolean) return access Geometry.lit_colored_textured.item'Class;


   ----------
   --  Vertex
   --

   type Vertex is
      record
         Site   : Vector_3;
         Normal : Vector_3;
         Color  : rgba_Color;
         Coords : Coordinate_2D;
         Shine  : Real;                    -- TODO: Use 'openGL.Shine' type.
      end record;

   type Vertex_array is array (Index_t range <>) of aliased Vertex;


   --------------
   --  Attributes
   --

   procedure Vertices_are   (Self : in out Item;   Now       : in Vertex_array);

   overriding
   procedure Indices_are    (Self : in out Item;   Now       : in Indices;
                                                   for_Facia : in Positive);


private

   type Item is new textured_Geometry.item with
      record
         null;
      end record;


end openGL.Geometry.lit_colored_textured;
