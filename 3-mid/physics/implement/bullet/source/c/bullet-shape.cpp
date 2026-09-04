#include "bullet-shape.h"
#include "bullet-space.h"
#include <btBulletDynamicsCommon.h>
#include <BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h>
#include <LinearMath/btAlignedObjectArray.h>



///////////
//  Utility
//

btCollisionShape*
to_bullet (Shape*   From)
{
  return (btCollisionShape*) From;
}


Shape*
to_bt3 (btCollisionShape*   From)
{
  return (Shape*) From;
}



extern "C"
{

/////////
//  Forge
//

Shape*
b3d_new_Box (Vector_3*   half_Extents)
{
  Shape*   Self = (Shape*)(btCollisionShape*) (new btBoxShape (btVector3 (half_Extents->x,
                                                                          half_Extents->y,
                                                                          half_Extents->z)));
  return Self;
}



Shape*
b3d_new_Capsule (Vector_2*   Radii,
                 Real        Height)
//
// The capsule lies along Z, like the openGL capsule model. Bullet capsules have
// one radius, so the two radii are averaged.
//
{
  Real     Radius = (Radii->x + Radii->y) / 2.0;
  Shape*   Self   = (Shape*)(btCollisionShape*) (new btCapsuleShapeZ (Radius,
                                                                      Height));
  return Self;
}



Shape*
b3d_new_Cone (Real   Radius,
              Real   Height)
{
  Shape*   Self = (Shape*)(btCollisionShape*) (new btConeShape (Radius, Height));

  return Self;
}



Shape*
b3d_new_convex_Hull (Vector_3     Points[],
                     int          point_Count)
{
  btConvexHullShape*   bt_Hull = new btConvexHullShape ();

  for (int i = 0;   i < point_Count;   i++)
    {
      bt_Hull->addPoint (btVector3 (Points [i].x,
                                    Points [i].y,
                                    Points [i].z));
    }

  Shape*   Self = (Shape*)(btCollisionShape*) bt_Hull;
  return   Self;
}



Shape*
b3d_new_Mesh (Vector_3     Points[],
              int          point_Count,
              Triangle     Triangles[],
              int          triangle_Count)
//
// The triangle mesh copies the vertices, so the arrays need not outlive the call.
// It is owned by the shape and freed with it.
//
{
  btTriangleMesh*   mesh = new btTriangleMesh();

  for (int i = 0;  i < triangle_Count;  i++)
    {
      btVector3   bV1, bV2, bV3;

      bV1 [0] = Points [Triangles [i].a - 1].x;
      bV1 [1] = Points [Triangles [i].a - 1].y;
      bV1 [2] = Points [Triangles [i].a - 1].z;

      bV2 [0] = Points [Triangles [i].b - 1].x;
      bV2 [1] = Points [Triangles [i].b - 1].y;
      bV2 [2] = Points [Triangles [i].b - 1].z;

      bV3 [0] = Points [Triangles [i].c - 1].x;
      bV3 [1] = Points [Triangles [i].c - 1].y;
      bV3 [2] = Points [Triangles [i].c - 1].z;

      mesh->addTriangle (bV1, bV2, bV3);
    }

  btBvhTriangleMeshShape*   bt_Mesh = new btBvhTriangleMeshShape (mesh, true, true);

  Shape*   Self = (Shape*)(btCollisionShape*) bt_Mesh;
  return   Self;
}



Shape*
b3d_new_Cylinder (Vector_3*   half_Extents)
{
  Shape*   Self = (Shape*)(btCollisionShape*) (new btCylinderShape (btVector3 (half_Extents->x,
                                                                               half_Extents->y,
                                                                               half_Extents->z)));
  return Self;
}



Shape*
b3d_new_Heightfield (int         Width,
                     int         Depth,
                     Real        Heights[],
                     Real        min_Height,
                     Real        max_Height,
                     Vector_3*   Scale)
//
// Bullet keeps the pointer to Heights, so the caller's array must outlive the shape.
// Heights [x + z * Width], with x varying fastest.
//
{
  btCollisionShape*   Self = (btCollisionShape*) (new btHeightfieldTerrainShape (Width,      Depth,
                                                                                 Heights,
                                                                                 1.0,
                                                                                 min_Height, max_Height,
                                                                                 1,  PHY_FLOAT, 0));
  Self->setLocalScaling (btVector3 (Scale->x,
                                    Scale->y,
                                    Scale->z));
  return (Shape*) Self;
}



Shape*
b3d_new_multiSphere (Vector_3*   Positions,
                     Real*       Radii,
                     int         sphere_Count)
{
  btAlignedObjectArray <btVector3>   bt_Positions;

  bt_Positions.resize (sphere_Count);

  for (int i=0;  i < sphere_Count;  i++)
    {
      bt_Positions [i][0] = Positions [i].x;
      bt_Positions [i][1] = Positions [i].y;
      bt_Positions [i][2] = Positions [i].z;
    }

  Shape*      Self = (Shape*)(btCollisionShape*) (new btMultiSphereShape (&bt_Positions [0],
                                                                          Radii,
                                                                          sphere_Count));
  return Self;
}



Shape*
b3d_new_Plane (Vector_3*   Normal,
               Real       Offset)
{
  Shape*   Self = (Shape*)(btCollisionShape*) (new btStaticPlaneShape (btVector3 (Normal->x,
                                                                                  Normal->y,
                                                                                  Normal->z),
                                                                       Offset));
  return Self;
}



Shape*
b3d_new_Sphere (Real   Radius)
{
  Shape*   Self = (Shape*)(btCollisionShape*) (new btSphereShape (Radius));

  return Self;
}



void
b3d_free_Shape (Shape*   Self)
//
// No body may still use the shape.
//
{
  btCollisionShape*   the_Shape = to_bullet (Self);

  if (the_Shape->getShapeType() == TRIANGLE_MESH_SHAPE_PROXYTYPE)
    {
      btBvhTriangleMeshShape*   the_Mesh = (btBvhTriangleMeshShape*) the_Shape;

      delete the_Mesh->getMeshInterface();
    }

  delete the_Shape;
}



//////////////
//  Attributes
//

void*
b3d_Shape_user_Data      (Shape*   Self)
{
  btCollisionShape*   the_Shape = to_bullet (Self);

  return the_Shape->getUserPointer();
}



void
b3d_Shape_user_Data_is   (Shape*   Self,   void*   Now)
{
  btCollisionShape*   the_Shape = to_bullet (Self);

  the_Shape->setUserPointer (Now);
}



void
b3d_Shape_Scale_is (Shape*   Self,   Vector_3*   Now)
{
  btCollisionShape*   the_Shape = to_bullet (Self);

  the_Shape->setLocalScaling (btVector3 (Now->x, Now->y, Now->z));
}


} // extern "C"
