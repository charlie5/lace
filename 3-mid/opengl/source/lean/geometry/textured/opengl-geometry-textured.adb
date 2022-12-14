with
     openGL.Buffer.general,
     openGL.Shader,
     openGL.Program.textured,
     openGL.Palette,
     openGL.Attribute,
     openGL.Texture,
     openGL.Tasks,

     GL.lean,
     GL.Pointers,

     System,
     Interfaces.C.Strings,
     System.storage_Elements;


package body openGL.Geometry.textured
is
   use GL.lean,
       GL.Pointers,

       Interfaces,
       System;

   -----------
   --  Globals
   --
   the_vertex_Shader    : aliased          openGL.Shader.item;
   the_fragment_Shader  : aliased          openGL.Shader.item;

   the_Program          :                  openGL.Program.textured.view;
   white_Texture        :                  openGL.Texture.Object;

   Attribute_1_Name     : aliased          C.char_array        := "aSite";
   Attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);

   Attribute_2_Name     : aliased          C.char_array        := "aCoords";
   Attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);


   ---------
   --  Forge
   --

   type Geometry_view is access all Geometry.textured.item'class;

   function new_Geometry return access Geometry.textured.item'class
   is
      use type openGL.Program.textured.view;

      check_is_OK : constant Boolean       :=     openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      Self        : constant Geometry_view := new Geometry.textured.item;

   begin
      if the_Program = null
      then   -- Define the shaders and program.
         declare
            use openGL.Palette,
                system.Storage_Elements;

            sample_Vertex : Vertex;

            Attribute_1   : openGL.Attribute.view;
            Attribute_2   : openGL.Attribute.view;

            white_Image   : constant openGL.Image := (1 .. 2 => (1 .. 2 => White));

         begin
            white_Texture := openGL.Texture.to_Texture (white_Image);

            the_vertex_Shader  .define (openGL.Shader.Vertex,   "assets/opengl/shader/textured.vert");
            the_fragment_Shader.define (openGL.Shader.Fragment, "assets/opengl/shader/textured.frag");

            the_Program := new openGL.Program.textured.item;

            the_Program.define (the_vertex_Shader  'Access,
                                the_fragment_Shader'Access);
            the_Program.enable;

            Attribute_1 := attribute.Forge.new_Attribute (name        => "aSite",
                                                          gl_location => the_Program.attribute_Location ("aSite"),
                                                          size        => 3,
                                                          data_kind   => attribute.GL_FLOAT,
                                                          stride      => textured.Vertex'Size / 8,
                                                          offset      => 0,
                                                          normalized  => False);

            Attribute_2 := attribute.Forge.new_Attribute (name        => "aCoords",
                                                          gl_location => the_Program.attribute_Location ("aCoords"),
                                                          size        => 2,
                                                          data_kind   => attribute.GL_FLOAT,
                                                          stride      => textured.Vertex'Size / 8,
                                                          offset      =>   sample_Vertex.Coords.S'Address
                                                                         - sample_Vertex.Site (1)'Address,
                                                          normalized  => False);
            the_Program.add (Attribute_1);
            the_Program.add (Attribute_2);

            glBindAttribLocation (program => the_Program.gl_Program,
                                  index   => the_Program.Attribute (named => "aSite").gl_Location,
                                  name    => +Attribute_1_Name_ptr);

            glBindAttribLocation (program => the_Program.gl_Program,
                                  index   => the_Program.Attribute (named => "aCoords").gl_Location,
                                  name    => +Attribute_2_Name_ptr);
         end;
      end if;

      Self.Program_is (the_Program.all'Access);
      return Self;
   end new_Geometry;


   --------------
   --  Attributes
   --

   overriding
   function is_Transparent (Self : in Item) return Boolean
   is
   begin
      return Self.is_Transparent;
   end is_Transparent;


   package openGL_Buffer_of_geometry_Vertices is new openGL.Buffer.general (base_object   => openGL.Buffer.array_Object,
                                                                            index         => Index_t,
                                                                            element       => Vertex,
                                                                            element_array => Vertex_array);

   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL_Buffer_of_geometry_Vertices;
   begin
      Self.Vertices := new openGL_Buffer_of_geometry_Vertices.Object' (to_Buffer (Now,
                                                                                  usage => openGL.Buffer.static_Draw));
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


   overriding
   procedure Indices_are  (Self : in out Item;   Now       : in Indices;
                                                 for_Facia : in Positive)
   is
   begin
      raise Program_Error with "opengl gemoetry textured - set indices ~ TODO";
   end Indices_are;


   overriding
   procedure enable_Texture (Self : in Item)
   is
      use GL, openGL.Texture;
      check_is_OK : constant Boolean := openGL.Tasks.Check;   pragma Unreferenced (check_is_OK);
   begin
      glActiveTexture (gl.GL_TEXTURE0);

      if Self.Texture = openGL.Texture.null_Object
      then   enable (white_Texture);
      else   enable (Self.Texture);
      end if;
   end enable_Texture;


end openGL.Geometry.textured;
