with
     openGL.Font,
     openGL.Palette,
     openGL.Geometry;


package openGL.Model.sphere.lit_colored_textured
--
--  Models a lit, colored, textured sphere.
--
is
   type Item is new Model.sphere.item with private;
   type View is access all Item'Class;


   function new_Sphere (Radius     : in Real;
                        lat_Count  : in Positive           := default_latitude_Count;
                        long_Count : in Positive           := default_longitude_Count;
                        Color      : in openGL.lucid_Color := (openGL.Palette.Grey,
                                                               Opacity => 1.0);
                        Image      : in asset_Name         := null_Asset) return View;


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

   type Item is new Model.sphere.item with     -- TODO: Add 'Color' component.
      record
         Color : openGL.lucid_Color;
         Image : asset_Name := null_Asset;     -- Usually a mercator projection to be mapped onto the sphere.
      end record;

end openGL.Model.sphere.lit_colored_textured;
