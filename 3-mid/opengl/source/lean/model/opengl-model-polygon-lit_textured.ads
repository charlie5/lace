with
     openGL.texture_Set,
     openGL.Texture,
     openGL.Model.texturing;


package openGL.Model.polygon.lit_textured
--
--  Models a lit and textured polygon.
--
is
   package textured_Model is new texturing.Mixin;

   type Item is new textured_Model.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_Polygon (vertex_Sites    : in Vector_2_array;
                         texture_Details : in texture_Set.Details) return View;

   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new textured_Model.item with
      record
         vertex_Sites : Vector_2_array (1 .. 8);
         vertex_Count : Positive;
      end record;


end openGL.Model.polygon.lit_textured;
