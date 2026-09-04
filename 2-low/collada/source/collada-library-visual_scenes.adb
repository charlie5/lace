with
     float_Math.Algebra.linear.D3,
     ada.unchecked_Deallocation;


package body collada.Library.visual_scenes
is
   use type Text;


   -------------
   --- Transform
   --

   function to_Matrix (Self : in Transform) return collada.Matrix_4x4
   is
      use
           Math,
           math.Algebra.linear.D3;
   begin
      case Self.Kind
      is
         when Translate =>
            return Transpose (to_translate_Matrix (Self.Vector));     -- Transpose converts from math Row vectors to collada Col vectors.

         when Rotate =>
            declare
               the_Rotation : constant Matrix_3x3 := Transpose (to_Rotation (Self.Axis (1),     -- Transpose converts from math Row vectors to collada Col vectors.
                                                                             Self.Axis (2),
                                                                             Self.Axis (3),
                                                                             Self.Angle));
            begin
               return to_rotate_Matrix (the_Rotation);
            end;

         when Scale =>
            return to_scale_Matrix (Self.Scale);

         when full_Transform =>
            return Self.Matrix;
      end case;
   end to_Matrix;


   --------
   --- Node
   --

   function Sid (Self : in Node) return Text
   is
   begin
      return Self.Sid;
   end Sid;



   function Id (Self : in Node) return Text
   is
   begin
      return Self.Id;
   end Id;



   function Name (Self : in Node) return Text
   is
   begin
      return Self.Name;
   end Name;



   procedure Sid_is (Self : in out Node;   Now : in Text)
   is
   begin
      Self.Sid := Now;
   end Sid_is;



   procedure Id_is (Self : in out Node;   Now : in Text)
   is
   begin
      Self.Id := Now;
   end Id_is;



   procedure Name_is (Self : in out Node;   Now : in Text)
   is
   begin
      Self.Name := Now;
   end Name_is;



   function Instance (Self : in Node) return Text
   is
   begin
      return Self.Instance;
   end Instance;



   procedure Instance_is (Self : in out Node;   Now : in Text)
   is
   begin
      Self.Instance := Now;
   end Instance_is;



   function Skeleton (Self : in Node) return Text
   is
   begin
      return Self.Skeleton;
   end Skeleton;



   procedure Skeleton_is (Self : in out Node;   Now : in Text)
   is
   begin
      Self.Skeleton := Now;
   end Skeleton_is;


   --------------
   --- Transforms
   --

   function Transforms (Self : in Node) return Transform_array
   is
   begin
      if Self.Transforms = null
      then
         return [];
      end if;

      return Self.Transforms.all;
   end Transforms;



   function fetch_Transform (Self : access Node;   transform_Sid : in String) return access Transform
   is
   begin
      if Self.Transforms /= null
      then
         for i in Self.Transforms'Range
         loop
            if Self.Transforms (i).Sid = transform_Sid
            then
               return Self.Transforms (i)'Access;
            end if;
         end loop;
      end if;

      return null;
   end fetch_Transform;



   procedure add (Self : in out Node;   the_Transform : in Transform)
   is
      Old : Transform_array_view := Self.Transforms;

      procedure deallocate is new ada.unchecked_Deallocation (Transform_array, Transform_array_view);

   begin
      if Old = null
      then
         Self.Transforms := new Transform_array' (1 =>      the_Transform);
      else
         Self.Transforms := new Transform_array' (Old.all & the_Transform);
         deallocate (Old);
      end if;
   end add;



   function local_Transform (Self : in Node) return Matrix_4x4
   is
      use Math;

      the_Result : Matrix_4x4 := math.Identity_4x4;
   begin
      if Self.Transforms /= null
      then
         for Each of Self.Transforms.all
         loop
            the_Result := the_Result * to_Matrix (Each);
         end loop;
      end if;

      return the_Result;
   end local_Transform;



   function global_Transform (Self : in Node) return Matrix_4x4
   is
      use Math;
   begin
      if Self.Parent = null
      then
         return Self.local_Transform;
      else
         return Self.Parent.global_Transform * Self.local_Transform;     -- Recurse.
      end if;
   end global_Transform;



   function find_Transform (Self : in Node;   of_Kind : in transform_Kind;
                                              Sid     : in String) return Positive
   is
   begin
      if Self.Transforms /= null
      then
         for i in Self.Transforms'Range
         loop
            if         Self.Transforms (i).Kind = of_Kind
              and then Self.Transforms (i).Sid  = Sid
            then
               return i;
            end if;
         end loop;
      end if;

      raise Transform_not_found with   "No "
                                     & transform_Kind'Image (of_Kind)
                                     & " transform found with sid: "
                                     & Sid
                                     & ".";
   end find_Transform;



   function find_Transform (Self : in Node;   of_Kind : in transform_Kind) return Positive
   is
   begin
      if Self.Transforms /= null
      then
         for i in Self.Transforms'Range
         loop
            if Self.Transforms (i).Kind = of_Kind
            then
               return i;
            end if;
         end loop;
      end if;

      raise Transform_not_found with "No " & of_Kind'Image & " transform found";
   end find_Transform;



   function find_Rotation (Self : in Node;   Axis : in Character) return Positive
   --
   -- Blender writes the rotation sids as 'rotationX', other exporters as 'rotateX'.
   --
   is
   begin
      if Self.Transforms /= null
      then
         for i in Self.Transforms'Range
         loop
            if         Self.Transforms (i).Kind = Rotate
              and then (   Self.Transforms (i).Sid = "rotation" & Axis
                        or Self.Transforms (i).Sid = "rotate"   & Axis)
            then
               return i;
            end if;
         end loop;
      end if;

      raise Transform_not_found with "No rotation about " & Axis & " found";
   end find_Rotation;



   function full_Transform (Self : in Node) return Matrix_4x4
   is
   begin
      return Self.Transforms (find_Transform (Self, full_Transform)).Matrix;
   end full_Transform;



   function Translation (Self : in Node) return Vector_3
   is
   begin
      return Self.Transforms (find_Transform (Self, Translate)).Vector;
   end Translation;



   function Rotation (Self : in Node;   Axis : in Character) return Vector_4
   is
      use Math;

      the_Rotation : Transform renames Self.Transforms (find_Rotation (Self, Axis));
   begin
      return Vector_4 (the_Rotation.Axis & the_Rotation.Angle);
   end Rotation;



   function Rotate_X (Self : in Node) return Vector_4
   is
   begin
      return Rotation (Self, 'X');
   end Rotate_X;



   function Rotate_Y (Self : in Node) return Vector_4
   is
   begin
      return Rotation (Self, 'Y');
   end Rotate_Y;



   function Rotate_Z (Self : in Node) return Vector_4
   is
   begin
      return Rotation (Self, 'Z');
   end Rotate_Z;



   function Scale (Self : in Node) return Vector_3
   is
   begin
      return Self.Transforms (find_Transform (Self, Scale, "scale")).Scale;
   end Scale;



   procedure set_x_rotation_Angle (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Rotation (Self, 'X')).Angle := To;
   end set_x_rotation_Angle;



   procedure set_y_rotation_Angle (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Rotation (Self, 'Y')).Angle := To;
   end set_y_rotation_Angle;



   procedure set_z_rotation_Angle (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Rotation (Self, 'Z')).Angle := To;
   end set_z_rotation_Angle;



   procedure set_Location (Self : in out Node;   To : in math.Vector_3)
   is
   begin
      Self.Transforms (find_Transform (Self, Translate, "location")).Vector := To;
   end set_Location;



   procedure set_Location_x (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Transform (Self, Translate, "location")).Vector (1) := To;
   end set_Location_x;



   procedure set_Location_y (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Transform (Self, Translate, "location")).Vector (2) := To;
   end set_Location_y;



   procedure set_Location_z (Self : in out Node;   To : in math.Real)
   is
   begin
      Self.Transforms (find_Transform (Self, Translate, "location")).Vector (3) := To;
   end set_Location_z;



   procedure set_Transform (Self : in out Node;   To : in math.Matrix_4x4)
   is
   begin
      Self.Transforms (find_Transform (Self, full_Transform, "transform")).Matrix := To;
   end set_Transform;


   -------------
   --- Hierarchy
   --

   function Parent (Self : in Node) return Node_view
   is
   begin
      return Self.Parent;
   end Parent;



   procedure Parent_is (Self : in out Node;   Now : in Node_view)
   is
   begin
      Self.Parent := Now;
   end Parent_is;



   function Children (Self : in Node) return Nodes
   is
   begin
      if Self.Children = null
      then
         return [];
      end if;

      return Self.Children.all;
   end Children;



   function Child (Self : in Node;   Which : in Positive) return Node_view
   is
   begin
      if   Self.Children = null
        or else Which > Self.Children'Length
      then
         return null;
      end if;

      return Self.Children (Which);
   end Child;



   function Child (Self : in Node;   Named : in String) return Node_view
   is
   begin
      if Self.Children /= null
      then
         for Each of Self.Children.all
         loop
            if Each.Name = Named
            then
               return Each;
            end if;

            declare
               the_Descendant : constant Node_view := Each.Child (Named);     -- Recurse.
            begin
               if the_Descendant /= null
               then
                  return the_Descendant;
               end if;
            end;
         end loop;
      end if;

      return null;
   end Child;



   procedure add (Self : in out Node;   the_Child : in Node_view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Nodes, Nodes_view);

      Old : Nodes_view := Self.Children;
   begin
      if Old = null
      then
         Self.Children := new Nodes' (1 => the_Child);
      else
         Self.Children := new Nodes' (Old.all & the_Child);
         deallocate (Old);
      end if;
   end add;



   procedure free (Self : in out Node_view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Node,            Node_view);
      procedure deallocate is new ada.unchecked_Deallocation (Nodes,           Nodes_view);
      procedure deallocate is new ada.unchecked_Deallocation (Transform_array, Transform_array_view);
   begin
      if Self = null
      then
         return;
      end if;

      if Self.Children /= null
      then
         for Each of Self.Children.all
         loop
            free (Each);
         end loop;

         deallocate (Self.Children);
      end if;

      deallocate (Self.Transforms);
      deallocate (Self);
   end free;


   ----------------
   --- Library Item
   --

   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Nodes,              Nodes_view);
      procedure deallocate is new ada.unchecked_Deallocation (visual_Scene_array, visual_Scene_array_view);
   begin
      if Self.Contents = null
      then
         return;
      end if;

      for Each of Self.Contents.all
      loop
         if Each.root_Nodes /= null
         then
            for the_Root of Each.root_Nodes.all
            loop
               free (the_Root);
            end loop;

            deallocate (Each.root_Nodes);
         end if;
      end loop;

      deallocate (Self.Contents);
   end destroy;


end collada.Library.visual_scenes;
