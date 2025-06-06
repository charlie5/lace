limited
with
     openGL.Renderer.lean;


package gel.World.client
--
--  Provides a gel world.
--
is
   --  pragma Suppress (Container_Checks);     -- Suppress expensive tamper checks.

   type Item  is limited new gel.World.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   ---------
   --  Forge
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
   procedure add (Self : access Item;   the_Sprite   : in gel.Sprite.view;
                                        and_Children : in Boolean := False);

   overriding
   procedure evolve (Self : in out Item);

   --  overriding
   --  procedure wait_on_evolve (Self : in out Item);


   --------------------
   --- Server Mirroring
   --

   procedure is_a_Mirror (Self : access Item'Class;   of_World : in remote.World.view);

   overriding
   procedure motion_Updates_are (Self : in Item;   seq_Id : in remote.World.sequence_Id;
                                                   Now    : in remote.World.motion_Updates);
   --
   --  'Self' must use 'in' mode to ensure async transmission with DSA.


   ----------
   --- Events
   --



private

   protected
   type safe_id_Map_of_sprite
   is
      procedure add (the_Sprite : in Sprite.view);
      procedure rid (the_Sprite : in Sprite.view);

      function  fetch (Id : in sprite_Id) return Sprite.view;
      function  fetch_all return id_Maps_of_sprite.Map;

   private
      Map : id_Maps_of_sprite.Map;
   end safe_id_Map_of_sprite;



   type sprite_Map is limited new World.sprite_Map with
      record
         Map : safe_id_Map_of_sprite;
      end record;

   overriding
   function  fetch (From : in sprite_Map) return id_Maps_of_sprite.Map;

   overriding
   procedure add   (To   : in out sprite_Map;   the_Sprite : in Sprite.view);

   overriding
   procedure rid   (To   : in out sprite_Map;   the_Sprite : in Sprite.view);



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
         all_Sprites               : aliased sprite_Map;

         -- Motion Updates
         --
         seq_Id : safe_sequence_Id_view := new safe_sequence_Id;
      end record;


   overriding
   function all_Sprites (Self : access Item) return access World.sprite_Map'Class;


end gel.World.client;
