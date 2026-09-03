with
     openGL.Tasks,
     GL.Binding,
     interfaces.C.Strings,
     ada.unchecked_Conversion;


package body openGL.Server
is

   function Version return String
   is
      use
           GL,
           GL.Binding,
           Interfaces;

      check_is_OK : constant Boolean := openGL.Tasks.Check with Unreferenced;

      type GLubyte_pointer  is access all GLubyte;

      function to_chars_ptr is new ada.unchecked_Conversion (GLubyte_pointer,
                                                             c.Strings.chars_ptr);

      the_Version : constant GLubyte_pointer := glGetString (GL_VERSION);
   begin
      if the_Version = null
      then
         raise openGL.Error with "glGetString (GL_VERSION) returned null ~ is an openGL context current ?";
      end if;

      return c.Strings.Value (to_chars_ptr (the_Version));
   end Version;



   function Version return a_Version
   is
      use
           GL,
           GL.Binding;

      check_is_OK : constant Boolean := openGL.Tasks.Check with Unreferenced;

      Major : aliased glInt;
      Minor : aliased glInt;
   begin
      glGetIntegerv (GL_MAJOR_VERSION, Major'Access);
      glGetIntegerv (GL_MINOR_VERSION, Minor'Access);

      return (Major => Integer (Major),
              Minor => Integer (Minor));
   end Version;


end openGL.Server;
