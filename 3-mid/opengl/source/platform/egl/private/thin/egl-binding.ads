with
     eGL.Pointers,
     eGL.NativeDisplayType,

     interfaces.C.Strings,
     System;


package eGL.Binding
is

   function eglGetError                             return eGL.EGLint;

   function eglGetDisplay (display_id : in eGL.NativeDisplayType.Item) return eGL.EGLDisplay;

   function eglInitialize (dpy   : in eGL.EGLDisplay;
                           major : in eGL.Pointers.EGLint_Pointer;
                           minor : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglTerminate (dpy : in eGL.EGLDisplay)  return eGL.EGLBoolean;

   function eglQueryString (dpy  : in eGL.EGLDisplay;
                            name : in eGL.EGLint) return interfaces.C.Strings.chars_ptr;

   function eglGetConfigs (dpy         : in eGL.EGLDisplay;
                           configs     : in eGL.Pointers.EGLConfig_Pointer;
                           config_size : in eGL.EGLint;
                           num_config  : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglChooseConfig (dpy         : in eGL.EGLDisplay;
                             attrib_list : in eGL.Pointers.EGLint_Pointer;
                             configs     : in eGL.Pointers.EGLConfig_Pointer;
                             config_size : in eGL.EGLint;
                             num_config  : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglGetConfigAttrib (dpy       : in eGL.EGLDisplay;
                                config    : in eGL.EGLConfig;
                                attribute : in eGL.EGLint;
                                value     : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglCreateWindowSurface (dpy         : in eGL.EGLDisplay;
                                    config      : in eGL.EGLConfig;
                                    win         : in eGL.NativeWindowType;
                                    attrib_list : in eGL.Pointers.EGLint_Pointer) return eGL.EGLSurface;

   function eglCreatePbufferSurface (dpy         : in eGL.EGLDisplay;
                                     config      : in eGL.EGLConfig;
                                     attrib_list : in eGL.Pointers.EGLint_Pointer) return eGL.EGLSurface;

   function eglCreatePixmapSurface (dpy         : in eGL.EGLDisplay;
                                    config      : in eGL.EGLConfig;
                                    pixmap      : in eGL.NativePixmapType;
                                    attrib_list : in eGL.Pointers.EGLint_Pointer) return eGL.EGLSurface;

   function eglDestroySurface (dpy     : in eGL.EGLDisplay;
                               surface : in eGL.EGLSurface) return eGL.EGLBoolean;

   function eglQuerySurface (dpy       : in eGL.EGLDisplay;
                             surface   : in eGL.EGLSurface;
                             attribute : in eGL.EGLint;
                             value     : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglBindAPI (api : in eGL.EGLenum)       return eGL.EGLBoolean;

   function eglQueryAPI                             return eGL.EGLenum;

   function eglWaitClient                           return eGL.EGLBoolean;

   function eglReleaseThread                        return eGL.EGLBoolean;

   function eglCreatePbufferFromClientBuffer (dpy         : in eGL.EGLDisplay;
                                              buftype     : in eGL.EGLenum;
                                              buffer      : in eGL.EGLClientBuffer;
                                              config      : in eGL.EGLConfig;
                                              attrib_list : in eGL.Pointers.EGLint_Pointer) return eGL.EGLSurface;

   function eglSurfaceAttrib (dpy       : in eGL.EGLDisplay;
                              surface   : in eGL.EGLSurface;
                              attribute : in eGL.EGLint;
                              value     : in eGL.EGLint) return eGL.EGLBoolean;

   function eglBindTexImage (dpy     : in eGL.EGLDisplay;
                             surface : in eGL.EGLSurface;
                             buffer  : in eGL.EGLint) return eGL.EGLBoolean;

   function eglReleaseTexImage (dpy     : in eGL.EGLDisplay;
                                surface : in eGL.EGLSurface;
                                buffer  : in eGL.EGLint) return eGL.EGLBoolean;

   function eglSwapInterval (dpy      : in eGL.EGLDisplay;
                             interval : in eGL.EGLint)
      return     eGL.EGLBoolean;

   function eglCreateContext (dpy           : in eGL.EGLDisplay;
                              config        : in eGL.EGLConfig;
                              share_context : in eGL.EGLContext;
                              attrib_list   : in eGL.Pointers.EGLint_Pointer) return eGL.EGLContext;

   function eglDestroyContext (dpy : in eGL.EGLDisplay;
                               ctx : in eGL.EGLContext) return eGL.EGLBoolean;

   function eglMakeCurrent (dpy  : in eGL.EGLDisplay;
                            draw : in eGL.EGLSurface;
                            read : in eGL.EGLSurface;
                            ctx  : in eGL.EGLContext) return eGL.EGLBoolean;

   function eglGetCurrentContext                      return eGL.EGLContext;

   function eglGetCurrentSurface (readdraw : in eGL.EGLint) return eGL.EGLSurface;

   function eglGetCurrentDisplay                      return eGL.EGLDisplay;

   function eglQueryContext (dpy       : in eGL.EGLDisplay;
                             ctx       : in eGL.EGLContext;
                             attribute : in eGL.EGLint;
                             value     : in eGL.Pointers.EGLint_Pointer) return eGL.EGLBoolean;

   function eglWaitGL                                 return eGL.EGLBoolean;

   function eglWaitNative (engine : in eGL.EGLint)    return eGL.EGLBoolean;

   function eglSwapBuffers (dpy     : in eGL.EGLDisplay;
                            surface : in eGL.EGLSurface) return eGL.EGLBoolean;

   function eglCopyBuffers (dpy     : in eGL.EGLDisplay;
                            surface : in eGL.EGLSurface;
                            target  : in eGL.NativePixmapType) return eGL.EGLBoolean;

   function eglGetProcAddress (procname : in interfaces.C.Strings.chars_ptr) return void_ptr;


   -- Out-of-band handle values.
   --
   egl_DEFAULT_DISPLAY : constant access eGL.Display;
   egl_NO_CONTEXT      : constant        eGL.EGLContext;
   egl_NO_DISPLAY      : constant        eGL.EGLDisplay;
   egl_NO_SURFACE      : constant        eGL.EGLSurface;

   -- Out-of-band attribute value.
   --
   egl_DONT_CARE       : constant        eGL.EGLint;



private
   use System;

   egl_DEFAULT_DISPLAY : constant access eGL.Display := null;
   egl_NO_CONTEXT      : constant eGL.EGLContext     := null_Address;
   egl_NO_DISPLAY      : constant  eGL.EGLDisplay    := null_Address;
   egl_NO_SURFACE      : constant  eGL.EGLSurface    := null_Address;

   egl_DONT_CARE       : constant  eGL.EGLint := -1;


   pragma import (C, eglGetError,                      "eglGetError");
   pragma import (C, eglGetDisplay,                    "eglGetDisplay");
   pragma import (C, eglInitialize,                    "eglInitialize");
   pragma import (C, eglTerminate,                     "eglTerminate");
   pragma import (C, eglQueryString,                   "eglQueryString");
   pragma import (C, eglGetConfigs,                    "eglGetConfigs");
   pragma import (C, eglChooseConfig,                  "eglChooseConfig");
   pragma import (C, eglGetConfigAttrib,               "eglGetConfigAttrib");
   pragma import (C, eglCreateWindowSurface,           "eglCreateWindowSurface");
   pragma import (C, eglCreatePbufferSurface,          "eglCreatePbufferSurface");
   pragma import (C, eglCreatePixmapSurface,           "eglCreatePixmapSurface");
   pragma import (C, eglDestroySurface,                "eglDestroySurface");
   pragma import (C, eglQuerySurface,                  "eglQuerySurface");
   pragma import (C, eglBindAPI,                       "eglBindAPI");
   pragma import (C, eglQueryAPI,                      "eglQueryAPI");
   pragma import (C, eglWaitClient,                    "eglWaitClient");
   pragma import (C, eglReleaseThread,                 "eglReleaseThread");
   pragma import (C, eglCreatePbufferFromClientBuffer, "eglCreatePbufferFromClientBuffer");
   pragma import (C, eglSurfaceAttrib,                 "eglSurfaceAttrib");
   pragma import (C, eglBindTexImage,                  "eglBindTexImage");
   pragma import (C, eglReleaseTexImage,               "eglReleaseTexImage");
   pragma import (C, eglSwapInterval,                  "eglSwapInterval");
   pragma import (C, eglCreateContext,                 "eglCreateContext");
   pragma import (C, eglDestroyContext,                "eglDestroyContext");
   pragma import (C, eglMakeCurrent,                   "eglMakeCurrent");
   pragma import (C, eglGetCurrentContext,             "eglGetCurrentContext");
   pragma import (C, eglGetCurrentSurface,             "eglGetCurrentSurface");
   pragma import (C, eglGetCurrentDisplay,             "eglGetCurrentDisplay");
   pragma import (C, eglQueryContext,                  "eglQueryContext");
   pragma import (C, eglWaitGL,                        "eglWaitGL");
   pragma import (C, eglWaitNative,                    "eglWaitNative");
   pragma import (C, eglSwapBuffers,                   "eglSwapBuffers");
   pragma import (C, eglCopyBuffers,                   "eglCopyBuffers");
   pragma import (C, eglGetProcAddress,                "eglGetProcAddress");


end eGL.Binding;
