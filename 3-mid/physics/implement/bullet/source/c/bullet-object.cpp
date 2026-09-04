#include "bullet-object.h"
#include "btBulletDynamicsCommon.h"



///////////////
/// C++ Support
//

class KinematicMotionState : public btMotionState
{
public:
              KinematicMotionState (const btTransform &initialpos)       { mPos1 = initialpos; }
    virtual ~ KinematicMotionState ()                                    { }

    virtual void getWorldTransform (      btTransform &worldTrans) const { worldTrans = mPos1; }
            void setKinematicPos   (      btTransform &currentPos)       { mPos1 = currentPos; }
    virtual void setWorldTransform (const btTransform &worldTrans)       { }

protected:
    btTransform   mPos1;
};



///////////
/// Utility
//

btRigidBody*
to_bullet (Object*   From)
{
  return (btRigidBody*) From;
}


Object*
to_bt3 (btRigidBody*   From)
{
  return (Object*) From;
}


static int
is_Kinematic (btRigidBody*   Self)
{
  return   Self->getCollisionFlags()
         & btCollisionObject::CF_KINEMATIC_OBJECT;
}


static void
set_Transform (btRigidBody*   the_Body,   btTransform   trans)
//
// Moves a body, kinematic or dynamic, and wakes it.
//
{
  if (is_Kinematic (the_Body))
    {
      KinematicMotionState*    the_Motion_State = (KinematicMotionState*) the_Body->getMotionState();

      the_Body->setWorldTransform (trans);
      the_Motion_State->setKinematicPos (trans);
    }
  else
    {
      the_Body->setCenterOfMassTransform (trans);     // Sets the world and the interpolation transforms.
    }

  the_Body->activate();
}



///////////////
/// C Interface
//

extern "C"
{

struct Object*
b3d_new_Object (Real     Mass,
                Shape*   the_Shape,
                int      is_Kinematic)
{
  btCollisionShape*   bt_Shape   = (btCollisionShape*) (the_Shape);
  btScalar            mass       = Mass;
  bool                isDynamic  = (mass != 0.f);
  btVector3           localInertia (0,0,0);
  btTransform         groundTransform;

  groundTransform.setIdentity();

  if (isDynamic)
    bt_Shape->calculateLocalInertia (mass, localInertia);

  KinematicMotionState*                      myMotionState = new KinematicMotionState (groundTransform);
  btRigidBody::btRigidBodyConstructionInfo   rbInfo              (mass, myMotionState, bt_Shape, localInertia);
  btRigidBody*                               body          = new btRigidBody (rbInfo);

  if (is_Kinematic)
    {
      body->setCollisionFlags (  body->getCollisionFlags()
			       | btCollisionObject::CF_KINEMATIC_OBJECT);
      body->setActivationState (DISABLE_DEACTIVATION);     // A kinematic body is moved by hand, so must never sleep.
    }

  return (Object*) body;
}



void
b3d_free_Object (Object*   Self)
//
// The body must already have been removed from its space.
//
{
  btRigidBody*   the_Body = to_bullet (Self);

  delete the_Body->getMotionState();
  delete the_Body;
}



Shape*
b3d_Object_Shape          (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);

  return (Shape*) the_Body->getCollisionShape ();
}



void*
b3d_Object_user_Data      (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);

  return the_Body->getUserPointer ();
}



void
b3d_Object_user_Data_is   (Object*   Self,
                           void*     Now)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->setUserPointer (Now);
}



Real
b3d_Object_Mass (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);
  Real           inv_Mass = the_Body->getInvMass();

  if (inv_Mass == 0.0)
    return 0.0;
  else
    return 1.0 / inv_Mass;
}



void
b3d_Object_Friction_is (Object*   Self,
                        Real      Now)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->setFriction (Now);
}



void
b3d_Object_Restitution_is    (Object*   Self,   Real   Now)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->setRestitution (Now);
}



void
b3d_Object_Scale_is (Object*   Self,   Vector_3*   Now)
//
// Scales the body's shape. The space must then update the body's bounds.
//
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->getCollisionShape()->setLocalScaling (btVector3 (Now->x, Now->y, Now->z));

  if (the_Body->getInvMass() != 0.0)
    {
      btVector3   localInertia (0,0,0);
      btScalar    mass = 1.0 / the_Body->getInvMass();

      the_Body->getCollisionShape()->calculateLocalInertia (mass, localInertia);
      the_Body->setMassProps (mass, localInertia);
    }

  the_Body->activate();
}



int
b3d_Object_is_Active (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);

  return the_Body->isActive();
}



