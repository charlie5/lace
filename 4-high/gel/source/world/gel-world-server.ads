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
   function    register (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view) return remote.World.mirror_Snapshot;
   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view);
   overriding
   procedure deregister (Self : in out Item;   the_Observer       : in lace.Observer.view);
   --
   -- The emitter buries a dead mirror's observer here on a failed delivery: drop that
   -- mirror from the client list too, so 'evolve' stops updating a client that has gone.

   overriding
   procedure evolve     (Self : in out Item);



private

   -----------
   --- Clients
   --

   use type remote.World .view,
            lace.Observer.view;

   type client_Pair is
      record
         Mirror   : remote.World .view;
         Observer : lace.Observer.view;     -- The observer given at registration, kept
      end record;                           -- so a disconnect can undo every subscription.

   package client_Vectors is new ada.Containers.Vectors (Positive, client_Pair);
   subtype client_Vector  is     client_Vectors.Vector;

   package observer_Vectors is new ada.Containers.Vectors (Positive, lace.Observer.view);
   subtype observer_Vector  is     observer_Vectors.Vector;


   protected
   type safe_Clients
   is
      procedure add (the_Mirror  : in     remote.World .view;
                     as_Observer : in     lace.Observer.view;
                     was_Added   :    out Boolean);
      entry     rid (the_Mirror  : in     remote.World .view;
                     the_Observer :   out lace.Observer.view;
                     Found       :    out Boolean);

      procedure note_Dead   (the_Observer : in lace.Observer.view);
      procedure prune_Dead;

      procedure begin_Round (Now : out client_Vector);
      procedure end_Round;

      function  is_Empty return Boolean;

   private
      Clients      : client_Vector;
      dead_Mirrors : observer_Vector;     -- Observers the emitter has buried, awaiting a prune by 'evolve'.
      round_Active : Boolean := False;
   end safe_Clients;
   --
   -- Protected ~ 'register' and 'deregister' arrive on PolyORB tasks while 'evolve'
   -- walks the list on the main task. 'add' reports whether the mirror was new, so a
   -- repeated registration cannot double the event subscriptions. An update round is
   -- bracketed by 'begin_Round'/'end_Round', and 'rid' waits for the round to end, so
   -- a mirror whose disconnect has completed can no longer receive an update call.


   --------------
   --- World Item
   --

   type Item is limited new gel.World.item with
      record
         Age_at_last_Clients_update : Duration := 0.0;
         Clients                    : safe_Clients;

         -- Motion Updates
         --
         seq_Id : remote.World.sequence_Id := 0 with Atomic;     -- Written by 'evolve', read by 'register' on a PolyORB task.
      end record;


end gel.World.server;
