#include "bullet-joint.h"
#include "bullet-space.h"
#include "bullet-conversions.h"

#include <btBulletDynamicsCommon.h>
#include <BulletDynamics/ConstraintSolver/btHingeConstraint.h>
#include <BulletDynamics/ConstraintSolver/btConeTwistConstraint.h>
#include <BulletDynamics/ConstraintSolver/btSliderConstraint.h>
#include <BulletDynamics/ConstraintSolver/btPoint2PointConstraint.h>
#include <BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h>



///////////////
/// C++ Support
//

static const Real   motor_Impulse = 100.0;     // The impulse a driven joint may apply per step.
static const Real   step_Duration = 1.0 / 60.0;


static btTransform
to_btTransform (Matrix_4x4*   From)
{
  btTransform   Result;

  Result.setFromOpenGLMatrix (&From->m00);
  return Result;
}


static Matrix_4x4
to_Matrix_4x4 (const btTransform&   From)
{
  btScalar   gl_Matrix [16];

  From.getOpenGLMatrix (gl_Matrix);
  return Matrix_4x4 (gl_Matrix);
}


static Matrix_4x4
to_Matrix_4x4 (const btVector3&   Translation)
{
  btTransform   Transform;

  Transform.setIdentity();
  Transform.setOrigin (Translation);
  return to_Matrix_4x4 (Transform);
}


static bool
is_Translation (int   DoF)
{
  return DoF >= 1 && DoF <= 3;
}


static bool
is_Rotation (int   DoF)
{
  return DoF >= 4 && DoF <= 6;
}



