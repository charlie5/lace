with
     openGL.Palette;


package openGL.Model.circle.colored
--
--  Models a colored circle.
--
is
   type Item is new Model.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   function new_circle (Radius : in Real;
                        Color  : in openGL.lucid_Color := (Primary => openGL.Palette.White,
                                                           Opacity => Opaque);
                        Sides  : in Positive           := 24) return View;

   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new Model.circle.item with
      record
         Color : lucid_Color;
      end record;

end openGL.Model.circle.colored;
