with
     box2d_c.Binding,
     box2d_physics.Object,
     c_math_c.Vector_3,
     c_math_c.Matrix_4x4,
     c_math_c.Conversion,
     Swig,
     interfaces.C,
     ada.unchecked_Deallocation,
     ada.unchecked_Conversion;


package body box2d_Physics.Joint
is
   use
        c_math_c.Conversion,
        box2d_c.Binding,
        Interfaces;

   use type C.int;

   type Any_limited_view is access all lace.Any.limited_item'Class;

   function to_Any_view is new ada.unchecked_Conversion (Swig.void_ptr,    Any_limited_view);
   function to_void_ptr is new ada.unchecked_Conversion (Any_limited_view, Swig.void_ptr);



   function c_Object (Object : in physics.Object.view) return box2d_c.Pointers.Object_pointer
   is
      use type physics.Object.view;
   begin
      if Object = null
      then
         raise physics.unsupported_Error with "A box2d joint needs both of its objects.";
      end if;

      return box2d_physics.Object.view (Object).C;
   end c_Object;



   procedure check (Supported : in C.int;   Operation : in String)
   is
   begin
      if Supported = 0
      then
         raise physics.unsupported_Error with "Box2d joint: " & Operation & " does not apply to this kind of joint.";
      end if;
   end check;



   ---------
   --- Forge
   --

   function new_Dof6_Joint (Object_A, Object_B : in physics.Object.view;
                            Frame_A,  Frame_B  : in Matrix_4x4) return physics.Joint.DoF6.view
   is
      Self      : constant DoF6_view := new DoF6;
      c_Frame_A : aliased c_math_c.Matrix_4x4.item := +Frame_A;
      c_Frame_B : aliased c_math_c.Matrix_4x4.item := +Frame_B;
   begin
      Self.C := b2d_new_DoF6_Joint (c_Object (Object_A),
                                    c_Object (Object_B),
                                    c_Frame_A'unchecked_Access,
                                    c_Frame_B'unchecked_Access);
      return physics.Joint.DoF6.view (Self);
   end new_Dof6_Joint;



   function new_Ball_Joint (Object_A,   Object_B   : in physics.Object.view;
                            Pivot_in_A, Pivot_in_B : in Vector_3) return physics.Joint.ball.view
   is
      Self         : constant Ball_view := new Ball;
      c_Pivot_in_A : aliased c_math_c.Vector_3.item := +Pivot_in_A;
      c_Pivot_in_B : aliased c_math_c.Vector_3.item := +Pivot_in_B;
   begin
      Self.C := b2d_new_ball_Joint (c_Object (Object_A),
                                    c_Object (Object_B),
                                    c_Pivot_in_A'unchecked_Access,
                                    c_Pivot_in_B'unchecked_Access);
      return physics.Joint.ball.view (Self);
   end new_Ball_Joint;



   function new_Slider_Joint (Object_A, Object_B : in physics.Object.view;
                              Frame_A,  Frame_B  : in Matrix_4x4) return physics.Joint.slider.view
   is
      Self      : constant Slider_view := new Slider;
      c_Frame_A : aliased  c_math_c.Matrix_4x4.item := +Frame_A;
      c_Frame_B : aliased  c_math_c.Matrix_4x4.item := +Frame_B;
   begin
      Self.C := b2d_new_slider_Joint (c_Object (Object_A),
                                      c_Object (Object_B),
                                      c_Frame_A'unchecked_Access,
                                      c_Frame_B'unchecked_Access);
      return physics.Joint.slider.view (Self);
   end new_Slider_Joint;



   function new_cone_Twist_Joint (Object_A, Object_B : in physics.Object.view;
                                  Frame_A,  Frame_B  : in Matrix_4x4) return physics.Joint.cone_twist.view
   is
      Self      : constant cone_Twist_view := new cone_Twist;
      c_Frame_A : aliased c_math_c.Matrix_4x4.item := +Frame_A;
      c_Frame_B : aliased c_math_c.Matrix_4x4.item := +Frame_B;
   begin
      Self.C := b2d_new_cone_twist_Joint (c_Object (Object_A),
                                          c_Object (Object_B),
                                          c_Frame_A'unchecked_Access,
                                          c_Frame_B'unchecked_Access);
      return physics.Joint.cone_twist.view (Self);
   end new_cone_Twist_Joint;



   function new_hinge_Joint (in_Space                 : in box2d_c.Pointers.Space_pointer;
                             Object_A,    Object_B    : in physics.Object.view;
                             Anchor_in_A, Anchor_in_B : in Vector_3;
                             low_Limit,   high_Limit  : in math.Real;
                             collide_Connected        : in Boolean) return physics.Joint.hinge.view
   is
      Self          : constant Hinge_view := new Hinge;
      c_Anchor_in_A : aliased c_math_c.Vector_3.item := +Anchor_in_A;
      c_Anchor_in_B : aliased c_math_c.Vector_3.item := +Anchor_in_B;
   begin
      Self.C := b2d_new_hinge_Joint_with_local_anchors (in_Space,
                                                        c_Object (Object_A),
                                                        c_Object (Object_B),
                                                        c_Anchor_in_A'unchecked_Access,
                                                        c_Anchor_in_B'unchecked_Access,
                                                        c_math_c.Real (low_Limit),
                                                        c_math_c.Real (high_Limit),
                                                        swig.bool (collide_Connected));
      return physics.Joint.hinge.view (Self);
   end new_hinge_Joint;



   function new_hinge_Joint (in_Space : in box2d_c.Pointers.Space_pointer;
                             Object_A : in physics.Object.view;
                             Frame_A  : in Matrix_4x4) return physics.Joint.hinge.view
   is
      Self      : constant Hinge_view := new Hinge;
      c_Frame_A : aliased  c_math_c.Matrix_4x4.item := +Frame_A;
   begin
      Self.C := b2d_new_space_hinge_Joint (in_Space,
                                           c_Object (Object_A),
                                           c_Frame_A'unchecked_Access);
      return physics.Joint.hinge.view (Self);
   end new_hinge_Joint;



   function new_hinge_Joint (in_Space              : in box2d_c.Pointers.Space_pointer;
                             Object_A,  Object_B   : in physics.Object.view;
                             Frame_A,   Frame_B    : in Matrix_4x4;
                             low_Limit, high_Limit : in math.Real;
                             collide_Connected     : in Boolean) return physics.Joint.hinge.view
   is
      Self      : constant Hinge_view := new Hinge;
      c_Frame_A : aliased c_math_c.Matrix_4x4.item := +Frame_A;
      c_Frame_B : aliased c_math_c.Matrix_4x4.item := +Frame_B;
   begin
      Self.C := b2d_new_hinge_Joint (in_Space,
                                     c_Object (Object_A),
                                     c_Object (Object_B),
                                     c_Frame_A'unchecked_Access,
                                     c_Frame_B'unchecked_Access,
                                     c_math_c.Real (low_Limit),
                                     c_math_c.Real (high_Limit),
                                     swig.bool (collide_Connected));
      return physics.Joint.hinge.view (Self);
   end new_hinge_Joint;



   overriding
   procedure destruct (Self : in out Item)
   --
   -- The joint must already have been removed from its space.
   --
   is
      use type box2d_c.Pointers.Joint_pointer;
   begin
      if Self.C /= null
      then
         b2d_free_Joint (Self.C);
         Self.C := null;
      end if;
   end destruct;



   procedure free (the_Joint : in out physics.Joint.view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (physics.Joint.item'Class,
                                                              physics.Joint.view);
   begin
      the_Joint.destruct;
      deallocate (the_Joint);
   end free;



   --------------
   --- Attributes
   --

   procedure register (Self : in View)
   is
   begin
      b2d_Joint_user_Data_is (Self.C, to_void_ptr (Any_limited_view (Self)));
   end register;



   function to_Object (c_Object : in box2d_c.Pointers.Object_pointer) return physics.Object.view
   is
      use type box2d_c.Pointers.Object_pointer;
   begin
      if c_Object = null
      then
         return null;     -- The ground body of a space hinge.
      end if;

      return physics.Object.view (to_Any_view (b2d_Object_user_Data (c_Object)));
   end to_Object;



   overriding
   function Object_A (Self : in Item) return physics.Object.view
   is
   begin
      return to_Object (b2d_Joint_Object_A (Self.C));
   end Object_A;



   overriding
   function Object_B (Self : in Item) return physics.Object.view
   is
   begin
      return to_Object (b2d_Joint_Object_B (Self.C));
   end Object_B;



   overriding
   function Frame_A (Self : in Item) return Matrix_4x4
   is
   begin
      return +b2d_Joint_Frame_A (Self.C);
   end Frame_A;



   overriding
   function Frame_B (Self : in Item) return Matrix_4x4
   is
   begin
      return +b2d_Joint_Frame_B (Self.C);
   end Frame_B;



   overriding
   procedure Frame_A_is (Self : in out Item;   Now : in Matrix_4x4)
   is
      c_Now : aliased c_math_c.Matrix_4x4.item := +Now;
   begin
      check (b2d_Joint_Frame_A_is (Self.C, c_Now'unchecked_Access),   "Frame_A_is");
   end Frame_A_is;



   overriding
   procedure Frame_B_is (Self : in out Item;   Now : in Matrix_4x4)
   is
      c_Now : aliased c_math_c.Matrix_4x4.item := +Now;
   begin
      check (b2d_Joint_Frame_B_is (Self.C, c_Now'unchecked_Access),   "Frame_B_is");
   end Frame_B_is;



   overriding
   function is_Limited (Self : in Item;   DoF : in Degree_of_freedom) return Boolean
   is
   begin
      return Boolean (b2d_Joint_is_Limited (Self.C, C.int (DoF)));
   end is_Limited;



   overriding
   procedure Velocity_is (Self : in out Item;   Now : in Real;
                                                DoF : in Degree_of_freedom)
   is
   begin
      check (b2d_Joint_Velocity_is (Self.C, C.int (DoF),
                                            c_math_c.Real (Now)),   "Velocity_is");
   end Velocity_is;



   overriding
   function Extent (Self : in Item;   DoF : in Degree_of_freedom) return Real
   is
   begin
      return Real (b2d_Joint_Extent (Self.C, C.int (DoF)));
   end Extent;



   overriding
   procedure desired_Extent_is (Self : in out Item;   Now : in Real;
                                                      DoF : in Degree_of_freedom)
   is
   begin
      raise physics.unsupported_Error with "Box2d joints have no position motor; use Velocity_is.";
   end desired_Extent_is;



   overriding
   function reaction_Force (Self : in Item) return Vector_3
   is
   begin
      return +b2d_Joint_reaction_Force (Self.C);
   end reaction_Force;



   overriding
   function reaction_Torque (Self : in Item) return Real
   is
   begin
      return +b2d_Joint_reaction_Torque (Self.C);
   end reaction_Torque;



   overriding
   procedure user_Data_is (Self : in out Item;   Now : access lace.Any.limited_item'Class)
   is
   begin
      Self.user_Data := Now;
   end user_Data_is;



   overriding
   function user_Data (Self : in Item) return access lace.Any.limited_item'Class
   is
   begin
      return Self.user_Data;
   end user_Data;



   overriding
   function collide_Connected (Self : in Item) return Boolean
   is
   begin
      return Boolean (b2d_Joint_collide_Connected (Self.C));
   end collide_Connected;



   ----------
   --- Limits
   --

   function lower_Limit (Self : in Item;   DoF : in Degree_of_freedom) return Real
   is
   begin
      return Real (b2d_Joint_lower_Limit (Self.C, C.int (DoF)));
   end lower_Limit;



   function upper_Limit (Self : in Item;   DoF : in Degree_of_freedom) return Real
   is
   begin
      return Real (b2d_Joint_upper_Limit (Self.C, C.int (DoF)));
   end upper_Limit;



   procedure lower_Limit_is (Self : in out Item;   Now : in Real;
                                                   DoF : in Degree_of_freedom)
   is
   begin
      check (b2d_Joint_lower_Limit_is (Self.C, C.int (DoF),
                                               c_math_c.Real (Now)),   "lower_Limit_is");
   end lower_Limit_is;



   procedure upper_Limit_is (Self : in out Item;   Now : in Real;
                                                   DoF : in Degree_of_freedom)
   is
   begin
      check (b2d_Joint_upper_Limit_is (Self.C, C.int (DoF),
                                               c_math_c.Real (Now)),   "upper_Limit_is");
   end upper_Limit_is;



   ---------
   --- Hinge
   --

   Revolve : constant Degree_of_freedom := 1;


   overriding
   procedure Limits_are (Self : in out Hinge;   Low, High        : in Real;
                                                Softness         : in Real := 0.9;
                                                biasFactor       : in Real := 0.3;
                                                relaxationFactor : in Real := 1.0)
   is
      pragma Unreferenced (Softness, biasFactor, relaxationFactor);     -- Box2d limits are rigid.
   begin
      b2d_Joint_hinge_Limits_are (Self.C, c_math_c.Real (Low),
                                          c_math_c.Real (High));
   end Limits_are;



   overriding
   function lower_Limit (Self : in Hinge) return Real
   is
   begin
      return Self.lower_Limit (Revolve);
   end lower_Limit;



   overriding
   function upper_Limit (Self : in Hinge) return Real
   is
   begin
      return Self.upper_Limit (Revolve);
   end upper_Limit;



   overriding
   function limit_Enabled (Self : in Hinge) return Boolean
   is
   begin
      return Boolean (b2d_Joint_hinge_limit_Enabled (Self.C));
   end limit_Enabled;



   overriding
   function reference_Angle (Self : in Hinge) return Radians
   is
   begin
      return Radians (b2d_Joint_hinge_reference_Angle (Self.C));
   end reference_Angle;



   overriding
   function Angle (Self : in Hinge) return Real
   is
   begin
      return Real (b2d_Joint_hinge_Angle (Self.C));
   end Angle;



   overriding
   function local_Anchor_on_A (Self : in Hinge) return Vector_3
   is
   begin
      return +b2d_Joint_hinge_local_Anchor_on_A (Self.C);
   end local_Anchor_on_A;



   overriding
   function local_Anchor_on_B (Self : in Hinge) return Vector_3
   is
   begin
      return +b2d_Joint_hinge_local_Anchor_on_B (Self.C);
   end local_Anchor_on_B;



   overriding
   function motor_Enabled (Self : in Hinge) return Boolean
   is
   begin
      return Boolean (b2d_Joint_hinge_motor_Enabled (Self.C));
   end motor_Enabled;



   overriding
   function motor_Speed (Self : in Hinge) return Real
   is
   begin
      return Real (b2d_Joint_hinge_motor_Speed (Self.C));
   end motor_Speed;



   overriding
   function max_motor_Torque (Self : in Hinge) return Real
   is
   begin
      return Real (b2d_Joint_hinge_max_motor_Torque (Self.C));
   end max_motor_Torque;


end box2d_Physics.Joint;