extern "C"
{

/////////
/// Forge
//

Joint*
b3d_new_hinge_Joint (Object*       Object_A,
                     Object*       Object_B,
                     Matrix_4x4*   Frame_A,
                     Matrix_4x4*   Frame_B)
{
  btTypedConstraint*   Self = new btHingeConstraint (*to_bullet_Object (Object_A),
                                                     *to_bullet_Object (Object_B),
                                                     to_btTransform (Frame_A),
                                                     to_btTransform (Frame_B));
  return (Joint*) Self;
}



Joint*
b3d_new_hinge_Joint_with_anchors (Object*     Object_A,
                                  Object*     Object_B,
                                  Vector_3*   Anchor_in_A,
                                  Vector_3*   Anchor_in_B,
                                  Vector_3*   Axis)
//
// The axis is given in the frame of Object A and expressed in the frame of B
// through the bodies' current orientations.
//
{
  btRigidBody&   Body_A    = *to_bullet_Object (Object_A);
  btRigidBody&   Body_B    = *to_bullet_Object (Object_B);
  btVector3      axis_in_A = to_btVector3 (Axis);
  btVector3      axis_in_B =   Body_B.getWorldTransform().getBasis().inverse()
                             * Body_A.getWorldTransform().getBasis()
                             * axis_in_A;

  btTypedConstraint*   Self = new btHingeConstraint (Body_A,
                                                     Body_B,
                                                     to_btVector3 (Anchor_in_A),
                                                     to_btVector3 (Anchor_in_B),
                                                     axis_in_A,
                                                     axis_in_B);
  return (Joint*) Self;
}



Joint*
b3d_new_space_hinge_Joint (Object*       Object_A,
                           Matrix_4x4*   Frame_A)
{
  btTypedConstraint*   Self = new btHingeConstraint (*to_bullet_Object (Object_A),
                                                     to_btTransform (Frame_A));
  return (Joint*) Self;
}



Joint*
b3d_new_DoF6_Joint (Object*       Object_A,
                    Object*       Object_B,
                    Matrix_4x4*   Frame_A,
                    Matrix_4x4*   Frame_B)
{
  btGeneric6DofConstraint*   Self = new btGeneric6DofConstraint (*to_bullet_Object (Object_A),
                                                                 *to_bullet_Object (Object_B),
                                                                 to_btTransform (Frame_A),
                                                                 to_btTransform (Frame_B),
                                                                 false);
  Self->setOverrideNumSolverIterations (2000);     // Improves joint limit stiffness.

  return (Joint*) Self;
}



Joint*
b3d_new_cone_twist_Joint (Object*       Object_A,
                          Object*       Object_B,
                          Matrix_4x4*   Frame_A,
                          Matrix_4x4*   Frame_B)
{
  btTypedConstraint*   Self = new btConeTwistConstraint (*to_bullet_Object (Object_A),
                                                         *to_bullet_Object (Object_B),
                                                         to_btTransform (Frame_A),
                                                         to_btTransform (Frame_B));
  return (Joint*) Self;
}



Joint*
b3d_new_slider_Joint (Object*       Object_A,
                      Object*       Object_B,
                      Matrix_4x4*   Frame_A,
                      Matrix_4x4*   Frame_B)
{
  btTypedConstraint*   Self = new btSliderConstraint (*to_bullet_Object (Object_A),
                                                      *to_bullet_Object (Object_B),
                                                      to_btTransform (Frame_A),
                                                      to_btTransform (Frame_B),
                                                      true);
  return (Joint*) Self;
}



Joint*
b3d_new_ball_Joint (Object*       Object_A,
                    Object*       Object_B,
                    Vector_3*     Pivot_in_A,
                    Vector_3*     Pivot_in_B)
{
  btTypedConstraint*   Self = new btPoint2PointConstraint (*to_bullet_Object (Object_A),
                                                           *to_bullet_Object (Object_B),
                                                           to_btVector3 (Pivot_in_A),
                                                           to_btVector3 (Pivot_in_B));
  return (Joint*) Self;
}



void
b3d_free_Joint (Joint*   Self)
//
// The joint must already have been removed from its space.
//
{
  delete to_bullet_Joint (Self);
}



//////////////
/// Attributes
//

void*
b3d_Joint_user_Data (Joint*   Self)
{
  return to_bullet_Joint (Self)->getUserConstraintPtr();
}



void
b3d_Joint_user_Data_is (Joint*   Self,
                        void*    Now)
{
  to_bullet_Joint (Self)->setUserConstraintPtr (Now);
}



Object*
b3d_Joint_Object_A (Joint*   Self)
{
  return to_bt3_Object (&to_bullet_Joint (Self)->getRigidBodyA());
}



Object*
b3d_Joint_Object_B (Joint*   Self)
{
  return to_bt3_Object (&to_bullet_Joint (Self)->getRigidBodyB());
}



Matrix_4x4
b3d_Joint_Frame_A (Joint*   Self)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:       return to_Matrix_4x4 (((btHingeConstraint*)       c_Self)->getAFrame());
    case CONETWIST_CONSTRAINT_TYPE:   return to_Matrix_4x4 (((btConeTwistConstraint*)   c_Self)->getAFrame());
    case SLIDER_CONSTRAINT_TYPE:      return to_Matrix_4x4 (((btSliderConstraint*)      c_Self)->getFrameOffsetA());
    case D6_CONSTRAINT_TYPE:          return to_Matrix_4x4 (((btGeneric6DofConstraint*) c_Self)->getFrameOffsetA());
    case POINT2POINT_CONSTRAINT_TYPE: return to_Matrix_4x4 (((btPoint2PointConstraint*) c_Self)->getPivotInA());
    default:                          return to_Matrix_4x4 (btTransform::getIdentity());
    }
}



Matrix_4x4
b3d_Joint_Frame_B (Joint*   Self)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:       return to_Matrix_4x4 (((btHingeConstraint*)       c_Self)->getBFrame());
    case CONETWIST_CONSTRAINT_TYPE:   return to_Matrix_4x4 (((btConeTwistConstraint*)   c_Self)->getBFrame());
    case SLIDER_CONSTRAINT_TYPE:      return to_Matrix_4x4 (((btSliderConstraint*)      c_Self)->getFrameOffsetB());
    case D6_CONSTRAINT_TYPE:          return to_Matrix_4x4 (((btGeneric6DofConstraint*) c_Self)->getFrameOffsetB());
    case POINT2POINT_CONSTRAINT_TYPE: return to_Matrix_4x4 (((btPoint2PointConstraint*) c_Self)->getPivotInB());
    default:                          return to_Matrix_4x4 (btTransform::getIdentity());
    }
}



