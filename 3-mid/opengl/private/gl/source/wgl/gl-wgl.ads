--
-- Copyright  (c) 2002-2003, David Holm
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:
--
--   * Redistributions of source code must retain the above copyright notice,
--     this list of conditions and the following disclaimer.
--   * Redistributions in binary form must reproduce the above copyright
--     notice,
--     this list of conditions and the following disclaimer in the
--     documentation
--     and/or other materials provided with the distribution.
--   * The names of its contributors may not be used to endorse or promote
--     products derived from this software without specific prior written
--     permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES;
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

with
     interfaces.C,
     interfaces.C.Extensions,

     System;


package GL.WGL
is
   WGL_FONT_LINES                 : constant := 8#0000#;
   WGL_FONT_POLYGONS              : constant := 1;
   WGL_SWAP_MAIN_PLANE            : constant := 1;
   WGL_SWAP_OVERLAY1              : constant := 2;
   WGL_SWAP_OVERLAY2              : constant := 4;
   WGL_SWAP_OVERLAY3              : constant := 8;
   WGL_SWAP_OVERLAY4              : constant := 16#0010#;
   WGL_SWAP_OVERLAY5              : constant := 16#0020#;
   WGL_SWAP_OVERLAY6              : constant := 16#0040#;
   WGL_SWAP_OVERLAY7              : constant := 16#0080#;
   WGL_SWAP_OVERLAY8              : constant := 16#0100#;
   WGL_SWAP_OVERLAY9              : constant := 16#0200#;
   WGL_SWAP_OVERLAY10             : constant := 16#0400#;
   WGL_SWAP_OVERLAY11             : constant := 16#0800#;
   WGL_SWAP_OVERLAY12             : constant := 16#1000#;
   WGL_SWAP_OVERLAY13             : constant := 16#2000#;
   WGL_SWAP_OVERLAY14             : constant := 16#4000#;
   WGL_SWAP_OVERLAY15             : constant := 16#8000#;
   WGL_SWAP_UNDERLAY1             : constant := 16#0001_0000#;
   WGL_SWAP_UNDERLAY2             : constant := 16#0002_0000#;
   WGL_SWAP_UNDERLAY3             : constant := 16#0004_0000#;
   WGL_SWAP_UNDERLAY4             : constant := 16#0008_0000#;
   WGL_SWAP_UNDERLAY5             : constant := 16#0010_0000#;
   WGL_SWAP_UNDERLAY6             : constant := 16#0020_0000#;
   WGL_SWAP_UNDERLAY7             : constant := 16#0040_0000#;
   WGL_SWAP_UNDERLAY8             : constant := 16#0080_0000#;
   WGL_SWAP_UNDERLAY9             : constant := 16#0100_0000#;
   WGL_SWAP_UNDERLAY10            : constant := 16#0200_0000#;
   WGL_SWAP_UNDERLAY11            : constant := 16#0400_0000#;
   WGL_SWAP_UNDERLAY12            : constant := 16#0800_0000#;
   WGL_SWAP_UNDERLAY13            : constant := 16#1000_0000#;
   WGL_SWAP_UNDERLAY14            : constant := 16#2000_0000#;
   WGL_SWAP_UNDERLAY15            : constant := 16#4000_0000#;

   type Pixel_Format_Descriptor is
       record
           nSize           : interfaces.C.short;
           nVersion        : interfaces.C.short;
           dwFlags         : interfaces.C.long;
           iPixelType      : interfaces.C.char;
           cColorBits      : interfaces.C.char;
           cRedBits        : interfaces.C.char;
           cRedShift       : interfaces.C.char;
           cGreenBits      : interfaces.C.char;
           cGreenShift     : interfaces.C.char;
           cBlueBits       : interfaces.C.char;
           cBlueShift      : interfaces.C.char;
           cAlphaBits      : interfaces.C.char;
           cAlphaShift     : interfaces.C.char;
           cAccumBits      : interfaces.C.char;
           cAccumRedBits   : interfaces.C.char;
           cAccumGreenBits : interfaces.C.char;
           cAccumBlueBits  : interfaces.C.char;
           cAccumAlphaBits : interfaces.C.char;
           cDepthBits      : interfaces.C.char;
           cStencilBits    : interfaces.C.char;
           cAuxBuffers     : interfaces.C.char;
           iLayerType      : interfaces.C.char;
           bReserved       : interfaces.C.char;
           dwLayerMask     : interfaces.C.long;
           dwVisibleMask   : interfaces.C.long;
           dwDamageMask    : interfaces.C.long;
       end record;
   pragma Convention (C_Pass_By_Copy, Pixel_Format_Descriptor);

   type Point_Float is
      record
          x : interfaces.C.C_float;
          y : interfaces.C.C_float;
      end record;
   pragma Convention (C_Pass_By_Copy, Point_Float);

   type Glyph_Metrics_Float is
      record
          gmfBlackBoxX     : interfaces.C.C_float;
          gmfBlackBoxY     : interfaces.C.C_float;
          gmfptGlyphOrigin : Point_Float;
          gmfCellIncX      : interfaces.C.C_float;
          gmfCellIncY      : interfaces.C.C_float;
      end record;
   pragma Convention (C_Pass_By_Copy, Glyph_Metrics_Float);

   type COLORREF is new interfaces.C.long;
   type COLORREF_Type is access all COLORREF;

   type Layer_Plane_Descriptor is
      record
          nSize           : interfaces.C.short;
          nVersion        : interfaces.C.short;
          dwFlags         : interfaces.C.long;
          iPixelType      : interfaces.C.char;
          cColorBits      : interfaces.C.char;
          cRedBits        : interfaces.C.char;
          cRedShift       : interfaces.C.char;
          cGreenBits      : interfaces.C.char;
          cGreenShift     : interfaces.C.char;
          cBlueBits       : interfaces.C.char;
          cBlueShift      : interfaces.C.char;
          cAlphaBits      : interfaces.C.char;
          cAlphaShift     : interfaces.C.char;
          cAccumBits      : interfaces.C.char;
          cAccumRedBits   : interfaces.C.char;
          cAccumGreenBits : interfaces.C.char;
          cAccumBlueBits  : interfaces.C.char;
          cAccumAlphaBits : interfaces.C.char;
          cDepthBits      : interfaces.C.char;
          cStencilBits    : interfaces.C.char;
          cAuxBuffers     : interfaces.C.char;
          iLayerPlane     : interfaces.C.char;
          bReserved       : interfaces.C.char;
          crTransparent   : COLORREF;
      end record;
   pragma Convention (C_Pass_By_Copy, Layer_Plane_Descriptor);

   type Layer_Plane_Descriptor_Type is access all Layer_Plane_Descriptor;
   type Glyph_Metrics_Float_Type is access all Glyph_Metrics_Float;
   type Pixel_Format_Descriptor_Type is access all Pixel_Format_Descriptor;

   type HANDLE is new interfaces.C.Extensions.void_ptr;
   subtype HDC is HANDLE;
   subtype HGLRC is HANDLE;

   type PROC is access function return interfaces.C.int;

   function wglDeleteContext (Rendering_Context : in HGLRC)
      return interfaces.C.int;

   function wglMakeCurrent (Device_Context    : in HDC;
                            Rendering_Context : in HGLRC)
                               return interfaces.C.int;

   function wglSetPixelFormat (Device_Context    : in HDC;
                               Pixel_Format      : in interfaces.C.int;
                               Pixel_Format_Desc :
                                  access Pixel_Format_Descriptor_Type)
                                     return interfaces.C.int;

   function wglSwapBuffers (Device_Context : in HDC)
      return interfaces.C.int;

   function wglGetCurrentDC return HANDLE;

   function wglCreateContext (Device_Context : in HDC)
      return HANDLE;

   function wglCreateLayerContext (Device_Context : in HDC;
                                   Layer_Plane    : in interfaces.C.int)
                                         return HANDLE;

   function wglGetCurrentContext return HANDLE;

   function wglGetProcAddress (Proc_Desc : access interfaces.C.char) return PROC;

   function wglChoosePixelFormat (Device_Context    : in HDC;
                                  Pixel_Format_Desc :
                                     access Pixel_Format_Descriptor_Type)
                                        return interfaces.C.int;


   function wglCopyContext (Rendering_Context_Source : in HGLRC;
                            Rendering_Context_Dest   : in HGLRC;
                            Mask                     :                             in interfaces.C.unsigned)
                                  return interfaces.C.int;

   function wglDescribeLayerPlane (Device_Context : in HDC;
                                   Pixel_Format   : in interfaces.C.int;
                                   Layer_Plane    : in interfaces.C.int;
                                   Bytes          : in interfaces.C.unsigned;
                                   Plane_Desc     :                                   in Layer_Plane_Descriptor_Type)
                                        return interfaces.C.int;

   function wglDescribePixelFormat (Device_Context    : in HDC;
                                    Layer_Plane       : in interfaces.C.int;
                                    Bytes             :                                     in interfaces.C.unsigned;
                                    Pixel_Format_Desc :                                     in Pixel_Format_Descriptor_Type)
                                          return interfaces.C.int;

   function wglGetLayerPaletteEntries (Device_Context : in HDC;
                                       Layer_Plane    : in interfaces.C.int;
                                       Start          : in interfaces.C.int;
                                       Entries        : in interfaces.C.int;
                                       Color_Ref      :
                                          access interfaces.C.long)
                                             return interfaces.C.int;

   function wglGetPixelFormat (Device_Context : in HDC)
      return interfaces.C.int;

   function wglRealizeLayerPalette (Device_Context : in HDC;
                                    Layer_Plane    : in interfaces.C.int;
                                    Realize        : in Boolean)
                                       return interfaces.C.int;

   function wglSetLayerPaletteEntries (Device_Context  : in HDC;
                                       Layer_Plane     : in interfaces.C.int;
                                       Start           : in interfaces.C.int;
                                       Entries         : in interfaces.C.int;
                                       Color_Reference : in COLORREF_Type)
                                          return interfaces.C.int;

   function wglShareLists (Existing_Rendering_Context : in HGLRC;
                           New_Rendering_Context      : in HGLRC)
                              return interfaces.C.int;

   function wglSwapLayerBuffers (Device_Context : in HDC;
                                 Planes         : in interfaces.C.unsigned)
                                    return interfaces.C.int;

   function wglUseFontBitmapsA (Device_Context : in HDC;
                                First          : in interfaces.C.unsigned;
                                Count          : in interfaces.C.unsigned;
                                List_Base      : in interfaces.C.unsigned)
                                   return interfaces.C.int;

   function wglUseFontBitmapsW (Device_Context : in HDC;
                                First          : in interfaces.C.unsigned;
                                Count          : in interfaces.C.unsigned;
                                List_Base      : in interfaces.C.unsigned)
                                   return interfaces.C.int;

   function wglUseFontOutlinesA (Device_Context    : in HDC;
                                 First             : in interfaces.C.unsigned;
                                 Count             : in interfaces.C.unsigned;
                                 List_Base         : in interfaces.C.unsigned;
                                 Deviation         : in interfaces.C.C_float;
                                 Extrusion         : in interfaces.C.C_float;
                                 Format            : in interfaces.C.int;
                                 Glyph_Data_Buffer : in Glyph_Metrics_Float_Type)
                                    return interfaces.C.int;

   function wglUseFontOutlinesW (Device_Context    : in HDC;
                                 First             : in interfaces.C.unsigned;
                                 Count             : in interfaces.C.unsigned;
                                 List_Base         : in interfaces.C.unsigned;
                                 Deviation         : in interfaces.C.C_float;
                                 Extrusion         : in interfaces.C.C_float;
                                 Format            : in interfaces.C.int;
                                 Glyph_Data_Buffer : in Glyph_Metrics_Float_Type)
                                    return interfaces.C.int;

   function SwapBuffers (Device_Context : in HDC) return
      interfaces.C.int;

   function ChoosePixelFormat (Device_Context    : in HDC;
                               Pixel_Format_Desc :
                                 access Pixel_Format_Descriptor_Type)
                                    return interfaces.C.int;

   function DescribePixelFormat (Device_Context    : in HDC;
                                 Pixel_Format      : in interfaces.C.int;
                                 Bytes             : in interfaces.C.unsigned;
                                 Pixel_Format_Desc :                                  in Pixel_Format_Descriptor_Type)
                                       return interfaces.C.int;

   function GetPixelFormat (Device_Context : in HDC)
      return interfaces.C.int;

   function SetPixelFormat (Device_Context    : in HDC;
                            Pixel_Format      : in interfaces.C.int;
                            Pixel_Format_Desc :
                              access Pixel_Format_Descriptor_Type)
                                 return interfaces.C.int;



