#include "box2d-shape.h"
#include "box2d-space.h"
#include <box2d/box2d.h>



extern "C"
{

/////////
//  Forge
//

void
b2d_free_Shape (Shape*       Self)
{
  b2Shape*   the_Shape = (b2Shape*) Self;

  delete (the_Shape);
}



Shape*
b2d_new_Circle (Real   Radius)
{
  b2CircleShape*   Self = new b2CircleShape();

  Self->m_radius = Radius;

  return (Shape*) Self;
}



Shape*
b2d_new_Polygon (Vector_2   Vertices[],
                 int        vertex_Count)
//
// Box2d computes the convex hull of the vertices, of which it allows at most
// b2_maxPolygonVertices (8).
//
{
  b2PolygonShape*   Self  = new b2PolygonShape();
  b2Vec2            Verts [b2_maxPolygonVertices];
  int               Count = vertex_Count < b2_maxPolygonVertices ? vertex_Count : b2_maxPolygonVertices;

  for (int i = 0;  i < Count;  i++)
    {
      Verts [i] = b2Vec2 (Vertices [i].x,
                          Vertices [i].y);
    }

  Self->Set (Verts, Count);

  return (Shape*) Self;
}



Shape*
b2d_new_Box (Vector_3*   half_Extents)
{
  return 0;
}



Shape*
b2d_new_Capsule (Vector_2*   Radii,
                 Real        Height)
{
  return 0;
}



Shape*
b2d_new_Cone (Real   Radius,
              Real   Height)
{
  return 0;
}



Shape*
b2d_new_convex_Hull (Vector_3     Points[],
                     int          point_Count)
{
  return 0;
}



Shape*
b2d_new_Cylinder (Vector_3*   half_Extents)
{
  return 0;
}



Shape*
b2d_new_Heightfield (int         Width,
                     int         Depth,
                     Real        Heights[],
                     Real        min_Height,
                     Real        max_Height,
                     Vector_3*   Scale)
{
  return 0;
}



Shape*
b2d_new_multiSphere (Vector_3*   Positions,
                     Real*       Radii,
                     int         sphere_Count)
{
  return 0;
}



Shape*
b2d_new_Plane (Vector_3*   Normal,
               Real       Offset)
{
  return 0;
}



Shape*
b2d_new_Sphere (Real   Radius)
{
  return 0;
}



//////////////
//  Attributes
//

void*
b2d_Shape_user_Data      (Shape*   Self)
//
// Box2d shapes carry no user data; the Ada object keeps its shape itself.
//
{
  return 0;
}



void
b2d_Shape_user_Data_is   (Shape*   Self,   void*   Now)
{
}


} // extern "C"
