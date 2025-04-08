with
     openGL.texture_Set,
     openGL.Texture;


package openGL.Model.circle.lit_textured
--
--  Models a lit, colored and textured hexagon.
--
is
   type Item is new Model.item with private;
   type View is access all Item'Class;


   type Face is
      record
         texture_Details : texture_Set.Details;
         --  Fades           : texture_Set.fade_Levels           (texture_Set.texture_Id)       := [others => 0.0];
         --  Textures        : openGL.asset_Names (1 .. Positive (texture_Set.texture_Id'Last)) := [others => null_Asset];     -- The textures to be applied to the hex.
         --  texture_Count   : Natural                                                          := 0;
         --  texture_Applies : texture_Set.texture_Apply_array                                  := [others => True];
         --  Animation       : texture_Set.Animation_view;
      end record;


   ---------
   --- Forge
   --

   function new_circle (Radius : in Real;
                        Face   : in lit_textured.Face;
                        Sides  : in Positive         := 24) return View;


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
   function  Fade               (Self : in     Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;

   overriding
   procedure Fade_is            (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in texture_Set.fade_Level);

   procedure Texture_is         (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in asset_Name);

   overriding
   function  texture_Count      (Self : in     Item) return Natural;


   overriding
   function  texture_Applied    (Self : in     Item;   Which : in texture_Set.texture_Id) return Boolean;

   overriding
   procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in Boolean);

   overriding
   procedure animate            (Self : in out Item);



private

   type Item is new Model.circle.item with
      record
         Face  : lit_textured.Face;
      end record;

end openGL.Model.circle.lit_textured;