private

   pragma import (StdCall, wglDeleteContext, "wglDeleteContext");

   pragma import (StdCall, wglMakeCurrent, "wglMakeCurrent");

   pragma import (StdCall, wglSetPixelFormat, "wglSetPixelFormat");

   pragma import (StdCall, wglSwapBuffers, "wglSwapBuffers");

   pragma import (StdCall, wglGetCurrentDC, "wglGetCurrentDC");

   pragma import (StdCall, wglCreateContext, "wglCreateContext");

   pragma import (StdCall, wglCreateLayerContext, "wglCreateLayerContext");

   pragma import (StdCall, wglGetCurrentContext, "wglGetCurrentContext");

   pragma import (StdCall, wglGetProcAddress, "wglGetProcAddress");

   pragma import (StdCall, wglChoosePixelFormat, "wglChoosePixelFormat");

   pragma import (StdCall, wglCopyContext, "wglCopyContext");

   pragma import (StdCall, wglDescribeLayerPlane, "wglDescribeLayerPlane");

   pragma import (StdCall, wglDescribePixelFormat, "wglDescribePixelFormat");

   pragma import (StdCall, wglGetLayerPaletteEntries, "wglGetLayerPaletteEntries");

   pragma import (StdCall, wglGetPixelFormat, "wglGetPixelFormat");

   pragma import (StdCall, wglRealizeLayerPalette, "wglRealizeLayerPalette");

   pragma import (StdCall, wglSetLayerPaletteEntries, "wglSetLayerPaletteEntries");

   pragma import (StdCall, wglShareLists, "wglShareLists");

   pragma import (StdCall, wglSwapLayerBuffers, "wglSwapLayerBuffers");

   pragma import (StdCall, wglUseFontBitmapsA, "wglUseFontBitmapsA");

   pragma import (StdCall, wglUseFontBitmapsW, "wglUseFontBitmapsW");

   pragma import (StdCall, wglUseFontOutlinesA, "wglUseFontOutlinesA");

   pragma import (StdCall, wglUseFontOutlinesW, "wglUseFontOutlinesW");

   pragma import (StdCall, SwapBuffers, "SwapBuffers");

   pragma import (StdCall, ChoosePixelFormat, "ChoosePixelFormat");

   pragma import (StdCall, DescribePixelFormat, "DescribePixelFormat");

   pragma import (StdCall, GetPixelFormat, "GetPixelFormat");

   pragma import (StdCall, SetPixelFormat, "SetPixelFormat");


end GL.WGL;
