with
     openGL.Variable.uniform,
     openGL.texture_Set,
     openGL.Program;


private
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
      type Item is new Geometry.item with private;


      procedure create_Uniforms (for_Program : in     openGL.Program.view);



      overriding
      procedure Fade_is      (Self : in out Item;   Now   : in texture_Set.fade_Level;
                                                    Which : in texture_Set.texture_ID := 1);
      overriding
      function  Fade         (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return texture_Set.fade_Level;


      overriding
      procedure Texture_is   (Self : in out Item;   Now   : in openGL.Texture.Object;
                                                    Which : in texture_Set.texture_ID := 1);
      overriding
      function  Texture      (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return openGL.Texture.Object;


      overriding
      procedure texture_Applied_is (Self : in out Item;   Now   : in Boolean;
                                                          Which : in texture_Set.texture_ID := 1);
      overriding
      function  texture_Applied    (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return Boolean;


      overriding
      procedure enable_Textures (Self : in out Item);



   private

      type Item is new Geometry.item with
         record
            texture_Set : openGL.texture_Set.item;
         end record;

   end Mixin;



end openGL.Model.texturing;
