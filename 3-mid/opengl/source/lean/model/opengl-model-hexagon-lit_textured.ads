with
     openGL.texturing,
     openGL.Texture;


package openGL.Model.hexagon.lit_textured
--
--  Models a lit, colored and textured hexagon.
--
is
   type Item is new Model.item with private;
   type View is access all Item'Class;


   type Face is
      record
         Fades         : texturing.fade_Levels             (texturing.texture_Id)       := [others => 0.0];
         Textures      : openGL.asset_Names (1 .. Positive (texturing.texture_Id'Last)) := [others => null_Asset];     -- The textures to be applied to the hex.
         texture_Count : Natural := 0;
      end record;


   ---------
   --- Forge
   --

   function new_Hexagon (Radius : in Real;
                         Face   : in lit_textured.Face) return View;


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
   function  Fade       (Self : in     Item;   Which : in texturing.texture_Id) return texturing.fade_Level;

   overriding
   procedure Fade_is    (Self : in out Item;   Which : in texturing.texture_Id;
                                               Now   : in texturing.fade_Level);

   procedure Texture_is (Self : in out Item;   Which : in texturing.texture_Id;
                                               Now   : in asset_Name);

   overriding
   function  texture_Count (Self : in Item) return Natural;



private

   type Item is new Model.hexagon.item with
      record
         Face : lit_textured.Face;
      end record;

end openGL.Model.hexagon.lit_textured;
