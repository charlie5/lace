-- Written by hand in the style of the SWIG generated bindings, since the
-- 'swig_gnat' generator is no longer available. Mirrors 'point_Collision' in
-- '../c/bullet-space.h'.
--
with
     c_math_c.Vector_3,
     interfaces.C;


package bullet_c.point_Collision
is
   --- Item
   --

   type Item is
      record
         near_Object : access  bullet_c.Object;
         Site_world  : aliased c_math_c.Vector_3.Item;
      end record;


   --- Items
   --

   type Items is array (interfaces.C.size_t range <>) of aliased bullet_c.point_Collision.Item;


   --- Pointer
   --

   type Pointer is access all bullet_c.point_Collision.Item;


end bullet_c.point_Collision;
