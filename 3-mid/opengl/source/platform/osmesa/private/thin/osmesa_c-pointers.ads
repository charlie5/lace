-- This file is generated by SWIG. Please do *not* modify by hand.
--
with Interfaces.C;

package osmesa_c.Pointers is

   -- GLenum_Pointer
   --
   type GLenum_Pointer is access all osmesa_c.GLenum;

   -- GLenum_Pointers
   --
   type GLenum_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.GLenum_Pointer;

   -- GLint_Pointer
   --
   type GLint_Pointer is access all osmesa_c.GLint;

   -- GLint_Pointers
   --
   type GLint_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.GLint_Pointer;

   -- GLsizei_Pointer
   --
   type GLsizei_Pointer is access all osmesa_c.GLsizei;

   -- GLsizei_Pointers
   --
   type GLsizei_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.GLsizei_Pointer;

   -- GLboolean_Pointer
   --
   type GLboolean_Pointer is access all osmesa_c.GLboolean;

   -- GLboolean_Pointers
   --
   type GLboolean_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.GLboolean_Pointer;

   -- OSMesaContext_Pointer
   --
   type OSMesaContext_Pointer is access all osmesa_c.OSMesaContext;

   -- OSMesaContext_Pointers
   --
   type OSMesaContext_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.OSMesaContext_Pointer;

   -- OSMESAproc_Pointer
   --
   type OSMESAproc_Pointer is access all osmesa_c.OSMESAproc;

   -- OSMESAproc_Pointers
   --
   type OSMESAproc_Pointers is
     array
       (Interfaces.C
          .size_t range <>) of aliased osmesa_c.Pointers.OSMESAproc_Pointer;

end osmesa_c.Pointers;
