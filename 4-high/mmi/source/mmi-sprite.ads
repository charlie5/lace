with
     mmi.Joint,

     openGL.Model,
     openGL.Visual,
     openGL.Program,

     physics.Model,
     physics.Object,
     physics.Shape,
     physics.Space,

     lace.Subject_and_deferred_Observer,
     lace.Response,

     ada.Containers.Vectors;

limited
with
     mmi.World;


package mmi.Sprite
--
--  Combines a graphics 'visual' and a physics 'solid'.
--
is
   use Math;


   type Item  is limited new lace.Subject_and_deferred_Observer.item with private;
   type View  is access all Item'Class;

   type Items is array (math.Index range <>) of aliased Item;
   type Views is array (math.Index range <>) of View;

   null_Sprites : constant Sprite.views;



   type physics_Space_view is access all physics.Space.item'Class;



   --------------
   --- Containers
   --

   type Grid       is array (math.Index range <>,
                             math.Index range <>) of Sprite.view;
   type Grid_view  is access all Grid;

   package Vectors is new ada.Containers.Vectors (Positive, Sprite.view);




   ----------
   --- Forge
   --

   procedure define       (Self : access Item;   World          : access mmi.World.item'Class;

                                                 graphics_Model : access openGL.     Model.item'Class;
                                                 physics_Model  : access physics.Model.item'Class;
                                                 owns_Graphics  : in     Boolean;
                                                 owns_Physics   : in     Boolean;

                                                 is_Kinematic   : in     Boolean       := False);

   procedure destroy      (Self : access Item;   and_Children   : in Boolean);
   function  is_Destroyed (Self : in     Item)                return Boolean;

   procedure free         (Self : in out View);


   package Forge
   is
      function  to_Sprite (Name           : in     String;
                           World          : access mmi.        World.item'Class;
                           graphics_Model : access openGL.     Model.item'class;
                           physics_Model  : access physics.Model.item'class;
                           owns_Graphics  : in     Boolean;
                           owns_Physics   : in     Boolean;
                           is_Kinematic   : in     Boolean       := False) return Item;

      function new_Sprite (Name           : in     String;
                           World          : access mmi.        World.item'Class;
                           graphics_Model : access openGL.     Model.item'class;
                           physics_Model  : access physics.Model.item'class;
                           owns_Graphics  : in     Boolean       := True;
                           owns_Physics   : in     Boolean       := True;
                           is_Kinematic   : in     Boolean       := False) return View;
   end Forge;



   ---------------
   --- Attributes
   --

   function  World                 (Self : in     Item'Class)     return  access mmi.World.item'Class;

   function  Id                    (Self : in     Item'Class)     return mmi.sprite_Id;
   procedure Id_is                 (Self : in out Item'Class;   Now : in mmi.sprite_Id);


   function  Visual                (Self : access Item'Class)     return openGL.Visual.view;

   function  graphics_Model        (Self : in     Item'Class)     return openGL.Model.view;
   procedure Model_is              (Self : in out Item'Class;   Now : in openGL.Model.view);
   function  owns_Graphics         (Self : in     Item)           return Boolean;

   function  physics_Model         (Self : in     Item'Class)     return access physics.Model.item'class;
   procedure physics_Model_is      (Self : in out Item'Class;   Now : in physics.Model.view);

   function  Scale                 (Self : in     Item'Class)     return math.Vector_3;
   procedure Scale_is              (Self : in out Item'Class;   Now : in math.Vector_3);

   function  Mass                  (Self : in     Item'Class)     return math.Real;
   function  is_Static             (Self : in     Item'Class)     return Boolean;
   function  is_Kinematic          (Self : in     Item'Class)     return Boolean;

   function  Depth_in_camera_space (Self : in     Item'Class)     return math.Real;

   procedure mvp_Matrix_is         (Self : in out Item'Class;   Now : in math.Matrix_4x4);
   function  mvp_Matrix            (Self : in     Item'Class)     return math.Matrix_4x4;

   procedure is_Visible            (Self : in out Item'Class;   Now : in Boolean);
   function  is_Visible            (Self : in     Item'Class)     return Boolean;

   procedure key_Response_is       (Self : in out Item'Class;   Now : in lace.Response.view);
   function  key_Response          (Self : in     Item'Class)     return lace.Response.view;


   subtype physics_Object_view is physics.Object.view;
   subtype physics_Shape_view  is physics.Shape .view;

   function  Solid                 (Self : in     Item'Class)     return physics_Object_view;
   procedure Solid_is              (Self :    out Item'Class;   Now : in physics_Object_view);

   function  Shape                 (Self : in     Item'Class)     return physics_Shape_view;


   function  to_MMI (the_Solid : in physics_Object_view) return mmi.Sprite.view;




   -------------
   --- Dynamics
   --

   --- Bounds
   --

   function Bounds (Self : in Item) return Geometry_3d.bounding_Box;



   --- Site
   --

   function  Site      (Self : in     Item)         return math.Vector_3;
   procedure Site_is   (Self : in out Item;   Now     : in math.Vector_3);

   procedure move      (Self : in out Item;   to_Site : in math.Vector_3);
   --
   --  Moves the sprite to a new site and recursively move children such that
   --  relative positions are maintained.


   --- Spin
   --

   function  Spin       (Self : in     Item)         return math.Matrix_3x3;
   procedure Spin_is    (Self : in out Item;   Now     : in math.Matrix_3x3);

   function  xy_Spin    (Self : in     Item)         return math.Radians;
   procedure xy_Spin_is (Self : in out Item;   Now     : in math.Radians);

   procedure rotate     (Self : in out Item;   to_Spin : in math.Matrix_3x3);
   --
   --  Rotates the sprite to a new spin and recursively moves and rotates children such that
   --  relative positions/orientations are maintained.


   function  Transform    (Self : in     Item)     return math.Matrix_4x4;
   procedure Transform_is (Self : in out Item;   Now : in math.Matrix_4x4);


   function  Speed     (Self : in     Item)          return math.Vector_3;
   procedure Speed_is  (Self : in out Item;   Now      : in math.Vector_3);

   procedure set_Speed (Self : in out Item;   to_Speed : in math.Vector_3);
   --
   --  Set Self and all children to given value.



   function  Gyre      (Self : in     Item)         return math.Vector_3;
   procedure Gyre_is   (Self : in out Item;   Now     : in math.Vector_3);

   procedure set_Gyre  (Self : in out Item;   to_Gyre : in math.Vector_3);
   --
   --  Set Self and all children to given value.


   --- Forces
   --

   procedure apply_Torque         (Self : in out Item;   Torque : in math.Vector_3);
   procedure apply_Torque_impulse (Self : in out Item;   Torque : in math.Vector_3);

   procedure apply_Force          (Self : in out Item;   Force  : in math.Vector_3);



   --- Mirrored Dynamics
   --

   function  desired_Site       (Self : in     Item)     return math.Vector_3;
   procedure desired_Site_is    (Self : in out Item;   Now : in math.Vector_3);
   procedure desired_Spin_is    (Self : in out Item;   Now : in math.Quaternion);

   procedure interpolate_Motion (Self : in out Item'Class);




   --- Hierachy
   --

   type DoF_Limits is
      record
         Low  : math.Real;
         High : math.Real;
      end record;


   function  parent_Joint     (Self : in     Item'Class) return mmi.Joint.view;
   function  child_Joints     (Self : in     Item'Class) return mmi.Joint.views;

   function  top_Parent       (Self : access Item'Class) return mmi.Sprite.view;
   function  Parent           (Self : in     Item)       return mmi.Sprite.view;
   function  tree_Depth       (Self : in     Item)       return Natural;


   procedure detach           (Self : in out Item;   the_Child : mmi.Sprite.view);

   no_such_Child : exception;


   type Action is access procedure (the_Sprite : in out Item'Class);

   procedure apply (Self : in out Item;   do_Action : Action);
   --
   -- Applies an action to a sprite and its children recursively.



   --  Hinge
   --
   procedure attach_via_Hinge (Self : access Item'Class;   the_Child         : in      Sprite.view;
                                                           pivot_Axis        : in      math.Vector_3;
                                                           Anchor            : in      math.Vector_3;
                                                           child_Anchor      : in      math.Vector_3;
                                                           low_Limit         : in      math.Real;
                                                           high_Limit        : in      math.Real;
                                                           collide_Connected : in      Boolean;
                                                           new_joint         :     out mmi.Joint.view);


   procedure attach_via_Hinge (Self : access Item'Class;   the_Child    : in      Sprite.view;
                                                           pivot_Axis   : in      math.Vector_3;
                                                           pivot_Anchor : in      math.Vector_3;
                                                           low_Limit    : in      math.Real;
                                                           high_Limit   : in      math.Real;
                                                           new_joint    :     out mmi.Joint.view);

   procedure attach_via_Hinge (Self : access Item'Class;   the_Child  : in      Sprite.view;
                                                           pivot_Axis : in      math.Vector_3;
                                                           low_Limit  : in      math.Real;
                                                           high_Limit : in      math.Real;
                                                           new_joint  :     out mmi.Joint.view);
   --
   --  Uses midpoint between Self and the_Child sprite as pivot_Anchor.


   procedure attach_via_Hinge (Self : access Item'Class;   the_Child         : in     Sprite.view;
                                                           Frame_in_parent   : in     math.Matrix_4x4;
                                                           Frame_in_child    : in     math.Matrix_4x4;
                                                           Limits            : in     DoF_Limits;
                                                           collide_Connected : in     Boolean;
                                                           new_joint         :    out mmi.Joint.view);


   --  Ball/Socket
   --
   procedure attach_via_ball_Socket (Self : access Item'Class;   the_Child    : in     Sprite.view;
                                                                 pivot_Anchor : in     math.Vector_3;
                                                                 pivot_Axis   : in     math.Matrix_3x3;
                                                                 pitch_Limits : in     DoF_Limits;
                                                                 yaw_Limits   : in     DoF_Limits;
                                                                 roll_Limits  : in     DoF_Limits;
                                                                 new_joint    :    out mmi.Joint.view);


   procedure attach_via_ball_Socket (Self : access Item'Class;   the_Child       : in     Sprite.view;
                                                                 Frame_in_parent : in     math.Matrix_4x4;
                                                                 Frame_in_child  : in     math.Matrix_4x4;
                                                                 pitch_Limits    : in     DoF_Limits;
                                                                 yaw_Limits      : in     DoF_Limits;
                                                                 roll_Limits     : in     DoF_Limits;
                                                                 new_joint       :    out mmi.Joint.view);



   --- Graphics
   --
   procedure program_Parameters_are  (Self : in out Item'Class;   Now : access opengl.Program.Parameters'Class);
   function  program_Parameters      (Self : in     Item'Class)  return access opengl.Program.Parameters'Class;



   --- Physics
   --
   procedure rebuild_Shape (Self : in out Item);
   procedure rebuild_Solid (Self : in out Item);




private

   type access_Joint_views is access all Joint.views;

   use type Joint.view;
   package joint_Vectors is new ada.Containers.Vectors (Positive, Joint.view);



   protected
   type safe_Matrix_4x4
   is
      function  Value       return math.Matrix_4x4;
      procedure Value_is (Now : in math.Matrix_4x4);
      procedure Site_is  (Now : in math.Vector_3);

   private
      the_Value : math.Matrix_4x4 := Identity_4x4;
   end safe_Matrix_4x4;



   type Item is limited new lace.Subject_and_deferred_Observer.item with
      record
         Id                      :        mmi.sprite_Id      := null_sprite_Id;

         Visual                  :        openGL.Visual.view := new openGL.Visual.item;
         program_Parameters      : access openGL.program.Parameters'Class;
         owns_Graphics           :        Boolean;

         physics_Model           :        physics.Model.view;
         owns_Physics            :        Boolean;

         World                   : access mmi.World.item'Class;
         Shape                   :        physics_Shape_view;
         Solid                   :        physics_Object_view;
         is_Kinematic            :        Boolean;

         Transform               :        safe_Matrix_4x4;

         Depth_in_camera_space   :        math.Real;

         desired_Site            :        math.Vector_3;
         interpolation_Vector    :        math.Vector_3;

         initial_Spin            :        math.Quaternion    := (0.0, (0.0, 1.0, 0.0));
         desired_Spin            :        math.Quaternion    := (0.0, (0.0, 1.0, 0.0));
         interpolation_spin_Time :        math.Real          := 0.0;

         parent_Joint            :        mmi.Joint.view;
         child_Joints            :        joint_Vectors.Vector;

         is_Visible              :        Boolean            := True;
         key_Response            :        lace.Response.view;

         is_Destroyed            :        Boolean            := False;
      end record;


   null_Sprites : constant Sprite.views (1 .. 0) := (others => null);


end mmi.Sprite;
