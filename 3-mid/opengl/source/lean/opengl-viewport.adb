with
     GL.Binding,
     openGL.Tasks,
     openGL.Errors;


package body openGL.Viewport
is
   use GL;


   function Extent return Extent_2d
   is
      use GL.Binding;
      Extent : array (1 .. 4) of aliased gl.glInt;
   begin
      Tasks.check;
      glGetIntegerv (gl_VIEWPORT,
                     Extent (1)'unchecked_Access);      Errors.log;

      return (Integer (Extent (3)),
              Integer (Extent (4)));
   end Extent;



   procedure Extent_is (Now : in Extent_2d)
   is
      use GL.Binding;
   begin
      Tasks.check;
      glViewport (0, 0,
                  GLint (Now.Width),
                  GLint (Now.Height));      Errors.log;
   end Extent_is;


end openGL.Viewport;
