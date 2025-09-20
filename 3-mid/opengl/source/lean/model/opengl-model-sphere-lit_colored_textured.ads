with
     openGL.Font,
     openGL.Palette,
     openGL.Geometry,
     openGL.Model.texturing;


package openGL.Model.sphere.lit_colored_textured
--
--  Models a lit, colored, textured sphere.
--
is
   package textured_Model is new texturing.Mixin (openGL.Model.sphere.item);

   type Item is new textured_Model.textured_item with private;
   type View is access all Item'Class;


   function new_Sphere (Radius     : in Real;
                        lat_Count  : in Positive           := default_latitude_Count;
                        long_Count : in Positive           := default_longitude_Count;
                        Color      : in openGL.lucid_Color := (openGL.Palette.Grey,
                                                               Opacity => 1.0);
                        texture_Details : in texture_Set.Details;
                        Image      : in asset_Name         := null_Asset) return View;


   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new textured_Model.textured_item with
      record
         Color : openGL.lucid_Color;
         Image : asset_Name := null_Asset;     -- Usually a mercator projection to be mapped onto the sphere.
      end record;

end openGL.Model.sphere.lit_colored_textured;
