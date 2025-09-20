with
     openGL.Geometry,
     openGL.Model.texturing;


package openGL.Model.capsule.lit_textured
--
--  Models a lit and textured capsule.
--
is
   package textured_Model is new texturing.Mixin (openGL.Model.capsule.item);

   type Item is new textured_Model.textured_item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_Capsule (Radius : in Real;
                         Height : in Real;
                         texture_Details : in texture_Set.Details;
                         Image  : in asset_Name := null_Asset) return View;

   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new textured_Model.textured_item with
      record
         Radius : Real;
         Height : Real;

         Image  : asset_Name := null_Asset;
      end record;


end openGL.Model.capsule.lit_textured;
