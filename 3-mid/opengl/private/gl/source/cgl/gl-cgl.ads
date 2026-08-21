-- Copyright (c) 2011, Felix Krause <flyx@isobeef.org>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

with
     interfaces.C.Pointers,
     interfaces.C.Extensions,
     interfaces.C.Strings,

     System;


package GL.CGL
is

   -- CGL types and constants

   subtype CGLContextObject      is System.Address;
   subtype CGLPixelFormatObject  is System.Address;
   subtype CGLRendererInfoObject is System.Address;
   subtype CGLPBufferObject      is System.Address;

   type CGLPixelFormatAttribute is (Terminator               ,
                                    kCGLPFAAllRenderers      ,
                                    kCGLPFATripleBuffer      ,
                                    kCGLPFADoubleBuffer      ,
                                    kCGLPFAStereo            ,
                                    kCGLPFAAuxBuffers        ,
                                    kCGLPFAColorSize         ,
                                    kCGLPFAAlphaSize         ,
                                    kCGLPFADepthSize         ,
                                    kCGLPFAStencilSize       ,
                                    kCGLPFAAccumSize         ,
                                    kCGLPFAMinimumPolicy     ,
                                    kCGLPFAMaximumPolicy     ,
                                    kCGLPFAOffScreen         ,
                                    kCGLPFAFullScreen        ,
                                    kCGLPFASampleBuffers     ,
                                    kCGLPFASamples           ,
                                    kCGLPFAAuxDepthStencil   ,
                                    kCGLPFAColorFloat        ,
                                    kCGLPFAMultisample       ,
                                    kCGLPFASupersample       ,
                                    kCGLPFASampleAlpha       ,

                                    kCGLPFARendererID        ,
                                    kCGLPFASingleRenderer    ,
                                    kCGLPFANoRecovery        ,
                                    kCGLPFAAccelerated       ,
                                    kCGLPFAClosestPolicy     ,
                                    kCGLPFARobust            ,
                                    kCGLPFABackingStore      ,
                                    kCGLPFAMPSafe            ,
                                    kCGLPFAWindow            ,
                                    kCGLPFAMultiScreen       ,
                                    kCGLPFACompliant         ,
                                    kCGLPFADisplayMask       ,
                                    kCGLPFAPBuffer           ,
                                    kCGLPFARemotePBuffer     ,
                                    kCGLPFAAllowOfflineRenderers,
                                    kCGLPFAAcceleratedCompute,
                                    kCGLPFAOpenGLProfile     ,
                                    kCGLPFAVirtualScreenCount
                                   );

   type CGLRendererProperty is (kCGLRPOffScreen             ,
                                kCGLRPFullScreen            ,
                                kCGLRPRendererID            ,
                                kCGLRPAccelerated           ,
                                kCGLRPRobust                ,
                                kCGLRPBackingStore          ,
                                kCGLRPMPSafe                ,
                                kCGLRPWindow                ,
                                kCGLRPMultiScreen           ,
                                kCGLRPCompliant             ,
                                kCGLRPDisplayMask           ,
                                kCGLRPBufferModes           ,
                                kCGLRPColorModes            ,
                                kCGLRPAccumModes            ,
                                kCGLRPDepthModes            ,
                                kCGLRPStencilModes          ,
                                kCGLRPMaxAuxBuffers         ,
                                kCGLRPMaxSampleBuffers      ,
                                kCGLRPMaxSamples            ,
                                kCGLRPSampleModes           ,
                                kCGLRPSampleAlpha           ,
                                kCGLRPVideoMemory           ,
                                kCGLRPTextureMemory         ,
                                kCGLRPGPUVertProcCapable    ,
                                kCGLRPGPUFragProcCapable    ,
                                kCGLRPRendererCount         ,
                                kCGLRPOnline                ,
                                kCGLRPAcceleratedCompute    ,
                                kCGLRPVideoMemoryMegabytes  ,
                                kCGLRPTextureMemoryMegabytes
                               );

   type CGLContextEnable is (kCGLCESwapRectangle  ,
                             kCGLCESwapLimit      ,
                             kCGLCERasterization  ,
                             kCGLCEStateValidation,
                             kCGLCESurfaceBackingSize,
                             kCGLCEDisplayListOptimization,
                             kCGLCEMPEngine       ,
                             kCGLCECrashOnRemovedFunctions
                            );

   type CGLContextParameter is (kCGLCPSwapRectangle         ,
                                kCGLCPSwapInterval          ,
                                kCGLCPDispatchTableSize     ,
                                kCGLCPClientStorage         ,
                                kCGLCPSurfaceTexture        ,
                                kCGLCPSurfaceOrder          ,
                                kCGLCPSurfaceOpacity        ,
                                kCGLCPSurfaceBackingSize    ,
                                kCGLCPSurfaceSurfaceVolatile,
                                kCGLCPReclaimResources      ,
                                kCGLCPCurrentRendererID     ,
                                kCGLCPGPUVertexProcessing   ,
                                kCGLCPGPUFragmentProcessing ,
                                kCGLCPHasDrawable           ,
                                kCGLCPMPSwapsInFlight
                               );

   type CGLGlobalOption is (kCGLGOFormatCacheSize ,
                            kCGLGOClearFormatCache,
                            kCGLGORetainRenderers ,
                            kCGLGOResetLibrary    ,
                            kCGLGOUseErrorHandler ,
                            kCGLGOUseBuildCache
                           );

   type CGLOpenGLProfile is (kCGLOGLPVersion_Legacy  ,
                             kCGLOGLPVersion_3_2_Core
                            );

   type CGLError is (kCGLNoError           ,
                     kCGLBadAttribute      ,
                     kCGLBadProperty       ,
                     kCGLBadPixelFormat    ,
                     kCGLBadRendererInfo   ,
                     kCGLBadContext        ,
                     kCGLBadDrawable       ,
                     kCGLBadDisplay        ,
                     kCGLBadState          ,
                     kCGLBadValue          ,
                     kCGLBadMatch          ,
                     kCGLBadEnumeration    ,
                     kCGLBadOffScreen      ,
                     kCGLBadFullScreen     ,
                     kCGLBadWindow         ,
                     kCGLBadAddress        ,
                     kCGLBadCodeModule     ,
                     kCGLBadAlloc          ,
                     kCGLBadConnection
                    );

   kCGLMonoscopicBit  : constant := 16#0000_0001#;
   kCGLStereoscopicBit: constant := 16#0000_0002#;
   kCGLSingleBufferBit: constant := 16#0000_0004#;
   kCGLDoubleBufferBit: constant := 16#0000_0008#;
   kCGLTripleBufferBit: constant := 16#0000_0010#;
   kCGL0Bit           : constant := 16#0000_0001#;
   kCGL1Bit           : constant := 16#0000_0002#;
   kCGL2Bit           : constant := 16#0000_0004#;
   kCGL3Bit           : constant := 16#0000_0008#;
   kCGL4Bit           : constant := 16#0000_0010#;
   kCGL5Bit           : constant := 16#0000_0020#;
   kCGL6Bit           : constant := 16#0000_0040#;
   kCGL8Bit           : constant := 16#0000_0080#;
   kCGL10Bit          : constant := 16#0000_0100#;
   kCGL12Bit          : constant := 16#0000_0200#;
   kCGL16Bit          : constant := 16#0000_0400#;
   kCGL24Bit          : constant := 16#0000_0800#;
   kCGL32Bit          : constant := 16#0000_1000#;
   kCGL48Bit          : constant := 16#0000_2000#;
   kCGL64Bit          : constant := 16#0000_4000#;
   kCGL96Bit          : constant := 16#0000_8000#;
   kCGL128Bit         : constant := 16#0001_0000#;
   kCGLRGB444Bit      : constant := 16#0000_0040#;
   kCGLARGB4444Bit    : constant := 16#0000_0080#;
   kCGLRGB444A8Bit    : constant := 16#0000_0100#;
   kCGLRGB555Bit      : constant := 16#0000_0200#;
   kCGLARGB1555Bit    : constant := 16#0000_0400#;
   kCGLRGB555A8Bit    : constant := 16#0000_0800#;
   kCGLRGB565Bit      : constant := 16#0000_1000#;
   kCGLRGB565A8Bit    : constant := 16#0000_2000#;
   kCGLRGB888Bit      : constant := 16#0000_4000#;
   kCGLARGB8888Bit    : constant := 16#0000_8000#;
   kCGLRGB888A8Bit    : constant := 16#0001_0000#;
   kCGLRGB101010Bit   : constant := 16#0002_0000#;
   kCGLARGB2101010Bit : constant := 16#0004_0000#;
   kCGLRGB101010_A8Bit: constant := 16#0008_0000#;
   kCGLRGB121212Bit   : constant := 16#0010_0000#;
   kCGLARGB12121212Bit: constant := 16#0020_0000#;
   kCGLRGB161616Bit   : constant := 16#0040_0000#;
   kCGLRGBA16161616Bit: constant := 16#0080_0000#;
   kCGLRGBFloat64Bit  : constant := 16#0100_0000#;
   kCGLRGBAFloat64Bit : constant := 16#0200_0000#;
   kCGLRGBFloat128Bit : constant := 16#0400_0000#;
   kCGLRGBAFloat128Bit: constant := 16#0800_0000#;
   kCGLRGBFloat256Bit : constant := 16#1000_0000#;
   kCGLRGBAFloat256Bit: constant := 16#2000_0000#;

   kCGLSupersampleBit : constant := 16#0000_0001#;
   kCGLMultisampleBit : constant := 16#0000_0002#;

   type CGLPixelFormatAttribute_array is array (Positive range <>) of
     aliased CGLPixelFormatAttribute;


   -- Pixel format functions

   function CGLChoosePixelFormat (attribs : access CGLPixelFormatAttribute;
                                  pix     : access CGLPixelFormatObject;
                                  npix    : access GLint) return CGLError;

   function CGLDestroyPixelFormat (pix : in CGLPixelFormatObject) return CGLError;

   function CGLDescribePixelFormat (pix    : in CGLPixelFormatObject; pix_num : in GLint;
                                    attrib : in CGLPixelFormatAttribute;
                                    value  : access GLint) return CGLError;

   procedure CGLReleasePixelFormat (pix : in CGLPixelFormatObject);

   function CGLRetainPixelFormat (pix : in CGLPixelFormatObject)
                                  return CGLPixelFormatObject;

   function CGLGetPixelFormatRetainCount (pix : in CGLPixelFormatObject)
                                          return GLuint;

   function CGLQueryRendererInfo (display_mask : in GLuint;
                                  rend         : access CGLRendererInfoObject;
                                  nrend        : access GLint) return CGLError;

   function CGLDestroyRendererInfo (rend : in CGLRendererInfoObject)
                                    return CGLError;

   function CGLDescribeRenderer (rend  : in CGLRendererInfoObject; rend_num : in GLint;
                                 prop  : in CGLRendererProperty;
                                 value : access GLint) return CGLError;

   function CGLCreateContext (pix   : in CGLPixelFormatObject;
                              share : in CGLContextObject;
                              ctx   : access CGLContextObject) return CGLError;

   function CGLDestroyContext (ctx : in CGLContextObject) return CGLError;

   function CGLCopyContext (src, dst : in CGLContextObject;
                            mask     : in GLbitfield) return CGLError;

   function CGLRetainContext (ctx : in CGLContextObject) return CGLContextObject;

   procedure CGLReleaseContext (ctx : in CGLContextObject);

   function CGLGetContextRetainCount (ctx : in CGLContextObject) return GLuint;

   function CGLGetPixelFormat (ctx : in CGLContextObject) return CGLPixelFormatObject;

   function CGLCreatePBuffer (width, height          : in GLsizei;
                              target, internalFormat : in GLenum;
                              max_level              : in GLint;
                              pbuffer                : access CGLPBufferObject)
                              return CGLError;

   function CGLDestroyPBuffer (pbuffer : in CGLPBufferObject) return CGLError;

   function CGLDescribePBuffer (obj                    : in CGLPBufferObject;
                                width, height          : access GLsizei;
                                target, internalFormat : access GLenum;
                                mipmap                 : access GLint) return CGLError;

   function CGLTexImagePBuffer (ctx     : in CGLContextObject;
                                pbuffer : in CGLPBufferObject;
                                source  : in GLenum) return CGLError;

   function CGLRetainPBuffer (pbuffer : in CGLPBufferObject)
                              return CGLPBufferObject;

   procedure CGLReleasePBuffer (pbuffer : in CGLPBufferObject);

   function CGLGetPBufferRetainCount (pbuffer : in CGLPBufferObject) return GLuint;

   function CGLSetOffScreen (ctx           : in CGLContextObject;
                             width, height : in GLsizei;
                             rowbytes      : in GLint;
                             baseaddr      : in interfaces.C.Extensions.void_ptr)
                             return CGLError;

   function CGLGetOffScreen (ctx           : in CGLContextObject;
                             width, height : access GLsizei;
                             rowbytes      : access GLint;
                             baseaddr      : access interfaces.C.Extensions.void_ptr)
                             return CGLError;

   function CGLSetFullScreen (ctx : in CGLContextObject) return CGLError;

   function CGLSetFullScreenOnDisplay (ctx          : in CGLContextObject;
                                       display_mask : in GLuint) return CGLError;

   function CGLSetPBuffer (ctx           : in CGLContextObject;
                           pbuffer       : in CGLPBufferObject;
                           face          : in GLenum;
                           level, screen : in GLint) return CGLError;

   function CGLGetPBuffer (ctx           : in CGLContextObject;
                           pbuffer       : access CGLPBufferObject;
                           face          : access GLenum;
                           level, screen : access GLint) return CGLError;

   function CGLClearDrawable (ctx : in CGLContextObject) return CGLError;

   function CGLFlushDrawable (ctx : in CGLContextObject) return CGLError;

   function CGLEnable (ctx : in CGLContextObject; pname : in CGLContextEnable)
                       return CGLError;

   function CGLDisable (ctx : in CGLContextObject; pname : in CGLContextEnable)
                        return CGLError;

   function CGLIsEnabled (ctx    : in CGLContextObject; pname : in CGLContextEnable;
                          enable : access GLint) return CGLError;

   function CGLSetParameter (ctx    : in CGLContextObject;
                             pname  : in CGLContextParameter;
                             params : access constant GLint) return CGLError;

   function CGLGetParameter (ctx    : in CGLContextObject;
                             pname  : in CGLContextParameter;
                             params : access GLint) return CGLError;

   function CGLSetVirtualScreen (ctx : in CGLContextObject; screen : in GLint)
                                 return CGLError;

   function CGLGetVirtualScreen (ctx : in CGLContextObject; screen : access GLint)
                                 return CGLError;

   function CGLUpdateContext (ctx : in CGLContextObject) return CGLError;

   function CGLSetGlobalOption (pname  : in CGLGlobalOption;
                                params : access constant GLint) return CGLError;

   function CGLGetGlobalOption (pname  : in CGLGlobalOption;
                                params : access GLint) return CGLError;

   function CGLSetOption (pname : in CGLGlobalOption; param : in GLint)
                          return CGLError;

   function CGLGetOption (pname : in CGLGlobalOption;
                          param : access GLint) return CGLError;

   function CGLLockContext (ctx : in CGLContextObject) return CGLError;

   function CGLUnlockContext (ctx : in CGLContextObject) return CGLError;

   procedure CGLGetVersion (majorvers, minorvers : out GLint);

   function CGLErrorString (error : in CGLError)
                            return interfaces.C.Strings.chars_ptr;

   function CGLSetCurrentContext (ctx : in CGLContextObject) return CGLError;

   function CGLGetCurrentContext return CGLContextObject;



