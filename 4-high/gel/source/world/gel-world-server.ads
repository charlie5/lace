with
     lace.Observer,
     ada.Containers.Vectors,
     ada.Containers.Ordered_Maps;

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

   procedure drop_Mirrors (Self : in out Item);
   --
   -- Disconnects every mirror, so nothing the world does from here on is delivered to a
   -- client. For a server closing down: told to shut down, each client frees its mirror
   -- while the world's own destroy would still be sending it the rid of every sprite, and
   -- a delivery to a mirror a client has freed faults in the emitter's courier task.



private

   -----------
   --- Clients
   --

   use type remote.World .view,
            lace.Observer.view;

   ------------
   --- Couriers
   --
   -- Each mirror's motion updates are carried to it by a task of its own. 'evolve' called
   -- 'motion_Updates_are' on each mirror itself, and the call, asynchronous as it is, writes
   -- to the mirror's connection in the calling task: a client which stopped reading, hung or
   -- on a link gone bad, held that write, and the world stood still for every client in it
   -- for as long (a client stopped for ninety seconds stopped its world for ninety, 2026-11-17).
   -- Now 'evolve' leaves each round's updates in the mirror's outbox and goes on, and the
   -- mirror's courier takes what the outbox holds and makes the call. The outbox keeps the
   -- latest update of each sprite, so a courier held up carries, when it is free again, one
   -- set which brings its mirror up to date, and the outbox never holds more than one update
   -- a sprite.

   package update_Maps is new ada.Containers.Ordered_Maps (Key_type     => gel.sprite_Id,
                                                           Element_type => remote.World.motion_Update,
                                                           "="          => remote.World."=");
   protected
   type Outbox
   is
      procedure deposit (seq_Id  : in     remote.World.sequence_Id;
                         Updates : in     remote.World.motion_Updates);
      entry     take    (seq_Id  :    out remote.World.sequence_Id;
                         Updates :    out update_Maps.Map;
                         Closed  :    out Boolean);
      procedure sent;
      procedure close;
      entry     await_Idle;
      --
      -- 'take' waits for updates, or for the close: it hands over all the outbox holds with
      -- the latest sequence id deposited, and the courier is then sending until it calls
      -- 'sent'. A closed outbox takes no deposit and gives 'Closed' to its courier, which
      -- ends. 'await_Idle' waits until no call to the mirror is under way.

   private
      Pending   : update_Maps.Map;
      Latest    : remote.World.sequence_Id := 0;
      Sending   : Boolean                  := False;
      is_Closed : Boolean                  := False;
   end Outbox;

   type Outbox_view is access Outbox;


   task type Courier
   is
      entry start (the_World  : in View;
                   the_Mirror : in remote.World.view;
                   the_Box    : in Outbox_view);
   end Courier;

   type Courier_view is access Courier;


   type client_Pair is
      record
         Mirror   : remote.World .view;
         Observer : lace.Observer.view;     -- The observer given at registration, kept
         --                                    so a disconnect can undo every subscription.
         Box      : Outbox_view;            -- Where 'evolve' leaves the mirror's motion updates,
         Carrier  : Courier_view;           -- and the task which carries them to it.
      end record;

   package client_Vectors is new ada.Containers.Vectors (Positive, client_Pair);
   subtype client_Vector  is     client_Vectors.Vector;

   package observer_Vectors is new ada.Containers.Vectors (Positive, lace.Observer.view);
   subtype observer_Vector  is     observer_Vectors.Vector;


   protected
   type safe_Clients
   is
      procedure add (the_Mirror  : in     remote.World .view;
                     as_Observer : in     lace.Observer.view;
                     the_Box     : in     Outbox_view;
                     was_Added   :    out Boolean);
      entry     rid (the_Mirror  : in     remote.World .view;
                     the_Pair    :    out client_Pair;
                     Found       :    out Boolean);

      procedure Carrier_is  (the_Mirror   : in remote.World.view;   Now : in Courier_view);

      procedure note_Dead   (the_Observer : in lace.Observer.view);
      procedure prune_Dead  (Pruned       : out client_Vector);

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
