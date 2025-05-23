with
     openGL.Font.texture,
     openGL.Geometry;


package openGL.Model.Text.lit_colored
--
--  Models lit and colored text.
--
is
   type Item is new Model.text.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_Text (Text     : in String;
                      Font     : in openGL.Font.font_Id;
                      Color    : in lucid_Color;
                      Centered : in Boolean := True) return View;


   --------------
   --- Attributes
   --

   overriding
   function  to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                     Fonts    : in     openGL.Font.font_id_Map_of_font) return Geometry.views;
   overriding
   procedure Text_is (Self : in out Item;   Now : in String);
   overriding
   function  Text    (Self : in     Item)     return String;

   overriding
   function  Font    (Self : in     Item) return openGL.Font.view;


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

   type Item is new Model.text.item with
      record
         Text     : String_view;

         Font_Id  : openGL.Font.font_Id;
         Font     : openGL.Font.texture.view;

         Color    : rgba_Color;
         Centered : Boolean;
      end record;

end openGL.Model.Text.lit_colored;
