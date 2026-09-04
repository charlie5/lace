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
        linear_Algebra_3D,
        lace.Event.utility,
        lace.Event;


   procedure log (Message : in String)
                  renames ada.text_IO.put_Line;


   procedure disconnect (Self : in out Item;   the_Mirror : in remote.World.view);
   --
   -- Undo a mirror's registration: rid it from the client list and, when it was
   -- registered, deregister its observer from every mirrored event kind.


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
                     was_Added   :    out Boolean)
      is
      begin
         was_Added := index_Of (the_Mirror) = client_Vectors.no_Index;

         if was_Added
         then
            Clients.append (client_Pair' (Mirror   => the_Mirror,
                                          Observer => as_Observer));
         end if;
      end add;



      entry rid (the_Mirror   : in     remote.World .view;
                 the_Observer :    out lace.Observer.view;
                 Found        :    out Boolean)
        when not round_Active
      is
         Index : constant client_Vectors.extended_Index := index_Of (the_Mirror);
      begin
         Found := Index /= client_Vectors.no_Index;

         if Found
         then
            the_Observer := Clients.Element (Index).Observer;
            Clients.delete (Index);
         else
            the_Observer := null;
         end if;
      end rid;



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

               -- Send updated sprite motions to all registered client worlds.
               --
               Self.Age_at_last_clients_update := Self.Age;
               Self.seq_Id                     := Self.seq_Id + 1;

               if updates_Count > 0
               then
                  declare
                     the_Clients  : client_Vector;
                     dead_Clients : client_Vector;
                  begin
                     Self.Clients.begin_Round (the_Clients);

                     begin
                        for the_Client of the_Clients
                        loop
                           begin
                              the_Client.Mirror.motion_Updates_are (Self.seq_Id,
                                                                    the_motion_Updates (1 .. updates_Count));
                           exception
                              when E : system.RPC.communication_Error
                                     | storage_Error =>
                                 -- The mirror is dead or unreachable: disconnect it rather
                                 -- than die with it. Any other exception is a genuine bug
                                 -- and is left to propagate loudly.
                                 --
                                 log ("Mirror update failed ~ disconnecting the mirror.");
                                 log (ada.Exceptions.exception_Information (E));
                                 dead_Clients.append (the_Client);
                           end;
                        end loop;

                        Self.Clients.end_Round;
                     exception
                        when others =>
                           Self.Clients.end_Round;
                           raise;
                     end;

                     -- Disconnect any dead clients, so one cannot stall the world forever.
                     --
                     for the_Client of dead_Clients
                     loop
                        disconnect (Self, the_Client.Mirror);
                     end loop;
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
   begin
      Self.Clients.add (the_Mirror, Mirror_as_observer, was_Added);

      if was_Added
      then
         Self.register (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
         Self.register (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
         Self.register (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
         Self.register (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
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



   procedure disconnect (Self : in out Item;   the_Mirror : in remote.World.view)
   is
      the_Observer : lace.Observer.view;
      Found        : Boolean;
   begin
      Self.Clients.rid (the_Mirror, the_Observer, Found);

      if not Found
      then
         return;     -- An unknown (or already disconnected) mirror ~ nothing to undo.
      end if;

      Self.deregister (the_Observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.deregister (the_Observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.deregister (the_Observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.deregister (the_Observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end disconnect;



   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view)
   is
      pragma unreferenced (Mirror_as_observer);     -- The observer given at registration is on record.
   begin
      disconnect (Self.all, the_Mirror);
   end deregister;


end gel.World.server;
