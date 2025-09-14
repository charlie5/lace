with
     openGL.texture_Set;

--  private
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

   --- Texturing.
   --

   --  procedure Fade_is      (Self : in out Item;   Now   : in texture_Set.fade_Level;
   --                                                Which : in texture_Set.texture_ID := 1);
   --  function  Fade         (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return texture_Set.fade_Level;
   --
   --
   --  procedure Texture_is   (Self : in out Item;   Now   : in openGL.Texture.Object;
   --                                                Which : in texture_Set.texture_ID);
   --  function  Texture      (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return openGL.Texture.Object;

   --  overriding
   --  procedure Texture_is   (Self : in out Item;   Now : in openGL.Texture.Object);
   --
   --  overriding
   --  function  Texture      (Self : in     Item)     return openGL.Texture.Object;



private

   type Item is new textured_Geometry.item with
      record
         null;
      end record;


   --  type Item is new Geometry.item with
   --     record
   --        Textures : texture_Set.Item;
   --     end record;


   --  overriding
   --  procedure enable_Textures (Self : in out Item);

end openGL.Geometry.lit_colored_textured;
