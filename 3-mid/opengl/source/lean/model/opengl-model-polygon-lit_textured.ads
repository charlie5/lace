with
     openGL.texture_Set,
     openGL.Texture,
     openGL.Model.texturing;


package openGL.Model.polygon.lit_textured
--
--  Models a lit and textured polygon.
--
is
   package textured_Model is new texturing.Mixin;

   type Item is new textured_Model.item with private;
   type View is access all Item'Class;



   --------
   --- Face
   --

   --  type Face_t is
   --     record
   --        texture_Details : texture_Set.Details;
   --     end record;


   ---------
   --- Forge
   --

   --  function new_Polygon (vertex_Sites : in Vector_2_array;
   --                        Face         : in lit_textured.Face_t) return View;

   function new_Polygon (vertex_Sites    : in Vector_2_array;
                         texture_Details : in texture_Set.Details) return View;


   --------------
   --- Attributes
   --

   --  function Face (Self : in Item) return Face_t;
   --  overriding
   --  function texture_Details (Self : in Item) return texture_Set.Details;

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views;

   ------------
   -- Texturing
   --

   --  overriding
   --  function  Fade               (Self : in     Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;
   --
   --  overriding
   --  procedure Fade_is            (Self : in out Item;   Which : in texture_Set.texture_Id;
   --                                                      Now   : in texture_Set.fade_Level);
   --
   --  procedure Texture_is         (Self : in out Item;   Which : in texture_Set.texture_Id;
   --                                                      Now   : in asset_Name);
   --
   --  overriding
   --  function  texture_Count      (Self : in     Item) return Natural;
   --
   --
   --  overriding
   --  function  texture_Applied    (Self : in     Item;   Which : in texture_Set.texture_Id) return Boolean;
   --
   --  overriding
   --  procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
   --                                                      Now   : in Boolean);
   --
   --  overriding
   --  procedure animate            (Self : in out Item);



private

   type Item is new textured_Model.item with
      record
         vertex_Sites : Vector_2_array (1 .. 8);
         vertex_Count : Positive;

         --  Face         : lit_textured.Face_t;
      end record;


end openGL.Model.polygon.lit_textured;
