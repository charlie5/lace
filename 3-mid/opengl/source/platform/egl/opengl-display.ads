with
     System;

private
with
     eGL;


package openGL.Display
--
-- Models an openGL display.
--
is
   type Item is tagged private;

   function Default return Item;

   function from_Native (native_Display : in System.Address) return Item;
   --
   -- Opens the display given a native display handle (an Xlib 'Display*' under X11),
   -- so EGL shares the same X connection as the windowing toolkit.


   procedure bind_client_API;
   --
   -- Binds the client API which openGL targets (see 'openGL.API'), for the calling task.
   -- The bound API is per-task and decides the kind of context which is created, so each
   -- task which creates a context must bind it.



private

   type Item is tagged
      record
         Thin          :         eGL.EGLDisplay;
         Version_major,
         Version_minor : aliased eGL.EGLint;
      end record;


end openGL.Display;
