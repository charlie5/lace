limited
with
     openGL.Renderer.lean;


package gel.World.simple
--
-- Provides a simple gel world.
--
is

   type Item  is limited new gel.World.item
   with private;

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
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.simple.item;

      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.simple.view;
   end Forge;



private

   type Item is limited new gel.World.item with null record;


end gel.World.simple;
