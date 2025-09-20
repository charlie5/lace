with
     openGL.Buffer.general,
     openGL.Shader,
     openGL.Program,
     openGL.Attribute,
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

   vertex_Shader   : aliased Shader.item;
   fragment_Shader : aliased Shader.item;

   the_Program     : openGL.Program.view;

   Name_1 : constant String := "Site";
   Name_2 : constant String := "Coords";

   Attribute_1_Name : aliased C.char_array := C.to_C (Name_1);
   Attribute_2_Name : aliased C.char_array := C.to_C (Name_2);

   Attribute_1_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_1_Name'Access);
   Attribute_2_Name_ptr : aliased constant C.strings.chars_ptr := C.strings.to_chars_ptr (Attribute_2_Name'Access);


   ---------
   --  Forge
   --

   function new_Geometry return View
   is
      use type openGL.Program.view;

      Self : constant View := new Geometry.textured.item;

   begin
      Tasks.check;

      if the_Program = null
      then   -- Define the shaders and program.
         declare
            use Attribute.Forge,
                system.Storage_Elements;

            Sample : Vertex;

            Attribute_1 : Attribute.view;
            Attribute_2 : Attribute.view;

         begin
            vertex_Shader  .define (Shader.vertex,   "assets/opengl/shader/textured.vert");
            fragment_Shader.define (Shader.Fragment, (asset_Names' (1 => to_Asset ("assets/opengl/shader/version.header"),
                                                                    2 => to_Asset ("assets/opengl/shader/texturing-frag.snippet"),
                                                                    3 => to_Asset ("assets/opengl/shader/textured.frag"))));
            the_Program := new openGL.Program.item;

            the_Program.define (  vertex_Shader'Access,
                                fragment_Shader'Access);
            the_Program.enable;

            Attribute_1 := new_Attribute (Name        => Name_1,
                                          gl_Location => the_Program.attribute_Location (Name_1),
                                          Size        => 3,
                                          data_Kind   => Attribute.GL_FLOAT,
                                          Stride      => textured.Vertex'Size / 8,
                                          Offset      => 0,
                                          Normalized  => False);

            Attribute_2 := new_Attribute (Name        => Name_2,
                                          gl_Location => the_Program.attribute_Location (Name_2),
                                          Size        => 2,
                                          data_Kind   => attribute.GL_FLOAT,
                                          Stride      => textured.Vertex'Size / 8,
                                          Offset      =>   Sample.Coords.S'Address
                                                         - Sample.Site (1)'Address,
                                          Normalized  => False);
            the_Program.add (Attribute_1);
            the_Program.add (Attribute_2);

            glBindAttribLocation (program => the_Program.gl_Program,
                                  index   => the_Program.Attribute (named => Name_1).gl_Location,
                                  name    => +Attribute_1_Name_ptr);

            glBindAttribLocation (program => the_Program.gl_Program,
                                  index   => the_Program.Attribute (named => Name_2).gl_Location,
                                  name    => +Attribute_2_Name_ptr);

            textured_Geometry.create_Uniforms (for_Program => the_Program.all'Access);
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


   package openGL_Buffer_of_geometry_Vertices is new Buffer.general (base_Object   => Buffer.array_Object,
                                                                     Index         => Index_t,
                                                                     Element       => Vertex,
                                                                     Element_Array => Vertex_array);


   procedure Vertices_are (Self : in out Item;   Now : in Vertex_array)
   is
      use openGL_Buffer_of_geometry_Vertices.Forge;
   begin
      Self.Vertices := new openGL_Buffer_of_geometry_Vertices.Object' (to_Buffer (Now,
                                                                                  usage => Buffer.static_Draw));
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



   overriding
   procedure Indices_are  (Self : in out Item;   Now       : in Indices;
                                                 for_Facia : in Positive)
   is
   begin
      raise Error with "opengl geometry textured - 'Indices_are' ~ TODO";
   end Indices_are;


end openGL.Geometry.textured;
