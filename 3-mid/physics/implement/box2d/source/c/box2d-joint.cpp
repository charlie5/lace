#include "box2d-joint.h"
#include "box2d-space.h"
#include "box2d-conversions.h"
#include "box2d-object-private.h"

#include <box2d/box2d.h>
#include <stdio.h>



////////////////
///  C++ Support
//

static const Real   motor_Force   = 100.0;     // The force or torque a driven joint may apply.
static const Real   step_Duration = 1.0 / 60.0;


class my_b2RevoluteJoint : public b2RevoluteJoint   // Exposes the local anchors for modification.
{
public:
  b2Vec2&   LocalAnchorA()   { return m_localAnchorA; }
  b2Vec2&   LocalAnchorB()   { return m_localAnchorB; }
};


class my_b2PrismaticJoint : public b2PrismaticJoint
{
public:
  b2Vec2&   LocalAnchorA()   { return m_localAnchorA; }
  b2Vec2&   LocalAnchorB()   { return m_localAnchorB; }
};


static b2JointDef*
to_Def (Joint*   Self)
{
  return (b2JointDef*) Self;
}


static b2Joint*
live_Joint (Joint*   Self)
//
// The b2Joint, once the definition has been added to a space, else null.
//
{
  return (b2Joint*) to_Def (Self)->userData.pointer;
}


static Matrix_4x4
to_Frame (const b2Vec2&   Anchor)
{
  Matrix_4x4   M;

  M.m00 = 1.0;   M.m01 = 0.0;   M.m02 = 0.0;   M.m03 = 0.0;
  M.m10 = 0.0;   M.m11 = 1.0;   M.m12 = 0.0;   M.m13 = 0.0;
  M.m20 = 0.0;   M.m21 = 0.0;   M.m22 = 1.0;   M.m23 = 0.0;
  M.m30 = Anchor.x;
  M.m31 = Anchor.y;
  M.m32 = 0.0;
  M.m33 = 1.0;

  return M;
}


static b2Vec2
anchor_of (Matrix_4x4*   Frame)
{
  return b2Vec2 (Frame->m30, Frame->m31);
}


static bool
is_Revolute (Joint*   Self)
{
  return to_Def (Self)->type == e_revoluteJoint;
}


static bool
is_Prismatic (Joint*   Self)
{
  return to_Def (Self)->type == e_prismaticJoint;
}


static const int   Revolve   = 6;     // The rotation about Z.
static const int   Slide     = 1;     // The translation along the joint axis.
static const int   Hinge_DoF = 1;     // A hinge's only degree.


static bool
turns (Joint*   Self,   int   DoF)
{
  return is_Revolute (Self) && (DoF == Revolve || DoF == Hinge_DoF);
}


static bool
slides (Joint*   Self,   int   DoF)
{
  return is_Prismatic (Self) && DoF == Slide;
}



