with
     openGL.Shader,
     openGL.Program.colored,
     openGL.Tasks,
     openGL.Buffer.general,
     openGL.Attribute,

     GL.lean,
     GL.Pointers,

     Interfaces.C.Strings,
     System.storage_Elements;


package body openGL.Geometry.colored
is
   use GL.lean, GL.Pointers;
   use Interfaces;


   -----------
   --  Globals
   --

   the_vertex_Shader    : aliased openGL.Shader.item;
   the_fragment_Shader  : aliased openGL.Shader.item;
   the_Program          :         openGL.Program.colored.view;

   Attribute_1_Name     : aliased C.char_array        := "aSite";
   Attribute_1_Name_ptr : aliased constant
                                  C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);

   Attribute_2_Name     : aliased C.char_array        := "aColor";
   Attribute_2_Name_ptr : aliased constant
                                  C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);


   ---------
   --  Forge
   --

   type colored_Geometry_view is access all Geometry.colored.item'class;

   function new_Geometry return access Geometry.colored.item'class
   is
      use      System.storage_Elements;
      use type openGL.Program.colored.view;

      check_is_OK : constant Boolean               :=     openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      Self        : constant colored_Geometry_view := new Geometry.colored.item;
   begin
      if the_Program = null
      then   -- Define the shaders and program.
         declare
            sample_Vertex : Vertex;

            Attribute_1   : openGL.Attribute.view;
            Attribute_2   : openGL.Attribute.view;
         begin
            the_vertex_Shader  .define (openGL.Shader.Vertex,   "assets/opengl/shader/colored.vert");
            the_fragment_Shader.define (openGL.Shader.Fragment, "assets/opengl/shader/colored.frag");

            the_Program := new openGL.Program.colored.item;
            the_Program.define (the_vertex_Shader  'Access,
                                the_fragment_Shader'Access);

            Attribute_1 := attribute.Forge.new_Attribute (name        => "aSite",
                                                          gl_location => the_Program.attribute_Location ("aSite"),
                                                          size        => 3,
                                                          data_kind   => attribute.GL_FLOAT,
                                                          stride      => colored.Vertex'Size / 8,
                                                          offset       => 0,
                                                          normalized  => False);

            Attribute_2 := attribute.Forge.new_Attribute (name        => "aColor",
                                                          gl_location => the_Program.attribute_Location ("aColor"),
                                                          size        => 4,
                                                          data_kind   => attribute.GL_UNSIGNED_BYTE,
                                                          stride      => colored.Vertex'Size / 8,
                                                          offset       =>   sample_Vertex.Color.Primary.Red'Address
                                                                          - sample_Vertex.Site (1)         'Address,
                                                          normalized  => True);
            the_Program.add (Attribute_1);
            the_Program.add (Attribute_2);

            glBindAttribLocation (program =>  the_Program.gl_Program,
                                  index   =>  the_Program.Attribute (named => "aSite").gl_Location,
                                  name    => +Attribute_1_Name_ptr);

            glBindAttribLocation (program =>  the_Program.gl_Program,
                                  index   =>  the_Program.Attribute (named => "aColor").gl_Location,
                                  name    => +Attribute_2_Name_ptr);
         end;
      end if;

      Self.Program_is (openGL.Program.view (the_Program));

      return Self;
   end new_Geometry;


   ----------
   --  Vertex
   --

   function is_Transparent (Self : in Vertex_array) return Boolean
   is
      function get_Color (Index : in Index_t) return lucid_Color
      is (Self (Index).Color);

      function my_Transparency is new get_Transparency (any_Index_t => Index_t,
                                                        get_Color   => get_Color);
   begin
      return my_Transparency (count => Self'Length);
   end is_Transparent;


   --------------
   --  Attributes
   --

   package openGL_Buffer_of_geometry_Vertices is new openGL.Buffer.general (base_object   => openGL.Buffer.array_Object,
                                                                            index         => Index_t,
                                                                            element       => Vertex,
                                                                            element_array => Vertex_array);

   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL.Buffer,
          openGL_Buffer_of_geometry_Vertices;
   begin
      free (Self.Vertices);
      Self.Vertices := new openGL_Buffer_of_geometry_Vertices.Object' (to_Buffer (Now,
                                                                                  usage => openGL.buffer.static_Draw));
      Self.is_Transparent := is_Transparent (Now);

      -- Set the bounds.
      --
      declare
         function get_Site (Index : in Index_t) return Vector_3
         is (Now (Index).Site);

         function bBox is new get_Bounds (Index_t, get_Site);
      begin
         Self.Bounds_are (bBox (count => Now'Length));
      end;
   end Vertices_are;


end openGL.Geometry.colored;
