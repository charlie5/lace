with
     openGL.texture_Set,
     openGL.Texture,
     openGL.Model.texturing;


package openGL.Model.hexagon.lit_textured
--
--  Models a lit and textured hexagon.
--
is
   package textured_Model is new texturing.Mixin (Model.hexagon.item);

   type Item is new textured_Model.textured_Item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_Hexagon (Radius          : in Real;
                         texture_Details : in texture_Set.Details) return View;


   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new textured_Model.textured_Item with null record;


end openGL.Model.hexagon.lit_textured;