static int
set_Frames (btTypedConstraint*   c_Self,   const btTransform&   Frame_A,
                                           const btTransform&   Frame_B)
{
  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:       ((btHingeConstraint*)       c_Self)->setFrames (Frame_A, Frame_B);   return 1;
    case CONETWIST_CONSTRAINT_TYPE:   ((btConeTwistConstraint*)   c_Self)->setFrames (Frame_A, Frame_B);   return 1;
    case SLIDER_CONSTRAINT_TYPE:      ((btSliderConstraint*)      c_Self)->setFrames (Frame_A, Frame_B);   return 1;
    case D6_CONSTRAINT_TYPE:          ((btGeneric6DofConstraint*) c_Self)->setFrames (Frame_A, Frame_B);   return 1;

    case POINT2POINT_CONSTRAINT_TYPE:
      ((btPoint2PointConstraint*) c_Self)->setPivotA (Frame_A.getOrigin());
      ((btPoint2PointConstraint*) c_Self)->setPivotB (Frame_B.getOrigin());
      return 1;

    default:
      return 0;
    }
}



int
b3d_Joint_Frame_A_is (Joint*        Self,
                      Matrix_4x4*   Now)
{
  btTypedConstraint*   c_Self  = to_bullet_Joint (Self);
  Matrix_4x4           Other   = b3d_Joint_Frame_B (Self);

  return set_Frames (c_Self, to_btTransform (Now), to_btTransform (&Other));
}



int
b3d_Joint_Frame_B_is (Joint*        Self,
                      Matrix_4x4*   Now)
{
  btTypedConstraint*   c_Self  = to_bullet_Joint (Self);
  Matrix_4x4           Other   = b3d_Joint_Frame_A (Self);

  return set_Frames (c_Self, to_btTransform (&Other), to_btTransform (Now));
}



bool
b3d_Joint_is_Limited (Joint*   Self,
                      int      DoF)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      return DoF == 1 && ((btHingeConstraint*) c_Self)->hasLimit();

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))   return the_Joint->getTranslationalLimitMotor()->isLimited (DoF - 1);
        if (is_Rotation    (DoF))   return the_Joint->getRotationalLimitMotor (DoF - 4)->isLimited();
        return false;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   return the_Joint->getLowerLinLimit() <= the_Joint->getUpperLinLimit();
        if (DoF == 4)   return the_Joint->getLowerAngLimit() <= the_Joint->getUpperAngLimit();
        return false;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      {
        btConeTwistConstraint*   the_Joint = (btConeTwistConstraint*) c_Self;

        if (DoF == 4)   return the_Joint->getTwistSpan()  < BT_LARGE_FLOAT;
        if (DoF == 5)   return the_Joint->getSwingSpan2() < BT_LARGE_FLOAT;
        if (DoF == 6)   return the_Joint->getSwingSpan1() < BT_LARGE_FLOAT;
        return false;
      }

    default:
      return false;
    }
}



Real
b3d_Joint_Extent (Joint*   Self,
                  int      DoF)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      return DoF == 1 ? ((btHingeConstraint*) c_Self)->getHingeAngle() : 0.0;

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        the_Joint->calculateTransforms();

        if (is_Translation (DoF))   return the_Joint->getRelativePivotPosition (DoF - 1);
        if (is_Rotation    (DoF))   return the_Joint->getAngle (DoF - 4);
        return 0.0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   return the_Joint->getLinearPos();
        if (DoF == 4)   return the_Joint->getAngularPos();
        return 0.0;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      return DoF == 4 ? ((btConeTwistConstraint*) c_Self)->getTwistAngle() : 0.0;

    default:
      return 0.0;
    }
}



