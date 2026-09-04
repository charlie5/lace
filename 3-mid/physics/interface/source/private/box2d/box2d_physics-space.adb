with
     box2d_c.Binding,
     box2d_c.b2d_Contact,
     box2d_c.b2d_ray_Collision,
     box2d_c.b2d_point_Collision,
     box2d_physics.Shape,
     box2d_physics.Joint,
     c_math_c.Vector_3,
     c_math_c.Conversion,
     Swig,
     lace.Any,
     interfaces.C,
     ada.unchecked_Conversion,
     system.storage_Elements;


package body box2d_Physics.Space
is
   use
        box2d_c.Binding,
        box2d_c.Pointers,
        c_math_c.Conversion,
        Interfaces;

   use type c_math_c.Real;

   type Any_limited_view is access all lace.Any.limited_item'Class;

   function to_Any_view    is new ada.unchecked_Conversion (Swig.void_ptr, Any_limited_view);
   function to_Object_view is new ada.unchecked_Conversion (swig.void_ptr, physics.Object.view);



   ---------
   --- Forge
   --

   function to_Space return Item
   is
   begin
      return Self : Item
      do
         Self.C := box2d_c.Binding.b2d_new_Space;
      end return;
   end to_Space;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      b2d_free_Space (Self.C);
   end destruct;



   -----------
   --- Factory
   --

   overriding
   function new_Shape (Self : access Item;   from_Model : in physics.Model.view) return physics.Shape.view
   is
      use physics.Model;

      Info : physics.Model.a_Shape renames from_Model.shape_Info;
   begin
      case Info.Kind
      is
         when Circle  => return Self.new_circle_Shape  (Info.circle_Radius);
         when Polygon => return Self.new_polygon_Shape (physics.Space.polygon_Vertices (Info.Vertices (1 .. Info.vertex_Count)));

         when Cube | Cylinder | Cone | a_Sphere | a_Capsule | Heightfield | Hull | Mesh | multi_Sphere | Plane =>
            raise physics.Space.unsupported_Shape with "3D shapes are not allowed in box2d physics.";
      end case;
   end new_Shape;



   -- 2d
   --

   overriding
   function new_circle_Shape (Self : access Item;   Radius : in Real := 0.5) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Shape.new_circle_Shape (Radius);
   end new_circle_Shape;



   overriding
   function new_polygon_Shape (Self : access Item;   Vertices : in physics.Space.polygon_Vertices) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Shape.new_polygon_Shape (Vertices);
   end new_polygon_Shape;



   -- 3d
   --

   overriding
   function new_sphere_Shape (Self : access Item;   Radius : in Real := 0.5) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Sphere shape not allowed in box2d physics.";
      return null;
   end new_sphere_Shape;



   overriding
   function new_box_Shape (Self : access Item;   half_Extents : in Vector_3 := [0.5, 0.5, 0.5]) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Box shape not allowed in box2d physics.";
      return null;
   end new_box_Shape;



   overriding
   function new_capsule_Shape (Self : access Item;   Radius : in Real :=  0.5;
                                                     Height : in Real) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Capsule shape not allowed in box2d physics.";
      return null;
   end new_capsule_Shape;



   overriding
   function new_cone_Shape (Self : access Item;   Radius : in Real := 0.5;
                                                  Height : in Real := 1.0) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Cone shape not allowed in box2d physics.";
      return null;
   end new_cone_Shape;



   overriding
   function new_cylinder_Shape (Self : access Item;   half_Extents : in Vector_3 := [0.5, 0.5, 0.5]) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Cylinder shape not allowed in box2d physics.";
      return null;
   end new_cylinder_Shape;



   overriding
   function new_heightfield_Shape (Self : access Item;   Heightfield  : in out physics.Heightfield;
                                                         Scale        : in     Vector_3) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Heightfield shape not allowed in box2d physics.";
      return null;
   end new_heightfield_Shape;



   overriding
   function new_multisphere_Shape (Self : access Item;   Sites : in physics.vector_3_array;
                                                         Radii : in math.Vector) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "multiSphere shape not allowed in box2d physics.";
      return null;
   end new_multisphere_Shape;



   overriding
   function new_plane_Shape (Self : access Item;   Normal : in Vector_3 := [0.0, 1.0, 0.0];
                                                   Offset : in Real     :=  0.0) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Plane shape not allowed in box2d physics.";
      return null;
   end new_plane_Shape;



   overriding
   function new_convex_hull_Shape (Self : access Item;   Points : in physics.Vector_3_array) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      raise physics.Space.unsupported_Shape with "Convex hull shape not allowed in box2d physics.";
      return null;
   end new_convex_hull_Shape;



   overriding
   function new_mesh_Shape (Self : access Item;   Points : access physics.Geometry_3D.a_Model) return physics.Shape.view
   is
      pragma unreferenced (Self, Points);
   begin
      raise physics.Space.unsupported_Shape with "Mesh shape not allowed in box2d physics.";
      return null;
   end new_mesh_Shape;



   -- Objects
   --

   function Hash (the_C_Object : in box2d_c.Pointers.Object_pointer) return ada.Containers.Hash_type
   is
      function convert is new ada.unchecked_Conversion (box2d_c.Pointers.Object_pointer,
                                                        system.storage_Elements.integer_Address);
   begin
      return ada.Containers.Hash_type'Mod (convert (the_C_Object));
   end Hash;



   overriding
   function new_Object (Self : access Item;   of_Shape     : in physics.Shape.view;
                                              of_Mass      : in Real;
                                              Friction     : in Real;
                                              Restitution  : in Real;
                                              at_Site      : in Vector_3;
                                              is_Kinematic : in Boolean) return physics.Object.view
   is
      pragma unreferenced (Self);
   begin
      return physics.Object.view (box2d_physics.Object.new_Object (of_Shape,
                                                                   of_Mass,
                                                                   Friction,
                                                                   Restitution,
                                                                   at_Site,
                                                                   is_Kinematic));
   end new_Object;



   overriding
   procedure discard_Moves (Self : in out Item)
   is
      procedure b2d_Space_discard_Moves (Self : in box2d_c.Pointers.Space_pointer);
      pragma import (C, b2d_Space_discard_Moves,
                        "b2d_Space_discard_Moves");
   begin
      b2d_Space_discard_Moves (Self.C);
   end discard_Moves;



   overriding
   procedure continuous_Physics_is (Self : in out Item;   Now : in Boolean)
   is
      procedure b2d_Space_continuous_Physics_is (Self : in box2d_c.Pointers.Space_pointer;
                                                 Now  : in interfaces.C.int);
      pragma import (C, b2d_Space_continuous_Physics_is,
                        "b2d_Space_continuous_Physics_is");
   begin
      b2d_Space_continuous_Physics_is (Self.C, (if Now then 1 else 0));
   end continuous_Physics_is;



   overriding
   function object_Count (Self : in Item) return Natural
   is
   begin
      return Natural (Self.object_Map.Length);
   end object_Count;



   -- Joints
   --

   overriding
   function new_hinge_Joint (Self : access Item;   Object_A,
                                                   Object_B          : in physics.Object.view;
                                                   Anchor_in_A,
                                                   Anchor_in_B       : in Vector_3;
                                                   pivot_Axis        : in Vector_3;
                                                   low_Limit,
                                                   high_Limit        : in Real;
                                                   collide_Connected : in Boolean) return physics.Joint.hinge.view
   is
      pragma Unreferenced (pivot_Axis);     -- A two dimensional hinge can only turn about Z.
   begin
      return box2d_physics.Joint.new_hinge_Joint (Self.C,
                                                  Object_A,    Object_B,
                                                  Anchor_in_A, Anchor_in_B,
                                                  low_Limit,   high_Limit,
                                                  collide_Connected);
   end new_hinge_Joint;



   overriding
   function new_hinge_Joint (Self : access Item;   Object_A : in physics.Object.view;
                                                   Frame_A  : in Matrix_4x4) return physics.Joint.hinge.view
   is
   begin
      return box2d_physics.Joint.new_hinge_Joint (Self.C, Object_A, Frame_A);
   end new_hinge_Joint;



   overriding
   function new_hinge_Joint (Self : access Item;   Object_A,
                                                   Object_B          : in physics.Object.view;
                                                   Frame_A,
                                                   Frame_B           : in Matrix_4x4;
                                                   low_Limit,
                                                   high_Limit        : in Real;
                                                   collide_Connected : in Boolean) return physics.Joint.hinge.view
   is
   begin
      return box2d_physics.Joint.new_hinge_Joint (Self.C,
                                                  Object_A,  Object_B,
                                                  Frame_A,   Frame_B,
                                                  low_Limit, high_Limit,
                                                  collide_Connected);
   end new_hinge_Joint;



   overriding
   function new_DoF6_Joint (Self : access Item;   Object_A,
                                                  Object_B  : in physics.Object.view;
                                                  Frame_A,
                                                  Frame_B   : in Matrix_4x4) return physics.Joint.DoF6.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Joint.new_DoF6_Joint (Object_A, Object_B,
                                                 Frame_A,  Frame_B);
   end new_DoF6_Joint;



   overriding
   function new_ball_Joint (Self : access Item;   Object_A,
                                                  Object_B     : in physics.Object.view;
                                                  Pivot_in_A,
                                                  Pivot_in_B   : in math.Vector_3) return physics.Joint.ball.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Joint.new_ball_Joint (Object_A,   Object_B,
                                                 Pivot_in_A, Pivot_in_B);
   end new_ball_Joint;



   overriding
   function new_slider_Joint (Self : access Item;   Object_A,
                                                    Object_B : in physics.Object.view;
                                                    Frame_A,
                                                    Frame_B  : in Matrix_4x4) return physics.Joint.slider.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Joint.new_slider_Joint (Object_A, Object_B,
                                                   Frame_A,  Frame_B);
   end new_slider_Joint;



   overriding
   function new_cone_twist_Joint (Self : access Item;   Object_A,
                                                        Object_B : in physics.Object.view;
                                                        Frame_A,
                                                        Frame_B  : in Matrix_4x4) return physics.Joint.cone_twist.view
   is
      pragma unreferenced (Self);
   begin
      return box2d_physics.Joint.new_cone_twist_Joint (Object_A, Object_B,
                                                       Frame_A,  Frame_B);
   end new_cone_twist_Joint;



   --------------
   --- Operations
   --

   overriding
   procedure update_Bounds (Self : in out Item;   of_Object : in physics.Object.view)
   --
   -- Box2d recomputes a body's bounds when its fixture is recreated, which scaling does.
   --
   is
      pragma Unreferenced (Self, of_Object);
   begin
      null;
   end update_Bounds;



   overriding
   procedure add (Self : in out Item;   the_Object : in physics.Object.view)
   is
      the_box2d_Object : constant box2d_physics.Object.view := box2d_physics.Object.view (the_Object);
      the_c_Object     : constant Object_pointer            := the_box2d_Object.C;
   begin
      Self.object_Map.insert (the_C_Object, the_box2d_Object);
      b2d_Space_add_Object   (Self.C, the_c_Object);
   end add;



   overriding
   procedure rid (Self : in out Item;   the_Object : in physics.Object.view)
   is
      the_c_Object : constant Object_pointer := box2d_physics.Object.view (the_Object).C;
   begin
      Self.object_Map.exclude (the_c_Object);     -- Else 'evolve' would update the dynamics
      --                                             of an object which may since be freed.
      b2d_Space_rid_Object (Self.C, the_c_Object);
   end rid;



   overriding
   function cast_Ray (Self : access Item;    From, To : in Vector_3) return physics.Space.ray_Collision
   is
      c_From          : aliased c_math_c.Vector_3.item := +From;
      c_To            : aliased c_math_c.Vector_3.item := +To;
      the_c_Collision : constant box2d_c.b2d_ray_Collision.Item := b2d_Space_cast_Ray (Self.C, c_From'unchecked_Access,
                                                                                               c_To  'unchecked_Access);
      the_Collision   : physics.Space.ray_Collision := (near_Object  => null,
                                                        hit_Fraction => Real (the_c_Collision.hit_Fraction),
                                                        Normal_world => +the_c_Collision.Normal_world,
                                                        Site_world   => +the_c_Collision.Site_world);
   begin
      if the_c_Collision.near_Object /= null
      then
         the_Collision.near_Object := to_Object_view (b2d_Object_user_Data (the_c_Collision.near_Object));
      end if;

      return the_Collision;
   end cast_Ray;



   overriding
   function cast_Point (Self : access Item;   Point : in Vector_3) return physics.Space.point_Collision
   is
      c_Point         : aliased  c_math_c.Vector_3.item           := +Point;
      the_c_Collision : constant box2d_c.b2d_point_Collision.item := b2d_Space_cast_Point (Self.C, c_Point'unchecked_Access);
      the_Collision   :          physics.Space.point_Collision    := (near_Object => null,
                                                                      Site_world  => +the_c_Collision.Site_world);
   begin
      if the_c_Collision.near_Object /= null
      then
         the_Collision.near_Object := to_Object_view (b2d_Object_user_Data (the_c_Collision.near_Object));
      end if;

      return the_Collision;
   end cast_Point;



   overriding
   procedure evolve (Self : in out Item;   By : in Duration)
   is
   begin
      b2d_Space_evolve (Self.C, C.C_float (By));

      -- Update each objects dynamics.
      --
      declare
         use c_Object_Maps_of_Object;

         Cursor     : c_Object_Maps_of_Object.Cursor := Self.object_Map.First;
         the_Object : box2d_Physics.Object.view;
      begin
         while has_Element (Cursor)
         loop
            the_Object := Element (Cursor);
            the_Object.update_Dynamics;

            next (Cursor);
         end loop;
      end;
   end evolve;



   overriding
   function Gravity (Self : in Item) return Vector_3
   is
   begin
      return +b2d_Space_Gravity (Self.C);
   end Gravity;



   overriding
   procedure Gravity_is (Self : in out Item;   Now : in Vector_3)
   is
      c_Now : aliased c_math_c.Vector_3.item := +Now;
   begin
      b2d_Space_Gravity_is (Self.C, c_Now'unchecked_Access);
   end Gravity_is;



   overriding
   procedure add (Self : in out Item;   the_Joint : in physics.Joint.view)
   is
      use box2d_physics.Joint;

      the_box2d_Joint : constant box2d_physics.Joint.view := box2d_physics.Joint.view (the_Joint);
   begin
      b2d_Space_add_Joint (Self.C, the_box2d_Joint.C);
      register (the_box2d_Joint);
   end add;



   overriding
   procedure rid (Self : in out Item;   the_Joint : in physics.Joint.view)
   is
      the_c_Joint : constant Joint_pointer := box2d_physics.Joint.view (the_Joint).C;
   begin
      b2d_Space_rid_Joint (Self.C, the_c_Joint);
   end rid;



   ---------------------
   --- Contact Manifolds
   --

   overriding
   function manifold_Count (Self : in Item) return Natural
   is
   begin
      return Natural (b2d_space_contact_Count (Self.C));
   end manifold_Count;



   overriding
   function Manifold (Self : access Item;   Index : in Positive) return physics.space.a_Manifold
   is
      use type C.int;

      the_Contact  : constant box2d_c.b2d_Contact.item := b2d_space_Contact (Self.C, C.int (Index) - 1);
      the_Manifold :          physics.space.a_Manifold := (Objects => [others => null],
                                                           Contact => (Site => math.Origin_3D));
   begin
      if the_Contact.Object_A /= null
      then
         the_Manifold.Objects (1)  := physics.Object.view (to_Any_view (b2d_object_user_Data (the_Contact.Object_A)));
         the_Manifold.Objects (2)  := physics.Object.view (to_Any_view (b2d_object_user_Data (the_Contact.Object_B)));
         the_Manifold.Contact.Site := +the_Contact.Site;
      end if;

      return the_Manifold;
   end Manifold;



   overriding
   procedure set_Joint_local_Anchor (Self : in out Item;   the_Joint    : in physics.Joint.view;
                                                           is_Anchor_A  : in Boolean;
                                                           local_Anchor : in Vector_3)
   is
      the_c_Joint : constant Joint_pointer          := box2d_physics.Joint.view (the_Joint).C;
      c_Anchor    : aliased  c_math_c.Vector_3.item := +local_Anchor;
   begin
      b2d_Joint_set_local_Anchor (the_c_Joint,
                                  swig.bool (is_Anchor_A),
                                  c_Anchor'unchecked_Access);
   end set_Joint_local_Anchor;



   --- Joint Cursors
   --

   overriding
   procedure next (Cursor : in out joint_Cursor)
   is
   begin
      if Cursor.C.Joint = null
      then
         raise constraint_Error with "Null cursor.";
      end if;

      b2d_Space_next_Joint (Cursor.C'unchecked_Access);
   end next;



   overriding
   function has_Element (Cursor : in joint_Cursor) return Boolean
   is
   begin
      return Cursor.C.Joint /= null;
   end has_Element;



   overriding
   function Element (Cursor : in joint_Cursor) return physics.Joint.view
   is
   begin
      if Cursor.C.Joint = null
      then
         raise constraint_Error with "Null cursor.";
      end if;

      declare
         the_C_raw_Joint : constant Swig.void_ptr    := b2d_b2Joint_user_Data (Cursor.C.Joint);
         the_raw_Joint   : constant Any_limited_view := to_Any_view (the_C_raw_Joint);
      begin
         return physics.Joint.view (the_raw_Joint);
      end;
   end Element;



   overriding
   function first_Joint (Self : in Item) return physics.Space.joint_Cursor'Class
   is
      the_Cursor : constant joint_Cursor := (C => b2d_Space_first_Joint (Self.C));
   begin
      return the_Cursor;
   end first_Joint;


end box2d_Physics.Space;
