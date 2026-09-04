#include "box2d-space.h"
#include "box2d-conversions.h"
#include <box2d/box2d.h>
#include "box2d-object-private.h"
#include <stdio.h>



///////////////
/// Conversions
//

b2World*
to_World (Space*   From)
{
  return (b2World*) From;
}


Space*
to_Space (b2World*   From)
{
  return (Space*) From;
}



///////////////
/// C++ Support
//

///  Raycasts
//

class my_raycast_Callback : public b2RayCastCallback
{
public:
  b2Fixture*   Nearest;
  b2Vec2       Point;
  b2Vec2       Normal;
  float        Fraction;

  my_raycast_Callback () : Nearest (0),  Fraction (1.0)   {}

  float
  ReportFixture (b2Fixture*      fixture,
		 const b2Vec2&   point,
		 const b2Vec2&   normal,
		 float           fraction)
  {
    Nearest  = fixture;
    Point    = point;
    Normal   = normal;
    Fraction = fraction;

    return fraction;     // Clips the ray, so later reports are nearer still.
  }
};



/// Collisions
//

const int32     k_maxContactPoints = 4 * 2048;

struct ContactPoint
{
	b2Fixture*      fixtureA;
	b2Fixture*      fixtureB;
	b2Vec2          normal;
	b2Vec2          position;
	b2PointState    state;
	float           normalImpulse;
	float           tangentImpulse;
	float           separation;
};


class contact_Listener : public b2ContactListener
{
public:
	         contact_Listener();
	virtual ~contact_Listener();

	virtual void BeginContact (b2Contact*   contact) { B2_NOT_USED(contact); }
	virtual void EndContact   (b2Contact*   contact) { B2_NOT_USED(contact); }
	virtual void PreSolve     (b2Contact*   contact, const b2Manifold*         oldManifold);
	virtual void PostSolve    (b2Contact*   contact, const b2ContactImpulse*   impulse)
	{
		B2_NOT_USED(contact);
		B2_NOT_USED(impulse);
	}

	ContactPoint   m_points[k_maxContactPoints];
	int32          m_pointCount;
};


contact_Listener::
contact_Listener()
{
  m_pointCount = 0;
}


contact_Listener::
~contact_Listener()
{
}


void
contact_Listener::
PreSolve (b2Contact*          contact,
	  const b2Manifold*   oldManifold)
{
  if (m_pointCount == k_maxContactPoints)
    return;

  const b2Manifold*     manifold = contact->GetManifold();

  if (manifold->pointCount == 0)
    return;

  b2Fixture*            fixtureA = contact->GetFixtureA();
  b2Fixture*            fixtureB = contact->GetFixtureB();

  b2PointState          state1 [b2_maxManifoldPoints],
                        state2 [b2_maxManifoldPoints];

  b2GetPointStates (state1,      state2,
		    oldManifold, manifold);

  b2WorldManifold       worldManifold;
  contact->GetWorldManifold (&worldManifold);

  ContactPoint*         cp = m_points + m_pointCount;

  cp->fixtureA = fixtureA;
  cp->fixtureB = fixtureB;
  cp->position.SetZero();

  for (int32 i = 0;   i < manifold->pointCount;   ++i)
    {
      cp->position      += worldManifold.points [i];
      cp->normal         = worldManifold.normal;
      cp->state          = state2 [i];
      cp->normalImpulse  = manifold->points [i].normalImpulse;
      cp->tangentImpulse = manifold->points [i].tangentImpulse;
      cp->separation     = worldManifold.separations [i];
    }

  if (manifold->pointCount > 1)
    cp->position *= (1.0 / float (manifold->pointCount));   // Calculate middle site.

  ++m_pointCount;
}


static contact_Listener*
listener_of (b2World*   the_World)
{
  return dynamic_cast <contact_Listener*> (the_World->GetContactManager().m_contactListener);
}



///////////////
/// C Interface
//