int
b3d_Joint_Velocity_is (Joint*   Self,
                       int      DoF,
                       Real     Now)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      if (DoF != 1)   return 0;
      ((btHingeConstraint*) c_Self)->enableAngularMotor (true, Now, motor_Impulse);
      return 1;

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))
          {
            btTranslationalLimitMotor*   the_Motor = the_Joint->getTranslationalLimitMotor();

            the_Motor->m_enableMotor    [DoF - 1] = true;
            the_Motor->m_targetVelocity [DoF - 1] = Now;
            the_Motor->m_maxMotorForce  [DoF - 1] = motor_Impulse;
            return 1;
          }

        if (is_Rotation (DoF))
          {
            btRotationalLimitMotor*   the_Motor = the_Joint->getRotationalLimitMotor (DoF - 4);

            the_Motor->m_enableMotor    = true;
            the_Motor->m_targetVelocity = Now;
            the_Motor->m_maxMotorForce  = motor_Impulse;
            return 1;
          }

        return 0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)
          {
            the_Joint->setPoweredLinMotor (true);
            the_Joint->setTargetLinMotorVelocity (Now);
            the_Joint->setMaxLinMotorForce (motor_Impulse);
            return 1;
          }

        if (DoF == 4)
          {
            the_Joint->setPoweredAngMotor (true);
            the_Joint->setTargetAngMotorVelocity (Now);
            the_Joint->setMaxAngMotorForce (motor_Impulse);
            return 1;
          }

        return 0;
      }

    default:
      return 0;
    }
}



int
b3d_Joint_desired_Extent_is (Joint*   Self,
                             int      DoF,
                             Real     Now)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      if (DoF != 1)   return 0;
      ((btHingeConstraint*) c_Self)->enableMotor (true);
      ((btHingeConstraint*) c_Self)->setMaxMotorImpulse (motor_Impulse);
      ((btHingeConstraint*) c_Self)->setMotorTarget (Now, step_Duration);
      return 1;

    default:
      return 0;
    }
}



Real
b3d_Joint_lower_Limit (Joint*   Self,
                       int      DoF)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      return DoF == 1 ? ((btHingeConstraint*) c_Self)->getLowerLimit() : 0.0;

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))   return the_Joint->getTranslationalLimitMotor()->m_lowerLimit [DoF - 1];
        if (is_Rotation    (DoF))   return the_Joint->getRotationalLimitMotor (DoF - 4)->m_loLimit;
        return 0.0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   return the_Joint->getLowerLinLimit();
        if (DoF == 4)   return the_Joint->getLowerAngLimit();
        return 0.0;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      return -b3d_Joint_upper_Limit (Self, DoF);     // Cone twist spans are symmetric.

    default:
      return 0.0;
    }
}



Real
b3d_Joint_upper_Limit (Joint*   Self,
                       int      DoF)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      return DoF == 1 ? ((btHingeConstraint*) c_Self)->getUpperLimit() : 0.0;

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))   return the_Joint->getTranslationalLimitMotor()->m_upperLimit [DoF - 1];
        if (is_Rotation    (DoF))   return the_Joint->getRotationalLimitMotor (DoF - 4)->m_hiLimit;
        return 0.0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   return the_Joint->getUpperLinLimit();
        if (DoF == 4)   return the_Joint->getUpperAngLimit();
        return 0.0;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      {
        btConeTwistConstraint*   the_Joint = (btConeTwistConstraint*) c_Self;

        if (DoF == 4)   return the_Joint->getTwistSpan();
        if (DoF == 5)   return the_Joint->getSwingSpan2();
        if (DoF == 6)   return the_Joint->getSwingSpan1();
        return 0.0;
      }

    default:
      return 0.0;
    }
}



static int
set_cone_twist_Limit (btConeTwistConstraint*   the_Joint,   int   DoF,   Real   Span)
{
  Real   twist  = the_Joint->getTwistSpan();
  Real   swing2 = the_Joint->getSwingSpan2();
  Real   swing1 = the_Joint->getSwingSpan1();

  switch (DoF)
    {
    case 4:   twist  = Span;   break;
    case 5:   swing2 = Span;   break;
    case 6:   swing1 = Span;   break;
    default:  return 0;
    }

  the_Joint->setLimit (swing1, swing2, twist);
  return 1;
}



