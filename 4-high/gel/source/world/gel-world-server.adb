with
     gel.Events,
     physics.Forge,
     openGL.Renderer.lean,
     lace.Event.utility,

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
   pragma Unreferenced (log);


   ---------
   --- Forge
   --

   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      deallocate (Self);
   end free;



   procedure define (Self : in out Item'Class;   Name       : in     String;
                                                 Id         : in     world_Id;
                                                 space_Kind : in     physics.space_Kind;
                                                 Renderer   : access openGL.Renderer.lean.item'Class);

   overriding
   procedure destroy (Self : in out Item)
   is
   begin
      physics.Space.free (Self.physics_Space);

      lace.Subject_and_deferred_Observer.item (Self).destroy;     -- Destroy base class.
      lace.Subject_and_deferred_Observer.free (Self.local_Subject_and_deferred_Observer);
   end destroy;



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


   ----------
   --- Define
   --

   procedure define  (Self : in out Item'Class;   Name       : in     String;
                                                  Id         : in     world_Id;
                                                  space_Kind : in     physics.space_Kind;
                                                  Renderer   : access openGL.Renderer.lean.Item'Class)
   is
      use lace.Subject_and_deferred_Observer.Forge;
   begin
      Self.local_Subject_and_deferred_Observer := new_Subject_and_Observer (Name => Name & " world" & Id'Image);

      Self.Id            := Id;
      Self.space_Kind    := space_Kind;
      Self.Renderer      := Renderer;
      Self.physics_Space := physics.Forge.new_Space (space_Kind);
   end define;


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
                     use World.server.world_Vectors;

                     Cursor     : world_Vectors.Cursor := Self.Clients.First;
                     the_Mirror : remote.World.view;
                  begin
                     while has_Element (Cursor)
                     loop
                        the_Mirror := Element (Cursor);
                        the_Mirror.motion_Updates_are (Self.seq_Id,
                                                       the_motion_Updates (1 .. updates_Count));
                        next (Cursor);
                     end loop;
                  end;
               end if;
            end;
         end if;
      end;

   end evolve;



   overriding
   function fetch (From : in sprite_Map) return id_Maps_of_sprite.Map
   is
   begin
      return From.Map;
   end fetch;



   overriding
   function fetch (From : in sprite_Map;   Id : in sprite_Id) return Sprite.view
   is
   begin
      return From.Map.Element (Id);
   end fetch;



   overriding
   function Contains (From : in sprite_Map;   Id : in sprite_Id) return Boolean
   is
   begin
      return From.Map.Contains (Id);
   end Contains;

   overriding
   function fetch_Views (From : in sprite_Map) return Sprite.Views
   is
      the_Views : Sprite.Views (1 .. math.Index (From.Map.Length));
      Count     : math.Index := 0;
   begin
      for Each of From.Map
      loop
         Count             := Count + 1;
         the_Views (Count) := Each;
      end loop;

      return the_Views;
   end fetch_Views;




   overriding
   procedure add (To : in out sprite_Map;   the_Sprite : in Sprite.view)
   is
   begin
      To.Map.insert (the_Sprite.Id, the_Sprite);
   end add;



   overriding
   procedure rid (From : in out sprite_Map;   the_Sprite : in Sprite.view)
   is
   begin
      From.Map.delete (the_Sprite.Id);
   end rid;



   overriding
   function all_Sprites (Self : access Item) return access World.sprite_Map'Class
   is
   begin
      return Self.all_Sprites'Access;
   end all_Sprites;


   -----------------------
   --- Client Registration
   --

   overriding
   procedure register (Self : access Item;   the_Mirror         : in remote.World.view;
                                             Mirror_as_observer : in lace.Observer.view)
   is
   begin
      Self.Clients.append (the_Mirror);

      Self.register (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.register (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.register (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.register (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end register;



   overriding
   procedure deregister (Self : access Item;   the_Mirror         : in remote.World.view;
                                               Mirror_as_observer : in lace.Observer.view)
   is
   begin
      Self.Clients.delete (Self.Clients.find_Index (the_Mirror));

      Self.deregister (Mirror_as_observer, to_Kind (remote.World.new_graphics_model_Event'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (remote.World. new_physics_model_Event'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (gel.events  .new_sprite_Event        'Tag));
      Self.deregister (Mirror_as_observer, to_Kind (gel.events  .rid_sprite_Event        'Tag));
   end deregister;


end gel.World.server;
