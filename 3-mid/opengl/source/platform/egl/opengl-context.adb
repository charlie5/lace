with
     opengl.Display        .privvy,
     opengl.surface_Profile.privvy,
     opengl.Surface        .privvy,
     opengl.API,

     egl.Binding,
     ada.Text_IO,
     System;


package body openGL.Context
is
   use
        egl.Binding,
        System;


   procedure define (Self : in out Item;   the_Display         : access opengl.Display.item'Class;
                                           the_surface_Profile : in     opengl.surface_Profile.item)
   is
      use
           EGL,
           opengl.Display        .privvy,
           opengl.surface_Profile.privvy;

      contextAttribs : EGLint_array := (case API.Current
                                        is
                                           when API.desktop_GL => [EGL_NONE],                              -- The driver provides its
                                           when API.GLES       => [EGL_CONTEXT_CLIENT_VERSION, 3,          -- highest compatible version.
                                                                   EGL_NONE]);
   begin
      Display.bind_client_API;
      --
      -- The bound API is per-task and decides the kind of context created, so it
      -- must be bound here, in the task which creates and uses the context.

      Self.egl_Context := eglCreateContext (to_eGL (the_Display.all),
                                            to_eGL (the_surface_Profile),
                                            EGL_NO_CONTEXT,
                                            contextAttribs (contextAttribs'First)'unchecked_Access);
      if Self.egl_Context = EGL_NO_CONTEXT
      then
         raise opengl.Error with "Unable to create an EGL Context.";
      else
         ada.Text_IO.put_Line ("Created a new eGL context.");
      end if;

      Self.Display := the_Display;
   end define;



   procedure make_Current (Self : in Item;   read_Surface  : in opengl.Surface.item;
                                             write_Surface : in opengl.Surface.item)
   is
      use
           eGL,
           opengl.Display.privvy,
           opengl.Surface.privvy;

      use type EGLBoolean;

      Success : constant EGLBoolean := eGLmakeCurrent (to_eGL (Self.Display.all),
                                                       to_eGL (read_Surface),
                                                       to_eGL (write_Surface),
                                                       Self.egl_Context);
   begin
      if Success = EGL_FALSE
      then
         raise openGL.Error with "unable to make egl Context current";
      end if;
   end make_Current;



   function egl_Context_debug (Self : in Item'Class) return egl.EGLConfig
   is
   begin
      return Self.egl_Context;
   end egl_Context_debug;


end openGL.Context;
