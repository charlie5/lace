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



private

   protected
   type safe_sequence_Id
   is
      procedure Value_is (Now : in remote.World.sequence_Id);
      function  Value       return remote.World.sequence_Id;
   private
      the_Value : remote.World.sequence_Id := 0;
   end safe_sequence_Id;

   type safe_sequence_Id_view is access all safe_sequence_Id;


   --------------
   --- World Item
   --

   type Item is limited new gel.World.item with
      record
         Age_at_last_mirror_update : Duration := 0.0;

         -- Motion Updates
         --
         seq_Id : safe_sequence_Id_view := new safe_sequence_Id;
      end record;


end gel.World.client;
