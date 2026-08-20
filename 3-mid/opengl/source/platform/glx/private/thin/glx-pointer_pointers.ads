with
     glx.Pointers;


package GLX.Pointer_Pointers
is
   use glx.Pointers;

   type VisualID_pointer_pointer    is access all VisualID_pointer;
   type XVisualInfo_pointer_pointer is access all XVisualInfo_pointer;
   type Pixmap_pointer_pointer      is access all Pixmap_pointer;
   type Font_pointer_pointer        is access all Font_pointer;
   type Window_pointer_pointer      is access all Window_pointer;
   type Bool_pointer_pointer        is access all Bool_pointer;
   type ContextRec_pointer_pointer  is access all ContextRec_pointer;
   type XID_pointer_pointer         is access all XID_pointer;
   type GLXPixmap_pointer_pointer   is access all GLXPixmap_pointer;
   type Drawable_pointer_pointer    is access all Drawable_pointer;
   type FBConfig_pointer_pointer    is access all FBConfig_pointer;
   type FBConfigID_pointer_pointer  is access all FBConfigID_pointer;
   type ContextID_pointer_pointer   is access all ContextID_pointer;
   type GLXWindow_pointer_pointer   is access all Window_pointer;
   type PBuffer_pointer_pointer     is access all PBuffer_pointer;


end GLX.Pointer_Pointers;
