with
     openGL.Model,
     GL.lean,
     GL.Binding,
     ada.Strings.fixed;


package body openGL.Geometry.texturing
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
                                                  --  GL_TEXTURE31);




   procedure enable (for_Model   : in openGL.Model.view;
                     Uniforms    : in texturing.Uniforms;
                     texture_Set : in openGL.texture_Set.Item)
   is
      use GL.Binding,
          GL.lean;

      use type GLint;

   begin
      if for_Model.texture_Count > 0
      then
         for i in 1 .. openGL.texture_Set.texture_Id (for_Model.texture_Count)
         loop
            Uniforms.Textures (i).tiling_Uniform         .Value_is (Vector_2' ((for_Model.Tiling  (Which => i).S,
                                                                                for_Model.Tiling  (Which => i).T)));
            Uniforms.Textures (i).fade_Uniform           .Value_is (Real     (for_Model.Fade      (Which => i)));
            Uniforms.Textures (i).texture_applied_Uniform.Value_is (for_Model.texture_Applied     (Which => i));

            glUniform1i     (Uniforms.Textures (i).texture_Uniform.gl_Variable,
                             GLint (i) - 1);
            glActiveTexture (all_texture_Units (i));
            glBindTexture   (GL_TEXTURE_2D,
                             texture_Set.Textures (i).Object.Name);
         end loop;
      end if;

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
            i                            : constant Positive := Positive (Id);
            texture_uniform_Name         : constant String   := "Textures["        & trim (Natural'Image (i - 1), Left) & "]";
            fade_uniform_Name            : constant String   := "Fade["            & trim (Natural'Image (i - 1), Left) & "]";
            texture_applies_uniform_Name : constant String   := "texture_Applies[" & trim (Natural'Image (i - 1), Left) & "]";
            tiling_uniform_Name          : constant String   := "Tiling["          & trim (Natural'Image (i - 1), Left) & "]";
         begin
            Uniforms.Textures (Id).        texture_Uniform := for_Program.uniform_Variable (Named =>         texture_uniform_Name);
            Uniforms.Textures (Id).           fade_Uniform := for_Program.uniform_Variable (Named =>            fade_uniform_Name);
            Uniforms.Textures (Id).texture_applied_Uniform := for_Program.uniform_Variable (Named => texture_applies_uniform_Name);
            Uniforms.Textures (Id).tiling_Uniform          := for_Program.uniform_Variable (Named =>          tiling_uniform_Name);
         end;
      end loop;


      Uniforms.Count := for_Program.uniform_Variable ("texture_Count");
   end create;




   -------------
   --- Mixin ---
   -------------

   package body Mixin
   is
      use openGL.texture_Set;


      texture_Uniforms : texturing.Uniforms;

      procedure create_Uniforms (for_Program : in openGL.Program.view)
      is
      begin
         create (texture_Uniforms, for_Program);
      end create_Uniforms;



      overriding
      procedure Fade_is (Self : in out Item;   Now   : in texture_Set.fade_Level;
                                               Which : in texture_Set.texture_ID := 1)
      is
      begin
         Self.texture_Set.Textures (Which).Fade := Now;
      end Fade_is;



      overriding
      function Fade (Self : in Item;   Which : in texture_Set.texture_ID := 1) return texture_Set.fade_Level
      is
      begin
         return Self.texture_Set.Textures (Which).Fade;
      end Fade;



      overriding
      procedure Texture_is (Self : in out Item;   Now   : in openGL.Texture.Object;
                                                  Which : in texture_Set.texture_ID := 1)
      is
      begin
         Texture_is (in_Set => Self.texture_Set,
                     Which  => Which,
                     Now    => Now);
      end Texture_is;



      overriding
      function Texture (Self : in Item;   Which : texture_Set.texture_ID := 1) return openGL.Texture.Object
      is
      begin
         return openGL.texture_Set.Texture (in_Set => Self.texture_Set,
                                            Which  => Which);
      end Texture;



      overriding
      procedure texture_Applied_is (Self : in out Item;   Now   : in Boolean;
                                                          Which : in texture_Set.texture_ID := 1)
      is
      begin
         Self.texture_Set.Textures (Which).Applied := Now;
      end texture_Applied_is;



      overriding
      function  texture_Applied    (Self : in Item;   Which : in texture_Set.texture_ID := 1) return Boolean
      is
      begin
         return Self.texture_Set.Textures (Which).Applied;
      end texture_Applied;



      overriding
      procedure Tiling_is (Self : in out Item;   Now   : in texture_Set.Tiling;
                                                 Which : in texture_Set.texture_ID := 1)
      is
      begin
         Self.texture_Set.Textures (Which).Tiling := Now;
      end Tiling_is;



      overriding
      function Tiling (Self : in     Item;   Which : in texture_Set.texture_ID := 1) return texture_Set.Tiling
      is
      begin
         return Self.texture_Set.Textures (Which).Tiling;
      end Tiling;







      overriding
      procedure enable_Textures (Self : in out Item)
      is
      begin
         texturing.enable (for_Model   => Self.Model.all'Access,
                           Uniforms    => texture_Uniforms,
                           texture_Set => Self.texture_Set);
      end enable_Textures;


   end Mixin;



end openGL.Geometry.texturing;
