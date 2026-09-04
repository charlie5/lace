with
     bullet_c.Binding,
     bullet_c.ray_Collision,
     bullet_c.point_Collision,
     bullet_c.b3d_Contact,
     c_math_c.Vector_3,
     c_math_c.Conversion,
     c_math_c.Pointers,
     bullet_physics.Shape,
     bullet_physics.Joint,
     float_Math.Algebra.linear.d3,
     Swig,
     lace.Any,
     ada.unchecked_Conversion,
     system.storage_Elements;


package body bullet_Physics.Space
is
   use
        bullet_c.Binding,
        bullet_c.Pointers,
        c_math_c.Conversion,
        Interfaces;

   use type C.int;

   type Any_limited_view is access all lace.Any.limited_item'Class;

   function to_Any_view    is new ada.unchecked_Conversion (Swig.void_ptr, Any_limited_view);
   function to_Object_view is new ada.unchecked_Conversion (Swig.void_ptr, physics.Object.view);



   ---------
   --- Forge
   --

   function to_Space return Item
   is
   begin
      return Self : Item
      do
         Self.C := bullet_c.Binding.b3d_new_Space;
      end return;
   end to_Space;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      bullet_c.Binding.b3d_free_Space (Self.C);
   end destruct;



   ---------
   --- Shape
   --

   overriding
   function new_Shape (Self : access Item;   from_Model : in physics.Model.view) return physics.Shape.view
   is
      use physics.Model;

      Info : physics.Model.a_Shape renames from_Model.shape_Info;
   begin
      case Info.Kind
      is
         when Cube         => return Self.new_box_Shape         (Info.half_Extents);
         when a_Sphere     => return Self.new_sphere_Shape      (Info.sphere_Radius);
         when multi_Sphere => return Self.new_multisphere_Shape (Info.Sites.all,
                                                                 Info.Radii.all);
         when Cone         => return Self.new_cone_Shape        (Radius => from_Model.Scale (1) / 2.0,
                                                                 Height => from_Model.Scale (2));
         when a_Capsule    => return bullet_physics.Shape.new_capsule_Shape (Radii  => [Info.lower_Radius,
                                                                                        Info.upper_Radius],
                                                                             Height => Info.Height);
         when Cylinder     => return Self.new_cylinder_Shape    (Info.half_Extents);
         when Hull         => return Self.new_convex_hull_Shape (Info.Points.all);
         when Mesh         => return Self.new_mesh_Shape        (Info.Model);
         when Plane        => return Self.new_plane_Shape       (Info.plane_Normal,
                                                                 Info.plane_Offset);
         when Heightfield  => return Self.new_heightfield_Shape (Info.Heights.all,
                                                                 from_Model.Scale);
         when Circle
            | Polygon      => raise physics.Space.unsupported_Shape with "2D shapes are not allowed in bullet physics.";
      end case;
   end new_Shape;



   overriding
   function new_sphere_Shape (Self : access Item;   Radius : in Real := 0.5) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_sphere_Shape (Radius);
   end new_sphere_Shape;



   overriding
   function new_box_Shape (Self : access Item;   half_Extents : in Vector_3 := [0.5, 0.5, 0.5]) return physics.Shape.view
   is
      pragma Unreferenced (Self);
   begin
      return bullet_physics.Shape.new_box_Shape (half_Extents);
   end new_box_Shape;



   overriding
   function new_capsule_Shape (Self : access Item;   Radius : in Real :=  0.5;
                                                     Height : in Real) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_capsule_Shape (Radii  => [Radius, Radius],
                                                     Height => Height);
   end new_capsule_Shape;



   overriding
   function new_cone_Shape (Self : access Item;   Radius : in Real := 0.5;
                                                  Height : in Real := 1.0) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_cone_Shape (Radius, Height);
   end new_cone_Shape;



   overriding
   function new_cylinder_Shape (Self : access Item;   half_Extents : in Vector_3 := [0.5, 0.5, 0.5]) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_cylinder_Shape (half_Extents);
   end new_cylinder_Shape;



   overriding
   function new_heightfield_Shape (Self : access Item;   Heightfield  : in out physics.Heightfield;
                                                         Scale        : in     Vector_3) return physics.Shape.view
   --
   -- Bullet keeps a pointer to the heights, so the caller's array must outlive the shape.
   -- Bullet reads the heights with the second index varying fastest, so the array's
   -- second dimension is its width.
   --
   is
      pragma unreferenced (Self);

      function height_Extent (Self : in physics.Heightfield) return Vector_2
      is
         Min : Real := Real'Last;
         Max : Real := Real'First;
      begin
         for Row in Self'Range (1)
         loop
            for Col in Self'Range (2)
            loop
               Min := Real'Min (Min, Self (Row, Col));
               Max := Real'Max (Max, Self (Row, Col));
            end loop;
         end loop;

         return [Min, Max];
      end height_Extent;

      function convert is new ada.unchecked_Conversion (physics.Space.Real_view,
                                                        c_math_c.Pointers.Real_pointer);

      the_height_Extent : constant Vector_2 := height_Extent (Heightfield);
   begin
      return bullet_physics.Shape.new_heightfield_Shape (Width      => Heightfield'Length (2),
                                                         Depth      => Heightfield'Length (1),
                                                         Heights    => convert (Heightfield (Heightfield'First (1),
                                                                                             Heightfield'First (2))'unchecked_Access),
                                                         min_Height => the_height_Extent (1),
                                                         max_Height => the_height_Extent (2),
                                                         Scale      => Scale);
   end new_heightfield_Shape;



   overriding
   function new_multisphere_Shape (Self : access Item;   Sites : in physics.vector_3_array;
                                                         Radii : in Vector) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_multisphere_Shape (Sites, Radii);
   end new_multisphere_Shape;



   overriding
   function new_plane_Shape (Self : access Item;   Normal : in Vector_3 := [0.0, 1.0, 0.0];
                                                   Offset : in Real     :=  0.0) return physics.Shape .view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_plane_Shape (Normal, Offset);
   end new_plane_Shape;



   overriding
   function new_convex_hull_Shape (Self : access Item;   Points : in physics.vector_3_array) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_convex_hull_Shape (Points);
   end new_convex_hull_Shape;



   overriding
   function new_mesh_Shape (Self : access Item;   Points : access physics.Geometry_3D.a_Model) return physics.Shape.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Shape.new_mesh_Shape (Points);
   end new_mesh_Shape;



   -- 2D
   --

   overriding
   function new_circle_Shape (Self : access Item;   Radius : in Real := 0.5) return physics.Shape.view
   is
   begin
      raise physics.Space.unsupported_Shape with "Circle shape not allowed in bullet physics.";
      return null;
   end new_circle_Shape;



   overriding
   function new_polygon_Shape (Self : access Item;   Vertices : in physics.Space.polygon_Vertices) return physics.Shape.view
   is
   begin
      raise physics.Space.unsupported_Shape with "Polygon shape not allowed in bullet physics.";
      return null;
   end new_polygon_Shape;



   -----------
   --- Objects
   --

   function Hash (the_C_Object : in bullet_c.Pointers.Object_pointer) return ada.Containers.Hash_type
   is
      function convert is new ada.unchecked_Conversion (bullet_c.Pointers.Object_pointer,
                                                        system.storage_Elements.integer_Address);
   begin
      return ada.Containers.Hash_type'Mod (convert (the_C_Object));
   end Hash;



   overriding
   function  new_Object (Self : access Item;   of_Shape     : in physics.Shape .view;
                                               of_Mass      : in Real;
                                               Friction     : in Real;
                                               Restitution  : in Real;
                                               at_Site      : in Vector_3;
                                               is_Kinematic : in Boolean) return physics.Object.view
   is
      pragma unreferenced (Self);
   begin
      return physics.Object.view (bullet_physics.Object.new_Object (Shape        => of_Shape,
                                                                    Mass         => of_Mass,
                                                                    Friction     => Friction,
                                                                    Restitution  => Restitution,
                                                                    at_Site      => at_Site,
                                                                    is_Kinematic => is_Kinematic));
   end new_Object;



   overriding
   function object_Count (Self : in Item) return Natural
   is
   begin
      return Natural (Self.object_Map.Length);
   end object_Count;



   ----------
   --- Joints
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
      pragma unreferenced (Self);
   begin
      return bullet_physics.Joint.new_hinge_Joint (Object_A,    Object_B,
                                                   Anchor_in_A, Anchor_in_B,
                                                   pivot_Axis,
                                                   low_Limit,   high_Limit,
                                                   collide_Connected);
   end new_hinge_Joint;



   overriding
   function new_hinge_Joint (Self : access Item;   Object_A : in physics.Object.view;
                                                   Frame_A  : in Matrix_4x4) return physics.Joint.hinge.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Joint.new_hinge_Joint (Object_A, Frame_A);
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
      pragma unreferenced (Self);
   begin
      return bullet_physics.Joint.new_hinge_Joint (Object_A,  Object_B,
                                                   Frame_A,   Frame_B,
                                                   low_Limit, high_Limit,
                                                   collide_Connected);
   end new_hinge_Joint;



   overriding
   function new_DoF6_Joint (Self : access Item;   Object_A,
                                                  Object_B : in physics.Object.view;
                                                  Frame_A,
                                                  Frame_B  : in Matrix_4x4) return physics.Joint.DoF6.view
   is
      pragma Unreferenced (Self);
   begin
      return bullet_physics.Joint.new_DoF6_Joint (Object_A, Object_B,
                                                  Frame_A,  Frame_B);
   end new_DoF6_Joint;



   overriding
   function new_ball_Joint (Self : access Item;   Object_A,
                                                  Object_B   : in physics.Object.view;
                                                  Pivot_in_A,
                                                  Pivot_in_B : in Vector_3) return physics.Joint.ball.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Joint.new_ball_Joint (Object_A,    Object_B,
                                                  Pivot_in_A,  Pivot_in_B);
   end new_ball_Joint;



   overriding
   function new_slider_Joint (Self : access Item;   Object_A,
                                                    Object_B : in physics.Object.view;
                                                    Frame_A,
                                                    Frame_B  : in Matrix_4x4) return physics.Joint.slider.view
   is
      pragma unreferenced (Self);
   begin
      return bullet_physics.Joint.new_slider_Joint (Object_A, Object_B,
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
      return bullet_physics.Joint.new_cone_twist_Joint (Object_A, Object_B,
                                                        Frame_A,  Frame_B);
   end new_cone_twist_Joint;



   --------------
   --- Operations
   --

   overriding
   procedure update_Bounds (Self : in out Item;   of_Object : in physics.Object.view)
   is
      the_c_Object : constant Object_pointer := bullet_physics.Object.view (of_Object).C;
   begin
      b3d_Space_update_Bounds (Self.C, the_c_Object);
   end update_Bounds;



   overriding
   procedure add (Self : in out Item;   Object : in physics.Object.view)
   is
      the_Object   : constant bullet_physics.Object.view := bullet_physics.Object.view (Object);
      the_c_Object : constant Object_pointer             := the_Object.C;
   begin
      Self.object_Map.insert (the_c_Object, the_Object);
      b3d_Space_add_Object   (Self.C, the_c_Object);
   end add;



   overriding
   procedure rid (Self : in out Item;   Object : in physics.Object.view)
   is
      the_c_Object : constant Object_pointer := bullet_physics.Object.view (Object).C;
   begin
      Self.object_Map.exclude (the_c_Object);     -- Else 'evolve' would update the dynamics
      --                                             of an object which may since be freed.
      b3d_Space_rid_Object (Self.C, the_c_Object);
   end rid;



   overriding
   function cast_Ray (Self : access Item;    From, To : in Vector_3) return physics.Space.ray_Collision
   is
      c_From          : aliased  c_math_c.Vector_3.item      := +From;
      c_To            : aliased  c_math_c.Vector_3.item      := +To;
      the_c_Collision : constant bullet_c.ray_Collision.item := b3d_Space_cast_Ray (Self.C, c_From'unchecked_Access,
                                                                                            c_To  'unchecked_Access);
      the_Collision   :          physics.Space.ray_Collision := (near_Object  => null,
                                                                 hit_Fraction => 1.0,
                                                                 Normal_world => math.Origin_3D,
                                                                 Site_world   => To);
   begin
      if the_c_Collision.near_Object /= null
      then
         the_Collision.near_Object  :=  to_Object_view (b3d_Object_user_Data (the_c_Collision.near_Object));
         the_Collision.hit_Fraction :=  Real (the_c_Collision.hit_Fraction);
         the_Collision.Normal_world := +the_c_Collision.Normal_world;
         the_Collision.Site_world   := +the_c_Collision.Site_world;
      end if;

      return the_Collision;
   end cast_Ray;



   overriding
   function cast_Point (Self : access Item;   Point : in Vector_3) return physics.Space.point_Collision
   is
      c_Point         : aliased  c_math_c.Vector_3.item        := +Point;
      the_c_Collision : constant bullet_c.point_Collision.item := b3d_Space_cast_Point (Self.C, c_Point'unchecked_Access);
      the_Collision   :          physics.Space.point_Collision := (near_Object => null,
                                                                   Site_world  => Point);
   begin
      if the_c_Collision.near_Object /= null
      then
         the_Collision.near_Object := to_Object_view (b3d_Object_user_Data (the_c_Collision.near_Object));
      end if;

      return the_Collision;
   end cast_Point;



   overriding
   procedure evolve (Self : in out Item;   By : in Duration)
   is
   begin
      bullet_c.Binding.b3d_Space_evolve (Self.C, C.C_float (By));

      -- Update each objects dynamics.
      --
      declare
         use c_Object_Maps_of_Object;

         Cursor     : c_Object_Maps_of_Object.Cursor := Self.object_Map.First;
         the_Object : bullet_Physics.Object.view;
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
      return +b3d_Space_Gravity (Self.C);
   end Gravity;



   overriding
   procedure Gravity_is (Self : in out Item;   Now : in Vector_3)
   is
      c_Now : aliased c_math_c.Vector_3.item := +Now;
   begin
      bullet_c.Binding.b3d_Space_Gravity_is (Self.C, c_Now'unchecked_Access);
   end Gravity_is;



   overriding
   procedure add (Self : in out Item;   Joint : in physics.Joint.view)
   is
      the_Joint : constant bullet_physics.Joint.view := bullet_physics.Joint.view (Joint);
   begin
      b3d_Space_add_Joint (Self.C, the_Joint.C,
                           collide_Connected => Boolean'Pos (the_Joint.collide_Connected));
   end add;



   overriding
   procedure rid (Self : in out Item;   Joint : in physics.Joint.view)
   is
      the_c_Joint : constant Joint_pointer := bullet_physics.Joint.view (Joint).C;
   begin
      b3d_Space_rid_Joint (Self.C, the_c_Joint);
   end rid;



   overriding
   function manifold_Count (Self : in Item) return Natural
   is
   begin
      return Natural (b3d_space_contact_Count (Self.C));
   end manifold_Count;



   overriding
   function Manifold (Self : access Item;   Index : in Positive) return physics.space.a_Manifold
   is
      the_Contact  : constant bullet_c.b3d_Contact.item := b3d_space_Contact (Self.C, C.int (Index) - 1);
      the_Manifold :          physics.space.a_Manifold  := (Objects => [others => null],
                                                            Contact => (Site => math.Origin_3D));
   begin
      if the_Contact.Object_A /= null
      then
         the_Manifold.Objects (1)  := physics.Object.view (to_Any_view (b3d_Object_user_Data (the_Contact.Object_A)));
         the_Manifold.Objects (2)  := physics.Object.view (to_Any_view (b3d_Object_user_Data (the_Contact.Object_B)));
         the_Manifold.Contact.Site := +the_Contact.Site;
      end if;

      return the_Manifold;
   end Manifold;



   overriding
   procedure set_Joint_local_Anchor (Self : in out Item;   the_Joint    : in physics.Joint.view;
                                                           is_Anchor_A  : in Boolean;
                                                           local_Anchor : in Vector_3)
   --
   -- Keeps the joint frame's orientation and moves its origin.
   --
   is
      pragma Unreferenced (Self);
      use float_Math.Algebra.linear.d3;
   begin
      if is_Anchor_A
      then
         declare
            Frame : Matrix_4x4 := the_Joint.Frame_A;
         begin
            set_Translation (Frame, local_Anchor);
            the_Joint.Frame_A_is (Frame);
         end;
      else
         declare
            Frame : Matrix_4x4 := the_Joint.Frame_B;
         begin
            set_Translation (Frame, local_Anchor);
            the_Joint.Frame_B_is (Frame);
         end;
      end if;
   end set_Joint_local_Anchor;



   -----------------
   --- Joint Cursors
   --

   overriding
   procedure next (Cursor : in out joint_Cursor)
   is
   begin
      Cursor.Index := Cursor.Index + 1;
   end next;



   overriding
   function has_Element (Cursor : in joint_Cursor) return Boolean
   is
   begin
      return Cursor.Index < Cursor.Count;
   end has_Element;



   overriding
   function Element (Cursor : in joint_Cursor) return physics.Joint.view
   is
      the_c_Joint : constant Joint_pointer := b3d_Space_Joint (Cursor.C, Cursor.Index);
   begin
      return physics.Joint.view (to_Any_view (b3d_Joint_user_Data (the_c_Joint)));
   end Element;



   overriding
   function first_Joint (Self : in Item) return physics.Space.joint_Cursor'Class
   is
   begin
      return joint_Cursor' (physics.Space.joint_Cursor with C     => Self.C,
                                                            Index => 0,
                                                            Count => b3d_Space_joint_Count (Self.C));
   end first_Joint;


end bullet_Physics.Space;
