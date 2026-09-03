limited
with
     openGL.Renderer.lean;


package gel.World.client
--
-- Provides a gel world which mirrors a server world.
--
is

   type Item  is limited new gel.World.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   ---------
   --- Forge
   --

   package Forge
   is
      function to_World  (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.client.item;

      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.client.view;
   end Forge;


   overriding
   procedure destroy (Self : in out Item);
   procedure free    (Self : in out View);


   --------------
   --- Operations
   --

   overriding
   procedure evolve (Self : in out Item);


   --------------------
   --- Server Mirroring
   --

   procedure is_a_Mirror (Self : access Item'Class;   of_World : in remote.World.view);

   overriding
   procedure motion_Updates_are (Self : in Item;   seq_Id : in remote.World.sequence_Id;
                                                   Now    : in remote.World.motion_Updates);
   --
   -- 'Self' must use 'in' mode to ensure async transmission with DSA.

   overriding
   function new_sprite_Id (Self : access Item) return sprite_Id;
   --
   -- Local sprite ids grow downward from 'sprite_Id'Last, so they cannot collide
   -- with the server-owned ids (which grow upward) kept by mirrored sprites.



private

   protected
   type safe_sequence_Id
   is
      procedure Value_is (Now : in remote.World.sequence_Id);
      function  Value       return remote.World.sequence_Id;

      procedure enter (Admitted : out Boolean);
      procedure leave;
      entry     close;
      --
      -- A motion update brackets its work with 'enter'/'leave'. 'close' bars any
      -- further updates and blocks until the admitted ones have left, so 'destroy'
      -- can tear the world down with no update in flight.
   private
      the_Value : remote.World.sequence_Id := 0;
      in_Flight : Natural                  := 0;
      is_Closed : Boolean                  := False;
   end safe_sequence_Id;

   type safe_sequence_Id_view is access all safe_sequence_Id;


   --------------
   --- World Item
   --

   type Item is limited new gel.World.item with
      record
         Age_at_last_mirror_update : Duration := 0.0;

         -- The server world being mirrored ~ on record so 'destroy' can deregister.
         --
         mirrored_World : remote.World.view;

         -- Motion Updates
         --
         seq_Id : safe_sequence_Id_view := new safe_sequence_Id;

         -- Local sprite id allocation (see 'new_sprite_Id', above).
         --
         next_local_sprite_Id : sprite_Id := sprite_Id'Last;
      end record;


end gel.World.client;
