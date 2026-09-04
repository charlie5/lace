-- Written by hand in the style of the SWIG generated bindings, since the
-- 'swig_gnat' generator is no longer available. Mirrors 'b3d_Contact' in
-- '../c/bullet-space.h'.
--
with
     c_math_c.Vector_3,
     interfaces.C;


package bullet_c.b3d_Contact
is
   --- Item
   --

   type Item is
      record
         Object_A : access  bullet_c.Object;
         Object_B : access  bullet_c.Object;
         Site     : aliased c_math_c.Vector_3.Item;
      end record;


   --- Items
   --

   type Items is array (interfaces.C.size_t range <>) of aliased bullet_c.b3d_Contact.Item;


   --- Pointer
   --

   type Pointer is access all bullet_c.b3d_Contact.Item;


end bullet_c.b3d_Contact;
