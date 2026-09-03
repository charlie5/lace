with
     openGL.API,
     openGL.Buffer.general,
     openGL.Shader,
     openGL.Program.lit,
     openGL.Attribute,
     openGL.Tasks,
     openGL.Errors,

     GL.lean,
     GL.Pointers,

     interfaces.C.Strings,
     System.storage_Elements;


package body openGL.Geometry.lit_textured
is
   use
        GL.lean,
        GL.Pointers,
        Interfaces;


   -----------
   --- Globals
   --

   vertex_Shader        : aliased Shader.item;
   fragment_Shader      : aliased Shader.item;

   the_Program          :          openGL.Program.lit.view;
   the_Uniforms         :          texturing.Uniforms_view;

   Name_1               : constant String := "Site";
   Name_2               : constant String := "Normal";
   Name_3               : constant String := "Coords";
   Name_4               : constant String := "Shine";

   Attribute_1_Name     : aliased C.char_array := C.to_C (Name_1);
   Attribute_2_Name     : aliased C.char_array := C.to_C (Name_2);
   Attribute_3_Name     : aliased C.char_array := C.to_C (Name_3);
   Attribute_4_Name     : aliased C.char_array := C.to_C (Name_4);

   attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);
   attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);
   attribute_3_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_3_Name'Access);
   attribute_4_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_4_Name'Access);


   ---------
   --- Forge
   --

   procedure create_Program
   is
      use
           Attribute.Forge,
           System.storage_Elements;

      use type system.Address;

      Sample : Vertex;

      Attribute_1 : Attribute.view;
      Attribute_2 : Attribute.view;
      Attribute_3 : Attribute.view;
      Attribute_4 : Attribute.view;

   begin
      vertex_Shader  .define (Shader.Vertex,   API.shader_Folder & "lit_textured.vert");
      fragment_Shader.define (Shader.Fragment, (asset_Names' (1 => to_Asset (API.shader_Folder & "version.header"),
                                                              2 => to_Asset (API.shader_Folder & "texturing-frag.snippet"),
                                                              3 => to_Asset (API.shader_Folder & "lighting-frag.snippet"),
                                                              4 => to_Asset (API.shader_Folder & "lit_textured.frag"))));
      the_Program := new openGL.Program.lit.item;
      the_Program.define (vertex_Shader  'Access,
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
                            name    => +attribute_1_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_2).gl_Location,
                            name    => +attribute_2_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_3).gl_Location,
                            name    => +attribute_3_Name_ptr);
      Errors.log;

      glBindAttribLocation (program =>  the_Program.gl_Program,
                            index   =>  the_Program.Attribute (named => Name_4).gl_Location,
                            name    => +attribute_4_Name_ptr);
      Errors.log;

      the_Uniforms := texturing.new_Uniforms (for_Program => the_Program.all'Access);
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


      Self.Program_is  (the_Program.all'Access);
      Self.Uniforms_are (the_Uniforms);
      return Self;
   end new_Geometry;


   ----------
   --- Vertex
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
   --- Attributes
   --

   package openGL_Buffer_of_geometry_Vertices       is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                           Index         => Index_t,
                                                                           Element       => Vertex,
                                                                           Element_array => Vertex_array);

   package openGL_large_Buffer_of_geometry_Vertices is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                           Index         => long_Index_t,
                                                                           Element       => Vertex,
                                                                           Element_array => Vertex_large_array);


   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL_Buffer_of_geometry_Vertices.Forge;
   begin
      Buffer.free (Self.Vertices);
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
      Buffer.free (Self.Vertices);
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


end openGL.Geometry.lit_textured;
