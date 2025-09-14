with any_math.any_Algebra.any_linear.any_d3;
with
     gel.Events,

     physics.remote.Model,
     physics.Forge,

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
   use linear_Algebra_3D,
       lace.Event.utility;


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
           := new gel.World.client.item' (to_Subject_and_Observer (name => Name & " world" & Id'Image)
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
      use openGL,
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



   --------------------------------
   --- 'create_new_Sprite' Response
   --

   type create_new_Sprite is new lace.Response.item with
      record
         World          :        gel.World.view;
         Models         : access id_Maps_of_graphics_model        .Map;
         physics_Models : access id_Maps_of_physics_model.Map;
      end record;


   overriding
   function Name (Self : in create_new_Sprite) return String;



   overriding
   procedure respond (Self : in out create_new_Sprite;   to_Event : in lace.Event.item'Class)
   is
   begin
      raise Program_Error with "???";
      --  declare
      --     the_Event  : constant gel.Events.new_sprite_Event := gel.Events.new_sprite_Event (to_Event);
      --     the_Sprite : constant gel.Sprite.view             := to_Sprite (the_Event.Pair,
      --                                                                     Self.Models.all,
      --                                                                     Self.physics_Models.all,
      --                                                                     Self.World);
      --  begin
      --     Self.World.add (the_Sprite);
      --  end;
   end respond;



   overriding
   function Name (Self : in create_new_Sprite) return String
   is
      pragma Unreferenced (Self);
   begin
      return "create_new_Sprite";
   end Name;


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
      Self.local_Subject_and_deferred_Observer := new_Subject_and_Observer (name => Name & " world" & Id'Image);

      Self.Id            := Id;
      Self.space_Kind    := space_Kind;
      Self.Renderer      := Renderer;
      Self.physics_Space := physics.Forge.new_Space (space_Kind);
   end define;



   -------------------------------
   --- new_graphics_model_Response
   --

   type new_graphics_model_Response is new lace.Response.item with
      record
         World : gel.World.view;
      end record;


   overriding
   function Name (Self : in new_graphics_model_Response) return String;


   overriding
   procedure respond (Self : in out new_graphics_model_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant remote.World.new_graphics_model_Event := remote.World.new_graphics_model_Event (to_Event);
   begin
      --  log ("gel.world.client ~ new graphics model response ~ model id:" & the_Event.Model.Id'Image);
      Self.World.add (new openGL.Model.item'Class' (openGL.Model.item'Class (the_Event.Model.all)));
   end respond;


   overriding
   function Name (Self : in new_graphics_model_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "new_graphics_model_Response";
   end Name;


   the_new_graphics_model_Response : aliased new_graphics_model_Response;



   ------------------------------
   --- new_physics_model_Response
   --

   type new_physics_model_Response is new lace.Response.item with
      record
         World : gel.World.view;
      end record;


   overriding
   function Name (Self : in new_physics_model_Response) return String;


   overriding
   procedure respond (Self : in out new_physics_model_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant remote.World.new_physics_model_Event := remote.World.new_physics_model_Event (to_Event);
   begin
      --  log ("gel.world.client ~ new physics model response ~ model id:" & the_Event.Model.Id'Image);
      Self.World.add (new physics.Model.item'Class' (physics.Model.item'Class (the_Event.Model.all)));
   end respond;


   overriding
   function Name (Self : in new_physics_model_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "new_physics_model_Response";
   end Name;


   the_new_physics_model_Response : aliased new_physics_model_Response;



   --------------------------
   --- my_new_sprite_Response
   --

   type my_new_sprite_Response is new lace.Response.item with
      record
         World           :        gel.World.view;
         graphics_Models : access id_Maps_of_graphics_model.Map;
         physics_Models  : access id_Maps_of_physics_model .Map;
      end record;


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



   procedure define (Self : in out my_new_sprite_Response;   World          : in     gel.World.view;
                                                             Models         : access id_Maps_of_graphics_model.Map;
                                                             physics_Models : access id_Maps_of_physics_model.Map)
   is
   begin
      Self.World           := World;
      Self.graphics_Models := Models;
      Self.physics_Models  := physics_Models;
   end define;



   overriding
   function Name (Self : in my_new_sprite_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "my_new_sprite_Response";
   end Name;

   the_my_new_sprite_Response : aliased my_new_sprite_Response;



   --------------------------
   --- my_rid_sprite_Response
   --

   type my_rid_sprite_Response is new lace.Response.item with
      record
         World           :        gel.World.view;
         graphics_Models : access id_Maps_of_graphics_model.Map;
         physics_Models  : access id_Maps_of_physics_model .Map;
      end record;


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

         the_Sprite : constant gel.Sprite.view := Self.World.fetch_Sprite (the_Event.Id);
      begin
         Self.World.rid (the_Sprite);
         Self.World.emit (remote.world.sprite_ridded_Event' (Id   => the_Event.Id,
                                                             Name => lace.Text.forge.to_Text_128 (the_Sprite.Name)));
      end;

   end respond;



   procedure define (Self : in out my_rid_sprite_Response;   World          : in     gel.World.view;
                                                             Models         : access id_Maps_of_graphics_model.Map;
                                                             physics_Models : access id_Maps_of_physics_model.Map)
   is
   begin
      Self.World           := World;
      Self.graphics_Models := Models;
      Self.physics_Models  := physics_Models;
   end define;



   overriding
   function Name (Self : in my_rid_sprite_Response) return String
   is
      pragma unreferenced (Self);
   begin
      return "my_rid_sprite_Response";
   end Name;

   the_my_rid_sprite_Response : aliased my_rid_sprite_Response;




   -------------------
   --- World Mirroring
   --
   type graphics_Model_iface_view is access all openGL .remote_Model.item'Class;
   type  physics_Model_iface_view is access all physics.remote.Model.item'Class;



   procedure is_a_Mirror (Self : access Item'Class;   of_World : in remote.World.view)
   is
   begin
      --  New graphics model response.
      --
      the_new_graphics_model_Response.World := Self.all'Access;

      Self.add (the_Response => the_new_graphics_model_Response'Access,
                to_Kind      => to_Kind (remote.World.new_graphics_model_Event'Tag),
                from_Subject => of_World.Name);

      --  New physics model response.
      --
      the_new_physics_model_Response.World := Self.all'Access;

      Self.add (the_new_physics_model_Response'Access,
                to_Kind (remote.World.new_physics_model_Event'Tag),
                from_Subject => of_World.Name);

      --  New Id response.
      --
      define   (the_my_new_sprite_Response, World          => Self.all'Access,
                                            Models         => Self.graphics_Models'Access,
                                            physics_Models => Self. physics_Models'Access);

      Self.add (the_my_new_sprite_Response'Access,
                to_Kind (gel.Events.new_sprite_Event'Tag),
                from_Subject => of_World.Name);

      --  Rid Id response.
      --
      define   (the_my_rid_sprite_Response, World          => Self.all'Access,
                                            Models         => Self.graphics_Models'Access,
                                            physics_Models => Self. physics_Models'Access);

      Self.add (the_my_rid_sprite_Response'Access,
                to_Kind (gel.Events.rid_sprite_Event'Tag),
                from_Subject => of_World.Name);

      --  Obtain and make a local copy of graphics models, physics models and sprites from the mirrored world.
      --
      declare
         use remote.World.id_Maps_of_graphics_model;

         --  the_server_graphics_Models : constant remote.World.id_Map_of_graphics_model := of_World.graphics_Models;     -- Fetch graphics models from the server.
         --  the_server_physics_Models  : constant remote.World.id_Map_of_physics_model  := of_World. physics_Models;     -- Fetch physics  models from the server.
         --  the_server_Sprites         : remote.World.sprite_model_Pairs                := of_World.Sprites;             -- Fetch sprites         from the server.

         the_server_graphics_Models : remote.World.id_Map_of_graphics_model;
         the_server_physics_Models  : remote.World.id_Map_of_physics_model;


         task      graphics_model_Fetcher;
         task body graphics_model_Fetcher
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
         task body physics_model_Fetcher
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


         --  task      sprite_Fetcher;
         --  task body sprite_Fetcher
         --  is
         --  begin
         --     the_server_Sprites := of_World.Sprites;                     -- Fetch sprites from the server.
         --  exception
         --     when E : others =>
         --        log ("");
         --        log ("__________________________________________________________________________");
         --        log ("Error detected in 'sprite_Fetcher'.");
         --        log (ada.Exceptions.exception_Information (E));
         --        log ("__________________________________________________________________________");
         --        log ("");
         --  end sprite_Fetcher;


         the_server_Sprites : constant remote.World.sprite_model_Pairs := of_World.Sprites;


      begin
         while not (    graphics_model_Fetcher'Terminated
                    and  physics_model_Fetcher'Terminated)
                    --  and         sprite_Fetcher'Terminated)
         loop
            delay 0.05;
         end loop;


         --  Create our local graphics models.
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

         --  Create our local physics models.
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

         --  Create our local sprites.
         --
         declare
            the_Sprite         :          gel.Sprite.view;
            --  the_server_Sprites : constant remote.World.sprite_model_Pairs := of_World.Sprites;
         begin
            for i in the_server_Sprites'Range
            loop
               the_Sprite := to_Sprite (the_server_Sprites (i),
                                        Self.graphics_Models,
                                        Self. physics_Models,
                                        gel.World.view (Self));
               --  log ("*** gel.world.client.is_a_Mirror.add sprite ~ " & the_Sprite.Name'Image);

               --  the_Sprite.Spin_is (z_Rotation_from (to_Radians (90.0)));
               Self.add (the_Sprite);
            end loop;
         end;
      end;

      of_World.register (the_Mirror         => Self,
                         Mirror_as_observer => Self);
   end is_a_Mirror;



   --------------
   --- Operations
   --

   overriding
   procedure add (Self : access Item;   the_Sprite   : in gel.Sprite.view;
                                        and_Children : in Boolean := False)
   is
      --  added_Event : gel.remote.World.sprite_added_Event;

   begin
      --  log ("gel.world.client.add (sprite and children) " & the_Sprite.Name & the_Sprite.Id'Image);
      gel.World.item (Self.all).add (the_Sprite, and_Children);     -- Do base class.
      --  Self.all_Sprites.Map.add (the_Sprite);

      --  added_Event.Id := the_Sprite.Id;

      --  log ("****** gel.world.client.add " & the_Sprite.Name);
      --  if the_Sprite.Id /= 50000000
      --  then
      --     raise Program_Error;
      --  end if;

      --  Self.emit (added_Event);
   end add;



   overriding
   procedure motion_Updates_are (Self : in Item;   seq_Id : in remote.World.sequence_Id;
                                                   Now    : in remote.World.motion_Updates)
   is
      use type remote.World.sequence_Id;

      all_Sprites : id_Maps_of_sprite.Map renames Self.all_Sprites.Map.fetch_all;
      the_Id      : gel.sprite_Id;

   begin
      if seq_Id > Self.seq_Id.Value
      then
         Self.seq_Id.Value_is (seq_Id);

         for i in Now'Range
         loop
            begin
               the_Id := Now (i).Id;

               declare
                  use remote.World;

                  the_Sprite         : constant Sprite.view   := all_Sprites.Element (the_Id);
                  new_Site           : constant Vector_3      := refined (Now (i).Site);
                  --  site_Delta         :          Vector_3;
                  --  min_teleport_Delta : constant               := 20.0;

                  new_Spin           : constant Quaternion    := refined (Now (i).Spin);
                  --  new_Spin           : constant Matrix_3x3        := Now (i).Spin;

               begin
                  --  site_Delta := new_Site - the_Sprite.desired_Site;
                  --
                  --  if        abs site_Delta (1) > min_teleport_Delta
                  --    or else abs site_Delta (2) > min_teleport_Delta
                  --    or else abs site_Delta (3) > min_teleport_Delta
                  --  then
                  --     log ("Teleport.");
                  --     the_Sprite.Site_is (new_Site);   -- Sprite has been 'teleported', so move it now
                  --  end if;                             -- to prevent later interpolation.


                  --  the_Sprite.Site_is (new_Site);
                  --  the_Sprite.Spin_is (to_Rotation (Axis  => new_Spin.V,
                  --                                   Angle => new_Spin.R));

                  --  the_Sprite.Spin_is (to_Matrix (to_Quaternion (new_Spin)));

                  --  the_Sprite.desired_Dynamics_are (Site => new_Site,
                  --                                   Spin => to_Quaternion (new_Spin));

                  the_Sprite.desired_Dynamics_are (Site => new_Site,
                                                   Spin => new_Spin);

                  --  the_Sprite.desired_Site_is (new_Site);
                  --  the_Sprite.desired_Spin_is (new_Spin);
               end;

            exception
               when constraint_Error =>
                  log ("Warning: Received motion updates for unknown sprite" & the_Id'Image & ".");
            end;
         end loop;

      end if;
   end motion_Updates_are;



   overriding
   procedure evolve (Self : in out Item)
   is
   begin
      Self.Age := Self.Age + evolve_Period;

      Self.respond;
      Self.local_Subject_and_deferred_Observer.respond;

      --  Interpolate Id transforms.
      --
      declare
         use id_Maps_of_sprite;

         --  all_Sprites   : constant id_Maps_of_sprite.Map    := Self.id_Map_of_sprite;
         all_Sprites   : id_Maps_of_sprite.Map    renames Self.all_Sprites.Map.fetch_all;
         Cursor        : id_Maps_of_sprite.Cursor :=      all_Sprites.First;
         the_Sprite    : gel.Sprite.view;

      begin
         while has_Element (Cursor)
         loop
            the_Sprite := Sprite.view (Element (Cursor));
            the_Sprite.interpolate_Motion;

            next (Cursor);
         end loop;
      end;


      gel.World.item (Self).evolve;

      --  --  Perform responses to events for all sprites.
      --  --
      --  declare
      --     use id_Maps_of_sprite;
      --
      --     all_Sprites : constant id_Maps_of_sprite.Map    := Item'Class (Self).all_Sprites.fetch;
      --     Cursor      :          id_Maps_of_sprite.Cursor := all_Sprites.First;
      --     the_Sprite  :          Sprite.view;
      --  begin
      --     while has_Element (Cursor)
      --     loop
      --        the_Sprite := Element (Cursor);
      --
      --        begin
      --           if not the_Sprite.is_Destroyed
      --           then
      --              the_Sprite.respond;
      --           end if;
      --
      --        exception
      --           when E : others =>
      --              log ("");   log ("");
      --              log ("Error in 'gel.World.client.evolve' Id response.");
      --              log ("");
      --              log (ada.Exceptions.exception_Information (E));
      --              log ("");   log ("");
      --        end;
      --
      --        next (Cursor);
      --     end loop;
      --  end;
   end evolve;



   overriding
   function fetch (From : in sprite_Map) return id_Maps_of_sprite.Map
   is
   begin
      return From.Map.fetch_all;
   end fetch;



   overriding
   procedure add (To : in out sprite_Map;   the_Sprite : in Sprite.view)
   is
   begin
      To.Map.add (the_Sprite);
   end add;



   overriding
   procedure rid (To : in out sprite_Map;   the_Sprite : in Sprite.view)
   is
   begin
      To.Map.rid (the_Sprite);
   end rid;



   overriding
   function all_Sprites (Self : access Item) return access World.sprite_Map'Class
   is
   begin
      return Self.all_Sprites'Access;
   end all_Sprites;



   --------------
   --  Containers
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



   protected
   body safe_id_Map_of_sprite
   is
      procedure add (the_Sprite : in Sprite.view)
      is
      begin
         --  log ("safe_id_Map_of_sprite" & the_Sprite.Id'Image);
         --  raise Program_Error;
         Map.insert (the_Sprite.Id,
                     the_Sprite);
      end add;


      procedure rid (the_Sprite : in Sprite.view)
      is
      begin
         Map.delete (the_Sprite.Id);
      end rid;


      function fetch (Id : in sprite_Id) return Sprite.view
      is
      begin
         return Map.Element (Id);
      end fetch;


      function fetch_all return id_Maps_of_sprite.Map
      is
      begin
         return Map;
      end fetch_all;

   end safe_id_Map_of_sprite;


end gel.World.client;
