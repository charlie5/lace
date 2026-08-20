with
     glx.Pointers,
     interfaces.C;


package glx.Binding
is
   function  getCurrentContext  return access ContextRec;
   function  getCurrentDrawable return        Drawable;

   procedure waitGL;
   procedure waitX;

   procedure useXFont (Font  : in GLX.Font;
                       First : in C.int;
                       Count : in C.int;
                       List  : in C.int);

   function  getCurrentReadDrawable return Drawable;

   function  get_visualid (Self : in Pointers.XVisualInfo_pointer) return VisualID;



private

   pragma import (C, getCurrentContext,      "glXGetCurrentContext");
   pragma import (C, getCurrentDrawable,     "glXGetCurrentDrawable");
   pragma import (C, waitGL,                 "glXWaitGL");
   pragma import (C, waitX,                  "glXWaitX");
   pragma import (C, useXFont,               "glXUseXFont");
   pragma import (C, getCurrentReadDrawable, "glXGetCurrentReadDrawable");
   pragma import (C, get_visualid,           "Ada_get_visualid");


end glx.Binding;
