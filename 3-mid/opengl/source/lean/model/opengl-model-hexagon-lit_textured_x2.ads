with
     openGL.Geometry.texturing,
     openGL.Texture;


package openGL.Model.hexagon.lit_textured_x2
--
--  Models a lit, colored and textured hexagon.
--
is
   type Item is new Model.item with private;
   type View is access all Item'Class;

   type Face is
      record
         Texture_1 : openGL.asset_Name                    := null_Asset;     -- The texture to be applied to the hex.
         Texture_2 : openGL.asset_Name                    := null_Asset;     -- The texture to be applied to the hex.
         Fade_1    : openGL.Geometry.texturing.fade_Level := 0.5;
         Fade_2    : openGL.Geometry.texturing.fade_Level := 0.5;
      end record;


   ---------
   --- Forge
   --

   function new_Hexagon (Radius : in Real;
                         Face   : in lit_textured_x2.Face) return View;


   --------------
   --- Attributes
   --

   procedure Texture_1_is (Self : in out Item;   Now : in openGL.asset_Name);
   procedure Texture_2_is (Self : in out Item;   Now : in openGL.asset_Name);


   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new Model.hexagon.item with
      record
         Face : lit_textured_x2.Face;
      end record;

end openGL.Model.hexagon.lit_textured_x2;
