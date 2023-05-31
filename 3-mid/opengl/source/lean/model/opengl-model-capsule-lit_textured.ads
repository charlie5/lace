with
     openGL.Geometry;


package openGL.Model.capsule.lit_textured
--
--  Models a lit and textured capsule.
--
is
   type Item is new Model.capsule.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_Capsule (Radius : in Real;
                         Height : in Real;
                         Image  : in asset_Name := null_Asset) return View;

   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


   ------------
   -- Texturing
   --

   overriding
   function  Fade       (Self : in     Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;

   overriding
   procedure Fade_is    (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in texture_Set.fade_Level);

   procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in asset_Name);

   overriding
   function  texture_Count (Self : in Item) return Natural;



private

   type Item is new Model.capsule.item with
      record
         Radius : Real;
         Height : Real;

         Image  : asset_Name := null_Asset;
      end record;

end openGL.Model.capsule.lit_textured;
