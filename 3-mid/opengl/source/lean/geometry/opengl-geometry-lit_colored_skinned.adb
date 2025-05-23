with
     openGL.Shader,
     openGL.Attribute,
     openGL.Buffer.general,
     openGL.Texture,
     openGL.Tasks,
     openGL.Errors,

     GL.lean,
     GL.Pointers,

     Interfaces.C.Strings,
     System.storage_Elements;


package body openGL.Geometry.lit_colored_skinned
is
   --  Globals
   --
   vertex_Shader   : aliased Shader.item;
   fragment_Shader : aliased Shader.item;

   the_Program     : aliased openGL.Program.lit.colored_skinned.item;
   is_Defined      :         Boolean := False;

   Name_1 : constant String := "Site";
   Name_2 : constant String := "Normal";
   Name_3 : constant String := "Color";
   Name_4 : constant String := "Shine";
   Name_5 : constant String := "bone_Ids";
   Name_6 : constant String := "bone_Weights";

   use Interfaces;

   Attribute_1_Name : aliased C.char_array := C.to_C (Name_1);
   Attribute_2_Name : aliased C.char_array := C.to_C (Name_2);
   Attribute_3_Name : aliased C.char_array := C.to_C (Name_3);
   Attribute_4_Name : aliased C.char_array := C.to_C (Name_4);
   Attribute_5_Name : aliased C.char_array := C.to_C (Name_5);
   Attribute_6_Name : aliased C.char_array := C.to_C (Name_6);

   Attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);
   Attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);
   Attribute_3_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_3_Name'Access);
   Attribute_4_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_4_Name'Access);
   Attribute_5_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_5_Name'Access);
   Attribute_6_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_6_Name'Access);


   ----------
   --  Vertex
   --

   function is_Transparent (Self : in Vertex_array) return Boolean   -- TODO: Replace this with the generic (check that all similar functions use the generic).
   is
      use type color_Value;
   begin
      for Each in Self'Range
      loop
         if Self (Each).Color.Alpha /= opaque_Value
         then
            return True;
         end if;
      end loop;

      return False;
   end is_Transparent;


   ---------
   --  Forge
   --

   function new_Geometry return Geometry.lit_colored_skinned.view
   is
      Self : constant Geometry.lit_colored_skinned.view := new Geometry.lit_colored_skinned.item;
   begin
      Self.Program_is (the_Program'Access);
      return Self;
   end new_Geometry;



   procedure define_Program
   is
      use Attribute.Forge,
          GL.lean,
          GL.Pointers,
          System.storage_Elements;

      Sample : Vertex;

      Attribute_1 : openGL.Attribute.view;
      Attribute_2 : openGL.Attribute.view;
      Attribute_3 : openGL.Attribute.view;
      Attribute_4 : openGL.Attribute.view;
      Attribute_5 : openGL.Attribute.view;
      Attribute_6 : openGL.Attribute.view;

   begin
      Tasks.check;

      if is_Defined
      then
         raise Error with "The 'lit_colored_textured_skinned' program has already been defined.";
      end if;

      is_Defined := True;

      -- Define the shaders and program.
      --
      vertex_Shader  .define (Shader.Vertex,   "assets/opengl/shader/lit_colored_skinned.vert");
      fragment_Shader.define (Shader.Fragment, (asset_Names' (1 => to_Asset ("assets/opengl/shader/version.header"),
                                                              2 => to_Asset ("assets/opengl/shader/lighting-frag.snippet"),
                                                              3 => to_Asset ("assets/opengl/shader/lit_colored.frag"))));
      the_Program.define (  vertex_Shader'Access,
                          fragment_Shader'Access);
      the_Program.enable;

      Attribute_1 := new_Attribute (Name        => Name_1,
                                    gl_Location => the_Program.attribute_Location (Name_1),
                                    Size        => 3,
                                    data_Kind   => Attribute.GL_FLOAT,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      => 0,
                                    Normalized  => False);

      Attribute_2 := new_Attribute (Name        => Name_2,
                                    gl_Location => the_Program.attribute_Location (Name_2),
                                    Size        => 3,
                                    data_Kind   => Attribute.GL_FLOAT,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      =>   Sample.Normal (1)'Address
                                                   - Sample.Site   (1)'Address,
                                    Normalized  => False);

      Attribute_3 := new_Attribute (Name        => Name_3,
                                    gl_Location => the_Program.attribute_Location (Name_3),
                                    Size        => 4,
                                    data_Kind   => Attribute.GL_UNSIGNED_BYTE,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      =>   Sample.Color.Primary.Red'Address
                                                   - Sample.Site (1)         'Address,
                                    Normalized  => True);

      Attribute_4 := new_Attribute (Name        => Name_4,
                                    gl_Location => the_Program.attribute_Location (Name_4),
                                    Size        => 4,
                                    data_Kind   => Attribute.GL_FLOAT,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      =>   Sample.Shine'Address
                                                   - Sample.Site (1)'Address,
                                    Normalized  => False);

      Attribute_5 := new_Attribute (Name        => Name_5,
                                    gl_Location => the_Program.attribute_Location (Name_5),
                                    Size        => 4,
                                    data_Kind   => Attribute.GL_FLOAT,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      =>   Sample.bone_Ids (1)'Address
                                                   - Sample.Site (1)'Address,
                                    Normalized  => False);

      Attribute_6 := new_Attribute (Name        => Name_6,
                                    gl_Location => the_Program.attribute_Location (Name_6),
                                    Size        => 4,
                                    data_Kind   => Attribute.GL_FLOAT,
                                    Stride      => lit_colored_skinned.Vertex'Size / 8,
                                    Offset      =>   Sample.bone_Weights (1)'Address
                                                   - Sample.Site (1)'Address,
                                    Normalized  => False);
      the_Program.add (Attribute_1);
      the_Program.add (Attribute_2);
      the_Program.add (Attribute_3);
      the_Program.add (Attribute_4);
      the_Program.add (Attribute_5);
      the_Program.add (Attribute_6);

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_1).gl_Location,
                            name    => +Attribute_1_Name_ptr);
      Errors.log;

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_2).gl_Location,
                            name    => +Attribute_2_Name_ptr);
      Errors.log;

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_3).gl_Location,
                            name    => +Attribute_3_Name_ptr);
      Errors.log;

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_4).gl_Location,
                            name    => +Attribute_4_Name_ptr);
      Errors.log;

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_5).gl_Location,
                            name    => +Attribute_5_Name_ptr);
      Errors.log;

      glBindAttribLocation (program => the_Program.gl_Program,
                            index   => the_Program.Attribute (named => Name_6).gl_Location,
                            name    => +Attribute_6_Name_ptr);
      Errors.log;

   end define_Program;


   --------------
   --  Attributes
   --

   function Program return openGL.Program.lit.colored_skinned.view
   is
   begin
      return the_Program'Access;
   end Program;



   overriding
   procedure Indices_are  (Self : in out Item;   Now       : in Indices;
                                                 for_Facia : in Positive)
   is
   begin
      raise Error with "openGL.Geometry.lit_coloured_textured_skinned - 'Indices_are' ~ TODO";
   end Indices_are;



   package openGL_Buffer_of_geometry_Vertices is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                     Index         => long_Index_t,
                                                                     Element       => Vertex,
                                                                     Element_Array => Vertex_array);

   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL_Buffer_of_geometry_Vertices.Forge;
   begin
      Self.Vertices       := new openGL_Buffer_of_geometry_Vertices.object' (to_Buffer (Now,
                                                                                        usage => Buffer.static_Draw));
      Self.is_Transparent :=    Self.is_Transparent
                             or is_Transparent (Now);
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
   procedure enable_Textures (Self : in out Item)
   is
   begin
      null;
   end enable_Textures;


end openGL.Geometry.lit_colored_skinned;
