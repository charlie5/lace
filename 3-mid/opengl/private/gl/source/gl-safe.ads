with
     interfaces.C.Pointers,
     System;


package GL.safe
--
-- Provides types, constants and functions specific to the openGL 'Safety Critical' profile.
--
is
   ---------
   --- Types
   --

   -- GLubyte_pointer
   --
   package GLubyte_Pointers is new C.Pointers (Index              => C.size_t,
                                               Element            => GLubyte,
                                               Element_array      => GLubyte_array,
                                               default_Terminator => 0);
   subtype GLubyte_pointer  is GLubyte_Pointers.Pointer;


   -- GLint_pointer
   --
   package GLint_pointers is new C.Pointers (Index              => C.size_t,
                                             Element            => GLint,
                                             Element_array      => GLint_array,
                                             default_Terminator => 0);
   subtype GLint_pointer  is GLint_pointers.Pointer;


   -- GLfloat_pointer
   --
   package GLfloat_Pointers is new C.Pointers (Index              => C.size_t,
                                               Element            => GLfloat,
                                               Element_array      => GLfloat_array,
                                               default_Terminator => 0.0);
   subtype GLfloat_pointer  is GLfloat_Pointers.Pointer;


   -- GLvoid_pointer
   --
   package GLvoid_Pointers is new C.Pointers (Index              => C.size_t,
                                              Element            => GLvoid,
                                              Element_array      => GLvoid_array,
                                              default_Terminator => system.null_Address);
   subtype GLvoid_pointer  is GLvoid_Pointers.Pointer;


   -- GLvoid_pointer_pointer
   --
   type    GLvoid_pointer_array    is array (C.size_t range <>) of aliased GLvoid_pointer;
   package GLvoid_Pointer_Pointers is new C.Pointers (Index              => C.size_t,
                                                      Element            => GLvoid_pointer,
                                                      Element_array      => GLvoid_pointer_array,
                                                      default_Terminator => null);
   subtype GLvoid_pointer_pointer  is GLvoid_Pointer_Pointers.Pointer;


   -------------
   --- Constants
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
                                    Bitmap         : in     GLubyte_pointer);
   procedure glCallLists           (N              : in     GLsizei;
                                    the_Type       : in     GLenum;
                                    Lists          : in     GLvoid_pointer);
   procedure glClientActiveTexture (Texture        : in     GLenum);
   procedure glColor4f             (Red            : in     GLfloat;
                                    Green          : in     GLfloat;
                                    Blue           : in     GLfloat;
                                    Alpha          : in     GLfloat);
   procedure glColor4fv            (V              : in     GLfloat_pointer);
   procedure glColor4ub            (Red            : in     GLubyte;
                                    Green          : in     GLubyte;
                                    Blue           : in     GLubyte;
                                    Alpha          : in     GLubyte);
   procedure glColorPointer        (Size           : in     GLint;
                                    the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_pointer);
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
                                    Pixels         : in     GLvoid_pointer);
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
                                    Params         : in     GLfloat_pointer);
   procedure glGetMaterialfv       (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glGetPointerv         (pName          : in     GLenum;
                                    Params         : in     GLvoid_pointer_pointer);
   procedure glGetPolygonStipple   (Mask           : in     GLubyte_pointer);
   procedure glGetTexEnvfv         (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glGetTexEnviv         (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLint_pointer);
   procedure glLightModelfv        (pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glLightfv             (Light          : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glLineStipple         (Factor         : in     GLint;
                                    Pattern        : in     GLushort);
   procedure glListBase            (Base           : in     GLuint);
   procedure glLoadIdentity;
   procedure glLoadMatrixf         (M              : in     GLfloat_pointer);
   procedure glMaterialf           (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Param          : in     GLfloat);
   procedure glMaterialfv          (Face           : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glMatrixMode          (Mode           : in     GLenum);
   procedure glMultMatrixf         (M              : in     GLfloat_pointer);
   procedure glMultiTexCoord2f     (Target         : in     GLenum;
                                    S              : in     GLfloat;
                                    T              : in     GLfloat);
   procedure glMultiTexCoord2fv    (Target         : in     GLenum;
                                    V              : in     GLfloat_pointer);
   procedure glNewList             (List           : in     GLuint;
                                    Mode           : in     GLenum);
   procedure glNormal3f            (nX             : in     GLfloat;
                                    nY             : in     GLfloat;
                                    nZ             : in     GLfloat);
   procedure glNormal3fv           (V              : in     GLfloat_pointer);
   procedure glNormalPointer       (the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_pointer);
   procedure glOrthof              (Left           : in     GLfloat;
                                    Right          : in     GLfloat;
                                    Bottom         : in     GLfloat;
                                    Top            : in     GLfloat;
                                    Near           : in     GLfloat;
                                    Far            : in     GLfloat);
   procedure glPointSize           (Size           : in     GLfloat);
   procedure glPolygonStipple      (Mask           : in     GLubyte_pointer);
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
                                    Ptr            : in     GLvoid_pointer);
   procedure glTexEnvfv            (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Params         : in     GLfloat_pointer);
   procedure glTexEnvi             (Target         : in     GLenum;
                                    pName          : in     GLenum;
                                    Param          : in     GLint);
   procedure glTranslatef          (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glVertex2f            (X              : in     GLfloat;
                                    Y              : in     GLfloat);
   procedure glVertex2fv           (V              : in     GLfloat_pointer);
   procedure glVertex3f            (X              : in     GLfloat;
                                    Y              : in     GLfloat;
                                    Z              : in     GLfloat);
   procedure glVertex3fv           (V              : in     GLfloat_pointer);
   procedure glVertexPointer       (Size           : in     GLint;
                                    the_Type       : in     GLenum;
                                    Stride         : in     GLsizei;
                                    Ptr            : in     GLvoid_pointer);



private

   pragma import (StdCall, glAlphaFunc,           "glAlphaFunc");
   pragma import (StdCall, glBegin,               "glBegin");
   pragma import (StdCall, glBitmap,              "glBitmap");
   pragma import (StdCall, glCallLists,           "glCallLists");
   pragma import (StdCall, glClientActiveTexture, "glClientActiveTexture");
   pragma import (StdCall, glColor4f,             "glColor4f");
   pragma import (StdCall, glColor4fv,            "glColor4fv");
   pragma import (StdCall, glColor4ub,            "glColor4ub");
   pragma import (StdCall, glColorPointer,        "glColorPointer");
   pragma import (StdCall, glCopyPixels,          "glCopyPixels");
   pragma import (StdCall, glDisableClientState,  "glDisableClientState");
   pragma import (StdCall, glDrawPixels,          "glDrawPixels");
   pragma import (StdCall, glEnableClientState,   "glEnableClientState");
   pragma import (StdCall, glEnd,                 "glEnd");
   pragma import (StdCall, glEndList,             "glEndList");
   pragma import (StdCall, glFrustumf,            "glFrustumf");
   pragma import (StdCall, glGenLists,            "glGenLists");
   pragma import (StdCall, glGetLightfv,          "glGetLightfv");
   pragma import (StdCall, glGetMaterialfv,       "glGetMaterialfv");
   pragma import (StdCall, glGetPointerv,         "glGetPointerv");
   pragma import (StdCall, glGetPolygonStipple,   "glGetPolygonStipple");
   pragma import (StdCall, glGetTexEnvfv,         "glGetTexEnvfv");
   pragma import (StdCall, glGetTexEnviv,         "glGetTexEnviv");
   pragma import (StdCall, glLightModelfv,        "glLightModelfv");
   pragma import (StdCall, glLightfv,             "glLightfv");
   pragma import (StdCall, glLineStipple,         "glLineStipple");
   pragma import (StdCall, glListBase,            "glListBase");
   pragma import (StdCall, glLoadIdentity,        "glLoadIdentity");
   pragma import (StdCall, glLoadMatrixf,         "glLoadMatrixf");
   pragma import (StdCall, glMaterialf,           "glMaterialf");
   pragma import (StdCall, glMaterialfv,          "glMaterialfv");
   pragma import (StdCall, glMatrixMode,          "glMatrixMode");
   pragma import (StdCall, glMultMatrixf,         "glMultMatrixf");
   pragma import (StdCall, glMultiTexCoord2f,     "glMultiTexCoord2f");
   pragma import (StdCall, glMultiTexCoord2fv,    "glMultiTexCoord2fv");
   pragma import (StdCall, glNewList,             "glNewList");
   pragma import (StdCall, glNormal3f,            "glNormal3f");
   pragma import (StdCall, glNormal3fv,           "glNormal3fv");
   pragma import (StdCall, glNormalPointer,       "glNormalPointer");
   pragma import (StdCall, glOrthof,              "glOrthof");
   pragma import (StdCall, glPointSize,           "glPointSize");
   pragma import (StdCall, glPolygonStipple,      "glPolygonStipple");
   pragma import (StdCall, glPopMatrix,           "glPopMatrix");
   pragma import (StdCall, glPushMatrix,          "glPushMatrix");
   pragma import (StdCall, glRasterPos3f,         "glRasterPos3f");
   pragma import (StdCall, glRotatef,             "glRotatef");
   pragma import (StdCall, glScalef,              "glScalef");
   pragma import (StdCall, glShadeModel,          "glShadeModel");
   pragma import (StdCall, glTexCoordPointer,     "glTexCoordPointer");
   pragma import (StdCall, glTexEnvfv,            "glTexEnvfv");
   pragma import (StdCall, glTexEnvi,             "glTexEnvi");
   pragma import (StdCall, glTranslatef,          "glTranslatef");
   pragma import (StdCall, glVertex2f,            "glVertex2f");
   pragma import (StdCall, glVertex2fv,           "glVertex2fv");
   pragma import (StdCall, glVertex3f,            "glVertex3f");
   pragma import (StdCall, glVertex3fv,           "glVertex3fv");
   pragma import (StdCall, glVertexPointer,       "glVertexPointer");


end GL.safe;

-- TODO:  Bind these missing functions, if needed.
--
-- GLAPI void   APIENTRY glColorSubTableEXT    (GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum type, const GLvoid *table);
-- GLAPI void   APIENTRY glColorTableEXT       (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid *table);
-- GLAPI void   APIENTRY glGetColorTableEXT    (GLenum target, GLenum format, GLenum type, GLvoid *table);
-- GLAPI void   APIENTRY glGetColorTableParameterivEXT
--                                              (GLenum target, GLenum pname, GLint *params);
