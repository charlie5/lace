with
     lace.Observer,
     ada.Containers.Vectors;

limited
with
     openGL.Renderer.lean;


package gel.World.server
--
-- Provides a gel world server.
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
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.server.item;

      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.server.view;
   end Forge;


   procedure free (Self : in out View);


   --------------
   --- Operations
   --

   overriding
   procedure   register (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view);
   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view);

   overriding
   procedure evolve     (Self : in out Item);



private

   -----------
   --- Clients
   --

   use type remote.World.view;

   package world_Vectors is new ada.Containers.Vectors (Positive, remote.World.view);
   subtype world_Vector  is     world_Vectors.Vector;


   protected
   type safe_Clients
   is
      procedure add (the_Mirror : in     remote.World.view);
      procedure rid (the_Mirror : in     remote.World.view;
                     Found      :    out Boolean);

      function  fetch    return world_Vector;
      function  is_Empty return Boolean;

   private
      Clients : world_Vector;
   end safe_Clients;
   --
   -- Protected ~ 'register' and 'deregister' arrive on PolyORB tasks while
   -- 'evolve' walks the list on the main task.


   --------------
   --- World Item
   --

   type Item is limited new gel.World.item with
      record
         Age_at_last_Clients_update : Duration := 0.0;
         Clients                    : safe_Clients;

         -- Motion Updates
         --
         seq_Id : remote.World.sequence_Id := 0;
      end record;


end gel.World.server;
