with
     gel.Events,
     openGL.Renderer.lean,
     lace.Event.utility,

     system.RPC,

     ada.Text_IO,
     ada.unchecked_Deallocation;


package body gel.World.server
is
   use
        gel.Sprite,
        linear_Algebra_3D,
        lace.Event.utility,
        lace.Event;


   procedure log (Message : in String)
                  renames ada.text_IO.put_Line;


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
      procedure add (the_Mirror : in remote.World.view)
      is
      begin
         Clients.append (the_Mirror);
      end add;



      procedure rid (the_Mirror : in     remote.World.view;
                     Found      :    out Boolean)
      is
         use world_Vectors;

         Index : constant world_Vectors.extended_Index := Clients.find_Index (the_Mirror);
      begin
         Found := Index /= no_Index;

         if Found
         then
            Clients.delete (Index);
         end if;
      end rid;



      function fetch return world_Vector
      is
      begin
         return Clients;
      end fetch;



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
                     the_Clients  : constant world_Vector := Self.Clients.fetch;
                     dead_Clients :          world_Vector;
                  begin
                     for the_Mirror of the_Clients
                     loop
                        begin
                           the_Mirror.motion_Updates_are (Self.seq_Id,
                                                          the_motion_Updates (1 .. updates_Count));
                        exception
                           when system.RPC.communication_Error
                              | storage_Error =>
                              dead_Clients.append (the_Mirror);     -- The client is dead or unreachable.
                        end;
                     end loop;

                     -- Evict any dead clients, so one cannot stall the world forever.
                     --
                     for the_Mirror of dead_Clients
                     loop
                        declare
                           Found : Boolean;
                        begin
                           Self.Clients.rid (the_Mirror, Found);

                           if Found
                           then
                              log ("Evicting a dead client mirror.");
                           end if;
                        end;
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
   procedure register (Self : access Item;   the_Mirror         : in remote.World.view;
                                             Mirror_as_observer : in lace.Observer.view)
   is
   begin
      Self.Clients.add (the_Mirror);

      Self.register (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.register (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.register (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.register (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end register;



   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view)
   is
      Found : Boolean;
   begin
      Self.Clients.rid (the_Mirror, Found);

      if not Found
      then
         return;     -- An unknown mirror ~ nothing to deregister.
      end if;

      Self.deregister (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end deregister;


end gel.World.server;
