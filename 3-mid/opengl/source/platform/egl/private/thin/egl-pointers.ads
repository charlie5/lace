package eGL.Pointers
is

   type Display_pointer          is access all eGL.Display;
   type NativeWindowType_pointer is access all eGL.NativeWindowType;
   type NativePixmapType_pointer is access all eGL.NativePixmapType;
   type EGLint_pointer           is access all eGL.EGLint;
   type EGLBoolean_pointer       is access all eGL.EGLBoolean;
   type EGLenum_pointer          is access all eGL.EGLenum;
   type EGLConfig_pointer        is access all eGL.EGLConfig;
   type EGLContext_pointer       is access all eGL.EGLContext;
   type EGLDisplay_pointer       is access all eGL.EGLDisplay;
   type EGLSurface_pointer       is access all eGL.EGLSurface;
   type EGLClientBuffer_pointer  is access all eGL.EGLClientBuffer;

   type Display_pointer_array          is array (C.size_t range <>) of aliased Display_pointer;
   type NativeWindowType_pointer_array is array (C.size_t range <>) of aliased NativeWindowType_pointer;
   type NativePixmapType_pointer_array is array (C.size_t range <>) of aliased NativePixmapType_pointer;
   type EGLint_pointer_array           is array (C.size_t range <>) of aliased EGLint_pointer;
   type EGLBoolean_pointer_array       is array (C.size_t range <>) of aliased EGLBoolean_pointer;
   type EGLenum_pointer_array          is array (C.size_t range <>) of aliased EGLenum_pointer;
   type EGLConfig_pointer_array        is array (C.size_t range <>) of aliased EGLConfig_pointer;
   type EGLContext_pointer_array       is array (C.size_t range <>) of aliased EGLContext_pointer;
   type EGLDisplay_pointer_array       is array (C.size_t range <>) of aliased EGLDisplay_pointer;
   type EGLSurface_pointer_array       is array (C.size_t range <>) of aliased EGLSurface_pointer;
   type EGLClientBuffer_pointer_array  is array (C.size_t range <>) of aliased EGLClientBuffer_pointer;


end eGL.Pointers;
