package GLX.Pointers
is

   --- VisualID_pointer
   --

   type VisualID_pointer  is access all VisualID;
   type VisualID_pointers is array (C.size_t range <>) of aliased VisualID_pointer;


   --- XVisualInfo_pointer
   --

   type XVisualInfo_pointer is access all XVisualInfo;
   type XVisualInfo_pointers is array (C.size_t range <>) of aliased XVisualInfo_pointer;


   --- Pixmap_pointer
   --

   type Pixmap_pointer  is access all Pixmap;
   type Pixmap_pointers is array (C.size_t range <>) of aliased Pixmap_pointer;


   --- Font_pointer
   --

   type Font_pointer  is access all Font;
   type Font_pointers is array (C.size_t range <>) of aliased Font_pointer;


   --- Window_pointer
   --

   type Window_pointer  is access all Window;
   type Window_pointers is array (C.size_t range <>) of aliased Window_pointer;


   --- Bool_pointer
   --

   type Bool_pointer  is access all Bool;
   type Bool_pointers is array (C.size_t range <>) of aliased Bool_pointer;


   --- ContextRec_pointer
   --

   type ContextRec_pointer  is access all ContextRec;
   type ContextRec_pointers is array (C.size_t range <>) of aliased ContextRec_pointer;


   --- XID_pointer
   --

   type XID_pointer  is access all XID;
   type XID_pointers is array (C.size_t range <>) of aliased XID_pointer;


   --- GLXPixmap_pointer
   --

   type GLXPixmap_pointer  is access all GLXPixmap;
   type GLXPixmap_pointers is array (C.size_t range <>) of aliased GLXPixmap_pointer;


   --- Drawable_pointer
   --

   type Drawable_pointer  is access all Drawable;
   type Drawable_pointers is array (C.size_t range <>) of aliased Drawable_pointer;


   --- FBConfig_pointer
   --

   type FBConfig_pointer  is access all FBConfig;
   type FBConfig_pointers is array (C.size_t range <>) of aliased FBConfig_pointer;


   --- GLXFBConfigID_pointer
   --

   type FBConfigID_pointer  is access all FBConfigID;
   type FBConfigID_pointers is array (C.size_t range <>) of aliased FBConfigID_pointer;


   --- GLXContextID_pointer
   --

   type ContextID_pointer  is access all ContextID;
   type ContextID_pointers is array (C.size_t range <>) of aliased ContextID_pointer;


   --- GLXWindow_pointer
   --

   type GLXWindow_pointer  is access all GLXWindow;
   type GLXWindow_pointers is array (C.size_t range <>) of aliased GLXWindow_pointer;


   --- PBuffer_pointer
   --

   type PBuffer_pointer  is access all PBuffer;
   type PBuffer_pointers is array (C.size_t range <>) of aliased PBuffer_pointer;


end GLX.Pointers;
