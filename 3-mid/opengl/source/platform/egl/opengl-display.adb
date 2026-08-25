with eGL.Binding,
     eGL.Pointers,

     openGL.API,

     ada.unchecked_Conversion,
     System;


package body openGL.Display
is
   use
        eGL,
        eGL.Binding,
        eGL.Pointers;


   procedure bind_client_API
   is
      use type eGL.EGLBoolean;

      Status : constant EGLBoolean := eglBindAPI (case API.Current
                                                  is
                                                     when API.desktop_GL => EGL_OPENGL_API,
                                                     when API.GLES       => EGL_OPENGL_ES_API);
   begin
      if Status = egl_False
      then
         raise openGL.Error with "Failed to bind the " & API.Current'Image & " client API with eGL.";
      end if;
   end bind_client_API;


   function open (native_Display : in eGL.Pointers.Display_pointer) return Item
   is
      use type System.Address,  eGL.EGLBoolean;

      the_Display : Display.item;
      Success     : EGLBoolean;

   begin
      the_Display.Thin := eglGetDisplay (native_Display);

      if the_Display.Thin = egl_NO_DISPLAY
      then
         raise openGL.Error with "Failed to open the Display with eGL.";
      end if;


      Success := eglInitialize (the_Display.Thin, the_Display.Version_major'unchecked_Access,
                                                  the_Display.Version_minor'unchecked_Access);
      if Success = egl_False
      then
         raise openGL.Error with "Failed to initialise eGL using the Display.";
      end if;

      bind_client_API;

      return the_Display;
   end open;



   function Default return Item
   is
   begin
      return open (Display_pointer (EGL_DEFAULT_DISPLAY));
   end Default;



   function from_Native (native_Display : in System.Address) return Item
   is
      function to_Display_pointer is new ada.unchecked_Conversion (System.Address,
                                                                   eGL.Pointers.Display_pointer);
   begin
      return open (to_Display_pointer (native_Display));
   end from_Native;


end openGL.Display;
