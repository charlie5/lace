with
     openGL.Variable.uniform,
     openGL.texture_Set,
     openGL.Program;

limited
with
     openGL.Model;


private
package openGL.Geometry.texturing
--
-- Provides texturing support for geometries.
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


end openGL.Geometry.texturing;
