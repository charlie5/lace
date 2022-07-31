with
     openGL.Geometry,
     openGL.Palette;


package openGL.Model.hex_grid
--
--  Models a regular hexagon grid.
--
is
   type Item is new Model.item with private;
   type View is access all Item'Class;


   type height_Map_view is access all height_Map;


   ---------
   --- Forge
   --

   function new_Grid (heights_Asset : in asset_Name;
                      Heights       : in height_Map_view;
                      Color         : in lucid_Color := (palette.White,
                                                         Opaque)) return View;
   overriding
   procedure destroy (Self : in out Item);


   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


private

   type Item is new Model.item with
      record
         heights_Asset : asset_Name     := null_Asset;
         Heights       : height_Map_view;
         Color         : rgba_Color;
      end record;


   overriding
   procedure set_Bounds (Self : in out Item);


end openGL.Model.hex_grid;