int
b3d_Joint_lower_Limit_is (Joint*   Self,
                          int      DoF,
                          Real     Now)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      {
        btHingeConstraint*   the_Joint = (btHingeConstraint*) c_Self;

        if (DoF != 1)   return 0;
        the_Joint->setLimit (Now, the_Joint->getUpperLimit());
        return 1;
      }

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))   { the_Joint->getTranslationalLimitMotor()->m_lowerLimit [DoF - 1] = Now;   return 1; }
        if (is_Rotation    (DoF))   { the_Joint->getRotationalLimitMotor (DoF - 4)->m_loLimit          = Now;   return 1; }
        return 0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   { the_Joint->setLowerLinLimit (Now);   return 1; }
        if (DoF == 4)   { the_Joint->setLowerAngLimit (Now);   return 1; }
        return 0;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      return set_cone_twist_Limit ((btConeTwistConstraint*) c_Self, DoF, -Now);     // Symmetric spans.

    default:
      return 0;
    }
}



int
b3d_Joint_upper_Limit_is (Joint*   Self,
                          int      DoF,
                          Real     Now)
{
  btTypedConstraint*   c_Self = to_bullet_Joint (Self);

  switch (c_Self->getConstraintType())
    {
    case HINGE_CONSTRAINT_TYPE:
      {
        btHingeConstraint*   the_Joint = (btHingeConstraint*) c_Self;

        if (DoF != 1)   return 0;
        the_Joint->setLimit (the_Joint->getLowerLimit(), Now);
        return 1;
      }

    case D6_CONSTRAINT_TYPE:
      {
        btGeneric6DofConstraint*   the_Joint = (btGeneric6DofConstraint*) c_Self;

        if (is_Translation (DoF))   { the_Joint->getTranslationalLimitMotor()->m_upperLimit [DoF - 1] = Now;   return 1; }
        if (is_Rotation    (DoF))   { the_Joint->getRotationalLimitMotor (DoF - 4)->m_hiLimit          = Now;   return 1; }
        return 0;
      }

    case SLIDER_CONSTRAINT_TYPE:
      {
        btSliderConstraint*   the_Joint = (btSliderConstraint*) c_Self;

        if (DoF == 1)   { the_Joint->setUpperLinLimit (Now);   return 1; }
        if (DoF == 4)   { the_Joint->setUpperAngLimit (Now);   return 1; }
        return 0;
      }

    case CONETWIST_CONSTRAINT_TYPE:
      return set_cone_twist_Limit ((btConeTwistConstraint*) c_Self, DoF, Now);

    default:
      return 0;
    }
}



Real
b3d_Joint_applied_Impulse (Joint*   Self)
{
  return to_bullet_Joint (Self)->getAppliedImpulse();
}



// Hinge Joint
//

void
b3d_Joint_hinge_Limits_are (Joint*   Self,
                            Real     Lower,
                            Real     Upper,
                            Real     Softeness,
                            Real     bias_Factor,
                            Real     relaxation_Factor)
{
  btHingeConstraint*     c_Self = (btHingeConstraint*) to_bullet_Joint (Self);

  c_Self->setLimit (Lower,
                    Upper,
                    Softeness,
                    bias_Factor,
                    relaxation_Factor);
}



bool
b3d_Joint_hinge_motor_Enabled (Joint*   Self)
{
  return ((btHingeConstraint*) to_bullet_Joint (Self))->getEnableAngularMotor();
}



Real
b3d_Joint_hinge_motor_Speed (Joint*   Self)
{
  return ((btHingeConstraint*) to_bullet_Joint (Self))->getMotorTargetVelocity();
}



Real
b3d_Joint_hinge_max_motor_Torque (Joint*   Self)
{
  return ((btHingeConstraint*) to_bullet_Joint (Self))->getMaxMotorImpulse();
}


} // extern "C"
