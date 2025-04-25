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


   type Face_t is
      record
         texture_Details : texture_Set.Details;
      end record;


   ---------
   --- Forge
   --

   function new_circle (Radius : in Real;
                        Face   : in lit_textured.Face_t;
                        Sides  : in Positive         := 24) return View;


   --------------
   --- Attributes
   --

   function Face (Self : in Item) return Face_t;


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
         Face  : lit_textured.Face_t;
      end record;

end openGL.Model.circle.lit_textured;
