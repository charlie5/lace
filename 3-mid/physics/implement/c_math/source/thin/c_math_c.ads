-- This file is generated by SWIG. Please do *not* modify by hand.
--
with Interfaces.C;

package c_math_c is

   -- Real
   --
   subtype Real is Interfaces.C.C_float;

   type Real_array is
     array (Interfaces.C.size_t range <>) of aliased c_math_c.Real;

   -- Index
   --
   subtype Index is Interfaces.C.int;

   type Index_array is
     array (Interfaces.C.size_t range <>) of aliased c_math_c.Index;

end c_math_c;
