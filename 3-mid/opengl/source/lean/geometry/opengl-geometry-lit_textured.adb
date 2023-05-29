with
     openGL.Buffer.general,
     openGL.Model,
     openGL.Shader,
     openGL.Program.lit,
     openGL.Variable.uniform,
     openGL.Attribute,
     openGL.Texture,
     openGL.Palette,
     openGL.Tasks,
     openGL.Errors,

     GL.lean,
     GL.Binding,
     GL.Pointers,

     ada.Strings.fixed,
     Interfaces.C.Strings,
     System.storage_Elements;

--  with ada.Text_IO; use ada.Text_IO;


package body openGL.Geometry.lit_textured
is
   use GL.lean,
       GL.Pointers,
       openGL.texturing,
       Interfaces;

   -----------
   --  Globals
   --

   vertex_Shader        : aliased Shader.item;
   fragment_Shader      : aliased Shader.item;

   the_Program          : openGL.Program.lit.view;
   white_Texture        : openGL.Texture.Object;

   Name_1               : constant String := "Site";
   Name_2               : constant String := "Normal";
   Name_3               : constant String := "Coords";
   Name_4               : constant String := "Shine";

   Attribute_1_Name     : aliased C.char_array := C.to_C (Name_1);
   Attribute_2_Name     : aliased C.char_array := C.to_C (Name_2);
   Attribute_3_Name     : aliased C.char_array := C.to_C (Name_3);
   Attribute_4_Name     : aliased C.char_array := C.to_C (Name_4);

   Attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);
   Attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);
   Attribute_3_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_3_Name'Access);
   Attribute_4_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_4_Name'Access);


   --- Uniforms
   --

   type texture_Uniforms is
      record
         texture_Uniform : openGL.Variable.uniform.sampler2D;
         fade_Uniform    : openGL.Variable.uniform.float;
      end record;

   the_Textures              : array (texture_Id range 1 .. max_Textures) of texture_Uniforms;
   the_texture_count_Uniform : openGL.Variable.uniform.int;



   ---------
   --  Forge
   --

   procedure create_Program
   is
      use Palette,
          Attribute.Forge,
          System.storage_Elements;

      use type system.Address;

      Sample : Vertex;

      Attribute_1 : Attribute.view;
      Attribute_2 : Attribute.view;
      Attribute_3 : Attribute.view;
      Attribute_4 : Attribute.view;

      white_Image : constant Image := [1 .. 2 => [1 .. 2 => +White]];

   begin
      white_Texture := openGL.Texture.Forge.to_Texture (white_Image);

      vertex_Shader  .define (Shader.Vertex,   "assets/opengl/shader/lit_textured.vert");
      fragment_Shader.define (Shader.Fragment, (asset_Names' (1 => to_Asset ("assets/opengl/shader/version.header"),
                                                              2 => to_Asset ("assets/opengl/shader/texturing.frag"),
                                                              3 => to_Asset ("assets/opengl/shader/lit_textured.frag"))));
      the_Program := new openGL.Program.lit.item;
      the_Program.define (  vertex_Shader'Access,
                            fragment_Shader'Access);
      the_Program.enable;

      Attribute_1 := new_Attribute (Name        => Name_1,
                                    gl_Location => the_Program.attribute_Location (Name_1),
                                    Size        => 3,
                                    data_Kind   => attribute.GL_FLOAT,
                                    Stride      => lit_textured.Vertex'Size / 8,
                                    Offset      => 0,
                                    Normalized  => False);

      Attribute_2 := new_Attribute (Name        => Name_2,
                                    gl_Location => the_Program.attribute_Location (Name_2),
                                    Size        => 3,
                                    data_Kind   => attribute.GL_FLOAT,
                                    Stride      => lit_textured.Vertex'Size / 8,
                                    Offset      =>   Sample.Normal (1)'Address
                                    - Sample.Site   (1)'Address,
                                    Normalized  => False);

      Attribute_3 := new_Attribute (Name        => Name_3,
                                    gl_Location => the_Program.attribute_Location (Name_3),
                                    Size        => 2,
                                    data_Kind   => attribute.GL_FLOAT,
                                    Stride      => lit_textured.Vertex'Size / 8,
                                    Offset      =>   Sample.Coords.S'Address
                                    - Sample.Site (1)'Address,
                                    Normalized  => False);

      Attribute_4 := new_Attribute (Name        => Name_4,
                                    gl_Location => the_Program.attribute_Location (Name_4),
                                    Size        => 1,
                                    data_Kind   => attribute.GL_FLOAT,
                                    Stride      => lit_textured.Vertex'Size / 8,
                                    Offset      =>   Sample.Shine   'Address
                                    - Sample.Site (1)'Address,
                                    Normalized  => False);

      the_Program.add (Attribute_1);
      the_Program.add (Attribute_2);
      the_Program.add (Attribute_3);
      the_Program.add (Attribute_4);

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_1).gl_Location,
                            name    => +Attribute_1_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_2).gl_Location,
                            name    => +Attribute_2_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_3).gl_Location,
                            name    => +Attribute_3_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_4).gl_Location,
                            name    => +Attribute_4_Name_ptr);
      Errors.log;


      --- Set up the texturing uniforms.
      --

      for Id in texture_Id'Range
      loop
         declare
            use ada.Strings,
                ada.Strings.fixed;
            i                    : constant Positive := Positive (Id);
            texture_uniform_Name : constant String   := "Textures[" & trim (Natural'Image (i - 1), Left) & "]";
            fade_uniform_Name    : constant String   := "Fade["     & trim (Natural'Image (i - 1), Left) & "]";
         begin
            the_Textures (Id).texture_Uniform := the_Program.uniform_Variable (named => texture_uniform_Name);
            the_Textures (Id).   fade_Uniform := the_Program.uniform_Variable (named =>    fade_uniform_Name);
         end;
      end loop;

      the_texture_count_Uniform := the_Program.uniform_Variable ("texture_Count");
   end create_Program;




   function new_Geometry return View
   is
      use type openGL.Program.lit.view;

      Self : constant View := new Geometry.lit_textured.item;
   begin
      Tasks.check;

      if the_Program = null
      then
         create_Program;     -- Define the shaders and program.
      end if;


      Self.Program_is (the_Program.all'Access);
      return Self;
   end new_Geometry;




   ----------
   --  Vertex
   --

   function is_Transparent (Self : in Vertex_array) return Boolean     -- TODO: Do these properly.
   is
      pragma Unreferenced (Self);
   begin
      return False;
   end is_Transparent;



   function is_Transparent (Self : in Vertex_large_array) return Boolean
   is
      pragma Unreferenced (Self);
   begin
      return False;
   end is_Transparent;




   --------------
   --  Attributes
   --

   package openGL_Buffer_of_geometry_Vertices       is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                           Index         => Index_t,
                                                                           Element       => Vertex,
                                                                           Element_Array => Vertex_array);

   package openGL_large_Buffer_of_geometry_Vertices is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                           Index         => long_Index_t,
                                                                           Element       => Vertex,
                                                                           Element_Array => Vertex_large_array);


   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL_Buffer_of_geometry_Vertices.Forge;
   begin
      Self.Vertices       := new openGL_Buffer_of_geometry_Vertices.Object' (to_Buffer (Now,
                                                                                        usage => Buffer.static_Draw));
      Self.is_Transparent := is_Transparent (Now);

      -- Set the bounds.
      --
      declare
         function get_Site (Index : in Index_t) return Vector_3
         is (Now (Index).Site);

         function bounding_Box is new get_Bounds (Index_t, get_Site);
      begin
         Self.Bounds_are (bounding_Box (Count => Now'Length));
      end;
   end Vertices_are;




   procedure Vertices_are (Self : in out Item;   Now : in Vertex_large_array)
   is
      use openGL_large_Buffer_of_geometry_Vertices.Forge;
   begin
      Self.Vertices       := new openGL_large_Buffer_of_geometry_Vertices.Object' (to_Buffer (Now,
                                                                                   usage => Buffer.static_Draw));
      Self.is_Transparent := is_Transparent (Now);

      -- Set the bounds.
      --
      declare
         function get_Site (Index : in long_Index_t) return Vector_3
         is (Now (Index).Site);

         function bounding_Box is new get_Bounds (long_Index_t, get_Site);
      begin
         Self.Bounds_are (bounding_Box (Count => Now'Length));
      end;
   end Vertices_are;




   overriding
   procedure Indices_are  (Self : in out Item;   Now       : in Indices;
                                                 for_Facia : in Positive)
   is
   begin
      raise Error with "TODO";
   end Indices_are;





   --- Texturing
   --

   procedure Fade_is (Self : in out Item;   Which : texture_ID;   Now : in texturing.fade_Level)
   is
   begin
      Self.texture_Set.Textures (which).Fade := Now;
   end Fade_is;



   function Fade (Self : in     Item;   Which : texturing.texture_ID)     return texturing.fade_Level
   is
   begin
      return Self.texture_Set.Textures (which).Fade;
   end Fade;



   procedure Texture_is (Self : in out Item;   Which : texture_ID;   Now : in openGL.Texture.Object)
   is
   begin
      Texture_is (in_Set => Self.texture_Set,
                  Which  => Which,
                  Now    => Now);
   end Texture_is;



   function Texture (Self : in Item;   Which : texture_ID) return openGL.Texture.Object
   is
   begin
      return openGL.texturing.Texture (in_Set => Self.texture_Set,
                                       Which  => Which);
   end Texture;



   overriding
   procedure Texture_is (Self : in out Item;   Now : in openGL.Texture.Object)
   is
   begin
      Texture_is (in_Set => Self.texture_Set,
                  Now    => Now);
   end Texture_is;



   overriding
   function Texture (Self : in Item) return openGL.Texture.Object
   is
   begin
      return texturing.Texture (in_Set => Self.texture_Set,
                                Which  => 1);
   end Texture;




   use GL,
       GL.Binding;

   use type GL.GLint;

   type texture_Units is array (texture_Id) of GLenum;

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


   overriding
   procedure enable_Texture (Self : in out Item)
   is
   begin
      for i in 1 .. texture_Id (Self.Model.texture_Count)
      loop
         the_Textures (i).fade_Uniform.Value_is (Real (Self.Model.Fade (i)));

         glUniform1i     (the_Textures (i).texture_Uniform.gl_Variable,
                          GLint (i) - 1);
         glActiveTexture (all_texture_Units (i));
         glBindTexture   (GL_TEXTURE_2D,
                          Self.texture_Set.Textures (i).Object.Name);
      end loop;

      the_texture_count_Uniform.Value_is (Self.texture_Set.Count);
   end enable_Texture;


end openGL.Geometry.lit_textured;
