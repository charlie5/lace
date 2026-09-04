package collada.Library.visual_scenes
--
-- Models a collada 'visual_scenes' library, which contains node/joint hierarchy info.
--
is

   -------------
   --- Transform
   --

   type transform_Kind is (Translate, Rotate, Scale, full_Transform);

   type Transform (Kind : transform_Kind := transform_Kind'First) is
      record
         Sid : Text;

         case Kind is
            when Translate =>
               Vector : Vector_3;

            when Rotate =>
               Axis   : Vector_3;
               Angle  : math.Real;

            when Scale =>
               Scale  : Vector_3;

            when full_Transform =>
               Matrix : Matrix_4x4;
         end case;
      end record;

   type Transform_array is array (Positive range <>) of aliased Transform;

   function to_Matrix (Self : in Transform) return collada.Matrix_4x4;
   --
   -- A column vector matrix, as collada uses.


   --------
   --- Node
   --

   type Node       is tagged private;
   type Node_view  is access all Node;
   type Nodes      is array (Positive range <>) of Node_view;
   type Nodes_view is access all Nodes;

   function  Sid     (Self : in     Node) return Text;
   function  Id      (Self : in     Node) return Text;
   function  Name    (Self : in     Node) return Text;

   procedure Sid_is  (Self : in out Node;   Now : in Text);
   procedure Id_is   (Self : in out Node;   Now : in Text);
   procedure Name_is (Self : in out Node;   Now : in Text);

   function  Instance    (Self : in     Node) return Text;
   procedure Instance_is (Self : in out Node;   Now : in Text);
   --
   -- The id of the geometry or controller the node instances, or empty.

   function  Skeleton    (Self : in     Node) return Text;
   procedure Skeleton_is (Self : in out Node;   Now : in Text);
   --
   -- The id of the first skeleton root of an instanced controller, or empty.

   procedure add             (Self : in out Node;   the_Transform : in Transform);
   function  Transforms      (Self : in     Node)                              return Transform_array;
   function  fetch_Transform (Self : access Node;   transform_Sid : in String) return access Transform;
   --
   -- Returns null if the node has no transform with the sid.

   function  local_Transform (Self : in     Node) return Matrix_4x4;
   --
   -- Returns the result of combining all 'Transforms'.

   function  global_Transform (Self : in    Node) return Matrix_4x4;
   --
   -- Returns the result of combining 'local_Transform' with each ancestors 'local_Transform'.

   function  full_Transform (Self : in     Node) return Matrix_4x4;
   function  Translation    (Self : in     Node) return Vector_3;
   function  Rotate_Z       (Self : in     Node) return Vector_4;
   function  Rotate_Y       (Self : in     Node) return Vector_4;
   function  Rotate_X       (Self : in     Node) return Vector_4;
   function  Scale          (Self : in     Node) return Vector_3;
   --
   -- Raise Transform_not_found when the node has no such transform. The rotations
   -- accept the sids 'rotationX' (as Blender writes) and 'rotateX'.

   procedure set_x_rotation_Angle (Self : in out Node;   To : in math.Real);
   procedure set_y_rotation_Angle (Self : in out Node;   To : in math.Real);
   procedure set_z_rotation_Angle (Self : in out Node;   To : in math.Real);

   procedure set_Location   (Self : in out Node;   To : in math.Vector_3);
   procedure set_Location_x (Self : in out Node;   To : in math.Real);
   procedure set_Location_y (Self : in out Node;   To : in math.Real);
   procedure set_Location_z (Self : in out Node;   To : in math.Real);

   procedure set_Transform  (Self : in out Node;   To : in math.Matrix_4x4);

   function  Parent    (Self : in     Node)     return Node_view;
   procedure Parent_is (Self : in out Node;   Now : in Node_view);

   function  Children  (Self : in     Node)                        return Nodes;
   function  Child     (Self : in     Node;   Which : in Positive) return Node_view;
   --
   -- Returns null when the node has no such child.

   function  Child     (Self : in     Node;   Named : in String  ) return Node_view;
   --
   -- Searches the node's descendants, depth first, and returns null when none has the name.

   procedure add       (Self : in out Node;   the_Child : in Node_view);

   procedure free      (Self : in out Node_view);
   --
   -- Frees the node and its descendants.

   Transform_not_found : exception;


   ----------------
   --- visual_Scene
   --

   type visual_Scene is
      record
         Id   : Text;
         Name : Text;

         root_Nodes : Nodes_view;     -- The scene's top-level nodes, in document order.
      end record;

   type visual_Scene_array      is array (Positive range <>) of visual_Scene;
   type visual_Scene_array_view is access visual_Scene_array;


   ----------------
   --- Library Item
   --

   type Item is
      record
         Contents      : visual_Scene_array_view;
         skeletal_Root : Text;                        -- The skeleton root of the first instanced controller, or empty.
      end record;

   procedure destroy (Self : in out Item);



private

   type Transform_array_view is access all Transform_array;

   type Node is tagged
      record
         Sid      : Text;
         Id       : Text;
         Name     : Text;
         Instance : Text;
         Skeleton : Text;

         Transforms : Transform_array_view;

         Parent   : Node_view;
         Children : Nodes_view;
      end record;


end collada.Library.visual_scenes;