void
b3d_Object_activate (Object*   Self,   int   force_Activation)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->activate (force_Activation != 0);
}



Vector_3
b3d_Object_Site (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);
  Vector_3       the_Site;

  btTransform&   trans    = the_Body->getWorldTransform ();
  btVector3      bt_Site  = trans.getOrigin();

  the_Site.x = bt_Site.x();
  the_Site.y = bt_Site.y();
  the_Site.z = bt_Site.z();

  return the_Site;
}



void
b3d_Object_Site_is (Object*   Self,   Vector_3*   Now)
{
  btRigidBody*   the_Body = to_bullet (Self);
  btTransform    trans    = the_Body->getWorldTransform ();

  trans.setOrigin (btVector3 (Now->x, Now->y, Now->z));
  set_Transform (the_Body, trans);
}



Matrix_3x3
b3d_Object_Spin (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);

  btTransform&   trans    = the_Body->getWorldTransform ();
  btMatrix3x3    the_Spin = trans.getBasis();

  btVector3&     R1       = the_Spin [0];
  btVector3&     R2       = the_Spin [1];
  btVector3&     R3       = the_Spin [2];

  // Transposed: bullet rotates column vectors, lace rotates row vectors.
  //
  return Matrix_3x3 (R1 [0],  R2 [0],  R3 [0],
                     R1 [1],  R2 [1],  R3 [1],
                     R1 [2],  R2 [2],  R3 [2]);
}



void
b3d_Object_Spin_is (Object*   Self,   Matrix_3x3*   Now)
{
  btRigidBody*   the_Body = to_bullet (Self);
  btTransform    trans    = the_Body->getWorldTransform();

  // Transposed: bullet rotates column vectors, lace rotates row vectors.
  //
  trans.setBasis (btMatrix3x3 (Now->m00, Now->m10, Now->m20,
                               Now->m01, Now->m11, Now->m21,
                               Now->m02, Now->m12, Now->m22));
  set_Transform (the_Body, trans);
}



Matrix_4x4
b3d_Object_Transform (Object*   Self)
{
  btRigidBody*   the_Body      = to_bullet (Self);
  btTransform&   trans         = the_Body->getWorldTransform ();
  btScalar       gl_Matrix [16];

  trans.getOpenGLMatrix (gl_Matrix);

  return Matrix_4x4 (gl_Matrix);
}



void
b3d_Object_Transform_is (Object*   Self,   Matrix_4x4*   Now)
{
  btRigidBody*   the_Body      = to_bullet (Self);
  btTransform    trans;

  trans.setFromOpenGLMatrix (&Now->m00);
  set_Transform (the_Body, trans);
}



Vector_3
b3d_Object_Speed (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);
  Vector_3       the_Speed;

  btVector3      bt_Speed = the_Body->getLinearVelocity ();

  the_Speed.x = bt_Speed.x();
  the_Speed.y = bt_Speed.y();
  the_Speed.z = bt_Speed.z();

  return the_Speed;
}



void
b3d_Object_Speed_is (Object*   Self,   Vector_3*   Now)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->setLinearVelocity (btVector3 (Now->x, Now->y, Now->z));
  the_Body->activate();
}



Vector_3
b3d_Object_Gyre (Object*   Self)
{
  btRigidBody*   the_Body = to_bullet (Self);
  Vector_3       the_Gyre;

  btVector3      bt_Gyre  = the_Body->getAngularVelocity ();

  the_Gyre.x = bt_Gyre.x();
  the_Gyre.y = bt_Gyre.y();
  the_Gyre.z = bt_Gyre.z();

  return the_Gyre;
}



void
b3d_Object_Gyre_is (Object*   Self,   Vector_3*   Now)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->setAngularVelocity (btVector3 (Now->x, Now->y, Now->z));
  the_Body->activate();
}



void
b3d_Object_apply_Torque (Object*   Self,   Vector_3*   Torque)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->applyTorque (btVector3 (Torque->x, Torque->y, Torque->z));
  the_Body->activate();
}



void
b3d_Object_apply_Torque_impulse (Object*   Self,   Vector_3*   Torque)
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->applyTorqueImpulse (btVector3 (Torque->x, Torque->y, Torque->z));
  the_Body->activate();
}



void
b3d_Object_apply_Force (Object*   Self,   Vector_3*   Force)
//
// A force, as the interface says, not an impulse: it acts for the coming step only.
//
{
  btRigidBody*   the_Body = to_bullet (Self);

  the_Body->applyCentralForce (btVector3 (Force->x, Force->y, Force->z));
  the_Body->activate();
}


} // extern "C"
