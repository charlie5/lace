with
     openGL.texture_Set,
     ada.Strings.unbounded,
     ada.unchecked_Deallocation;


package body gel.Human
is
   use ada.Strings.unbounded;


   function makehuman_Details return gel.Rig.bone_id_Map_of_details
   is
      use gel.Rig;

      Details : bone_id_Map_of_details;

      Wide : constant gel.Sprite.DoF_Limits := (-0.5, 0.5);
      Hand : constant gel.Sprite.DoF_Limits := (-0.5, 0.0);
      None : constant gel.Sprite.DoF_Limits := ( 0.0, 0.0);
      Knee : constant gel.Sprite.DoF_Limits := ( 0.0, to_Radians (90.0));


      procedure limit (Bone : in String;   Pitch, Yaw, Roll : in gel.Sprite.DoF_Limits)
      is
      begin
         Details.insert (to_unbounded_String (Bone),
                         to_Details (pitch_Limits => Pitch,
                                     yaw_Limits   => Yaw,
                                     roll_Limits  => Roll));
      end limit;

   begin
      for Side of String'("LR")
      loop
         limit ("Clavicle_" & Side,  Wide, Wide, Wide);
         limit ("UpArm_"    & Side,  Wide, Wide, Wide);
         limit ("LoArm_"    & Side,  Wide, Wide, Wide);
         limit ("Hand_"     & Side,  Hand, Hand, None);
         limit ("LoLeg_"    & Side,  Knee, None, None);
      end loop;

      return Details;
   end makehuman_Details;


   ---------
   --- Forge
   --

   procedure define (Self : in out Item;   World        : in gel.World.view;
                                           Model        : in String;
                                           Mass         : in Real                        := 0.0;
                                           is_Kinematic : in Boolean                     := False;
                                           Display      : in display_Mode                := Skin;
                                           bone_Details : in gel.Rig.bone_id_Map_of_details := gel.Rig.bone_id_Maps_of_details.empty_Map)
   is
   begin
      Self.Model := openGL.Model.any.new_Model (Model            => openGL.to_Asset (Model),
                                                Texture          => openGL.null_Asset,
                                                texture_Details  => openGL.texture_Set.to_Set ([1 => openGL.to_Asset ("assets/gel/Face1.bmp")]),
                                                Texture_is_lucid => False);

      Self.Rig.define (World, Self.Model.all'Access, Mass, is_Kinematic, bone_Details);

      World.add (Self.Rig.base_Sprite, and_Children => True);
      Self.Rig.enable_Graphics;
      Self.display_Mode_is (Display);
   end define;



   procedure destroy (Self : in out Item)
   is
   begin
      Self.Rig.destroy;
   end destroy;



   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      Self.destroy;
      deallocate (Self);
   end free;



   package body Forge
   is
      function new_Human (World        : in gel.World.view;
                          Model        : in String;
                          Mass         : in Real                        := 0.0;
                          is_Kinematic : in Boolean                     := False;
                          Display      : in display_Mode                := Skin;
                          bone_Details : in gel.Rig.bone_id_Map_of_details := gel.Rig.bone_id_Maps_of_details.empty_Map) return View
      is
         Self : constant View := new Item;
      begin
         Self.define (World, Model, Mass, is_Kinematic, Display, bone_Details);
         return Self;
      end new_Human;
   end Forge;


   --------------
   --- Attributes
   --

   function Rig (Self : access Item) return gel.Rig.view
   is
   begin
      return Self.Rig'unchecked_Access;
   end Rig;



   function base_Sprite (Self : in Item'Class) return gel.Sprite.view
   is
   begin
      return Self.Rig.base_Sprite;
   end base_Sprite;



   function skin_Sprite (Self : in Item'Class) return gel.Sprite.view
   is
   begin
      return Self.Rig.skin_Sprite;
   end skin_Sprite;



   procedure motion_Mode_is (Self : in out Item;   Now : in motion_Mode)
   is
   begin
      Self.Rig.motion_Mode_is (Now);
   end motion_Mode_is;



   procedure display_Mode_is (Self : in out Item;   Now : in display_Mode)
   is
      use gel.Rig.bone_id_Maps_of_sprite;
      use type gel.Sprite.view;

      the_Bones : constant gel.Rig.bone_id_Map_of_sprite := Self.Rig.bone_Sprites;
      Cursor    :          gel.Rig.bone_id_Maps_of_sprite.Cursor := the_Bones.First;
   begin
      Self.Display := Now;
      Self.Rig.skin_Sprite.is_Visible (Now in Skin | Skin_and_Bones);

      while has_Element (Cursor)
      loop
         if Element (Cursor) /= Self.Rig.skin_Sprite
         then
            Element (Cursor).is_Visible (Now in Bones | Skin_and_Bones);
         end if;

         next (Cursor);
      end loop;
   end display_Mode_is;



   procedure Site_is (Self : in out Item;   Now : in Vector_3)
   is
   begin
      Self.Rig.Site_is (Now);
   end Site_is;



   procedure Spin_is (Self : in out Item;   Now : in Matrix_3x3)
   is
   begin
      Self.Rig.Spin_is (Now);
   end Spin_is;


   --------------
   --- Operations
   --

   procedure evolve (Self : in out Item'Class;   world_Age : in Duration)
   is
      use type gel.Rig.motion_Mode;
   begin
      Self.Rig.evolve (world_Age);

      if Self.Rig.Mode = gel.Rig.Animation
      then
         Self.Rig.assume_Pose;     -- Hold the bone sprites in the bind pose while the animation drives the skin.
      end if;
   end evolve;


end gel.Human;
