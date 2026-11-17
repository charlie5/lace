with
     gel.Events,
     openGL.Renderer.lean,
     lace.Event.utility,

     system.RPC,

     ada.Exceptions,
     ada.Text_IO,
     ada.unchecked_Deallocation;


package body gel.World.server
is
   use
        gel.Sprite,
        linear_Algebra,
        lace.Event.utility,
        lace.Event;


   procedure log (Message : in String)
                  renames ada.text_IO.put_Line;


   procedure disconnect (Self : in out Item;   the_Mirror     : in remote.World.view;
                                               by_its_Courier : in Boolean := False);
   --
   -- Undo a mirror's registration: rid it from the client list and, when it was
   -- registered, close its outbox and deregister its observer from every mirrored event
   -- kind. It waits for any call to the mirror under way to end, two seconds at most, so
   -- that a mirror whose disconnect has completed is sent no more updates, unless that
   -- mirror hangs: 'by_its_Courier' for the courier itself, which has no call under way.


   procedure free is new ada.unchecked_Deallocation (Outbox,  Outbox_view);
   procedure free is new ada.unchecked_Deallocation (Courier, Courier_view);


   ------------
   --- Couriers
   --

   protected
   body Outbox
   is
      procedure deposit (seq_Id  : in     remote.World.sequence_Id;
                         Updates : in     remote.World.motion_Updates)
      is
      begin
         if is_Closed
         then
            return;
         end if;

         for Each of Updates
         loop
            Pending.include (Each.Id, Each);     -- The latest of each sprite.
         end loop;

         Latest := seq_Id;
      end deposit;



      entry take (seq_Id  :    out remote.World.sequence_Id;
                  Updates :    out update_Maps.Map;
                  Closed  :    out Boolean)
        when        is_Closed
            or else not Pending.is_Empty
      is
      begin
         Closed := is_Closed;
         seq_Id := Latest;

         if not is_Closed
         then
            Updates.move (Source => Pending);
            Sending := True;
         end if;
      end take;



      procedure sent
      is
      begin
         Sending := False;
      end sent;



      procedure close
      is
      begin
         is_Closed := True;
         Pending.clear;
      end close;



      entry await_Idle
        when not Sending
      is
      begin
         null;
      end await_Idle;

   end Outbox;



   task
   body Courier
   is
      use remote.World;

      World   : View;
      Mirror  : remote.World.view;
      Box     : Outbox_view;

      seq_Id  : remote.World.sequence_Id;
      Updates : update_Maps.Map;
      Closed  : Boolean;
   begin
      accept start (the_World  : in View;
                    the_Mirror : in remote.World.view;
                    the_Box    : in Outbox_view)
      do
         World  := the_World;
         Mirror := the_Mirror;
         Box    := the_Box;
      end start;

      loop
         Box.take (seq_Id, Updates, Closed);
         exit when Closed;

         declare
            Now : remote.World.motion_Updates (1 .. Natural (Updates.Length));
            i   : Natural := 0;
         begin
            for Each of Updates
            loop
               i       := i + 1;
               Now (i) := Each;
            end loop;

            Mirror.motion_Updates_are (seq_Id, Now);
            Box.sent;

         exception
            when E : system.RPC.communication_Error
                   | storage_Error =>
               -- The mirror is dead or unreachable: disconnect it rather than go on
               -- calling it. Any other exception is a genuine bug and is reported below.
               --
               Box.sent;
               Box.close;
               log ("Mirror update failed ~ disconnecting the mirror.");
               log (ada.Exceptions.exception_Information (E));
               disconnect (Item (World.all), Mirror, by_its_Courier => True);
               exit;
         end;
      end loop;

   exception
      when E : others =>
         Box.sent;
         Box.close;
         log ("Error in a 'gel.World.server' mirror's courier, which ends.");
         log (ada.Exceptions.exception_Information (E));
   end Courier;


   ---------
   --- Forge
   --

   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      deallocate (Self);
   end free;



   package body Forge
   is

      function to_World (Name       : in     String;
                         Id         : in     world_Id;
                         space_Kind : in     physics.space_Kind;
                         Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.server.item
      is
         use lace.Subject_and_deferred_Observer.Forge;
      begin
         return Self : gel.World.server.item := (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                                 with others => <>)
         do
            Self.define (Name, Id, space_Kind, Renderer);
         end return;
      end to_World;



      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.server.view
      is
         use lace.Subject_and_deferred_Observer.Forge;

         Self : constant gel.World.server.view
           := new gel.World.server.item' (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                          with others => <>);
      begin
         Self.define (Name, Id, space_Kind, Renderer);
         return Self;
      end new_World;

   end Forge;


   -----------
   --- Clients
   --

   protected
   body safe_Clients
   is

      function index_Of (the_Mirror : in remote.World.view) return client_Vectors.extended_Index
      is
      begin
         for i in Clients.first_Index .. Clients.last_Index
         loop
            if Clients.Element (i).Mirror = the_Mirror
            then
               return i;
            end if;
         end loop;

         return client_Vectors.no_Index;
      end index_Of;



      procedure add (the_Mirror  : in     remote.World .view;
                     as_Observer : in     lace.Observer.view;
                     the_Box     : in     Outbox_view;
                     was_Added   :    out Boolean)
      is
      begin
         was_Added := index_Of (the_Mirror) = client_Vectors.no_Index;

         if was_Added
         then
            Clients.append (client_Pair' (Mirror   => the_Mirror,
                                          Observer => as_Observer,
                                          Box      => the_Box,
                                          Carrier  => null));
         end if;
      end add;



      entry rid (the_Mirror : in     remote.World.view;
                 the_Pair   :    out client_Pair;
                 Found      :    out Boolean)
        when not round_Active
      is
         Index : constant client_Vectors.extended_Index := index_Of (the_Mirror);
      begin
         Found := Index /= client_Vectors.no_Index;

         if Found
         then
            the_Pair := Clients.Element (Index);
            Clients.delete (Index);
         else
            the_Pair := (others => <>);
         end if;
      end rid;



      procedure Carrier_is (the_Mirror : in remote.World.view;   Now : in Courier_view)
      is
         Index : constant client_Vectors.extended_Index := index_Of (the_Mirror);
      begin
         if Index /= client_Vectors.no_Index
         then
            Clients (Index).Carrier := Now;
         end if;
      end Carrier_is;



      procedure note_Dead (the_Observer : in lace.Observer.view)
      is
      begin
         dead_Mirrors.append (the_Observer);     -- 'evolve' prunes these; see 'prune_Dead'.
      end note_Dead;



      procedure prune_Dead (Pruned : out client_Vector)
      is
         use type lace.Observer.view;
      begin
         Pruned.clear;

         for each_dead_Observer of dead_Mirrors
         loop
            for i in Clients.first_Index .. Clients.last_Index
            loop
               if Clients.Element (i).Observer = each_dead_Observer
               then
                  Pruned.append (Clients.Element (i));
                  Clients.delete (i);
                  exit;
               end if;
            end loop;
         end loop;

         dead_Mirrors.clear;
      end prune_Dead;



      procedure begin_Round (Now : out client_Vector)
      is
      begin
         round_Active := True;
         Now          := Clients;
      end begin_Round;



      procedure end_Round
      is
      begin
         round_Active := False;
      end end_Round;



      function is_Empty return Boolean
      is
      begin
         return Clients.is_Empty;
      end is_Empty;

   end safe_Clients;


   --------------
   --- Operations
   --

   overriding
   procedure evolve (Self : in out Item)
   is
   begin
      gel.World.item (Self).evolve;     -- Evolve the base class.

      -- Drop any mirror the emitter has buried, before this step's update round: its
      -- outbox is closed, at which its courier ends.
      --
      declare
         Pruned : client_Vector;
      begin
         Self.Clients.prune_Dead (Pruned);

         for Each of Pruned
         loop
            if Each.Box /= null
            then
               Each.Box.close;
            end if;
         end loop;
      end;

      -- Update dynamics in client worlds.
      --
      declare
         use remote.World;

         is_a_mirrored_World    : constant Boolean := not Self.Clients.is_Empty;
         mirror_Updates_are_due : constant Boolean := Self.Age >= Self.Age_at_last_Clients_update + client_update_Period;

      begin
         if        is_a_mirrored_World
           and then mirror_Updates_are_due
         then
            declare
               all_Sprites        : constant gel.Sprite.Views := Self.all_Sprites.fetch_Views;
               --
               -- Taken only when an update is actually due: this runs every frame.

               updates_Count      :          Natural := 0;
               the_motion_Updates :          remote.World.motion_Updates (1 .. all_Sprites'Length);
            begin
               for the_Sprite of all_Sprites
               loop
                  declare
                     the_Site : constant Vector_3   := the_Sprite.Site;
                     the_Spin : constant Matrix_3x3 := the_Sprite.Spin;
                  begin
                     if the_Sprite.has_Moved (current_Site => the_Site,
                                              current_Spin => the_Spin)
                     then
                        updates_Count                      := updates_Count + 1;
                        the_motion_Updates (updates_Count) := (Id   => the_Sprite.Id,
                                                               Site => coarsen (the_Site),
                                                               Spin => coarsen (to_Quaternion (the_Spin)));
                     end if;
                  end;
               end loop;

               -- Leave the updated sprite motions in the outbox of each registered client
               -- world, for its courier to carry: nothing here waits on a client.
               --
               Self.Age_at_last_clients_update := Self.Age;
               Self.seq_Id                     := Self.seq_Id + 1;

               if updates_Count > 0
               then
                  declare
                     the_Clients : client_Vector;
                  begin
                     Self.Clients.begin_Round (the_Clients);

                     for the_Client of the_Clients
                     loop
                        if the_Client.Box /= null
                        then
                           the_Client.Box.deposit (Self.seq_Id,
                                                   the_motion_Updates (1 .. updates_Count));
                        end if;
                     end loop;

                     Self.Clients.end_Round;
                  end;
               end if;
            end;
         end if;
      end;

   end evolve;


   -----------------------
   --- Client Registration
   --

   overriding
   function register (Self : access Item;   the_Mirror         : in remote.World.view;
                                            Mirror_as_observer : in lace.Observer.view) return remote.World.mirror_Snapshot
   is
      was_Added : Boolean;
      the_Box   : Outbox_view := new Outbox;
   begin
      Self.Clients.add (the_Mirror, Mirror_as_observer, the_Box, was_Added);

      if was_Added
      then
         declare
            the_Courier : constant Courier_view := new Courier;     -- Made here, not in the protected 'add'.
         begin
            the_Courier.start (View (Self), the_Mirror, the_Box);
            Self.Clients.Carrier_is (the_Mirror, the_Courier);
         end;

         Self.register (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
         Self.register (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
         Self.register (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
         Self.register (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
      end if;

      if not was_Added
      then
         free (the_Box);     -- A repeated registration: the mirror has its outbox.
      end if;

      -- Capture the snapshot only now, after the observer is subscribed, so an
      -- addition or removal happening meanwhile can appear in both the snapshot
      -- and an event (the mirror applies them idempotently) but never in neither.
      -- The sequence id is read first, so an overlapping motion round is replayed
      -- rather than lost, and the models last, so every snapshot sprite's models
      -- are present.
      --
      declare
         the_seq_Id          : constant remote.World.sequence_Id              := Self.seq_Id;
         the_Sprites         : constant remote.World.sprite_model_Pairs       := Self.Sprites;
         the_graphics_Models : constant remote.World.id_Map_of_graphics_model := graphics_Models (Self.all);
         the_physics_Models  : constant remote.World.id_Map_of_physics_model  := physics_Models  (Self.all);
      begin
         return (sprite_Count    => the_Sprites'Length,
                 Sprites         => the_Sprites,
                 graphics_Models => the_graphics_Models,
                 physics_Models  => the_physics_Models,
                 seq_Id          => the_seq_Id);
      end;
   end register;



   procedure disconnect (Self : in out Item;   the_Mirror     : in remote.World.view;
                                               by_its_Courier : in Boolean := False)
   is
      the_Pair : client_Pair;
      Found    : Boolean;
   begin
      Self.Clients.rid (the_Mirror, the_Pair, Found);

      if not Found
      then
         return;     -- An unknown (or already disconnected) mirror ~ nothing to undo.
      end if;

      if the_Pair.Box /= null
      then
         the_Pair.Box.close;

         if not by_its_Courier
         then
            select
               the_Pair.Box.await_Idle;     -- No call to the mirror is under way, and none will be made.
            or
               delay 2.0;                   -- The mirror hangs: its courier is left to its call.
            end select;

            -- The courier ends at the close: it and the outbox are freed once it has, and
            -- left where it has not, a few thousand bytes the price of not waiting on a
            -- mirror which hangs.
            --
            if the_Pair.Carrier /= null
            then
               for Try in 1 .. 20
               loop
                  exit when the_Pair.Carrier'Terminated;
                  delay 0.01;
               end loop;

               if the_Pair.Carrier'Terminated
               then
                  free (the_Pair.Carrier);
                  free (the_Pair.Box);
               end if;
            end if;
         end if;
      end if;

      Self.deregister (the_Pair.Observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.deregister (the_Pair.Observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.deregister (the_Pair.Observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.deregister (the_Pair.Observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end disconnect;



   procedure drop_Mirrors (Self : in out Item)
   is
      Pairs : client_Vector;
   begin
      Self.Clients.begin_Round (Pairs);     -- A copy of the list, as an update round takes one.
      Self.Clients.end_Round;

      for Each of Pairs
      loop
         disconnect (Self, Each.Mirror);
      end loop;
   end drop_Mirrors;



   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view)
   is
      pragma unreferenced (Mirror_as_observer);     -- The observer given at registration is on record.
   begin
      disconnect (Self.all, the_Mirror);
   end deregister;



   overriding
   procedure deregister (Self : in out Item;   the_Observer : in lace.Observer.view)
   is
   begin
      -- The emitter buries a dead observer here on a failed delivery, from its own courier
      -- task. When that observer is a mirror's, note it so 'evolve' drops the mirror on its
      -- next step ~ each update to a gone client is a failed connection the async call
      -- swallows. Only a note is taken here, never a client-list edit under a round barrier:
      -- 'evolve' owns the list, so the courier can never block waiting on a round to end.
      --
      Self.Clients.note_Dead (the_Observer);

      gel.World.item (Self).deregister (the_Observer);     -- The base does the actual observer removal.
   end deregister;


end gel.World.server;
