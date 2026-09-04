#ifndef C_BOX2D_OBJECT_PRIVATE_H
#define C_BOX2D_OBJECT_PRIVATE_H

#include <box2d/box2d.h>


extern "C"
{
  struct Object
  {
    b2FixtureDef     fixtureDef;
    b2BodyDef        bodyDef;
    b2Body*          body;        // Null until the object is added to a space.
    b2Vec2           Scale;
    Real             Mass;        // The mass asked for; the fixture's density is set to give it.
    void*            userData;    // This holds the physics Object pointer (not the box2d Object pointer).
  };

} //extern "C"

#endif
