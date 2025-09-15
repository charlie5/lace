with
     openGL.Geometry,
     openGL.Model.texturing,
     openGL.texture_Set;


package openGL.Model.terrain
--
--  Models lit, textured terrain.
--
is
   package textured_Model is new texturing.Mixin (openGL.Model.item);

   type Item is new textured_Model.textured_item with private;
   type View is access all Item'Class;


   type height_Map_view is access all height_Map;


   ---------
   --- Forge
   --

   function new_Terrain (heights_Asset   : in asset_Name;
                         Row, Col        : in Integer;
                         Heights         : in height_Map_view;
                         color_Map       : in asset_Name;
                         texture_Details : in texture_Set.Details  := texture_Set.no_Details;
                         Tiling          : in texture_Transform_2d := (S => (0.0, 1.0),
                                                                       T => (0.0, 1.0))) return View;
   overriding
   procedure destroy (Self : in out Item);


   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;


   ------------
   -- Texturing
   --

   --  overriding
   --  function  Fade       (Self : in     Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;
   --
   --  overriding
   --  procedure Fade_is    (Self : in out Item;   Which : in texture_Set.texture_Id;
   --                                              Now   : in texture_Set.fade_Level);
   --
   --  procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
   --                                              Now   : in asset_Name);
   --
   --  overriding
   --  function  texture_Count (Self : in Item) return Natural;



private

   type Item is new textured_Model.textured_item with
      record
         heights_Asset : asset_Name := null_Asset;

         Heights       : height_Map_view;
         Row, Col      : Integer;

         color_Map     : asset_Name := null_Asset;
         Tiling        : texture_Transform_2D;
      end record;


   overriding
   procedure set_Bounds (Self : in out Item);

end openGL.Model.terrain;
