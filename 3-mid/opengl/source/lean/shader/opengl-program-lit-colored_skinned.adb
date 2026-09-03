with
     ada.Strings.fixed;


package body openGL.Program.lit.colored_skinned
is
   -- Old code kept for reference til new code is tested and stable ...
   --

--     overriding
--     procedure define (Self : in out Item)
--     is
--        use openGL.Palette,
--            GL.lean,
--            GL.Pointers,
--            Interfaces,
--            system.Storage_Elements;
--
--        check_is_OK          : constant Boolean := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
--
--        sample_Vertex        :          Geometry.lit_textured_skinned.Vertex;
--
--        Attribute_1_Name     : aliased          C.char_array        := "Site";
--        attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'unchecked_Access);
--
--        Attribute_2_Name     : aliased          C.char_array        := "Normal";
--        attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'unchecked_Access);
--
--        Attribute_3_Name     : aliased          C.char_array        := "Color";
--        attribute_3_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_3_Name'unchecked_Access);
--
--        Attribute_4_Name     : aliased          C.char_array        := "Coords";
--        attribute_4_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_4_Name'unchecked_Access);
--
--        Attribute_5_Name     : aliased          C.char_array        := "bone_Ids";
--        attribute_5_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_5_Name'unchecked_Access);
--
--        Attribute_6_Name     : aliased          C.char_array        := "bone_Weights";
--        attribute_6_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_6_Name'unchecked_Access);
--
--        Attribute_1 : openGL.Attribute.view;
--        Attribute_2 : openGL.Attribute.view;
--        Attribute_3 : openGL.Attribute.view;
--        Attribute_4 : openGL.Attribute.view;
--        Attribute_5 : openGL.Attribute.view;
--        Attribute_6 : openGL.Attribute.view;
--
--        white_Image : constant openGL.Image := (1 .. 2 => (1 .. 2 => White));
--
--     begin
--        white_Texture := openGL.Texture.to_Texture (white_Image);
--
--        the_vertex_Shader  .define (openGL.Shader.Vertex,   API.shader_Folder & "lit_textured_skinned.vert");
--        the_fragment_Shader.define (openGL.Shader.Fragment, API.shader_Folder & "lit_textured_skinned.frag");
--
--        Self.define (the_vertex_Shader  'Access,
--                     the_fragment_Shader'Access);
--
--        Self.enable;
--
--        Attribute_1 := openGL.Attribute.Forge.new_Attribute
--          (name        => "Site",
--           gl_location => Self.attribute_Location ("Site"),
--           size        => 3,
--           data_kind   => openGL.Attribute.GL_FLOAT,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      => 0,
--           normalized  => False);
--
--        Attribute_2 := openGL.Attribute.Forge.new_Attribute
--          (name        => "Normal",
--           gl_location => Self.attribute_Location ("Normal"),
--           size        => 3,
--           data_kind   => openGL.Attribute.GL_FLOAT,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      =>   sample_Vertex.Normal (1)'Address
--                          - sample_Vertex.Site   (1)'Address,
--           normalized  => False);
--
--        Attribute_3 := openGL.Attribute.Forge.new_Attribute
--          (name        => "Color",
--           gl_location => Self.attribute_Location ("Color"),
--           size        => 4,
--           data_kind   => openGL.Attribute.GL_UNSIGNED_BYTE,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      =>   sample_Vertex.Color.Primary.Red'Address
--                          - sample_Vertex.Site (1)         'Address,
--           normalized  => True);
--
--        Attribute_4 := openGL.Attribute.Forge.new_Attribute
--          (name        => "Coords",
--           gl_location => Self.attribute_Location ("Coords"),
--           size        => 2,
--           data_kind   => openGL.Attribute.GL_FLOAT,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      =>   sample_Vertex.Coords.S'Address
--                          - sample_Vertex.Site (1)'Address,
--           normalized  => False);
--
--        Attribute_5 := openGL.Attribute.Forge.new_Attribute
--          (name        => "bone_Ids",
--           gl_location => Self.attribute_Location ("bone_Ids"),
--           size        => 4,
--           data_kind   => openGL.Attribute.GL_FLOAT,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      =>   sample_Vertex.bone_Ids (1)'Address
--                          - sample_Vertex.Site (1)'Address,
--           normalized  => False);
--
--        Attribute_6 := openGL.Attribute.Forge.new_Attribute
--          (name        => "bone_Weights",
--           gl_location => Self.attribute_Location ("bone_Weights"),
--           size        => 4,
--           data_kind   => openGL.Attribute.GL_FLOAT,
--           stride      => Geometry.lit_textured_skinned.Vertex'Size / 8,
--           offset      =>   sample_Vertex.bone_Weights (1)'Address
--                          - sample_Vertex.Site (1)'Address,
--           normalized  => False);
--
--        Self.add (Attribute_1);
--        Self.add (Attribute_2);
--        Self.add (Attribute_3);
--        Self.add (Attribute_4);
--        Self.add (Attribute_5);
--        Self.add (Attribute_6);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "Site").gl_Location,
--                              name    => +attribute_1_Name_ptr);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "Normal").gl_Location,
--                              name    => +attribute_2_Name_ptr);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "Color").gl_Location,
--                              name    => +attribute_3_Name_ptr);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "Coords").gl_Location,
--                              name    => +attribute_4_Name_ptr);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "bone_Ids").gl_Location,
--                              name    => +attribute_5_Name_ptr);
--
--        glBindAttribLocation (program => Self.gl_Program,
--                              index   => Self.Attribute (named => "bone_Weights").gl_Location,
--                              name    => +attribute_6_Name_ptr);
--     end define;



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


end openGL.Program.lit.colored_skinned;
