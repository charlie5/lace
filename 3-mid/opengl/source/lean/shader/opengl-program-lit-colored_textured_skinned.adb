with
     ada.Strings.fixed;


package body openGL.Program.lit.colored_textured_skinned
is

   overriding
   procedure define  (Self : in out Item;   use_vertex_Shader   : in Shader.view;
                                            use_fragment_Shader : in Shader.view)
   is
      use
           ada.Strings,
           ada.Strings.fixed;
   begin
      openGL.Program.lit.item (Self).define (use_vertex_Shader,
                                             use_fragment_Shader);   -- Define base class.

      for i in Self.bone_transform_Uniforms'Range
      loop
         Self.bone_transform_Uniforms (i).define (Self'Access,
                                                  "bone_Matrices[" & Trim (Integer'Image (i - 1), Left) & "]");
      end loop;
   end define;



   procedure bone_Transform_is (Self : in Item;   Which : in Integer;
                                                  Now   : in Matrix_4x4)
   is
   begin
      Self.bone_transform_Uniforms (Which).Value_is (Now);
   end bone_Transform_is;


end openGL.Program.lit.colored_textured_skinned;
