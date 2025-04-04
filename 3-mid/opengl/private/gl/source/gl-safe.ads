with
     Interfaces.C.Pointers,
     System;


package GL.safe
--
--  Provides types, constants and functions specific to the openGL 'Safety Critical' profile.
--
is
   ---------
   --  Types
   --

   --  GLubyte_Pointer
   --
   package GLubyte_Pointers is new C.Pointers (Index              => C.size_t,
                                               Element            => GLubyte,
                                               Element_Array      => GLubyte_array,
                                               Default_Terminator => 0);
   subtype GLubyte_Pointer  is GLubyte_Pointers.Pointer;


   --  GLint_Pointer
   --
   package GLint_Pointers is new C.Pointers (Index              => C.size_t,
                                             Element            => GLint,
                                             Element_Array      => GLint_array,
                                             Default_Terminator => 0);
   subtype GLint_Pointer  is GLint_Pointers.Pointer;


   --  GLfloat_Pointer
   --
   package GLfloat_Pointers is new C.Pointers (Index              => C.size_t,
                                               Element            => GLfloat,
                                               Element_Array      => GLfloat_array,
                                               Default_Terminator => 0.0);
   subtype GLfloat_Pointer  is GLfloat_Pointers.Pointer;


   --  GLvoid_Pointer
   --
   package GLvoid_Pointers is new C.Pointers (Index              => C.size_t,
                                              Element            => GLvoid,
                                              Element_Array      => GLvoid_array,
                                              Default_Terminator => system.null_Address);
   subtype GLvoid_Pointer  is GLvoid_Pointers.Pointer;


   --  GLvoid_Pointer_Pointer
   --
   type    GLvoid_Pointer_array    is array (C.size_t range <>) of aliased GLvoid_Pointer;
   package GLvoid_Pointer_Pointers is new C.Pointers (Index              => C.size_t,
                                                      Element            => GLvoid_Pointer,
                                                      Element_Array      => GLvoid_Pointer_array,
                                                      Default_Terminator => null);
   subtype GLvoid_Pointer_Pointer  is GLvoid_Pointer_Pointers.Pointer;



   -------------
   --  Constants
   --

   GL_ADD                            : constant := 16#0104#;
   GL_ALPHA_TEST                     : constant := 16#0BC0#;
   GL_ALPHA_TEST_FUNC                : constant := 16#0BC1#;
   GL_ALPHA_TEST_REF                 : constant := 16#0BC2#;
   GL_AMBIENT                        : constant := 16#1200#;
   GL_AMBIENT_AND_DIFFUSE            : constant := 16#1602#;
   GL_BLEND_DST                      : constant := 16#0BE0#;
   GL_BLEND_SRC                      : constant := 16#0BE1#;
   GL_CLIENT_ACTIVE_TEXTURE          : constant := 16#84E1#;
   GL_COLOR                          : constant := 16#1800#;
   GL_COLOR_ARRAY                    : constant := 16#8076#;
   GL_COLOR_ARRAY_POINTER            : constant := 16#8090#;
   GL_COLOR_ARRAY_SIZE               : constant := 16#8081#;
   GL_COLOR_ARRAY_STRIDE             : constant := 16#8083#;
   GL_COLOR_ARRAY_TYPE               : constant := 16#8082#;
   GL_COLOR_INDEX                    : constant := 16#1900#;
   GL_COLOR_INDEX8_EXT               : constant := 16#80E5#;
   GL_COLOR_MATERIAL                 : constant := 16#0B57#;
   GL_COLOR_TABLE_ALPHA_SIZE         : constant := 16#80DD#;
   GL_COLOR_TABLE_BLUE_SIZE          : constant := 16#80DC#;
   GL_COLOR_TABLE_FORMAT             : constant := 16#80D8#;
   GL_COLOR_TABLE_GREEN_SIZE         : constant := 16#80DB#;
   GL_COLOR_TABLE_INTENSITY_SIZE     : constant := 16#80DF#;
   GL_COLOR_TABLE_LUMINANCE_SIZE     : constant := 16#80DE#;
   GL_COLOR_TABLE_RED_Size           : constant := 16#80DA#;
   GL_COLOR_TABLE_WIDTH              : constant := 16#80D9#;
   GL_COMPILE                        : constant := 16#1300#;
   GL_CURRENT_COLOR                  : constant := 16#0B00#;
   GL_CURRENT_NORMAL                 : constant := 16#0B02#;
   GL_CURRENT_RASTER_COLOR           : constant := 16#0B04#;
   GL_CURRENT_RASTER_TEXTURE_COORDS  : constant := 16#0B06#;
   GL_CURRENT_TEXTURE_COORDS         : constant := 16#0B03#;
   GL_DECAL                          : constant := 16#2101#;
   GL_DIFFUSE                        : constant := 16#1201#;
   GL_EMISSION                       : constant := 16#1600#;
   GL_EXT_paletted_texture           : constant := 1;
   GL_FLAT                           : constant := 16#1D00#;
   GL_LIGHT0                         : constant := 16#4000#;
   GL_LIGHT1                         : constant := 16#4001#;
   GL_LIGHTING                       : constant := 16#0B50#;
   GL_LIGHT_MODEL_AMBIENT            : constant := 16#0B53#;
   GL_LINE_SMOOTH                    : constant := 16#0B20#;
   GL_LINE_SMOOTH_HINT               : constant := 16#0C52#;
   GL_LINE_STIPPLE                   : constant := 16#0B24#;
   GL_LINE_STIPPLE_PATTERN           : constant := 16#0B25#;
   GL_LINE_STIPPLE_REPEAT            : constant := 16#0B26#;
   GL_LIST_BASE                      : constant := 16#0B32#;
   GL_MATRIX_MODE                    : constant := 16#0BA0#;
   GL_MAX_ELEMENTS_INDICES           : constant := 16#80E9#;
   GL_MAX_ELEMENTS_VERTICES          : constant := 16#80E8#;
   GL_MAX_LIGHTS                     : constant := 16#0D31#;
   GL_MAX_LIST_NESTING               : constant := 16#0B31#;
   GL_MAX_MODELVIEW_STACK_DEPTH      : constant := 16#0D36#;
   GL_MAX_PROJECTION_STACK_DEPTH     : constant := 16#0D38#;
   GL_MAX_TEXTURE_UNITS              : constant := 16#84E2#;
   GL_MODELVIEW                      : constant := 16#1700#;
   GL_MODELVIEW_MATRIX               : constant := 16#0BA6#;
   GL_MODELVIEW_STACK_DEPTH          : constant := 16#0BA3#;
   GL_MODULATE                       : constant := 16#2100#;
   GL_NORMALIZE                      : constant := 16#0BA1#;
   GL_NORMAL_ARRAY                   : constant := 16#8075#;
   GL_NORMAL_ARRAY_POINTER           : constant := 16#808F#;
   GL_NORMAL_ARRAY_STRIDE            : constant := 16#807F#;
   GL_NORMAL_ARRAY_TYPE              : constant := 16#807E#;
   GL_OES_single_precision           : constant := 1;
   GL_OSC_VERSION_1_0                : constant := 1;
   GL_PERSPECTIVE_CORRECTION_HINT    : constant := 16#0C50#;
   GL_POINT_SIZE                     : constant := 16#0B11#;
   GL_POINT_SMOOTH                   : constant := 16#0B10#;
   GL_POINT_SMOOTH_HINT              : constant := 16#0C51#;
   GL_POLYGON_SMOOTH_HINT            : constant := 16#0C53#;
   GL_POLYGON_STIPPLE                : constant := 16#0B42#;
   GL_POSITION                       : constant := 16#1203#;
   GL_PROJECTION                     : constant := 16#1701#;
   GL_PROJECTION_MATRIX              : constant := 16#0BA7#;
   GL_PROJECTION_STACK_DEPTH         : constant := 16#0BA4#;
   GL_RESCALE_NORMAL                 : constant := 16#803A#;
   GL_SHADE_MODEL                    : constant := 16#0B54#;
   GL_SHININESS                      : constant := 16#1601#;
   GL_SMOOTH                         : constant := 16#1D01#;
   GL_SMOOTH_LINE_WIDTH_GRANULARITY  : constant := 16#0B23#;
   GL_SMOOTH_LINE_WIDTH_RANGE        : constant := 16#0B22#;
   GL_SMOOTH_POINT_SIZE_GRANULARITY  : constant := 16#0B13#;
   GL_SMOOTH_POINT_SIZE_RANGE        : constant := 16#0B12#;
   GL_SPECULAR                       : constant := 16#1202#;
   GL_STACK_OVERFLOW                 : constant := 16#0503#;
   GL_STACK_UNDERFLOW                : constant := 16#0504#;
   GL_TEXTURE_COORD_ARRAY            : constant := 16#8078#;
   GL_TEXTURE_COORD_ARRAY_POINTER    : constant := 16#8092#;
   GL_TEXTURE_COORD_ARRAY_SIZE       : constant := 16#8088#;
   GL_TEXTURE_COORD_ARRAY_STRIDE     : constant := 16#808A#;
   GL_TEXTURE_COORD_ARRAY_TYPE       : constant := 16#8089#;
   GL_TEXTURE_ENV                    : constant := 16#2300#;
   GL_TEXTURE_ENV_COLOR              : constant := 16#2201#;
   GL_TEXTURE_ENV_MODE               : constant := 16#2200#;
   GL_VERTEX_ARRAY                   : constant := 16#8074#;
   GL_VERTEX_ARRAY_POINTER           : constant := 16#808E#;
   GL_VERTEX_ARRAY_SIZE              : constant := 16#807A#;
   GL_VERTEX_ARRAY_STRIDE            : constant := 16#807C#;
   GL_VERTEX_ARRAY_TYPE              : constant := 16#807B#;


   --------------
   --   Functions
   --

   procedure glAlphaFunc           (Func           : in     GLenum;
                                    Ref            : in     GLclampf);
   procedure glBegin               (Mode           : in     GLenum);
   procedure glBitmap              (Width          : in     GLsizei;
                                    Height         : in     GLsizei;
                                    xOrig          : in     GLfloat;
                                    yOrig          : in     GLfloat;
                                    xMove          : in     GLfloat;
                                    yMove          : in     GLfloat;
                                    Bitmap         : in     GLubyte_Pointer);
   procedure glCallLists           (N              : in     GLsizei;
                                    the_Type       : in     GLenum;
                                    Lists          : in     GLvoid_Pointer);
   procedure glClientActiveTexture (Texture        : in     GLenum);
   procedure glColor4f             (Red            : in     GLfloat;
                                    Green          : in     GLfloat;
                                    Blue           : in     GLfloat;
                                    Alpha          : in     GLfloat);
   procedure glColor4fv            (V              : in     GLfloat_Pointer);
   procedure glColor4ub            (Red            : in     GLubyte;
                                    Green          : in     GLubyte;
                                    Blue           : in     GLubyte;
                                    Alpha          : in     GLubyte);
   procedure glColorPointer        (Size           : in     GLint;
                                    the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_Pointer);
   procedure glCopyPixels          (X              : in     GLint;
                                    Y              : in     GLint;
                                    Width          : in     GLsizei;
                                    Height         : in     GLsizei;
                                    the_Type       : in     GLenum);
   procedure glDisableClientState  (Cap            : in     GLenum);
   procedure glDrawPixels          (Width          : in     GLsizei;
                                    Height         : in     GLsizei;
                                    Format         : in     GLenum;
                                    the_Type       : in     GLenum;
                                    Pixels         : in     GLvoid_Pointer);
   procedure glEnableClientState   (Cap            : in     GLenum);
   procedure glEnd;
   procedure glEndList;
   procedure glFrustumf            (Left           : in     GLfloat;
                                    Right          : in     GLfloat;
                                    Bottom         : in     GLfloat;
                                    Top            : in     GLfloat;
                                    near_Val       : in     GLfloat;
                                    far_Val        : in     GLfloat);
   function  glGenLists            (the_Range      : in     GLsizei) return GLuint;
   procedure glGetLightfv          (Light          : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glGetMaterialfv       (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glGetPointerv         (pName          : in     GLenum;
                                    Params         : in     GLvoid_Pointer_Pointer);
   procedure glGetPolygonStipple   (Mask           : in     GLubyte_Pointer);
   procedure glGetTexEnvfv         (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glGetTexEnviv         (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLint_Pointer);
   procedure glLightModelfv        (pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glLightfv             (Light          : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glLineStipple         (Factor         : in     GLint;
                                    Pattern        : in     GLushort);
   procedure glListBase            (Base           : in     GLuint);
   procedure glLoadIdentity;
   procedure glLoadMatrixf         (M              : in     GLfloat_Pointer);
   procedure glMaterialf           (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Param          : in     GLfloat);
   procedure glMaterialfv          (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glMatrixMode          (Mode           : in     GLenum);
   procedure glMultMatrixf         (M              : in     GLfloat_Pointer);
   procedure glMultiTexCoord2f     (Target         : in     GLenum;
                                    S              : in     GLfloat;
                                    T              : in     GLfloat);
   procedure glMultiTexCoord2fv    (Target         : in     GLenum;
                                    V              : in     GLfloat_Pointer);
   procedure glNewList             (List           : in     GLuint;
                                    Mode           : in     GLenum);
   procedure glNormal3f            (nX             : in     GLfloat;
                                    nY             : in     GLfloat;
                                    nZ             : in     GLfloat);
   procedure glNormal3fv           (V              : in     GLfloat_Pointer);
   procedure glNormalPointer       (the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_Pointer);
   procedure glOrthof              (Left           : in     GLfloat;
                                    Right          : in     GLfloat;
                                    Bottom         : in     GLfloat;
                                    Top            : in     GLfloat;
                                    Near           : in     GLfloat;
                                    Far            : in     GLfloat);
   procedure glPointSize           (Size           : in     GLfloat);
   procedure glPolygonStipple      (Mask           : in     GLubyte_Pointer);
   procedure glPopMatrix;
   procedure glPushMatrix;
   procedure glRasterPos3f         (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glRotatef             (Angle          : in     GLfloat;
                                    X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glScalef              (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glShadeModel          (Mode           : in     GLenum);
   procedure glTexCoordPointer     (Size           : in     GLint;
                                    the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_Pointer);
   procedure glTexEnvfv            (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_Pointer);
   procedure glTexEnvi             (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Param          : in     GLint);
   procedure glTranslatef          (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glVertex2f            (X              : in     GLfloat;
                                    Y              : in     GLfloat);
   procedure glVertex2fv           (V              : in     GLfloat_Pointer);
   procedure glVertex3f            (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glVertex3fv           (V              : in     GLfloat_Pointer);
   procedure glVertexPointer       (Size           : in     GLint;
                                    the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_Pointer);

private

   pragma Import (StdCall, glAlphaFunc,           "glAlphaFunc");
   pragma Import (StdCall, glBegin,               "glBegin");
   pragma Import (StdCall, glBitmap,              "glBitmap");
   pragma Import (StdCall, glCallLists,           "glCallLists");
   pragma Import (StdCall, glClientActiveTexture, "glClientActiveTexture");
   pragma Import (StdCall, glColor4f,             "glColor4f");
   pragma Import (StdCall, glColor4fv,            "glColor4fv");
   pragma Import (StdCall, glColor4ub,            "glColor4ub");
   pragma Import (StdCall, glColorPointer,        "glColorPointer");
   pragma Import (StdCall, glCopyPixels,          "glCopyPixels");
   pragma Import (StdCall, glDisableClientState,  "glDisableClientState");
   pragma Import (StdCall, glDrawPixels,          "glDrawPixels");
   pragma Import (StdCall, glEnableClientState,   "glEnableClientState");
   pragma Import (StdCall, glEnd,                 "glEnd");
   pragma Import (StdCall, glEndList,             "glEndList");
   pragma Import (StdCall, glFrustumf,            "glFrustumf");
   pragma Import (StdCall, glGenLists,            "glGenLists");
   pragma Import (StdCall, glGetLightfv,          "glGetLightfv");
   pragma Import (StdCall, glGetMaterialfv,       "glGetMaterialfv");
   pragma Import (StdCall, glGetPointerv,         "glGetPointerv");
   pragma Import (StdCall, glGetPolygonStipple,   "glGetPolygonStipple");
   pragma Import (StdCall, glGetTexEnvfv,         "glGetTexEnvfv");
   pragma Import (StdCall, glGetTexEnviv,         "glGetTexEnviv");
   pragma Import (StdCall, glLightModelfv,        "glLightModelfv");
   pragma Import (StdCall, glLightfv,             "glLightfv");
   pragma Import (StdCall, glLineStipple,         "glLineStipple");
   pragma Import (StdCall, glListBase,            "glListBase");
   pragma Import (StdCall, glLoadIdentity,        "glLoadIdentity");
   pragma Import (StdCall, glLoadMatrixf,         "glLoadMatrixf");
   pragma Import (StdCall, glMaterialf,           "glMaterialf");
   pragma Import (StdCall, glMaterialfv,          "glMaterialfv");
   pragma Import (StdCall, glMatrixMode,          "glMatrixMode");
   pragma Import (StdCall, glMultMatrixf,         "glMultMatrixf");
   pragma Import (StdCall, glMultiTexCoord2f,     "glMultiTexCoord2f");
   pragma Import (StdCall, glMultiTexCoord2fv,    "glMultiTexCoord2fv");
   pragma Import (StdCall, glNewList,             "glNewList");
   pragma Import (StdCall, glNormal3f,            "glNormal3f");
   pragma Import (StdCall, glNormal3fv,           "glNormal3fv");
   pragma Import (StdCall, glNormalPointer,       "glNormalPointer");
   pragma Import (StdCall, glOrthof,              "glOrthof");
   pragma Import (StdCall, glPointSize,           "glPointSize");
   pragma Import (StdCall, glPolygonStipple,      "glPolygonStipple");
   pragma Import (StdCall, glPopMatrix,           "glPopMatrix");
   pragma Import (StdCall, glPushMatrix,          "glPushMatrix");
   pragma Import (StdCall, glRasterPos3f,         "glRasterPos3f");
   pragma Import (StdCall, glRotatef,             "glRotatef");
   pragma Import (StdCall, glScalef,              "glScalef");
   pragma Import (StdCall, glShadeModel,          "glShadeModel");
   pragma Import (StdCall, glTexCoordPointer,     "glTexCoordPointer");
   pragma Import (StdCall, glTexEnvfv,            "glTexEnvfv");
   pragma Import (StdCall, glTexEnvi,             "glTexEnvi");
   pragma Import (StdCall, glTranslatef,          "glTranslatef");
   pragma Import (StdCall, glVertex2f,            "glVertex2f");
   pragma Import (StdCall, glVertex2fv,           "glVertex2fv");
   pragma Import (StdCall, glVertex3f,            "glVertex3f");
   pragma Import (StdCall, glVertex3fv,           "glVertex3fv");
   pragma Import (StdCall, glVertexPointer,       "glVertexPointer");

end GL.safe;

-- TODO:  Bind these missing functions, if needed.
--
--  GLAPI void   APIENTRY glColorSubTableEXT    (GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum type, const GLvoid *table);
--  GLAPI void   APIENTRY glColorTableEXT       (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid *table);
--  GLAPI void   APIENTRY glGetColorTableEXT    (GLenum target, GLenum format, GLenum type, GLvoid *table);
--  GLAPI void   APIENTRY glGetColorTableParameterivEXT
--                                              (GLenum target, GLenum pname, GLint *params);
