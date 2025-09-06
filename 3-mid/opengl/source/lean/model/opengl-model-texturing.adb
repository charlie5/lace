with
     --  openGL.Model,
     GL.lean,
     GL.Binding,
     ada.Strings.fixed;

--  with ada.Text_IO;


package body openGL.Model.texturing
is
   use GL;


   type texture_Units is array (texture_Set.texture_Id) of GLenum;

   all_texture_Units : constant texture_Units := [GL_TEXTURE0,
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
                                                  GL_TEXTURE15];
                                                  --  GL_TEXTURE16,
                                                  --  GL_TEXTURE17,
                                                  --  GL_TEXTURE18,
                                                  --  GL_TEXTURE19,
                                                  --  GL_TEXTURE20,
                                                  --  GL_TEXTURE21,
                                                  --  GL_TEXTURE22,
                                                  --  GL_TEXTURE23,
                                                  --  GL_TEXTURE24,
                                                  --  GL_TEXTURE25,
                                                  --  GL_TEXTURE26,
                                                  --  GL_TEXTURE27,
                                                  --  GL_TEXTURE28,
                                                  --  GL_TEXTURE29,
                                                  --  GL_TEXTURE30,
                                                  --  GL_TEXTURE31];




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




   -------------
   --- Mixin ---
   -------------

   package body Mixin
   is
      overriding
      procedure Fade_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                         Now   : in texture_Set.fade_Level)
      is
      begin
         Self.texture_Details.Fades (which) := Now;
      end Fade_is;



      overriding
      function Fade (Self : in Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
      is
      begin
         return Self.texture_Details.Fades (which);
      end Fade;



      procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                            Now   : in openGL.asset_Name)
      is
      begin
         Self.texture_Details.Textures (Positive (which)) := Now;
      end Texture_is;




      overriding
      function texture_Count (Self : in Item) return Natural
      is
      begin
         return Self.texture_Details.texture_Count;
      end texture_Count;



      overriding
      function texture_Applied (Self : in Item;   Which : in texture_Set.texture_Id) return Boolean
      is
      begin
         return Self.texture_Details.texture_Applies (Which);
      end texture_Applied;



      overriding
      procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                    Now   : in Boolean)
      is
      begin
         Self.texture_Details.texture_Applies (Which) := Now;
      end texture_Applied_is;




      overriding
      procedure animate (Self : in out Item)
      is
         use type texture_Set.Animation_view;
      begin
         if Self.texture_Details.Animation = null
         then
            return;
         end if;

         texture_Set.animate (Self.texture_Details.Animation.all,
                              Self.texture_Details.texture_Applies);
      end animate;



      function texture_Details (Self : in Item) return openGL.texture_Set.Details
      is
      begin
         return Self.texture_Details;
      end texture_Details;


      procedure texture_Details_is (Self : in out Item;   Now : in openGL.texture_Set.Details)
      is
      begin
         Self.texture_Details := Now;
      end texture_Details_is;


   end Mixin;



end openGL.Model.texturing;
