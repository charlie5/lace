with
     openGL.Model,
     GL.lean,
     GL.Binding,
     ada.Strings.fixed;


package body openGL.Geometry.texturing
is
   use GL;


   type texture_Units is array (texture_Set.texture_Id) of GLenum;

   all_texture_Units : constant texture_Units := (GL_TEXTURE0,
                                                  GL_TEXTURE1,
                                                  GL_TEXTURE2,
                                                  GL_TEXTURE3,
                                                  GL_TEXTURE4,
                                                  GL_TEXTURE5,
                                                  GL_TEXTURE6,
                                                  GL_TEXTURE7,
                                                  GL_TEXTURE8,
                                                  GL_TEXTURE9,
                                                  GL_TEXTURE10,
                                                  GL_TEXTURE11,
                                                  GL_TEXTURE12,
                                                  GL_TEXTURE13,
                                                  GL_TEXTURE14,
                                                  GL_TEXTURE15,
                                                  GL_TEXTURE16,
                                                  GL_TEXTURE17,
                                                  GL_TEXTURE18,
                                                  GL_TEXTURE19,
                                                  GL_TEXTURE20,
                                                  GL_TEXTURE21,
                                                  GL_TEXTURE22,
                                                  GL_TEXTURE23,
                                                  GL_TEXTURE24,
                                                  GL_TEXTURE25,
                                                  GL_TEXTURE26,
                                                  GL_TEXTURE27,
                                                  GL_TEXTURE28,
                                                  GL_TEXTURE29,
                                                  GL_TEXTURE30,
                                                  GL_TEXTURE31);




   procedure enable (for_Model   : in openGL.Model.view;
                     Uniforms    : in texturing.Uniforms;
                     texture_Set : in openGL.texture_Set.Item)
   is
      use GL.Binding,
          GL.lean;

      use type GLint;

   begin
      for i in 1 .. openGL.texture_Set.texture_Id (for_Model.texture_Count)
      loop
         Uniforms.Textures (i).fade_Uniform.Value_is (Real (for_Model.Fade (i)));

         glUniform1i     (Uniforms.Textures (i).texture_Uniform.gl_Variable,
                          GLint (i) - 1);
         glActiveTexture (all_texture_Units (i));
         glBindTexture   (GL_TEXTURE_2D,
                          texture_Set.Textures (i).Object.Name);
      end loop;

      Uniforms.Count.Value_is (for_Model.texture_Count);
   end enable;




   procedure create (Uniforms    :    out texturing.Uniforms;
                     for_Program : in     openGL.Program.view)
   is
   begin
      for Id in texture_Set.texture_Id'Range
      loop
         declare
            use ada.Strings,
                ada.Strings.fixed;
            i                    : constant Positive := Positive (Id);
            texture_uniform_Name : constant String   := "Textures[" & trim (Natural'Image (i - 1), Left) & "]";
            fade_uniform_Name    : constant String   := "Fade["     & trim (Natural'Image (i - 1), Left) & "]";
         begin
            Uniforms.Textures (Id).texture_Uniform := for_Program.uniform_Variable (named => texture_uniform_Name);
            Uniforms.Textures (Id).   fade_Uniform := for_Program.uniform_Variable (named =>    fade_uniform_Name);
         end;
      end loop;


      Uniforms.Count := for_Program.uniform_Variable ("texture_Count");
   end create;


end openGL.Geometry.texturing;
