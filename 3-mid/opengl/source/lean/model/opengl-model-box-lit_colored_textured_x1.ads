with
     openGL.Geometry,
     openGL.Font,
     openGL.Model.texturing,
     openGL.Texture;


package openGL.Model.Box.lit_colored_textured_x1
--
--  Models a lit, colored and textured box.
--
--  Each face may be separately colored via each of its 4 vertices.
--  All faces use the same texture.
--
is
   package textured_Model is new texturing.Mixin (openGL.Model.box.item);

   --  type Item is new Model.box.item with private;
   type Item is new textured_Model.textured_item with private;
   type View is access all Item'Class;


   type Face is
      record
         Colors : lucid_Colors (1 .. 4);      -- The color of each faces 4 vertices.
      end record;

   type Faces is array (Side) of Face;


   ---------
   --- Forge
   --

   function new_Box (Size    : in Vector_3;
                     Faces   : in lit_colored_textured_x1.Faces;
                     Texture : in asset_Name) return View;


   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   --  type Item is new Model.box.item with
   type Item is new textured_Model.textured_item with
      record
         Faces        : lit_colored_textured_x1.Faces;
         texture_Name : asset_Name := null_Asset;     -- The texture applied to all faces.
      end record;

end openGL.Model.Box.lit_colored_textured_x1;
