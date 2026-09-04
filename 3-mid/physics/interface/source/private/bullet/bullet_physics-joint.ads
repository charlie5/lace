with
     physics.Joint.DoF6,
     physics.Joint.cone_twist,
     physics.Joint.slider,
     physics.Joint.hinge,
     physics.Joint.ball,
     physics.Object,
     bullet_C.Pointers,
     lace.Any;


package bullet_Physics.Joint
--
-- Provides glue between a physics joint and a Bullet3D joint.
--
-- Degrees of freedom are numbered as in the physics interface: 1 .. 3 are the
-- translations along X, Y and Z, 4 .. 6 the rotations about them. A hinge has the
-- single degree 1. An operation which a kind of bullet joint cannot perform raises
-- physics.unsupported_Error.
--
is
   type Item is abstract limited new physics.Joint.item with
      record
         C                 :        bullet_c.Pointers.Joint_pointer;
         user_Data         : access lace.Any.limited_item'Class;
         collide_Connected :        Boolean := False;
      end record;

   type View is access all Item'Class;


   ---------
   --- Forge
   --

   use Math,
       physics.Joint;

   function new_Dof6_Joint       (Object_A,   Object_B   : in physics.Object.view;
                                  Frame_A,    Frame_B    : in Matrix_4x4) return physics.Joint.DoF6.view;

   function new_ball_Joint       (Object_A,   Object_B   : in physics.Object.view;
                                  Pivot_in_A, Pivot_in_B : in Vector_3) return physics.Joint.ball.view;

   function new_slider_Joint     (Object_A,   Object_B   : in physics.Object.view;
                                  Frame_A,    Frame_B    : in Matrix_4x4) return physics.Joint.slider.view;

   function new_cone_twist_Joint (Object_A,   Object_B   : in physics.Object.view;
                                  Frame_A,    Frame_B    : in Matrix_4x4) return physics.Joint.cone_twist.view;

   function new_hinge_Joint      (Object_A,   Object_B   : in physics.Object.view;
                                  Frame_A,    Frame_B    : in Matrix_4x4;
                                  low_Limit,  high_Limit : in Real;
                                  collide_Connected      : in Boolean) return physics.Joint.hinge.view;

   function new_hinge_Joint      (Object_A,    Object_B    : in physics.Object.view;
                                  Anchor_in_A, Anchor_in_B : in Vector_3;
                                  pivot_Axis               : in Vector_3;
                                  low_Limit,   high_Limit  : in Real;
                                  collide_Connected        : in Boolean) return physics.Joint.hinge.view;

   function new_hinge_Joint      (Object_A               : in physics.Object.view;
                                  Frame_A                : in Matrix_4x4) return physics.Joint.hinge.view;

   procedure free (the_Joint : in out physics.Joint.view);


   --------------
   --- Attributes
   --

   overriding
   procedure destruct    (Self : in out Item);

   overriding
   function  Object_A    (Self : in     Item) return physics.Object.view;
   overriding
   function  Object_B    (Self : in     Item) return physics.Object.view;

   overriding
   function  Frame_A     (Self : in     Item) return Matrix_4x4;
   overriding
   function  Frame_B     (Self : in     Item) return Matrix_4x4;

   overriding
   procedure Frame_A_is  (Self : in out Item;   Now : in Matrix_4x4);
   overriding
   procedure Frame_B_is  (Self : in out Item;   Now : in Matrix_4x4);

   overriding
   function  is_Limited  (Self : in     Item;   DoF : in Degree_of_freedom) return Boolean;

   overriding
   procedure Velocity_is (Self : in out Item;   Now : in Real;
                                                DoF : in Degree_of_freedom);
   overriding
   function  Extent            (Self : in     Item;   DoF : in Degree_of_freedom) return Real;

   overriding
   procedure desired_Extent_is (Self : in out Item;   Now : in Real;
                                                      DoF : in Degree_of_freedom);
   overriding
   function  reaction_Force  (Self : in     Item) return Vector_3;
   overriding
   function  reaction_Torque (Self : in     Item) return Real;

   overriding
   procedure user_Data_is    (Self : in out Item;   Now : access lace.Any.limited_item'Class);
   overriding
   function  user_Data       (Self : in     Item)  return access lace.Any.limited_item'Class;

   overriding
   function  collide_Connected (Self : in Item) return Boolean;


   -- Limits, which the DoF6, slider, cone twist and ball interfaces declare alike.
   --
   function  lower_Limit    (Self : in     Item;   DoF : in Degree_of_freedom) return Real;
   function  upper_Limit    (Self : in     Item;   DoF : in Degree_of_freedom) return Real;

   procedure lower_Limit_is (Self : in out Item;   Now : in Real;
                                                   DoF : in Degree_of_freedom);
   procedure upper_Limit_is (Self : in out Item;   Now : in Real;
                                                   DoF : in Degree_of_freedom);



private

   type DoF6       is new Item and physics.Joint.DoF6      .item with null record;
   type Slider     is new Item and physics.Joint.Slider    .item with null record;
   type cone_Twist is new Item and physics.Joint.cone_Twist.item with null record;
   type Ball       is new Item and physics.Joint.Ball      .item with null record;

   type DoF6_view       is access DoF6;
   type Slider_view     is access Slider;
   type cone_Twist_view is access cone_Twist;
   type Ball_view       is access Ball;


   ---------
   --- Hinge
   --

   type Hinge is new Item and physics.Joint.Hinge.item with null record;
   type Hinge_view is access Hinge;

   overriding
   procedure Limits_are  (Self : in out Hinge;   Low, High        : in Real;
                                                 Softness         : in Real := 0.9;
                                                 biasFactor       : in Real := 0.3;
                                                 relaxationFactor : in Real := 1.0);
   overriding
   function  lower_Limit (Self : in     Hinge)   return Real;
   overriding
   function  upper_Limit (Self : in     Hinge)   return Real;

   overriding
   function  limit_Enabled (Self : in Hinge) return Boolean;

   overriding
   function  reference_Angle (Self : in Hinge) return Radians;
   overriding
   function  Angle           (Self : in Hinge) return Real;

   overriding
   function  local_Anchor_on_A (Self : in Hinge) return Vector_3;
   overriding
   function  local_Anchor_on_B (Self : in Hinge) return Vector_3;

   overriding
   function motor_Enabled    (Self : in Hinge) return Boolean;
   overriding
   function motor_Speed      (Self : in Hinge) return Real;
   overriding
   function max_motor_Torque (Self : in Hinge) return Real;

end bullet_Physics.Joint;
