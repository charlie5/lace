with
     openGL.texture_Set,
     openGL.Texture,
     openGL.Model.texturing;


package openGL.Model.circle.lit_textured
--
--  Models a lit and textured circle.
--
is
   package textured_Model is new texturing.Mixin (Model.circle.item);

   type Item is new textured_Model.textured_Item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_circle (Radius          : in Real;
                        texture_Details : in texture_Set.Details;
                        Sides           : in Positive           := 24) return View;


   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new textured_Model.textured_Item with null record;


end openGL.Model.circle.lit_textured;
