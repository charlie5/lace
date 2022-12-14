with
     openGL.Model,
     openGL.Geometry;


package openGL.Model.any
--
--  Provides a general 3D model.
--
--  This model is largely used by the IO importers of various model formats (ie collada, wavefront, etc).
--
is

   type Geometry_view is access all openGL.Geometry.item'Class;


   type Item is new openGL.Model.item with
      record
         Model             : asset_Name   := null_Asset;   -- A wavefront '.obj' or collada '.dae' file.

         Texture           : asset_Name   := null_Asset;   -- The models texture image.
         has_lucid_Texture : Boolean      := False;

         Geometry          : Geometry_view;
      end record;

   type View is access all Item'Class;



   ---------
   --- Forge
   --

   function new_Model (Scale            : in math.Vector_3;
                       Model            : in asset_Name;
                       Texture          : in asset_Name;
                       Texture_is_lucid : in Boolean) return openGL.Model.any.view;



   --------------
   --- Attributes
   --

   overriding
   function  to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                     Fonts    : in     Font.font_id_Maps_of_font.Map) return openGL.Geometry.views;
   --
   --  Raises unsupported_model_Format when the Model is not a :
   --     - wavefront       '.obj'
   --     - collada         '.dae'
   --     - tabulated polar '.tab'

   unsupported_model_Format : exception;



private

   procedure build_GL_Geometries (Self : in out Item);

end openGL.Model.any;