extern "C"
{

//////////
///  Forge
//

static b2RevoluteJointDef*
new_revolute_Def (Object*         Object_A,
                  Object*         Object_B,
                  const b2Vec2&   Anchor_in_A,
                  const b2Vec2&   Anchor_in_B)
{
  b2RevoluteJointDef*   Self = new b2RevoluteJointDef();

  Self->bodyA = (b2Body*) Object_A;   // Using the jointDefs' bodyA/B to hold pointers to our 'fat' Object_A/B.
  Self->bodyB = (b2Body*) Object_B;   // The actual b2Body will be substituted when the joint is added to the world.

  Self->localAnchorA = Anchor_in_A;
  Self->localAnchorB = Anchor_in_B;

  return Self;
}



Joint*
b2d_new_hinge_Joint_with_local_anchors (Space*      in_Space,
                                        Object*     Object_A,
                                        Object*     Object_B,
                                        Vector_3*   Anchor_in_A,
                                        Vector_3*   Anchor_in_B,
                                        float       low_Limit,
                                        float       high_Limit,
                                        bool        collide_Connected)
{
  b2RevoluteJointDef*   Self = new_revolute_Def (Object_A, Object_B,
                                                 b2Vec2 (Anchor_in_A->x, Anchor_in_A->y),
                                                 b2Vec2 (Anchor_in_B->x, Anchor_in_B->y));
  Self->lowerAngle       = low_Limit;
  Self->upperAngle       = high_Limit;
  Self->enableLimit      = true;
  Self->collideConnected = collide_Connected;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_hinge_Joint (Space*        in_Space,
                     Object*       Object_A,
                     Object*       Object_B,
                     Matrix_4x4*   Frame_A,
                     Matrix_4x4*   Frame_B,
                     float         low_Limit,
                     float         high_Limit,
                     bool          collide_Connected)
{
  b2RevoluteJointDef*   Self = new_revolute_Def (Object_A, Object_B,
                                                 anchor_of (Frame_A),
                                                 anchor_of (Frame_B));
  Self->lowerAngle       = low_Limit;
  Self->upperAngle       = high_Limit;
  Self->enableLimit      = true;
  Self->collideConnected = collide_Connected;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_space_hinge_Joint (Space*        in_Space,
                           Object*       Object_A,
                           Matrix_4x4*   Frame_A)
//
// Hinges the object to a ground body, which lives until the joint is removed.
//
{
  b2World*              World  = (b2World*) in_Space;
  b2BodyDef             groundDef;
  b2Body*               Ground = World->CreateBody (&groundDef);
  b2RevoluteJointDef*   Self   = new b2RevoluteJointDef();

  Self->bodyA        = (b2Body*) Object_A;
  Self->bodyB        = Ground;
  Self->localAnchorA = anchor_of (Frame_A);

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_DoF6_Joint (Object*       Object_A,
                    Object*       Object_B,
                    Matrix_4x4*   Frame_A,
                    Matrix_4x4*   Frame_B)
//
// In two dimensions the only freedom left to a pinned joint is the rotation about Z,
// so a revolute joint with no limits.
//
{
  b2RevoluteJointDef*   Self = new_revolute_Def (Object_A, Object_B,
                                                 anchor_of (Frame_A),
                                                 anchor_of (Frame_B));
  Self->lowerAngle  = -b2_pi;
  Self->upperAngle  =  b2_pi;
  Self->enableLimit = false;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_cone_twist_Joint (Object*       Object_A,
                          Object*       Object_B,
                          Matrix_4x4*   Frame_A,
                          Matrix_4x4*   Frame_B)
//
// A cone in two dimensions is a range of angles: a revolute joint with limits.
//
{
  b2RevoluteJointDef*   Self = new_revolute_Def (Object_A, Object_B,
                                                 anchor_of (Frame_A),
                                                 anchor_of (Frame_B));
  Self->lowerAngle  = -b2_pi;
  Self->upperAngle  =  b2_pi;
  Self->enableLimit = true;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_slider_Joint (Object*       Object_A,
                      Object*       Object_B,
                      Matrix_4x4*   Frame_A,
                      Matrix_4x4*   Frame_B)
//
// Slides along the X axis of frame A (row 1 of the row vector convention frame).
//
{
  b2PrismaticJointDef*   Self = new b2PrismaticJointDef();

  Self->bodyA        = (b2Body*) Object_A;
  Self->bodyB        = (b2Body*) Object_B;
  Self->localAnchorA = anchor_of (Frame_A);
  Self->localAnchorB = anchor_of (Frame_B);
  Self->localAxisA   = b2Vec2 (Frame_A->m00, Frame_A->m01);
  Self->localAxisA.Normalize();
  Self->enableLimit  = false;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



Joint*
b2d_new_ball_Joint (Object*       Object_A,
                    Object*       Object_B,
                    Vector_3*     Pivot_in_A,
                    Vector_3*     Pivot_in_B)
//
// A ball joint in two dimensions is a pin: a free revolute joint.
//
{
  b2RevoluteJointDef*   Self = new_revolute_Def (Object_A, Object_B,
                                                 b2Vec2 (Pivot_in_A->x, Pivot_in_A->y),
                                                 b2Vec2 (Pivot_in_B->x, Pivot_in_B->y));
  Self->enableLimit = false;

  return (Joint*) static_cast <b2JointDef*> (Self);
}



void
b2d_free_Joint (Joint*   Self)
//
// The joint must already have been removed from its space.
//
{
  b2JointDef*   Def = to_Def (Self);

  if (Def->type == e_revoluteJoint)
    delete static_cast <b2RevoluteJointDef*> (Def);
  else if (Def->type == e_prismaticJoint)
    delete static_cast <b2PrismaticJointDef*> (Def);
  else
    delete Def;
}



void
b2d_free_hinge_Joint (Joint*   Self)
{
  b2d_free_Joint (Self);
}



///////////////
///  Attributes
//

void*
b2d_Joint_user_Data (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  return Live ? (void*) Live->GetUserData().pointer : 0;
}



void
b2d_Joint_user_Data_is (Joint*   Self,   void*   Now)
//
// Only a live joint carries user data; the definition's is the live joint itself.
//
{
  b2Joint*   Live = live_Joint (Self);

  if (Live)
    Live->GetUserData().pointer = (uintptr_t) Now;
}



Object*
b2d_Joint_Object_A (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (Live)   return (Object*) Live->GetBodyA()->GetUserData().pointer;
  else        return (Object*) to_Def (Self)->bodyA;
}



Object*
b2d_Joint_Object_B (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (Live)   return (Object*) Live->GetBodyB()->GetUserData().pointer;
  else        return (Object*) to_Def (Self)->bodyB;
}



static b2Vec2
local_Anchor (Joint*   Self,   bool   of_A)
{
  b2Joint*   Live = live_Joint (Self);

  if (is_Revolute (Self))
    {
      if (Live)   return of_A ? ((b2RevoluteJoint*)    Live)->GetLocalAnchorA() : ((b2RevoluteJoint*)    Live)->GetLocalAnchorB();
      else        return of_A ? ((b2RevoluteJointDef*) Self)->localAnchorA      : ((b2RevoluteJointDef*) Self)->localAnchorB;
    }

  if (is_Prismatic (Self))
    {
      if (Live)   return of_A ? ((b2PrismaticJoint*)    Live)->GetLocalAnchorA() : ((b2PrismaticJoint*)    Live)->GetLocalAnchorB();
      else        return of_A ? ((b2PrismaticJointDef*) Self)->localAnchorA      : ((b2PrismaticJointDef*) Self)->localAnchorB;
    }

  return b2Vec2 (0.0, 0.0);
}



static int
local_Anchor_is (Joint*   Self,   bool   of_A,   const b2Vec2&   Now)
{
  b2Joint*   Live = live_Joint (Self);

  if (is_Revolute (Self))
    {
      if (Live)
        {
          my_b2RevoluteJoint*   the_Joint = static_cast <my_b2RevoluteJoint*> (Live);
          (of_A ? the_Joint->LocalAnchorA() : the_Joint->LocalAnchorB()) = Now;
        }
      else
        {
          b2RevoluteJointDef*   Def = (b2RevoluteJointDef*) Self;
          (of_A ? Def->localAnchorA : Def->localAnchorB) = Now;
        }
      return 1;
    }

  if (is_Prismatic (Self))
    {
      if (Live)
        {
          my_b2PrismaticJoint*   the_Joint = static_cast <my_b2PrismaticJoint*> (Live);
          (of_A ? the_Joint->LocalAnchorA() : the_Joint->LocalAnchorB()) = Now;
        }
      else
        {
          b2PrismaticJointDef*   Def = (b2PrismaticJointDef*) Self;
          (of_A ? Def->localAnchorA : Def->localAnchorB) = Now;
        }
      return 1;
    }

  return 0;
}



Matrix_4x4
b2d_Joint_Frame_A (Joint*   Self)
{
  return to_Frame (local_Anchor (Self, true));
}



Matrix_4x4
b2d_Joint_Frame_B (Joint*   Self)
{
  return to_Frame (local_Anchor (Self, false));
}



int
b2d_Joint_Frame_A_is (Joint*   Self,   Matrix_4x4*   Now)
{
  return local_Anchor_is (Self, true, anchor_of (Now));
}



int
b2d_Joint_Frame_B_is (Joint*   Self,   Matrix_4x4*   Now)
{
  return local_Anchor_is (Self, false, anchor_of (Now));
}



void
b2d_Joint_set_local_Anchor (Joint*   Self,   bool        is_Anchor_A,
                                             Vector_3*   local_Anchor)
{
  local_Anchor_is (Self, is_Anchor_A, b2Vec2 (local_Anchor->x, local_Anchor->y));
}



bool
b2d_Joint_is_Limited (Joint*   Self,   int   DoF)
{
  b2Joint*   Live = live_Joint (Self);

  if (turns (Self, DoF))
    return Live ? ((b2RevoluteJoint*) Live)->IsLimitEnabled() : ((b2RevoluteJointDef*) Self)->enableLimit;

  if (slides (Self, DoF))
    return Live ? ((b2PrismaticJoint*) Live)->IsLimitEnabled() : ((b2PrismaticJointDef*) Self)->enableLimit;

  return false;
}



Real
b2d_Joint_Extent (Joint*   Self,   int   DoF)
{
  b2Joint*   Live = live_Joint (Self);

  if (Live == 0)
    return 0.0;

  if (turns  (Self, DoF))   return ((b2RevoluteJoint*)  Live)->GetJointAngle();
  if (slides (Self, DoF))   return ((b2PrismaticJoint*) Live)->GetJointTranslation();

  return 0.0;
}



int
b2d_Joint_Velocity_is (Joint*   Self,   int   DoF,   Real   Now)
{
  b2Joint*   Live = live_Joint (Self);

  if (turns (Self, DoF))
    {
      if (Live)
        {
          b2RevoluteJoint*   the_Joint = (b2RevoluteJoint*) Live;

          the_Joint->EnableMotor (true);
          the_Joint->SetMaxMotorTorque (motor_Force);
          the_Joint->SetMotorSpeed (Now);
        }
      else
        {
          b2RevoluteJointDef*   Def = (b2RevoluteJointDef*) Self;

          Def->enableMotor    = true;
          Def->maxMotorTorque = motor_Force;
          Def->motorSpeed     = Now;
        }
      return 1;
    }

  if (slides (Self, DoF))
    {
      if (Live)
        {
          b2PrismaticJoint*   the_Joint = (b2PrismaticJoint*) Live;

          the_Joint->EnableMotor (true);
          the_Joint->SetMaxMotorForce (motor_Force);
          the_Joint->SetMotorSpeed (Now);
        }
      else
        {
          b2PrismaticJointDef*   Def = (b2PrismaticJointDef*) Self;

          Def->enableMotor   = true;
          Def->maxMotorForce = motor_Force;
          Def->motorSpeed    = Now;
        }
      return 1;
    }

  return 0;
}



Real
b2d_Joint_lower_Limit (Joint*   Self,   int   DoF)
{
  b2Joint*   Live = live_Joint (Self);

  if (turns  (Self, DoF))   return Live ? ((b2RevoluteJoint*)  Live)->GetLowerLimit() : ((b2RevoluteJointDef*)  Self)->lowerAngle;
  if (slides (Self, DoF))   return Live ? ((b2PrismaticJoint*) Live)->GetLowerLimit() : ((b2PrismaticJointDef*) Self)->lowerTranslation;

  return 0.0;
}



Real
b2d_Joint_upper_Limit (Joint*   Self,   int   DoF)
{
  b2Joint*   Live = live_Joint (Self);

  if (turns  (Self, DoF))   return Live ? ((b2RevoluteJoint*)  Live)->GetUpperLimit() : ((b2RevoluteJointDef*)  Self)->upperAngle;
  if (slides (Self, DoF))   return Live ? ((b2PrismaticJoint*) Live)->GetUpperLimit() : ((b2PrismaticJointDef*) Self)->upperTranslation;

  return 0.0;
}



static int
limits_are (Joint*   Self,   int   DoF,   Real   Lower,   Real   Upper)
{
  b2Joint*   Live = live_Joint (Self);

  if (turns (Self, DoF))
    {
      if (Live)
        {
          ((b2RevoluteJoint*) Live)->SetLimits (Lower, Upper);
          ((b2RevoluteJoint*) Live)->EnableLimit (true);
        }
      else
        {
          b2RevoluteJointDef*   Def = (b2RevoluteJointDef*) Self;

          Def->lowerAngle  = Lower;
          Def->upperAngle  = Upper;
          Def->enableLimit = true;
        }
      return 1;
    }

  if (slides (Self, DoF))
    {
      if (Live)
        {
          ((b2PrismaticJoint*) Live)->SetLimits (Lower, Upper);
          ((b2PrismaticJoint*) Live)->EnableLimit (true);
        }
      else
        {
          b2PrismaticJointDef*   Def = (b2PrismaticJointDef*) Self;

          Def->lowerTranslation = Lower;
          Def->upperTranslation = Upper;
          Def->enableLimit      = true;
        }
      return 1;
    }

  return 0;
}



int
b2d_Joint_lower_Limit_is (Joint*   Self,   int   DoF,   Real   Now)
{
  return limits_are (Self, DoF, Now, b2d_Joint_upper_Limit (Self, DoF));
}



int
b2d_Joint_upper_Limit_is (Joint*   Self,   int   DoF,   Real   Now)
{
  return limits_are (Self, DoF, b2d_Joint_lower_Limit (Self, DoF), Now);
}



Vector_3
b2d_Joint_reaction_Force (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (Live == 0)
    return Vector_3 (0.0, 0.0, 0.0);

  b2Vec2   the_Force = Live->GetReactionForce (1.0 / step_Duration);

  return Vector_3 (the_Force.x, the_Force.y, 0.0);
}



Real
b2d_Joint_reaction_Torque (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  return Live ? Live->GetReactionTorque (1.0 / step_Duration) : 0.0;
}



bool
b2d_Joint_collide_Connected (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  return Live ? Live->GetCollideConnected() : to_Def (Self)->collideConnected;
}



/// Hinge
//

bool
b2d_Joint_hinge_limit_Enabled (Joint*   Self)
{
  return b2d_Joint_is_Limited (Self, Hinge_DoF);
}



void
b2d_Joint_hinge_Limits_are (Joint*   Self,   Real   Low,
                                             Real   High)
{
  limits_are (Self, Hinge_DoF, Low, High);
}



Vector_3
b2d_Joint_hinge_local_Anchor_on_A (Joint*   Self)
{
  b2Vec2   Anchor = local_Anchor (Self, true);

  return Vector_3 (Anchor.x, Anchor.y, 0.0);
}



Vector_3
b2d_Joint_hinge_local_Anchor_on_B (Joint*   Self)
{
  b2Vec2   Anchor = local_Anchor (Self, false);

  return Vector_3 (Anchor.x, Anchor.y, 0.0);
}



Real
b2d_Joint_hinge_reference_Angle (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (!is_Revolute (Self))   return 0.0;

  return Live ? ((b2RevoluteJoint*) Live)->GetReferenceAngle() : ((b2RevoluteJointDef*) Self)->referenceAngle;
}



Real
b2d_Joint_hinge_Angle (Joint*   Self)
{
  return b2d_Joint_Extent (Self, Hinge_DoF);
}



bool
b2d_Joint_hinge_motor_Enabled (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (!is_Revolute (Self))   return false;

  return Live ? ((b2RevoluteJoint*) Live)->IsMotorEnabled() : ((b2RevoluteJointDef*) Self)->enableMotor;
}



Real
b2d_Joint_hinge_motor_Speed (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (!is_Revolute (Self))   return 0.0;

  return Live ? ((b2RevoluteJoint*) Live)->GetMotorSpeed() : ((b2RevoluteJointDef*) Self)->motorSpeed;
}



Real
b2d_Joint_hinge_max_motor_Torque (Joint*   Self)
{
  b2Joint*   Live = live_Joint (Self);

  if (!is_Revolute (Self))   return 0.0;

  return Live ? ((b2RevoluteJoint*) Live)->GetMaxMotorTorque() : ((b2RevoluteJointDef*) Self)->maxMotorTorque;
}


} // extern "C"
