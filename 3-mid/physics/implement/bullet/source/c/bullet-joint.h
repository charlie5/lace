#ifndef C_BULLET_JOINT_H
#define C_BULLET_JOINT_H

#include "bullet.h"
#include "bullet-object.h"


extern "C"
{
  struct Joint;

  // Degrees of freedom are numbered as in the physics interface: 1 .. 3 are the
  // translations along X, Y and Z, 4 .. 6 the rotations about them. A hinge has
  // the single degree 1.
  //
  // Attributes which do not apply to a kind of joint return 0 (or false), and the
  // setters return 0 to say so.

  /////////
  /// Forge
  //

  Joint*     b3d_new_hinge_Joint         (Object*       Object_A,
                                          Object*       Object_B,
                                          Matrix_4x4*   Frame_A,
                                          Matrix_4x4*   Frame_B);
  Joint*     b3d_new_hinge_Joint_with_anchors (Object*     Object_A,
                                               Object*     Object_B,
                                               Vector_3*   Anchor_in_A,
                                               Vector_3*   Anchor_in_B,
                                               Vector_3*   Axis);
  Joint*     b3d_new_space_hinge_Joint   (Object*       Object_A,
                                          Matrix_4x4*   Frame_A);
  Joint*     b3d_new_DoF6_Joint          (Object*       Object_A,
                                          Object*       Object_B,
                                          Matrix_4x4*   Frame_A,
                                          Matrix_4x4*   Frame_B);
  Joint*     b3d_new_cone_twist_Joint    (Object*       Object_A,
                                          Object*       Object_B,
                                          Matrix_4x4*   Frame_A,
                                          Matrix_4x4*   Frame_B);
  Joint*     b3d_new_slider_Joint        (Object*       Object_A,
                                          Object*       Object_B,
                                          Matrix_4x4*   Frame_A,
                                          Matrix_4x4*   Frame_B);
  Joint*     b3d_new_ball_Joint          (Object*       Object_A,
                                          Object*       Object_B,
                                          Vector_3*     Pivot_in_A,
                                          Vector_3*     Pivot_in_B);

  void       b3d_free_Joint              (Joint*   Self);


  /////////////
  // Attributes
  //

  void*             b3d_Joint_user_Data      (Joint*   Self);
  void              b3d_Joint_user_Data_is   (Joint*   Self,   void*   Now);

  Object*           b3d_Joint_Object_A       (Joint*   Self);
  Object*           b3d_Joint_Object_B       (Joint*   Self);

  Matrix_4x4        b3d_Joint_Frame_A        (Joint*   Self);
  Matrix_4x4        b3d_Joint_Frame_B        (Joint*   Self);
  int               b3d_Joint_Frame_A_is     (Joint*   Self,   Matrix_4x4*   Now);
  int               b3d_Joint_Frame_B_is     (Joint*   Self,   Matrix_4x4*   Now);

  bool              b3d_Joint_is_Limited     (Joint*   Self,   int           DoF);
  Real              b3d_Joint_Extent         (Joint*   Self,   int           DoF);
  int               b3d_Joint_Velocity_is    (Joint*   Self,   int           DoF,
                                                               Real          Now);
  int               b3d_Joint_desired_Extent_is (Joint*   Self,   int        DoF,
                                                                  Real       Now);

  Real              b3d_Joint_lower_Limit    (Joint*   Self,   int           DoF);
  Real              b3d_Joint_upper_Limit    (Joint*   Self,   int           DoF);
  int               b3d_Joint_lower_Limit_is (Joint*   Self,   int           DoF,
                                                               Real          Now);
  int               b3d_Joint_upper_Limit_is (Joint*   Self,   int           DoF,
                                                               Real          Now);

  Real              b3d_Joint_applied_Impulse (Joint*   Self);


  // Hinge Joint
  //
  void             b3d_Joint_hinge_Limits_are (Joint*   Self,   Real           Lower,
                                                                Real           Upper,
                                                                Real           Softeness,
                                                                Real           bias_Factor,
                                                                Real           relaxation_Factor);
  bool             b3d_Joint_hinge_motor_Enabled    (Joint*   Self);
  Real             b3d_Joint_hinge_motor_Speed      (Joint*   Self);
  Real             b3d_Joint_hinge_max_motor_Torque (Joint*   Self);

} // extern "C"

#endif
