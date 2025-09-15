with
     openGL.Geometry,
     openGL.Font,
     openGL.Model.texturing,
     openGL.texture_Set;


package openGL.Model.Box.lit_textured
--
--  Models a lit and textured box.
--
--  Each face may have a separate texture.
--
is
   package textured_Model is new texturing.Mixin (openGL.Model.box.item);

   type Item is new textured_Model.textured_item with private;
   --  type Item is new Model.box.item with private;
   type View is access all Item'Class;


   type Face is
      record
         texture_Name : asset_Name := null_Asset;   -- The texture applied to the face.
      end record;

   type Faces is array (Side) of Face;


   ---------
   --- Forge
   --

   function new_Box (Size            : in Vector_3;
                     Faces           : in lit_textured.Faces;
                     texture_Details : in texture_Set.Details := texture_Set.no_Details) return View;


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

   --  type Item is new Model.box.item with
   type Item is new textured_Model.textured_item with
      record
         Faces : lit_textured.Faces;
      end record;

end openGL.Model.Box.lit_textured;
