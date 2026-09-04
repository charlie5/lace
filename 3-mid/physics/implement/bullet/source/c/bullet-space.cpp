#include "bullet-space.h"
#include "bullet-conversions.h"
#include "btBulletDynamicsCommon.h"



extern "C"
{

struct Space
{
  btDefaultCollisionConfiguration*       collisionConfiguration;
  btCollisionDispatcher*                 dispatcher;
  btBroadphaseInterface*                 overlappingPairCache;
  btSequentialImpulseConstraintSolver*   solver;
  btDiscreteDynamicsWorld*               dynamicsWorld;
};



struct Space*
b3d_new_Space ()
{
  Space*    Self = new Space();

  // collision configuration contains default setup for memory, collision setup. Advanced users can create their own configuration.
  //
  Self->collisionConfiguration = new btDefaultCollisionConfiguration();

  // use the default collision dispatcher. For parallel processing you can use a diffent dispatcher (see Extras/BulletMultiThreaded)
  //
  Self->dispatcher = new btCollisionDispatcher (Self->collisionConfiguration);

  // btDbvtBroadphase is a good general purpose broadphase. You can also try out btAxis3Sweep.
  //
  Self->overlappingPairCache = new btDbvtBroadphase();

  // the default constraint solver. For parallel processing you can use a different solver (see Extras/BulletMultiThreaded)
  //
  Self->solver = new btSequentialImpulseConstraintSolver;

  Self->dynamicsWorld = new btDiscreteDynamicsWorld (Self->dispatcher,
                                                     Self->overlappingPairCache,
                                                     Self->solver,
                                                     Self->collisionConfiguration);
  return Self;
}



void
b3d_free_Space (Space*   Self)
{
  delete Self->dynamicsWorld;
  delete Self->solver;
  delete Self->overlappingPairCache;
  delete Self->dispatcher;
  delete Self->collisionConfiguration;

  delete Self;
}



Vector_3
b3d_Space_Gravity (Space*   Self)
{
  btVector3   the_Gravity = Self->dynamicsWorld->getGravity();

  return to_Vector_3 (the_Gravity);
}



void
b3d_Space_Gravity_is (Space*   Self,    Vector_3*     Now)
{
  Self->dynamicsWorld->setGravity (btVector3 (Now->x, Now->y, Now->z));
}



void
b3d_Space_evolve (Space*   Self,     float   By)
{
  Self->dynamicsWorld->stepSimulation (By,  10);
}



void
b3d_Space_add_Object (Space*   Self,    Object*   the_Object)
{
  Self->dynamicsWorld->addRigidBody (to_bullet_Object (the_Object));
}



void
b3d_Space_rid_Object (Space*   Self,    Object*   the_Object)
{
  Self->dynamicsWorld->removeRigidBody (to_bullet_Object (the_Object));
}



void
b3d_Space_update_Bounds (Space*   Self,    Object*   the_Object)
{
  Self->dynamicsWorld->updateSingleAabb (to_bullet_Object (the_Object));
}



void
b3d_Space_add_Joint (Space*   Self,    Joint*   the_Joint,
                                       int      collide_Connected)
{
  bool    disable_Collisions = (collide_Connected == 0);

  Self->dynamicsWorld->addConstraint (to_bullet_Joint (the_Joint),
                                      disable_Collisions);
}



void
b3d_Space_rid_Joint (Space*   Self,    Joint*   the_Joint)
{
  Self->dynamicsWorld->removeConstraint (to_bullet_Joint (the_Joint));
}



int
b3d_Space_joint_Count (Space*   Self)
{
  return Self->dynamicsWorld->getNumConstraints();
}



Joint*
b3d_Space_Joint (Space*   Self,    int   Index)
{
  return to_bt3_Joint (Self->dynamicsWorld->getConstraint (Index));
}



ray_Collision
b3d_Space_cast_Ray (Space*   Self,    Vector_3*   From,
                                      Vector_3*   To)
{
  btVector3                                    rayFrom    = to_btVector3 (From);
  btVector3                                    rayTo      = to_btVector3 (To);
  btCollisionWorld::ClosestRayResultCallback   rayCallback (rayFrom, rayTo);

  Self->dynamicsWorld->rayTest (rayFrom, rayTo,
                                rayCallback);

  ray_Collision   the_Collision;

  the_Collision.near_Object  = (Object*) (rayCallback.m_collisionObject);
  the_Collision.hit_Fraction = rayCallback.m_closestHitFraction;
  the_Collision.Normal_world = to_Vector_3 (rayCallback.m_hitNormalWorld);
  the_Collision.Site_world   = to_Vector_3 (rayCallback.m_hitPointWorld);

  return the_Collision;
}



//  Point Casting
//

class point_Callback : public btCollisionWorld::ContactResultCallback
{
public:
  const btCollisionObject*   Probe;
  const btCollisionObject*   Hit;

  point_Callback (const btCollisionObject*   the_Probe) : Probe (the_Probe),  Hit (0)   {}

  virtual btScalar
  addSingleResult (btManifoldPoint&                 the_Point,
                   const btCollisionObjectWrapper*  Wrapper_0,   int   part_0,   int   index_0,
                   const btCollisionObjectWrapper*  Wrapper_1,   int   part_1,   int   index_1)
  {
    if (Hit == 0 && the_Point.getDistance() <= 0.0)
      {
        Hit = (Wrapper_0->getCollisionObject() == Probe) ? Wrapper_1->getCollisionObject()
                                                         : Wrapper_0->getCollisionObject();
      }

    return 0;
  }
};



point_Collision
b3d_Space_cast_Point (Space*   Self,    Vector_3*   Point)
//
// Tests a tiny sphere at the point against every object in the space.
//
{
  btSphereShape       the_Shape (0.001);
  btCollisionObject   the_Probe;
  btTransform         the_Transform;

  the_Transform.setIdentity();
  the_Transform.setOrigin (to_btVector3 (Point));

  the_Probe.setCollisionShape  (&the_Shape);
  the_Probe.setWorldTransform  (the_Transform);

  point_Callback   the_Callback (&the_Probe);

  Self->dynamicsWorld->contactTest (&the_Probe, the_Callback);

  point_Collision   the_Collision;

  the_Collision.near_Object = (Object*) the_Callback.Hit;
  the_Collision.Site_world  = *Point;

  return the_Collision;
}



//  Contacts
//

static btPersistentManifold*
touching_Manifold (Space*   Self,   int   contact_Id)
//
// The contact_Id'th manifold (from 0) which holds at least one contact point.
//
{
  btCollisionDispatcher*   the_Dispatcher = Self->dispatcher;
  int                      Found          = -1;

  for (int i = 0;   i < the_Dispatcher->getNumManifolds();   i++)
    {
      btPersistentManifold*   the_Manifold = the_Dispatcher->getManifoldByIndexInternal (i);

      if (the_Manifold->getNumContacts() > 0)
        {
          Found++;

          if (Found == contact_Id)
            return the_Manifold;
        }
    }

  return 0;
}



int
b3d_space_contact_Count (Space*   Self)
{
  btCollisionDispatcher*   the_Dispatcher = Self->dispatcher;
  int                      Count          = 0;

  for (int i = 0;   i < the_Dispatcher->getNumManifolds();   i++)
    {
      if (the_Dispatcher->getManifoldByIndexInternal (i)->getNumContacts() > 0)
        Count++;
    }

  return Count;
}



b3d_Contact
b3d_space_Contact (Space*   Self,   int   contact_Id)
{
  b3d_Contact             the_Contact;
  btPersistentManifold*   the_Manifold = touching_Manifold (Self, contact_Id);

  the_Contact.Object_A = 0;
  the_Contact.Object_B = 0;
  the_Contact.Site     = Vector_3 (0.0, 0.0, 0.0);

  if (the_Manifold == 0)
    return the_Contact;

  btVector3   the_Site (0.0, 0.0, 0.0);

  for (int i = 0;   i < the_Manifold->getNumContacts();   i++)
    the_Site += the_Manifold->getContactPoint (i).getPositionWorldOnB();

  the_Site /= btScalar (the_Manifold->getNumContacts());     // The middle of the contact points.

  the_Contact.Object_A = (Object*) the_Manifold->getBody0();
  the_Contact.Object_B = (Object*) the_Manifold->getBody1();
  the_Contact.Site     = to_Vector_3 (the_Site);

  return the_Contact;
}


} // extern "C"
