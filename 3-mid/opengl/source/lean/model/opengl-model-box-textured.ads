with
     openGL.Geometry,
     openGL.Font,
     openGL.Texture;


package openGL.Model.Box.textured
--
--  Models a textured box.
--
--  Each face may have a separate texture.
--
is
   type Item is new Model.box.item with private;
   type View is access all Item'Class;


   type Face is
      record
         texture_Name : asset_Name := null_Asset;
      end record;

   type Faces is array (Side) of Face;


   ---------
   --- Forge
   --

   function new_Box (Size      : in Vector_3;
                     Faces     : in textured.Faces;
                     is_Skybox : in Boolean := False) return View;


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
   function  Fade       (Self : in     Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;

   overriding
   procedure Fade_is    (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in texture_Set.fade_Level);

   procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in asset_Name);

   overriding
   function  texture_Count (Self : in Item) return Natural;



private

   type Item is new Model.box.item with
      record
         Faces     : textured.Faces;
         is_Skybox : Boolean := False;
      end record;

end openGL.Model.Box.textured;