private
   C_Enum_Size : constant := 32;

   for CGLPixelFormatAttribute use (Terminator                =>   0,
                                    kCGLPFAAllRenderers       =>   1,
                                    kCGLPFATripleBuffer       =>   3,
                                    kCGLPFADoubleBuffer       =>   5,
                                    kCGLPFAStereo             =>   6,
                                    kCGLPFAAuxBuffers         =>   7,
                                    kCGLPFAColorSize          =>   8,
                                    kCGLPFAAlphaSize          =>  11,
                                    kCGLPFADepthSize          =>  12,
                                    kCGLPFAStencilSize        =>  13,
                                    kCGLPFAAccumSize          =>  14,
                                    kCGLPFAMinimumPolicy      =>  51,
                                    kCGLPFAMaximumPolicy      =>  52,
                                    kCGLPFAOffScreen          =>  53,
                                    kCGLPFAFullScreen         =>  54,
                                    kCGLPFASampleBuffers      =>  55,
                                    kCGLPFASamples            =>  56,
                                    kCGLPFAAuxDepthStencil    =>  57,
                                    kCGLPFAColorFloat         =>  58,
                                    kCGLPFAMultisample        =>  59,
                                    kCGLPFASupersample        =>  60,
                                    kCGLPFASampleAlpha        =>  61,

                                    kCGLPFARendererID            =>  70,
                                    kCGLPFASingleRenderer        =>  71,
                                    kCGLPFANoRecovery            =>  72,
                                    kCGLPFAAccelerated           =>  73,
                                    kCGLPFAClosestPolicy         =>  74,
                                    kCGLPFARobust                =>  75,
                                    kCGLPFABackingStore          =>  76,
                                    kCGLPFAMPSafe                =>  78,
                                    kCGLPFAWindow                =>  80,
                                    kCGLPFAMultiScreen           =>  81,
                                    kCGLPFACompliant             =>  83,
                                    kCGLPFADisplayMask           =>  84,
                                    kCGLPFAPBuffer               =>  90,
                                    kCGLPFARemotePBuffer         =>  91,
                                    kCGLPFAAllowOfflineRenderers =>  96,
                                    kCGLPFAAcceleratedCompute    =>  97,
                                    kCGLPFAOpenGLProfile         =>  99,
                                    kCGLPFAVirtualScreenCount    => 128
                                   );
   for CGLPixelFormatAttribute'Size use C_Enum_Size;
   pragma Convention (C, CGLPixelFormatAttribute);

   for CGLRendererProperty use (kCGLRPOffScreen              =>  53,
                                kCGLRPFullScreen             =>  54,
                                kCGLRPRendererID             =>  70,
                                kCGLRPAccelerated            =>  73,
                                kCGLRPRobust                 =>  75,
                                kCGLRPBackingStore           =>  76,
                                kCGLRPMPSafe                 =>  78,
                                kCGLRPWindow                 =>  80,
                                kCGLRPMultiScreen            =>  81,
                                kCGLRPCompliant              =>  83,
                                kCGLRPDisplayMask            =>  84,
                                kCGLRPBufferModes            => 100,
                                kCGLRPColorModes             => 103,
                                kCGLRPAccumModes             => 104,
                                kCGLRPDepthModes             => 105,
                                kCGLRPStencilModes           => 106,
                                kCGLRPMaxAuxBuffers          => 107,
                                kCGLRPMaxSampleBuffers       => 108,
                                kCGLRPMaxSamples             => 109,
                                kCGLRPSampleModes            => 110,
                                kCGLRPSampleAlpha            => 111,
                                kCGLRPVideoMemory            => 120,
                                kCGLRPTextureMemory          => 121,
                                kCGLRPGPUVertProcCapable     => 122,
                                kCGLRPGPUFragProcCapable     => 123,
                                kCGLRPRendererCount          => 128,
                                kCGLRPOnline                 => 129,
                                kCGLRPAcceleratedCompute     => 130,
                                kCGLRPVideoMemoryMegabytes   => 131,
                                kCGLRPTextureMemoryMegabytes => 132
                               );
   for CGLRendererProperty'Size use C_Enum_Size;
   pragma Convention (C, CGLRendererProperty);

   for CGLContextEnable use (kCGLCESwapRectangle           => 201,
                             kCGLCESwapLimit               => 203,
                             kCGLCERasterization           => 221,
                             kCGLCEStateValidation         => 301,
                             kCGLCESurfaceBackingSize      => 305,
                             kCGLCEDisplayListOptimization => 307,
                             kCGLCEMPEngine                => 313,
                             kCGLCECrashOnRemovedFunctions => 316
                            );
   for CGLContextEnable'Size use C_Enum_Size;
   pragma Convention (C, CGLContextEnable);

   for CGLContextParameter use (kCGLCPSwapRectangle          => 200,
                                kCGLCPSwapInterval           => 222,
                                kCGLCPDispatchTableSize      => 224,
                                kCGLCPClientStorage          => 226,
                                kCGLCPSurfaceTexture         => 228,
                                kCGLCPSurfaceOrder           => 235,
                                kCGLCPSurfaceOpacity         => 236,
                                kCGLCPSurfaceBackingSize     => 304,
                                kCGLCPSurfaceSurfaceVolatile => 306,
                                kCGLCPReclaimResources       => 308,
                                kCGLCPCurrentRendererID      => 309,
                                kCGLCPGPUVertexProcessing    => 310,
                                kCGLCPGPUFragmentProcessing  => 311,
                                kCGLCPHasDrawable            => 314,
                                kCGLCPMPSwapsInFlight        => 315
                               );
   for CGLContextParameter'Size use C_Enum_Size;
   pragma Convention (C, CGLContextParameter);

   for CGLGlobalOption use (kCGLGOFormatCacheSize  => 501,
                            kCGLGOClearFormatCache => 502,
                            kCGLGORetainRenderers  => 503,
                            kCGLGOResetLibrary     => 504,
                            kCGLGOUseErrorHandler  => 505,
                            kCGLGOUseBuildCache    => 506
                           );
   for CGLGlobalOption'Size use C_Enum_Size;
   pragma Convention (C, CGLGlobalOption);

   for CGLOpenGLProfile use (kCGLOGLPVersion_Legacy   => 16#1000#,
                             kCGLOGLPVersion_3_2_Core => 16#3200#
                            );
   for CGLOpenGLProfile'Size use C_Enum_Size;
   pragma Convention (C, CGLOpenGLProfile);

   for CGLError use (kCGLNoError            => 0,
                     kCGLBadAttribute       => 10_000,
                     kCGLBadProperty        => 10_001,
                     kCGLBadPixelFormat     => 10_002,
                     kCGLBadRendererInfo    => 10_003,
                     kCGLBadContext         => 10_004,
                     kCGLBadDrawable        => 10_005,
                     kCGLBadDisplay         => 10_006,
                     kCGLBadState           => 10_007,
                     kCGLBadValue           => 10_008,
                     kCGLBadMatch           => 10_009,
                     kCGLBadEnumeration     => 10_010,
                     kCGLBadOffScreen       => 10_011,
                     kCGLBadFullScreen      => 10_012,
                     kCGLBadWindow          => 10_013,
                     kCGLBadAddress         => 10_014,
                     kCGLBadCodeModule      => 10_015,
                     kCGLBadAlloc           => 10_016,
                     kCGLBadConnection      => 10_017
                    );
   for CGLError'Size use C_Enum_Size;
   pragma Convention (C, CGLError);

   pragma import (C, CGLChoosePixelFormat,         "CGLChoosePixelFormat");
   pragma import (C, CGLDestroyPixelFormat,        "CGLDestroyPixelFormat");
   pragma import (C, CGLDescribePixelFormat,       "CGLDescribePixelFormat");
   pragma import (C, CGLReleasePixelFormat,        "CGLReleasePixelFormat");
   pragma import (C, CGLRetainPixelFormat,         "CGLRetainPixelFormat");
   pragma import (C, CGLGetPixelFormatRetainCount, "CGLGetPixelFormatRetainCount");

   pragma import (C, CGLQueryRendererInfo,   "CGLQueryRendererInfo");
   pragma import (C, CGLDestroyRendererInfo, "CGLDestroyRendererInfo");
   pragma import (C, CGLDescribeRenderer,    "CGLDescribeRenderer");

   pragma import (C, CGLCreateContext,         "CGLCreateContext");
   pragma import (C, CGLDestroyContext,        "CGLDestroyContext");
   pragma import (C, CGLCopyContext,           "CGLCopyContext");
   pragma import (C, CGLRetainContext,         "CGLRetainContext");
   pragma import (C, CGLReleaseContext,        "CGLReleaseContext");
   pragma import (C, CGLGetContextRetainCount, "CGLGetContextRetainCount");
   pragma import (C, CGLGetPixelFormat,        "CGLGetPixelFormat");

   pragma import (C, CGLCreatePBuffer,         "CGLCreatePBuffer");
   pragma import (C, CGLDestroyPBuffer,        "CGLDestroyPBuffer");
   pragma import (C, CGLDescribePBuffer,       "CGLDescribePBuffer");
   pragma import (C, CGLTexImagePBuffer,       "CGLTexImagePBuffer");
   pragma import (C, CGLRetainPBuffer,         "CGLRetainPBuffer");
   pragma import (C, CGLReleasePBuffer,        "CGLReleasePBuffer");
   pragma import (C, CGLGetPBufferRetainCount, "CGLGetPBufferRetainCount");

   pragma import (C, CGLSetOffScreen,           "CGLSetOffScreen");
   pragma import (C, CGLGetOffScreen,           "CGLGetOffScreen");
   pragma import (C, CGLSetFullScreen,          "CGLSetFullScreen");
   pragma import (C, CGLSetFullScreenOnDisplay, "CGLSetFullScreenOnDisplay");
   pragma import (C, CGLSetPBuffer,             "CGLSetPBuffer");
   pragma import (C, CGLGetPBuffer,             "CGLGetPBuffer");
   pragma import (C, CGLClearDrawable,          "CGLClearDrawable");
   pragma import (C, CGLFlushDrawable,          "CGLFlushDrawable");

   pragma import (C, CGLEnable,       "CGLEnable");
   pragma import (C, CGLDisable,      "CGLDisable");
   pragma import (C, CGLIsEnabled,    "CGLIsEnabled");
   pragma import (C, CGLSetParameter, "CGLSetParameter");
   pragma import (C, CGLGetParameter, "CGLGetParameter");

   pragma import (C, CGLSetVirtualScreen, "CGLSetVirtualScreen");
   pragma import (C, CGLGetVirtualScreen, "CGLGetVirtualScreen");
   pragma import (C, CGLUpdateContext,    "CGLUpdateContext");

   pragma import (C, CGLSetGlobalOption, "CGLSetGlobalOption");
   pragma import (C, CGLGetGlobalOption, "CGLGetGlobalOption");
   pragma import (C, CGLSetOption,       "CGLSetOption");
   pragma import (C, CGLGetOption,       "CGLGetOption");

   pragma import (C, CGLLockContext,   "CGLLockContext");
   pragma import (C, CGLUnlockContext, "CGLUnlockContext");


   pragma import (C, CGLGetVersion,  "CGLGetVersion");
   pragma import (C, CGLErrorString, "CGLErrorString");

   pragma import (C, CGLSetCurrentContext, "CGLSetCurrentContext");
   pragma import (C, CGLGetCurrentContext, "CGLGetCurrentContext");


end GL.CGL;
