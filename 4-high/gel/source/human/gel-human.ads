with
     gel.Rig,
     gel.Sprite,
     gel.World;

private
with
     openGL.Model.any;


package gel.Human
--
-- A rigged human: a gel.Rig built from a collada model, with a choice of what
-- to show and the joint limits of a MakeHuman skeleton ready to hand.
--
is
   type Item is tagged limited private;
   type View is access all Item'Class;

   use Math;


   --------------
   --- Core Types
   --

   subtype motion_Mode is gel.Rig.motion_Mode;

   function Dynamics  return motion_Mode renames gel.Rig.Dynamics;
   function Animation return motion_Mode renames gel.Rig.Animation;

   type display_Mode is (Skin, Bones, Skin_and_Bones);


   function makehuman_Details return gel.Rig.bone_id_Map_of_details;
   --
   -- Joint limits for the skeleton MakeHuman exports (bones 'Hips', 'Spine1',
   -- 'Clavicle_L', 'UpArm_L' and so on).


   ---------
   --- Forge
   --

   procedure define (Self : in out Item;   World        : in gel.World.view;
                                           Model        : in String;
                                           Mass         : in Real                        := 0.0;
                                           is_Kinematic : in Boolean                     := False;
                                           Mode         : in motion_Mode                 := Animation;
                                           Display      : in display_Mode                := Skin;
                                           bone_Details : in gel.Rig.bone_id_Map_of_details := gel.Rig.bone_id_Maps_of_details.empty_Map);
   --
   -- Builds the rig from the collada file 'Model' and adds the human to the world.
   -- A human made for Animation is built from kinematic bodies (see gel.Rig.define).

   procedure destroy (Self : in out Item);
   --
   -- Destroy a human after its world, as for a rig.

   procedure free (Self : in out View);


   package Forge
   is
      function new_Human (World        : in gel.World.view;
                          Model        : in String;
                          Mass         : in Real                        := 0.0;
                          is_Kinematic : in Boolean                     := False;
                          Mode         : in motion_Mode                 := Animation;
                          Display      : in display_Mode                := Skin;
                          bone_Details : in gel.Rig.bone_id_Map_of_details := gel.Rig.bone_id_Maps_of_details.empty_Map) return View;
   end Forge;


   --------------
   --- Attributes
   --

   function  Rig             (Self : access Item)       return gel.Rig.view;
   function  base_Sprite     (Self : in     Item'Class) return gel.Sprite.view;
   function  skin_Sprite     (Self : in     Item'Class) return gel.Sprite.view;

   procedure motion_Mode_is  (Self : in out Item;   Now : in motion_Mode);
   procedure display_Mode_is (Self : in out Item;   Now : in display_Mode);

   procedure Site_is         (Self : in out Item;   Now : in Vector_3);
   procedure Spin_is         (Self : in out Item;   Now : in Matrix_3x3);


   --------------
   --- Operations
   --

   procedure evolve (Self : in out Item'Class;   world_Age : in Duration);
   --
   -- Animates the rig when in Animation mode, then poses the skin.



private

   type Item is tagged limited
      record
         Rig     : aliased gel.Rig.item;
         Model   :         openGL.Model.any.view;
         Display :         display_Mode := Skin;
      end record;

end gel.Human;
