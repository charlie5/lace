with
     gel.Forge,
     gel.Conversions,
     physics.Model,

     openGL.Model.any,
     opengl.Palette,
     opengl.Program .lit.colored_textured_skinned,
     opengl.Geometry.lit_colored_textured_skinned,

     collada.Library,
     collada.Library.controllers,
     collada.Library.animations,

     ada.Strings.unbounded,
     ada.Strings.fixed,
     ada.unchecked_Deallocation;

package body gel.Rig
is
   use linear_Algebra,
       linear_Algebra_3D;


   -----------
   --- Utility
   --

   function "+" (From : in ada.strings.unbounded.unbounded_String) return String
     renames ada.strings.unbounded.to_String;

   function "+" (From : in String) return ada.strings.unbounded.unbounded_String
     renames ada.strings.unbounded.to_unbounded_String;



   function to_gel_joint_Id (Parent, Child : in bone_Id) return gel_joint_Id
   is
      use ada.Strings.unbounded;
   begin
      return Parent & "_to_" & Child;
   end to_gel_joint_Id;



   function to_Details (Length       : Real := Unspecified;
                        width_Factor,
                        depth_Factor : Real := 0.1;

                        pitch_Limits,
                        yaw_Limits,
                        roll_Limits  : gel.Sprite.DoF_Limits := (to_Radians (-15.0),
                                                                 to_Radians ( 15.0))) return bone_Details
   is
   begin
      return (Length,       width_Factor, depth_Factor,
              pitch_Limits, yaw_Limits,   roll_Limits);
   end to_Details;


   ---------
   --- Forge
   --

   package body Forge
   is

      function new_Rig (in_World     : in gel.World.view;
                        Model        : in openGL.Model.view;
                        Mass         : in Real             := 0.0;
                        is_Kinematic : in Boolean          := False;
                        Mode         : in motion_Mode      := Dynamics) return Rig.view
      is
         Self : constant Rig.view := new Rig.item;
      begin
         Self.define (in_World, Model, Mass, is_Kinematic, Mode);

         return Self;
      end new_Rig;



      function new_Rig (bone_Sprites            : in bone_id_Map_of_sprite;
                        joint_inv_bind_Matrices : in inverse_bind_matrix_Vector;
                        joint_site_Offets       : in joint_Id_Map_of_bone_site_offset;
                        Model                   : in openGL.Model.view) return Rig.view
      is
         the_Box : constant Rig.View := new Rig.item;
      begin
         the_Box.bone_Sprites            := bone_Sprites;
         the_Box.joint_inv_bind_Matrices := joint_inv_bind_Matrices;
         the_Box.phys_joint_site_Offets  := joint_site_Offets;
         the_Box.Model                   := Model;

         return the_Box;
      end new_Rig;

   end Forge;


   ---------------------------
   --- Skin program parameters
   --

   overriding
   procedure enable (Self : in out skin_program_Parameters)
   is
      use joint_id_Maps_of_slot;

      subtype Program_view is openGL.Program.lit.colored_textured_skinned.view;

      Cursor : joint_id_Maps_of_slot.Cursor := Self.joint_Map_of_slot.First;
      Slot   : Integer;

   begin
      while has_Element (Cursor)
      loop
         Slot := Element (Cursor);

         Program_view (Self.Program).bone_Transform_is (Which => Slot,
                                                        Now   => Self.bone_Transforms.Element (Slot));
         next (Cursor);
      end loop;
   end enable;


   -------------
   --- Animation
   --

   procedure define_global_Transform_for (Self : in out Item'Class;   the_Joint : in     collada.Library.visual_scenes.Node_view;
                                                                      Slot      : in out Positive)
   is
      use collada.Library;

      which_Joint          : constant scene_joint_Id      := the_Joint.Id;
      child_Joints         : constant visual_scenes.Nodes := the_Joint.Children;

      default_scene_Joint  :          scene_Joint;
      the_global_Transform : constant Matrix_4x4 := Transpose (the_Joint.global_Transform);     -- Transpose to convert to row-major.

   begin
      Self.joint_pose_Transforms.insert (which_Joint,  the_global_Transform);
      Self.collada_Joints       .insert (which_Joint,  the_Joint);

      default_scene_Joint.Node := the_Joint;
      Self.scene_Joints.insert (which_Joint, default_scene_Joint);

      for i in child_Joints'Range
      loop
         Slot := Slot + 1;
         define_global_Transform_for (Self, child_Joints (i), Slot);      -- Recurse over children.
      end loop;
   end define_global_Transform_for;



   procedure update_global_Transform_for (Self : in out Item'Class;   the_Joint : in collada.Library.visual_scenes.Node_view)
   is
      use
           collada.Library,
           ada.Strings.unbounded;

      which_Joint          : constant scene_joint_Id      := the_Joint.Id;
      child_Joints         : constant visual_scenes.Nodes := the_Joint.Children;

      the_global_Transform : constant Matrix_4x4 := math.Transpose (the_Joint.global_Transform);     -- Transpose to convert to row-major.
      joint_site_Offet     :          Vector_3;

   begin
      if which_Joint = Self.root_Joint.Id
      then   joint_site_Offet := [0.0, 0.0, 0.0];
      else   joint_site_Offet := Self.anim_joint_site_Offets (which_Joint);
      end if;


      Self.joint_pose_Transforms.replace (which_Joint, (the_global_Transform));
      Self.scene_Joints (which_Joint).Transform      := the_global_Transform;

      declare
         use type gel.Sprite.view;

         the_bone_Id : constant bone_Id   := which_Joint;
         Site        :          Vector_3;
         Rotation    :          Matrix_3x3;

      begin
         if Self.bone_Sprites (the_bone_Id) /= null
         then
            Site := get_Translation (the_global_Transform);
            Site := Site - joint_site_Offet * (get_Rotation (the_global_Transform));
            Site := Site * Inverse (Self.base_Sprite.Spin);
            Site := Site + Self.overall_Site;

            Rotation := Inverse (get_Rotation (the_global_Transform));
            Rotation := Rotation * Self.base_Sprite.Spin;

            Self.bone_Sprites (the_bone_Id).all.Site_is (Site);

            if which_Joint /= Self.root_Joint.Id
            then
               Self.bone_Sprites (the_bone_Id).all.Spin_is (Rotation);
            end if;
         end if;
      end;

      for i in child_Joints'Range
      loop
         Self.update_global_Transform_for (child_Joints (i));      -- Recurse over children.
      end loop;
   end update_global_Transform_for;



   procedure update_all_global_Transforms (Self : in out Item'Class)
   is
   begin
      Self.update_global_Transform_for (Self.root_Joint);            -- Re-determine all joint transforms, recursively.
   end update_all_global_Transforms;



   procedure set_rotation_Angle (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                             Axis      : in axis_Kind;
                                                             To        : in Radians)
   is
   begin
      case Axis is
         when x_Axis =>   Self.set_x_rotation_Angle (for_Joint, To);
         when y_Axis =>   Self.set_y_rotation_Angle (for_Joint, To);
         when z_Axis =>   Self.set_z_rotation_Angle (for_Joint, To);
      end case;
   end set_rotation_Angle;



   procedure set_Location (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                       To        : in Vector_3)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_Location (To);
   end set_Location;



   procedure set_Location_x (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                         To        : in Real)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_Location_x (To);
   end set_Location_x;



   procedure set_Location_y (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                         To        : in Real)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_Location_y (To);
   end set_Location_y;



   procedure set_Location_z (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                         To        : in Real)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_Location_z (To);
   end set_Location_z;



   procedure set_Transform (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                        To        : in Matrix_4x4)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_Transform (To);
   end set_Transform;



   procedure set_x_rotation_Angle (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                               To        : in Radians)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_x_rotation_Angle (To);
   end set_x_rotation_Angle;



   procedure set_y_rotation_Angle (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                               To        : in Radians)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_y_rotation_Angle (To);
   end set_y_rotation_Angle;



   procedure set_z_rotation_Angle (Self : in out Item'Class;   for_Joint : in scene_joint_Id;
                                                               To        : in Radians)
   is
   begin
      Self.scene_Joints (for_Joint).Node.set_z_rotation_Angle (To);
   end set_z_rotation_Angle;


   ----------
   --- Define
   --

   procedure define (Self : in out Item;   in_World     : in gel   .World.view;
                                           Model        : in openGL.Model.view;
                                           Mass         : in Real                   := 0.0;
                                           is_Kinematic : in Boolean                := False;
                                           Mode         : in motion_Mode            := Dynamics;
                                           bone_Details : in bone_id_Map_of_details := bone_id_Maps_of_details.empty_Map)
   is
      Kinematic : constant Boolean := is_Kinematic or Mode = Animation;     -- An animation poses the bodies itself.

      use
           collada.Document,
           collada.Library,
           collada.Library.visual_Scenes,
           ada.Strings.unbounded;

      type any_Model_view is access all openGL.Model.any.item;

      the_Model    : constant any_Model_view        := any_Model_view (Model);
      model_Name   : constant String                := openGL.to_String (the_Model.model_Name);
      the_Document : constant collada.Document.item := to_Document (model_Name);


      function Node_with_Id (From : in visual_Scenes.Node_view;   Id : in String) return visual_Scenes.Node_view
      is
      begin
         if +From.Id = Id
         then
            return From;
         end if;

         for Each of From.Children
         loop
            declare
               Found : constant visual_Scenes.Node_view := Node_with_Id (Each, Id);     -- Recurse.
            begin
               if Found /= null
               then
                  return Found;
               end if;
            end;
         end loop;

         return null;
      end Node_with_Id;



      function get_root_Joint return visual_Scenes.Node_view
      --
      -- The node the document names as the skeleton root, or the first scene node.
      --
      is
         the_Scenes : constant visual_Scenes.visual_Scene_array_view := the_Document.Libraries.visual_Scenes.Contents;
         root_Id    : constant String                                := +the_Document.Libraries.visual_Scenes.skeletal_Root;
      begin
         if        the_Scenes = null
           or else the_Scenes'Length = 0
           or else the_Scenes (1).root_Nodes = null
           or else the_Scenes (1).root_Nodes'Length = 0
         then
            raise gel.Error with model_Name & ": the model has no visual scene";
         end if;

         if root_Id = ""
         then
            return the_Scenes (1).root_Nodes (1);
         end if;

         for Each of the_Scenes (1).root_Nodes.all
         loop
            declare
               Found : constant visual_Scenes.Node_view := Node_with_Id (Each, root_Id);
            begin
               if Found /= null
               then
                  return Found;
               end if;
            end;
         end loop;

         raise gel.Error with model_Name & ": the skeleton root '" & root_Id & "' is not a node of the scene";
      end get_root_Joint;



      function get_Skin return collada.Library.controllers.Skin
      is
         use type collada.Library.controllers.Controller_array_view;

         the_Controllers : constant collada.Library.controllers.Controller_array_view := the_Document.Libraries.Controllers.Contents;
      begin
         if the_Controllers = null or else the_Controllers'Length = 0
         then
            raise gel.Error with model_Name & ": the model has no skin controller";
         end if;

         return the_Controllers (1).Skin;
      end get_Skin;


      the_root_Joint    : constant visual_scenes.Node_view          := get_root_Joint;
      the_Skin          : constant collada.Library.controllers.Skin := get_Skin;
      prior_bone_Length :          Real                             := 1.0;


      package joint_id_Maps_of_vector_3 is new ada.Containers.hashed_Maps (Key_type        => scene_joint_Id,
                                                                           Element_type    => Vector_3,
                                                                           Hash            => ada.Strings.unbounded.Hash,
                                                                           equivalent_Keys => ada.Strings.unbounded."=",
                                                                           "="             => "=");
      subtype joint_id_Map_of_vector_3 is joint_id_Maps_of_vector_3.Map;


      joint_Sites : joint_id_Map_of_vector_3;

      procedure set_Site_for (the_Joint : in visual_Scenes.Node_view)
      is
         which_Joint  : constant scene_joint_Id      := the_Joint.Id;
         child_Joints : constant visual_Scenes.Nodes := the_Joint.Children;

      begin
         if which_Joint = Self.root_Joint.Id
         then
            joint_Sites.insert (which_Joint,
                                [0.0, 0.0, 0.0]);
         else
            joint_Sites.insert (which_Joint,
                                get_Translation (Self.joint_bind_Matrix (which_Joint)));
         end if;

         for i in child_Joints'Range
         loop
            set_Site_for (child_Joints (i));     -- Recurse over children.
         end loop;
      end set_Site_for;



      procedure create_Bone (the_Bone    : in bone_Id;
                             start_Joint : in scene_joint_Id;
                             end_Point   : in Vector_3;
                             Scale       : in Vector_3)
      is
         use opengl.Palette;

         new_Sprite    :          gel.Sprite.view;
         the_bone_Site : constant Vector_3  := midPoint (joint_Sites (start_Joint),
                                                         end_Point);
      begin
         if the_Bone = Self.root_Joint.Id
         then
            declare
               use standard.physics.Model;

               Size : constant Vector_3 := [0.1, 0.1, 0.1];

               physics_Model : constant standard.physics.Model.View
                 := standard.physics.Model.Forge.new_physics_Model (shape_Info  => (Kind         => Cube,
                                                                                    half_Extents => Size / 2.0),
                                                                    Mass        => Mass);
            begin
               new_Sprite := gel.Sprite.Forge.new_Sprite (Name           => "Skin Sprite",
                                                          World          => gel.Sprite.World_view (in_World),
                                                          graphics_Model => Model,
                                                          physics_Model  => physics_Model,
                                                          is_Kinematic   => Kinematic);
            end;

            new_Sprite.Site_is ([0.0, 0.0, 0.0]);
            new_Sprite.Spin_is (Identity_3x3);

            Self.bone_pose_Transforms.insert (the_Bone, Identity_4x4);
            Self.skin_Sprite := new_Sprite;

         else
            new_Sprite := gel.Forge.new_box_Sprite (in_World     => in_World.all'Access,
                                                    Mass         => 1.0,
                                                    Size         => Scale,
                                                    Colors       => [1      => Black,
                                                                     3      => Green,
                                                                     4      => Blue,
                                                                     others => Red],
                                                    is_Kinematic => Kinematic);
            new_Sprite.Site_is (the_bone_Site);
            new_Sprite.Spin_is (Inverse (get_Rotation (Self.joint_bind_Matrix (start_Joint))));

            new_Sprite.is_Visible (False);

            Self.anim_joint_site_Offets.insert (the_Bone,   Inverse (get_Rotation (Self.joint_inv_bind_Matrix (start_Joint)))
                                                          * (joint_Sites (start_Joint) - the_bone_Site));

            Self.phys_joint_site_Offets.insert (the_Bone,  joint_Sites (start_Joint) - the_bone_Site);


            Self.bone_pose_Transforms  .insert (the_Bone,  to_transform_Matrix (Rotation    => get_Rotation (Self.joint_pose_Transforms (start_Joint)),
                                                                                Translation => the_bone_Site));
         end if;

         Self.bone_Sprites.insert (the_Bone, new_Sprite);

         declare
            new_Sprite : constant gel.Sprite.view := gel.Forge.new_box_Sprite (in_World     => in_World,
                                                                               Mass         => 0.0,
                                                                               Size         => [0.02, 0.02, 0.02],
                                                                               Colors       => [others => Yellow],
                                                                               is_Kinematic => True);
         begin
            Self.joint_Sprites.insert (the_Bone, new_Sprite);
         end;
      end create_Bone;



      procedure create_Bone_for (the_Joint : in visual_Scenes.Node_view;   Parent : in bone_Id)
      is
         use bone_id_Maps_of_details;

         which_Joint      : constant scene_joint_Id      := the_Joint.Id;
         child_Joints     : constant visual_Scenes.Nodes := the_Joint.Children;

         the_bone_Details :          Rig.bone_Details;

         bone_Length      :          Real;
         end_Point        :          Vector_3;

         new_Joint        :          gel.Joint.view;


         function guessed_bone_Length return Real
         is
         begin
            if child_Joints'Length = 0
            then
               return prior_bone_Length;

            else
               if which_Joint = Self.root_Joint.Id
               then
                  return Distance (joint_Sites.Element (which_Joint),
                                   joint_Sites.Element (child_Joints (child_Joints'First).Id));
               else
                  return Distance (joint_Sites.Element (which_Joint),
                                   joint_Sites.Element (child_Joints (child_Joints'Last).Id));
               end if;
            end if;
         end guessed_bone_Length;


      begin
         if bone_Details.contains (which_Joint)
         then
            the_bone_Details := bone_Details.Element (which_Joint);

            if the_bone_Details.Length = Unspecified
            then   bone_Length := guessed_bone_Length;
            else   bone_Length := the_bone_Details.Length;
            end if;

         else
            bone_Length := guessed_bone_Length;
         end if;

         end_Point         :=   joint_Sites.Element (which_Joint)
                              + [0.0, bone_Length, 0.0] * get_Rotation (Self.joint_bind_Matrix (which_Joint));
         prior_bone_Length := bone_Length;

         Self.joint_Parent.insert (which_Joint, Parent);

         create_Bone (which_Joint,
                      which_Joint,
                      end_Point,
                      [the_bone_Details.width_Factor * bone_Length,
                       bone_Length * 0.90,
                       the_bone_Details.depth_Factor * bone_Length]);

         if Parent /= (+"")
         then
            Self.Sprite (Parent).attach_via_ball_Socket (Self.bone_Sprites (which_Joint),

                                                         pivot_Axis   => x_Rotation_from (0.0),
                                                         pivot_Anchor => joint_Sites.Element (which_Joint),

                                                         pitch_Limits => the_bone_Details.pitch_Limits,
                                                         yaw_Limits   => the_bone_Details.  yaw_Limits,
                                                         roll_Limits  => the_bone_Details. roll_Limits,

                                                         new_Joint    => new_Joint);

            Self.Joints.insert (to_gel_joint_Id (Parent, which_Joint),
                                new_Joint);
         end if;

         for i in child_Joints'Range
         loop
            create_Bone_for (child_Joints (i),           -- Recurse over children.
                             parent => which_Joint);
         end loop;
      end create_Bone_for;


      use collada.Library.Controllers;

      global_transform_Slot : Positive := 1;

   begin
      Self.root_Joint := the_root_Joint;                 -- Remember our root joint.
      Self.Model      := Model.all'unchecked_Access;     -- Remember our model.
      Self.Mode       := Mode;


      --- Parse Controllers.
      --

      -- Set the bind shape matrix.
      --
      Self.bind_shape_Matrix := Transpose (bind_shape_Matrix_of (the_Skin));


      -- Set the inverse bind matrices for all joints.
      --
      declare
         the_bind_Poses : constant collada.Matrix_4x4_array := bind_Poses_of (the_Skin);
      begin
         for i in 1 .. Integer (the_bind_Poses'Length)
         loop
            Self.joint_inv_bind_Matrices           .append (Transpose (the_bind_Poses (i)));    -- Transpose corrects for collada column vectors.
            Self.program_Parameters.bone_Transforms.append (Identity_4x4);
         end loop;
      end;


      --- Parse Visual Scene.
      --

      Self.define_global_Transform_for (the_root_Joint,                  -- Determine all joint transforms, recursively.
                                        Slot => global_transform_Slot);


      -- Set the joint slots: the skin names its joints by the nodes' sids (or ids), the rig keys them by id.
      --
      declare
         the_joint_Names : constant collada.Text_array := joint_Names_of (the_Skin);
         id_of_Sid       :          joint_id_Map_of_joint_id;
      begin
         for Each in Self.collada_Joints.iterate
         loop
            declare
               the_Node : constant visual_Scenes.Node_view := joint_id_Maps_of_scene_node.Element (Each);
            begin
               if the_Node.Sid /= "" and then not id_of_Sid.contains (the_Node.Sid)
               then
                  id_of_Sid.insert (the_Node.Sid, the_Node.Id);
               end if;
            end;
         end loop;

         for i in 1 .. Integer (the_joint_Names'Length)
         loop
            declare
               Name : constant scene_joint_Id := the_joint_Names (i);
               Id   : constant scene_joint_Id := (if    id_of_Sid          .contains (Name) then id_of_Sid (Name)
                                                  elsif Self.collada_Joints.contains (Name) then Name
                                                  else  null_Id);
            begin
               if Id = null_Id
               then
                  raise gel.Error with model_Name & ": the skin joint '" & (+Name) & "' is not a node under the skeleton root";
               end if;

               Self.program_Parameters.joint_Map_of_slot.insert (Id, i);
            end;
         end loop;
      end;

      set_Site_for    (the_root_Joint);
      create_Bone_for (the_root_Joint, Parent => +"");                   -- Create all other bones, recursively.


      --- Parse the animations.
      --

      declare
         use collada.Library.Animations;

         the_Animations : constant Animation_array_view := the_Document.Libraries.Animations.Contents;


         procedure add_Channel (the_Animation : in collada.Library.animations.Animation)
         --
         -- The channel's target names a joint's transform as '<node id>/<sid>[.<member>]'.
         -- Animations of nodes the rig does not model, of transforms a node lacks, and
         -- of things which are not node transforms (materials, for instance) are ignored.
         --
         is
            Target : constant String  := +the_Animation.Channel.Target;
            Slash  : constant Natural := ada.Strings.fixed.Index (Target, "/");
         begin
            if Slash = 0
            then
               return;
            end if;

            declare
               Joint  : constant scene_joint_Id := +Target (Target'First .. Slash - 1);
               Rest   : constant String         :=  Target (Slash + 1 .. Target'Last);
               Dot    : constant Natural        :=  ada.Strings.fixed.Index (Rest, ".");
               Sid    : constant String         := (if Dot = 0 then Rest else Rest (Rest'First .. Dot - 1));
               Member : constant String         := (if Dot = 0 then ""   else Rest (Dot + 1 .. Rest'Last));

               the_Channel : animation_Channel;
               per_Key     : Positive;
            begin
               if not Self.scene_Joints.contains (Joint)
               then
                  return;
               end if;

               the_Channel.target_Joint := Joint;
               the_Channel.Target       := Self.scene_Joints (Joint).Node.fetch_Transform (Sid);
               the_Channel.Times        := Inputs_of  (the_Animation);
               the_Channel.Values       := Outputs_of (the_Animation);

               if the_Channel.Target = null or else the_Channel.Times = null or else the_Channel.Values = null
               then
                  return;
               end if;

               case the_Channel.Target.Kind
               is
                  when visual_Scenes.full_Transform =>
                     if Member /= "" then return; end if;
                     the_Channel.Kind := full_Transform;
                     per_Key          := 16;

                  when visual_Scenes.Rotate =>
                     if Member /= "ANGLE" then return; end if;
                     the_Channel.Kind := Rotation;
                     per_Key          := 1;

                  when visual_Scenes.Translate =>
                     if    Member = ""  then the_Channel.Kind := Location;     per_Key := 3;
                     elsif Member = "X" then the_Channel.Kind := location_X;   per_Key := 1;
                     elsif Member = "Y" then the_Channel.Kind := location_Y;   per_Key := 1;
                     elsif Member = "Z" then the_Channel.Kind := location_Z;   per_Key := 1;
                     else                    return;
                     end if;

                  when visual_Scenes.Scale =>
                     return;
               end case;

               if the_Channel.Values'Length /= the_Channel.Times'Length * per_Key
               then
                  raise gel.Error with   model_Name & ": animation '" & Target & "' has"
                                       & the_Channel.Values'Length'Image & " values for"
                                       & the_Channel.Times'Length'Image  & " keys";
               end if;

               if the_Channel.Kind = full_Transform
               then
                  the_Channel.Transforms := new Transforms (1 .. the_Channel.Times'Length);

                  for i in the_Channel.Transforms'Range
                  loop
                     declare
                        the_Matrix : constant Matrix_4x4 := Transpose (collada.get_Matrix (the_Channel.Values.all, Which => i));
                     begin
                        the_Channel.Transforms (i) := (Rotation    => to_Quaternion (get_Rotation    (the_Matrix)),
                                                       Translation =>                get_Translation (the_Matrix));
                     end;
                  end loop;
               end if;

               if Self.Channels.contains (+Target)
               then
                  raise gel.Error with model_Name & ": animation '" & Target & "' appears twice";
               end if;

               Self.Channels.insert (+Target, the_Channel);
            end;
         end add_Channel;

      begin
         if the_Animations /= null
         then
            for Each of the_Animations.all
            loop
               add_Channel (Each);
            end loop;
         end if;
      end;

      Self.Document := the_Document;
   end define;



   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Transforms, Transforms_view);
   begin
      for Each of Self.Channels
      loop
         deallocate (Each.Transforms);
      end loop;

      Self.Channels            .clear;
      Self.animation_Transforms.clear;
      Self.bone_pose_Transforms.clear;
      Self.scene_Joints        .clear;
      Self.collada_Joints      .clear;
      Self.root_Joint := null;

      Self.Document.destroy;
   end destroy;



   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      Self.destroy;
      deallocate (Self);
   end free;



   procedure enable_Graphics (Self : in out Item)
   is
   begin
      Self            .program_Parameters.Program_is (opengl.Program.view (opengl.Geometry.lit_colored_textured_skinned.Program));
      Self.skin_Sprite.program_Parameters_are (Self.program_Parameters'unchecked_Access);
   end enable_Graphics;



   function Joints (Self : in Item) return gel_joint_id_Map_of_gel_Joint
   is
   begin
      return Self.Joints;
   end Joints;



   function joint_inv_bind_Matrices (Self : in Item'Class) return inverse_bind_matrix_Vector
   is
   begin
      return Self.joint_inv_bind_Matrices;
   end joint_inv_bind_Matrices;



   procedure joint_inv_bind_Matrices_are (Self : in out Item'Class;   Now : in inverse_bind_matrix_Vector)
   is
   begin
      Self.joint_inv_bind_Matrices := Now;
   end joint_inv_bind_Matrices_are;



   function joint_site_Offets (Self : in Item'Class) return joint_Id_Map_of_bone_site_offset
   is
   begin
      return Self.phys_joint_site_Offets;
   end joint_site_Offets;


   --------------
   --- Attributes
   --

   procedure Site_is (Self : in out Item;   Now : in Vector_3)
   is
   begin
      Self.base_Sprite.move (to_Site => Now);
      Self.overall_Site := Now;
   end Site_is;



   procedure Spin_is (Self : in out Item;   Now : in Matrix_3x3)
   is
   begin
      Self.base_Sprite.rotate (to_Spin => Now);
      Self.overall_Spin := Now;
   end Spin_is;



   function Sprite (Self : in Item'Class;   Bone : in bone_Id) return gel.Sprite.view
   is
   begin
      return Self.bone_Sprites (Bone);
   end Sprite;



   function base_Sprite (Self : in Item'Class) return gel.Sprite.view
   is
   begin
      return Self.bone_Sprites.Element (Self.root_Joint.Id);
   end base_Sprite;



   function skin_Sprite (Self : in Item'Class) return gel.Sprite.view
   is
   begin
      return Self.skin_Sprite;
   end skin_Sprite;



   function bone_Sprites (Self : in Item) return bone_id_Map_of_sprite
   is
   begin
      return Self.bone_Sprites;
   end bone_Sprites;



   procedure set_GL_program_Parameters (Self : in out Item'Class;   for_Bone : in controller_joint_Id;
                                                                    To       : in Matrix_4x4)
   is
      use gel.Conversions;

      bone_Slot : constant Positive := Self.program_Parameters.joint_Map_of_slot.Element (for_Bone);
   begin
      Self.program_Parameters.bone_Transforms.replace_Element (bone_Slot,
                                                               to_GL (To));
   end set_GL_program_Parameters;



   procedure animation_Transforms_are (Self : in out Item'Class;   Now : in bone_id_Map_of_transform)
   is
   begin
      Self.animation_Transforms := Now;
   end animation_Transforms_are;



   procedure motion_Mode_is (Self : in out Item;   Now : in motion_Mode)
   is
   begin
      Self.Mode := Now;
   end motion_Mode_is;



   function Mode (Self : in Item) return motion_Mode
   is
   begin
      return Self.Mode;
   end Mode;


   --------------
   --- Operations
   --

   procedure evolve (Self : in out Item'Class;   world_Age : in Duration)
   is

      function get_root_Transform return Matrix_4x4
      is
      begin
         case Self.Mode
         is
            when Dynamics =>
               return Self.base_Sprite.Transform;

            when Animation =>
               declare
                  the_Transform : Matrix_4x4;
               begin
                  set_Rotation    (the_Transform,  x_Rotation_from (to_Radians (0.0)));
                  set_Translation (the_Transform, -get_Translation (Inverse (Self.joint_pose_Transforms (Self.root_Joint.Id))));

                  return the_Transform;
               end;
         end case;
      end get_root_Transform;


      root_Transform     : constant Matrix_4x4 := get_root_Transform;
      inv_root_Transform : constant Matrix_4x4 := Inverse (root_Transform);


      function joint_Transform_for (the_collada_Joint : in controller_joint_Id) return Matrix_4x4
      is
      begin
         case Self.Mode
         is
            when Dynamics =>
               declare
                  the_bone_Transform    : constant Matrix_4x4 := Self.Sprite (the_collada_Joint).Transform;
                  the_joint_site_Offset :          Vector_3   := Self.joint_site_Offet (the_collada_Joint);
                  the_joint_Transform   :          Matrix_4x4;
               begin
                  the_joint_site_Offset :=   the_joint_site_Offset
                                           * get_Rotation (Self.joint_inv_bind_Matrix (the_collada_Joint))
                                           * get_Rotation (the_bone_Transform);

                  set_Translation (the_joint_Transform,  get_Translation (the_bone_Transform) + the_joint_site_Offset);
                  set_Rotation    (the_joint_Transform,  get_Rotation    (the_bone_Transform));

                  Self.joint_Sprites (the_collada_Joint).all.Site_is (get_Translation (the_joint_Transform));

                  return the_joint_Transform;
               end;

            when Animation =>
               Self.joint_Sprites (the_collada_Joint).all.Site_is (         get_Translation (Self.scene_Joints (the_collada_Joint).Transform));
               Self.joint_Sprites (the_collada_Joint).all.Spin_is (Inverse (get_Rotation    (Self.scene_Joints (the_collada_Joint).Transform)));

               return Self.scene_Joints (the_collada_Joint).Transform;
         end case;
      end joint_Transform_for;



      procedure set_Transform_for (the_Bone : in controller_joint_Id)
      is
         the_Slot : constant Positive := Self.program_Parameters.joint_Map_of_slot (the_Bone);
      begin
         Self.set_GL_program_Parameters (for_Bone => the_Bone,
                                         To       =>   Self.bind_shape_Matrix
                                                     * Self.joint_inv_bind_Matrices.Element (the_Slot)
                                                     * joint_Transform_for (the_Bone)
                                                     * inv_root_Transform);
      end set_Transform_for;



      use joint_id_Maps_of_slot;

      Cursor : joint_id_Maps_of_slot.Cursor := Self.program_Parameters.joint_Map_of_slot.First;

   begin
      if Self.Mode = Animation
      then
         Self.animate (world_Age);
      end if;

      while has_Element (Cursor)
      loop
         set_Transform_for (Key (Cursor));     -- Updates the skin program's bone transform, the root's included.
         next (Cursor);
      end loop;
   end evolve;



   procedure assume_Pose (Self : in out Item)
   is
      use bone_id_Maps_of_transform;

      Placement : constant Matrix_4x4 := to_transform_Matrix (Rotation    => Self.overall_Spin,
                                                              Translation => Self.overall_Site);
      the_Bone  : gel.Sprite.view;
      Cursor    : bone_id_Maps_of_transform.Cursor := Self.bone_pose_Transforms.First;

   begin
      while has_Element (Cursor)
      loop
         the_Bone := Self.bone_Sprites (Key (Cursor));
         the_Bone.Transform_is (Element (Cursor) * Placement);     -- The pose is about the origin; then the rig's placement.

         next (Cursor);
      end loop;
   end assume_Pose;



   function Parent_of (Self : in Item;   the_Bone : in bone_Id) return bone_Id
   is
   begin
      if Self.joint_Parent.Contains (the_Bone)
      then
         return Self.joint_Parent.Element (the_Bone);
      else
         return null_Id;
      end if;
   end Parent_of;



   function joint_site_Offet (Self : in Item;   for_Bone : in bone_Id) return math.Vector_3
   is
      use ada.Strings.unbounded;
   begin
      if for_Bone = Self.root_Joint.Id
      then
         return [0.0, 0.0, 0.0];     -- The root bone's sprite sits on its joint.
      end if;

      return Self.phys_joint_site_Offets.Element (for_Bone);
   end joint_site_Offet;



   function joint_inv_bind_Matrix (Self : in Item;   for_Bone : in bone_Id) return math.Matrix_4x4
   is
      use ada.Strings.unbounded;
   begin
      if for_Bone = Self.root_Joint.Id
      then
         return math.Identity_4x4;
      else
         return Self.joint_inv_bind_Matrices.Element (Self.program_Parameters.joint_Map_of_slot.Element (for_Bone));
      end if;
   end joint_inv_bind_Matrix;



   function joint_bind_Matrix (Self : in Item;   for_Bone : in bone_Id) return Matrix_4x4
   is
   begin
      return Inverse (Self.joint_inv_bind_Matrix (for_Bone));
   end joint_bind_Matrix;


   -------------
   --- Animation
   --

   procedure apply (the_Channel : in out animation_Channel;   at_Time : in Real)
   --
   -- Poses the channel's transform for a time into its clip, interpolating
   -- between the keys on either side of it. The clip loops.
   --
   is
      Times  : collada.float_array renames the_Channel.Times .all;
      Values : collada.float_array renames the_Channel.Values.all;

      Last   : constant Index := Times'Last;
      Time   :          Real  := at_Time;
      Key    :          Index;                   -- The key at or after 'Time' ...
      Prior  :          Index;                   -- ... and the one before it.
      Blend  :          Real;                    -- How far from 'Prior' to 'Key', 0.0 .. 1.0.


      function Reduced (Angle : in Real) return Real
      --
      -- The shortest way round, for angles in degrees.
      --
      is
      begin
         if    Angle >  180.0 then   return Angle - 360.0;
         elsif Angle < -180.0 then   return Angle + 360.0;
         else                        return Angle;
         end if;
      end Reduced;


      function Scalar (at_Key : in Index) return Real
      is (Values (at_Key));

      function Vector (at_Key : in Index) return Vector_3
      is ([Values ((at_Key - 1) * 3 + 1),
           Values ((at_Key - 1) * 3 + 2),
           Values ((at_Key - 1) * 3 + 3)]);

   begin
      if Times'Length = 0
      then
         return;
      end if;

      if Times (Last) > 0.0 and then Time >= Times (Last)
      then
         Time := Time - Real'Floor (Time / Times (Last)) * Times (Last);     -- Loop the clip.
      end if;

      if Times'Length = 1 or else Time <= Times (Times'First)
      then
         Key   := Times'First;
         Prior := Key;
         Blend := 0.0;
      else
         Key := Times'First + 1;

         while Key < Last and then Time >= Times (Key)
         loop
            Key := Key + 1;
         end loop;

         Prior := Key - 1;
         Blend := (Time - Times (Prior)) / (Times (Key) - Times (Prior));
      end if;

      case the_Channel.Kind
      is
         when Rotation =>
            the_Channel.Target.Angle := to_Radians (Degrees (  Scalar (Prior)
                                                             + Blend * Reduced (Scalar (Key) - Scalar (Prior))));
         when Location =>
            the_Channel.Target.Vector := Vector (Prior) + (Vector (Key) - Vector (Prior)) * Blend;

         when location_X =>
            the_Channel.Target.Vector (1) := Scalar (Prior) + Blend * (Scalar (Key) - Scalar (Prior));

         when location_Y =>
            the_Channel.Target.Vector (2) := Scalar (Prior) + Blend * (Scalar (Key) - Scalar (Prior));

         when location_Z =>
            the_Channel.Target.Vector (3) := Scalar (Prior) + Blend * (Scalar (Key) - Scalar (Prior));

         when full_Transform =>
            declare
               From          : Transform renames the_Channel.Transforms (Prior);
               To            : Transform renames the_Channel.Transforms (Key);
               new_Transform : Matrix_4x4 := Identity_4x4;
            begin
               if Blend = 0.0
               then
                  set_Rotation (new_Transform, to_Matrix (From.Rotation));
               else
                  set_Rotation (new_Transform, to_Matrix (Interpolated (From.Rotation,
                                                                        To  .Rotation,
                                                                        Percent => to_Percentage (Blend))));
               end if;

               set_Translation (new_Transform, From.Translation + (To.Translation - From.Translation) * Blend);

               the_Channel.Target.Matrix := Transpose (new_Transform);     -- Transpose to convert to collada column vectors.
            end;
      end case;
   end apply;



   procedure animate (Self : in out Item;   world_Age : in Duration)
   is
   begin
      if Self.start_Time = 0.0
      then
         Self.start_Time := world_Age;
      end if;

      declare
         Elapsed : constant Real := Real (world_Age - Self.start_Time);
      begin
         for Each of Self.Channels
         loop
            apply (Each, at_Time => Elapsed);
         end loop;
      end;

      Self.update_all_global_Transforms;
   end animate;



   procedure reset_Animation (Self : in out Item)
   is
   begin
      Self.start_Time := 0.0;
   end reset_Animation;


end gel.Rig;
