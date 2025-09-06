with
     openGL.Variable.uniform,
     openGL.texture_Set,
     openGL.Program;


package openGL.Model.texturing
--
-- Provides texturing support for models.
--
is
   --- Uniforms
   --

   type texture_fade_Uniform_pair is
      record
         texture_Uniform : openGL.Variable.uniform.sampler2D;
         fade_Uniform    : openGL.Variable.uniform.float;
      end record;


   type texture_fade_Uniform_pairs is array (openGL.texture_Set.texture_Id
                                             range 1 .. openGL.texture_Set.max_Textures) of texture_fade_Uniform_pair;

   type Uniforms is
      record
         Textures : texture_fade_Uniform_pairs;
         Count    : openGL.Variable.uniform.int;
      end record;



   --- Operations
   --

   procedure enable (for_Model   : in     openGL.Model.view;
                     Uniforms    : in     texturing.Uniforms;
                     texture_Set : in     openGL.texture_Set.Item);


   procedure create (Uniforms    :    out texturing.Uniforms;
                     for_Program : in     openGL.Program.view);



   -------------
   --- Mixin ---
   -------------

   generic
   package Mixin
   is
      type Item is abstract new Model.item with private;


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


      function texture_Details     (Self : in Item) return openGL.texture_Set.Details;

      procedure texture_Details_is (Self : in out Item;   Now : in openGL.texture_Set.Details);



   private

      type Item is abstract new Model.item with
         record
            texture_Details : openGL.texture_Set.Details;
         end record;

   end Mixin;


end openGL.Model.texturing;
