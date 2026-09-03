with
     gel.Events,

     physics.remote.Model,

     openGL.remote_Model,
     openGL.Renderer.lean,

     lace.Response,
     lace.Event.utility,
     lace.Text.forge,

     ada.unchecked_Deallocation,
     ada.Exceptions,
     ada.Text_IO;


package body gel.World.client
is
   use
        linear_Algebra_3D,
        lace.Event.utility;


   procedure log (Message : in String)
                  renames ada.text_IO.put_Line;


   ---------
   --- Forge
   --

   overriding
   procedure destroy (Self : in out Item)
   is
      procedure free is new ada.unchecked_Deallocation (safe_sequence_Id, safe_sequence_Id_view);
   begin
      gel.World.item (Self).destroy;     -- Destroy the base class.
      free (Self.seq_Id);
   end destroy;



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
                         Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.client.item
      is
         use lace.Subject_and_deferred_Observer.Forge;
      begin
         return Self : gel.World.client.item := (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                                 with others => <>)
         do
            Self.define (Name, Id, space_Kind, Renderer);
         end return;
      end to_World;



      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.client.view
      is
         use lace.Subject_and_deferred_Observer.Forge;

         Self : constant gel.World.client.view
           := new gel.World.client.item' (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                          with others => <>);
      begin
         Self.define (Name, Id, space_Kind, Renderer);
         return Self;
      end new_World;

   end Forge;



   function to_Sprite (the_Pair            : in remote.World.sprite_model_Pair;
                       the_graphics_Models : in id_Maps_of_graphics_model.Map;
                       the_physics_Models  : in Id_Maps_of_physics_Model .Map;
                       the_World           : in gel.World.view) return gel.Sprite.view
   is
      use
           openGL,
           lace.Text;

      the_graphics_Model : access openGL .Model.item'Class;
      the_physics_Model  : access physics.Model.item'Class;
      the_Sprite         :        gel.Sprite.view;

   begin
      the_graphics_Model := openGL .Model.view (the_graphics_Models.Element (the_Pair.graphics_Model_Id));
      the_physics_Model  := physics.Model.view ( the_physics_Models.Element (the_Pair. physics_Model_Id));

      the_Sprite := gel.Sprite.forge.new_Sprite (+the_Pair.sprite_Name,
                                                 sprite.World_view (the_World),
                                                 get_Translation (the_Pair.Transform),
                                                 get_Rotation    (the_Pair.Transform),
                                                 the_graphics_Model,
                                                 the_physics_Model,
                                                 owns_Graphics => False,
                                                 owns_Physics  => False,
                                                 is_Kinematic  => the_Pair.Mass /= 0.0);

      the_Sprite.Id_is      (Now => the_Pair.sprite_Id);
      the_Sprite.is_Visible (Now => the_Pair.is_Visible);

      the_Sprite.Site_is    (get_Translation (the_Pair.Transform));
      the_Sprite.Spin_is    (get_Rotation    (the_Pair.Transform));

      the_Sprite.desired_Dynamics_are (Site => the_Sprite.Site,
                                       Spin => to_Quaternion (get_Rotation (the_Sprite.Transform)));

      return the_Sprite;
   end to_Sprite;


   -------------------------------
   --- new_graphics_model_Response
   --

   type new_graphics_model_Response is new lace.Response.item with
      record
         World : gel.World.view;
      end record;

   type new_graphics_model_Response_view is access all new_graphics_model_Response;


   overriding
   function Name (Self : in new_graphics_model_Response) return String;


   overriding
   procedure respond (Self : in out new_graphics_model_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant remote.World.new_graphics_model_Event := remote.World.new_graphics_model_Event (to_Event);
   begin
      Self.World.add (new openGL.Model.item'Class' (openGL.Model.item'Class (the_Event.Model.all)));
   end respond;



   overriding
   function Name (Self : in new_graphics_model_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "new_graphics_model_Response";
   end Name;


   ------------------------------
   --- new_physics_model_Response
   --

   type new_physics_model_Response is new lace.Response.item with
      record
         World : gel.World.view;
      end record;

   type new_physics_model_Response_view is access all new_physics_model_Response;


   overriding
   function Name (Self : in new_physics_model_Response) return String;


   overriding
   procedure respond (Self : in out new_physics_model_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant remote.World.new_physics_model_Event := remote.World.new_physics_model_Event (to_Event);
   begin
      Self.World.add (new physics.Model.item'Class' (physics.Model.item'Class (the_Event.Model.all)));
   end respond;



   overriding
   function Name (Self : in new_physics_model_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "new_physics_model_Response";
   end Name;


   --------------------------
   --- my_new_sprite_Response
   --

   type my_new_sprite_Response is new lace.Response.item with
      record
         World           :        gel.World.view;
         graphics_Models : access id_Maps_of_graphics_model.Map;
         physics_Models  : access id_Maps_of_physics_model .Map;
      end record;

   type my_new_sprite_Response_view is access all my_new_sprite_Response;


   overriding
   function Name (Self : in my_new_sprite_Response) return String;


   overriding
   procedure respond (Self : in out my_new_sprite_Response;   to_Event : in lace.Event.Item'Class)
   is
   begin
      log ("gel.world.client.my_new_Sprite.respond");

      declare
         the_Event  : constant gel.Events.new_sprite_Event
           := gel.events.new_sprite_Event (to_Event);

         the_Sprite : constant gel.Sprite.view
           := to_Sprite (the_Event.Pair,
                         Self.graphics_Models.all,
                         Self. physics_Models.all,
                         Self.World);
      begin
         log ("*** gel.world.client.my_new_sprite_Response.add sprite ~ " & the_Sprite.Name'Image);
         Self.World.add  (the_Sprite);
         Self.World.emit (remote.world.sprite_added_Event' (Sprite => the_Sprite.Id));
      end;

   end respond;



   overriding
   function Name (Self : in my_new_sprite_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "my_new_sprite_Response";
   end Name;


   --------------------------
   --- my_rid_sprite_Response
   --

   type my_rid_sprite_Response is new lace.Response.item with
      record
         World : gel.World.view;
      end record;

   type my_rid_sprite_Response_view is access all my_rid_sprite_Response;


   overriding
   function Name (Self : in my_rid_sprite_Response) return String;



   overriding
   procedure respond (Self : in out my_rid_sprite_Response;   to_Event : in lace.Event.Item'Class)
   is
   begin
      log ("gel.world.client.my_rid_Sprite.respond");

      declare
         the_Event  : constant gel.Events.rid_sprite_Event
           := gel.events.rid_sprite_Event (to_Event);
      begin
         if not Self.World.sprite_Exists (the_Event.Id)
         then     -- This client never knew of the sprite: it was created and mirrored
                  -- before the client had registered with the server world.
            log ("Warning: Received rid for unknown sprite" & the_Event.Id'Image & ".");
            return;
         end if;

         declare
            the_Sprite : constant gel.Sprite.view := Self.World.fetch_Sprite (the_Event.Id);
         begin
            Self.World.emit (remote.world.sprite_ridded_Event' (Id   => the_Event.Id,
                                                                Name => lace.Text.forge.to_Text_128 (the_Sprite.Name)));

            -- Destroying rids the sprite from the world and frees it on a later
            -- pass ~ a mirror sprite owns neither model, so this frees the sprite,
            -- its visual, its shape and its solid, and leaves the shared models alone.
            --
            if not the_Sprite.is_Destroyed
            then
               the_Sprite.destroy (and_Children => True);
            end if;
         end;
      end;

   end respond;



   overriding
   function Name (Self : in my_rid_sprite_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "my_rid_sprite_Response";
   end Name;


   -------------------
   --- World Mirroring
   --

   type graphics_Model_iface_view is access all openGL .remote_Model.item'Class;
   type  physics_Model_iface_view is access all physics.remote.Model.item'Class;



   procedure is_a_Mirror (Self : access Item'Class;   of_World : in remote.World.view)
   is
      -- The responses are allocated per world, so a client may mirror several
      -- server worlds without one world's responses being re-aimed at another.
      --
      graphics_Response : constant new_graphics_model_Response_view := new new_graphics_model_Response;
      physics_Response  : constant new_physics_model_Response_view  := new new_physics_model_Response;
      new_Response      : constant my_new_sprite_Response_view      := new my_new_sprite_Response;
      rid_Response      : constant my_rid_sprite_Response_view      := new my_rid_sprite_Response;

   begin
      -- New graphics model response.
      --
      graphics_Response.World := Self.all'Access;

      Self.add (the_Response => lace.Response.view (graphics_Response),
                to_Kind      => to_Kind (remote.World.new_graphics_model_Event'Tag),
                from_Subject => of_World.Name);

      -- New physics model response.
      --
      physics_Response.World := Self.all'Access;

      Self.add (lace.Response.view (physics_Response),
                to_Kind (remote.World.new_physics_model_Event'Tag),
                from_Subject => of_World.Name);

      -- New sprite response.
      --
      new_Response.World           := Self.all'Access;
      new_Response.graphics_Models := Self.graphics_Models'Access;
      new_Response.physics_Models  := Self. physics_Models'Access;

      Self.add (lace.Response.view (new_Response),
                to_Kind (gel.Events.new_sprite_Event'Tag),
                from_Subject => of_World.Name);

      -- Rid sprite response.
      --
      rid_Response.World := Self.all'Access;

      Self.add (lace.Response.view (rid_Response),
                to_Kind (gel.Events.rid_sprite_Event'Tag),
                from_Subject => of_World.Name);

      -- Obtain and make a local copy of graphics models, physics models and sprites from the mirrored world.
      --
      declare
         use remote.World.id_Maps_of_graphics_model;

         the_server_graphics_Models : remote.World.id_Map_of_graphics_model;
         the_server_physics_Models  : remote.World.id_Map_of_physics_model;


         task      graphics_model_Fetcher;
         task
         body graphics_model_Fetcher
         is
         begin
            the_server_graphics_Models := of_World.graphics_Models;     -- Fetch graphics models from the server.

         exception
            when E : others =>
               log ("");
               log ("__________________________________________________________________________");
               log ("Error detected in 'graphics_model_Fetcher'.");
               log (ada.Exceptions.exception_Information (E));
               log ("__________________________________________________________________________");
               log ("");
         end graphics_model_Fetcher;



         task      physics_model_Fetcher;
         task
         body physics_model_Fetcher
         is
         begin
            the_server_physics_Models := of_World.physics_Models;       -- Fetch physics models from the server.

         exception
            when E : others =>
               log ("");
               log ("__________________________________________________________________________");
               log ("Error detected in 'physics_model_Fetcher'.");
               log (ada.Exceptions.exception_Information (E));
               log ("__________________________________________________________________________");
               log ("");
         end physics_model_Fetcher;


         the_server_Sprites : constant remote.World.sprite_model_Pairs := of_World.Sprites;


      begin
         while not (         graphics_model_Fetcher'Terminated
                    and then  physics_model_Fetcher'Terminated)
         loop
            delay 0.05;
         end loop;


         -- Create our local graphics models.
         --
         declare
            Cursor    : remote.World.id_Maps_of_graphics_model.Cursor := the_server_graphics_Models.First;
            new_Model : graphics_Model_iFace_view;
         begin
            while has_Element (Cursor)
            loop
               new_Model := new openGL.remote_Model.item'Class' (Element (Cursor));
               Self.add (openGL.Model.view (new_Model));

               next (Cursor);
            end loop;
         end;

         -- Create our local physics models.
         --
         declare
            use remote.World.id_Maps_of_physics_model;

            Cursor    : remote.World.id_Maps_of_physics_model.Cursor := the_server_physics_Models.First;
            new_Model : physics_Model_iFace_view;

         begin
            while has_Element (Cursor)
            loop
               new_Model := new physics.remote.Model.item'Class' (Element (Cursor));
               Self.add (physics.Model.view (new_Model));

               next (Cursor);
            end loop;
         end;

         -- Create our local sprites.
         --
         declare
            the_Sprite : gel.Sprite.view;
         begin
            for i in the_server_Sprites'Range
            loop
               the_Sprite := to_Sprite (the_server_Sprites (i),
                                        Self.graphics_Models,
                                        Self. physics_Models,
                                        gel.World.view (Self));
               Self.add (the_Sprite);
            end loop;
         end;
      end;

      of_World.register (the_Mirror         => remote.World .view (Self),
                         Mirror_as_observer => lace.Observer.view (Self));
   end is_a_Mirror;


   --------------
   --- Operations
   --

   overriding
   procedure motion_Updates_are (Self : in Item;   seq_Id : in remote.World.sequence_Id;
                                                   Now    : in remote.World.motion_Updates)
   is
      use type remote.World.sequence_Id;

      stale_Window : constant := 64;
      --
      -- Updates may arrive out of order, so a recently superseded id is dropped.
      -- An id far older than the latest means the server has restarted (or the
      -- id has wrapped), so the mirror resynchronises to it instead of freezing.

      Latest : constant remote.World.sequence_Id := Self.seq_Id.Value;

      the_Id : gel.sprite_Id;

   begin
      if        seq_Id = Latest
        or else Latest - seq_Id < stale_Window     -- A modular difference ~ small only for a recently superseded id.
      then
         return;
      end if;

      Self.seq_Id.Value_is (seq_Id);

      for i in Now'Range
      loop
         begin
            the_Id := Now (i).Id;

            declare
               use remote.World;

               the_Sprite : constant Sprite.view := Self.the_Sprites.Map.fetch (the_Id);
               new_Site   : constant Vector_3    := refined (Now (i).Site);
               new_Spin   : constant Quaternion  := refined (Now (i).Spin);

            begin
               the_Sprite.desired_Dynamics_are (Site => new_Site,
                                                Spin => new_Spin);
            end;

         exception
            when constraint_Error =>
               log ("Warning: Received motion updates for unknown sprite" & the_Id'Image & ".");
         end;
      end loop;
   end motion_Updates_are;



   ---------------------
   --- safe_sequence_Id
   --

   protected
   body safe_sequence_Id
   is
      procedure Value_is (Now : in remote.World.sequence_Id)
      is
      begin
         the_Value := Now;
      end Value_is;



      function Value return remote.World.sequence_Id
      is
      begin
         return the_Value;
      end Value;

   end safe_sequence_Id;



   overriding
   procedure evolve (Self : in out Item)
   is
   begin
      --  The age is advanced by the base class 'evolve', below.
      --
      Self.respond;
      Self.local_Subject_and_deferred_Observer.respond;

      -- Interpolate sprite transforms.
      --
      declare
         all_Sprites : constant Sprite.Views := Self.the_Sprites.Map.fetch_Views;
      begin
         for the_Sprite of all_Sprites
         loop
            the_Sprite.interpolate_Motion;
         end loop;
      end;

      gel.World.item (Self).evolve;
   end evolve;


end gel.World.client;