extern "C"
{

int
b2d_space_contact_Count (Space*   Self)
{
  return listener_of (to_World (Self))->m_pointCount;
}



b2d_Contact
b2d_space_Contact       (Space*   Self,   int   contact_Id)
{
  contact_Listener*   the_contact_Listener = listener_of (to_World (Self));
  b2d_Contact         the_Contact;

  the_Contact.Object_A = 0;
  the_Contact.Object_B = 0;
  the_Contact.Site     = Vector_3 (0.0, 0.0, 0.0);

  if (contact_Id < 0 || contact_Id >= the_contact_Listener->m_pointCount)
    return the_Contact;

  ContactPoint*       point = the_contact_Listener->m_points + contact_Id;
  b2Body*             body1 = point->fixtureA->GetBody();
  b2Body*             body2 = point->fixtureB->GetBody();

  the_Contact.Object_A = (Object*) (body1->GetUserData().pointer);
  the_Contact.Object_B = (Object*) (body2->GetUserData().pointer);

  the_Contact.Site.x = point->position.x;
  the_Contact.Site.y = point->position.y;
  the_Contact.Site.z = 0.0;

  return the_Contact;
}



struct Space*
b2d_new_Space ()
{
  b2World*    Self = new b2World (b2Vec2 (0.0, -9.8));

  Self->SetContactListener (new contact_Listener());

  return to_Space (Self);
}



void
b2d_Space_continuous_Physics_is (Space*   Self,
                                 int      Now)
{
  to_World (Self)->SetContinuousPhysics (Now != 0);
}



void
b2d_free_Space (struct Space*    Self)
{
  b2World*   the_World = to_World (Self);

  delete the_World->GetContactManager().m_contactListener;
  delete the_World;
}



Vector_3
b2d_Space_Gravity (Space*   Self)
{
  b2Vec2   the_Gravity = to_World (Self)->GetGravity();

  return Vector_3 (the_Gravity.x, the_Gravity.y, 0.0);
}



void
b2d_Space_Gravity_is (Space*      Self,
                      Vector_3*   Now)
{
  to_World (Self)->SetGravity (b2Vec2 (Now->x, Now->y));
}



void
b2d_Space_evolve (Space*   Self,
                  float    By)
{
  b2World*   the_World = to_World (Self);

  listener_of (the_World)->m_pointCount = 0;
  the_World->Step (By,  6, 2);
}



void
b2d_Space_add_Object (Space*    Self,
                      Object*   the_Object)
//
// Creates the body and gives it the mass asked for, whatever the fixture's area.
//
{
  b2World*   the_World = to_World (Self);

  the_Object->body = the_World->CreateBody (&the_Object->bodyDef);
  the_Object->body->GetUserData().pointer = (uintptr_t) the_Object;
  the_Object->body->CreateFixture (&the_Object->fixtureDef);

  if (the_Object->bodyDef.type == b2_dynamicBody && the_Object->Mass > 0.0)
    {
      b2MassData   the_Mass;

      the_Object->body->GetMassData (&the_Mass);

      if (the_Mass.mass > 0.0)
        the_Mass.I *= the_Object->Mass / the_Mass.mass;

      the_Mass.mass = the_Object->Mass;
      the_Object->body->SetMassData (&the_Mass);
    }
}



void
b2d_Space_rid_Object (Space*    Self,
                      Object*   the_Object)
{
  if (the_Object->body == 0)
    return;

  to_World (Self)->DestroyBody (the_Object->body);
  the_Object->body = 0;
}



void
b2d_Space_discard_Moves (Space*   Self)
{
  b2World*   the_World = to_World (Self);

  // The buffered proxy moves are only consumed when the world is stepped, so a
  // world which is never stepped (a client mirror) must discard them, else the
  // buffer grows without bound. Ray casts use the tree, not the buffer.
  //
  const_cast<b2ContactManager&> (the_World->GetContactManager()).m_broadPhase.ClearMoves();
}



void
b2d_Space_add_Joint (Space*   Self,
                     Joint*   the_Joint)
//
// Swaps the definition's fat objects for their bodies, creates the joint and
// remembers it in the definition.
//
{
  b2World*           the_World = to_World (Self);
  b2JointDef*        jointDef  = (b2JointDef*) the_Joint;

  Object*            Object_A  = (Object*) jointDef->bodyA;
  Object*            Object_B  = (Object*) jointDef->bodyB;

  jointDef->bodyA = Object_A->body;

  if (Object_B->userData != 0 || jointDef->type != e_revoluteJoint)     // Not the ground body of a space hinge.
    jointDef->bodyB = Object_B->body;

  b2Joint*           Live = the_World->CreateJoint (jointDef);

  jointDef->userData.pointer = (uintptr_t) Live;
}



void
b2d_Space_rid_Joint (Space*   Self,    Joint*   the_Joint)
//
// Destroys the joint and puts the definition back the way it was before it was
// added, so it may be added again or freed.
//
{
  b2World*           the_World     = to_World (Self);
  b2JointDef*        the_Joint_Def = (b2JointDef*) the_Joint;
  b2Joint*           Live          = (b2Joint*) the_Joint_Def->userData.pointer;

  if (Live == 0)
    return;

  b2Body*            body_A        = Live->GetBodyA();
  b2Body*            body_B        = Live->GetBodyB();
  Object*            Object_A      = (Object*) body_A->GetUserData().pointer;
  Object*            Object_B      = (Object*) body_B->GetUserData().pointer;

  the_World->DestroyJoint (Live);
  the_Joint_Def->userData.pointer = 0;

  the_Joint_Def->bodyA = (b2Body*) Object_A;

  if (Object_B == 0)                                  // The ground body of a space hinge.
    {
      the_World->DestroyBody (body_B);
      the_Joint_Def->bodyB = 0;
    }
  else
    the_Joint_Def->bodyB = (b2Body*) Object_B;
}



void*
b2d_b2Joint_user_Data (b2Joint*   the_Joint)
{
  return (void*) the_Joint->GetUserData().pointer;
}



/// Joint Cursor
//

joint_Cursor
b2d_Space_first_Joint    (Space*          Self)
{
  return {to_World (Self)->GetJointList()};
}



void
b2d_Space_next_Joint    (joint_Cursor*   Cursor)
{
  Cursor->Joint = Cursor->Joint->GetNext();
}



b2Joint*
b2d_Space_joint_Element (joint_Cursor*   Cursor)
{
  return Cursor->Joint;
}



///  Raycasts
//

b2d_ray_Collision
b2d_Space_cast_Ray (Space*   Self,    Vector_3*   From,
                                      Vector_3*   To)
{
  b2World*              the_World   = to_World (Self);
  my_raycast_Callback   the_Callback;

  the_World->RayCast (&the_Callback,
                      b2Vec2 (From->x, From->y),
                      b2Vec2 (To  ->x, To  ->y));

  b2d_ray_Collision   the_Collision;

  if (the_Callback.Nearest == 0)
    {
      the_Collision.near_Object  = 0;
      the_Collision.hit_Fraction = 1.0;
      the_Collision.Normal_world = Vector_3 (0.0, 0.0, 0.0);
      the_Collision.Site_world   = *To;
    }
  else
    {
      the_Collision.near_Object  = (Object*) (the_Callback.Nearest->GetBody()->GetUserData().pointer);
      the_Collision.hit_Fraction = the_Callback.Fraction;
      the_Collision.Normal_world = Vector_3 (the_Callback.Normal.x, the_Callback.Normal.y, 0.0);
      the_Collision.Site_world   = Vector_3 (the_Callback.Point.x,  the_Callback.Point.y,  0.0);
    }

  return the_Collision;
}



/// Pointcasts
//

class QueryCallback : public b2QueryCallback
{
public:
	QueryCallback (const b2Vec2& point)
	{
		m_point   = point;
		m_fixture = NULL;
	}

	bool
	ReportFixture (b2Fixture*   fixture) override
	{
		bool      inside = fixture->TestPoint (m_point);

    if (inside)
		{
	     m_fixture = fixture;
			 return false;            // We are done, terminate the query.
		}

		return true;                // Continue the query.
  }

  b2Vec2       m_point;
	b2Fixture*   m_fixture;
};



b2d_point_Collision
b2d_Space_cast_Point (Space*      Self,
                      Vector_3*   Point)
{
   b2d_point_Collision   Result;
   b2World*              the_World = to_World (Self);
   const b2Vec2          p         = b2Vec2 (Point->x,
                                             Point->y);
   // Make a small box.
   //
   b2AABB   aabb;
   b2Vec2   d;

   d.Set (0.001f, 0.001f);
   aabb.lowerBound = p - d;
   aabb.upperBound = p + d;

   // Query the world for overlapping shapes.
   //
   QueryCallback   Callback (p);
   the_World->QueryAABB (&Callback, aabb);

   if (Callback.m_fixture)
   {
     Result.near_Object = (Object*) Callback.m_fixture->GetBody()->GetUserData().pointer;
   }
   else
   {
     Result.near_Object = NULL;
   }

   Result.Site_world = *Point;

   return Result;
}


} // extern "C"
