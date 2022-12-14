with
     mmi.Events,
     physics.remote.Model,
     physics.Forge,

     openGL.remote_Model,
     openGL.Renderer.lean,

     physics.Object,

     float_math.Algebra.linear.d3,

     lace.Response,
     lace.Event.utility,

     ada.Calendar,
     ada.Text_IO,
     ada.Exceptions,
     ada.Unchecked_Deallocation,
     ada.Containers.Hashed_Sets;


package body mmi.World
is
   use mmi .Sprite,
       math.Algebra.linear.d3,

       lace.Event.Utility,
       lace.Event,

       ada .Calendar,
       ada .Exceptions,
       ada .Text_IO;

   package std_Physics renames standard.Physics;



   procedure log (Message : in String)
--                    renames ada.text_IO.put_Line;
   is null;



   ---------
   --  Forge
   --

   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.Unchecked_Deallocation (Item'Class, View);
   begin
      deallocate (Self);
   end free;


   procedure free is new ada.Unchecked_Deallocation (lace.Any.limited_Item'Class, Any_limited_view);


   procedure define  (Self : in out Item'Class;   Name       : in     String;
                                                  Id         : in     world_Id;
                                                  space_Kind : in     std_physics.space_Kind;
                                                  Renderer   : access openGL.Renderer.lean.item'Class);



   overriding
   procedure destroy (Self : in out Item)
   is
   begin
      Self.sprite_transform_Updater.stop;
      Self.physics_Engine          .stop;
      Self.Engine                  .stop;

      while not Self.Engine                  'Terminated
        and not Self.sprite_transform_Updater'Terminated
      loop
         delay 0.01;
      end loop;

      --  Free record components.
      --
      declare
         procedure free is new ada.Unchecked_Deallocation (sprite_transform_Updater, sprite_transform_Updater_view);
         procedure free is new ada.Unchecked_Deallocation (safe_command_Set,         safe_command_Set_view);
         procedure free is new ada.Unchecked_Deallocation (Engine,                   Engine_view);
      begin
         std_physics.Space.free (Self.physics_Space);
         free (Self.Commands);
      end;

      lace.Subject_and_deferred_Observer.destroy (lace.Subject_and_deferred_Observer.item (Self));   -- Destroy base class.
      lace.Subject_and_deferred_Observer.free    (Self.local_Subject_and_deferred_Observer);
   end destroy;




   package body Forge
   is

      function to_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     standard.physics.space_Kind;
                         Renderer   : access openGL.Renderer.lean.item'Class) return mmi.World.item
      is
         use lace.Subject_and_deferred_Observer.forge;
      begin
         return Self : mmi.World.item := (to_Subject_and_Observer (name => Name & " world" & world_Id'Image (Id))
                                          with others => <>)
         do
            define (Self, Name, Id, space_Kind, Renderer);
         end return;
      end to_World;



      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     Standard.physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return mmi.World.view
      is
         use lace.Subject_and_deferred_Observer.forge;

         Self : constant mmi.World.view
           := new mmi.World.item' (to_Subject_and_Observer (name => Name & " world" & world_Id'Image (Id))
                                   with others => <>);
      begin
         define (Self.all,  Name, Id, space_Kind, Renderer);
         return  Self;
      end new_World;

   end Forge;





   function  local_Observer (Self : in     Item)     return lace.Observer.view
   is
   begin
      return lace.Observer.view (Self.local_Subject_and_deferred_Observer);
   end local_Observer;


   function  local_Subject  (Self : in     Item)     return lace.Subject .view
   is
   begin
      return lace.Subject.view (Self.local_Subject_and_deferred_Observer);
   end local_Subject;




   function Id (Self : in Item) return world_Id
   is
   begin
      return Self.Id;
   end Id;




   function to_Sprite (the_Pair           : in remote.World.sprite_model_Pair;
                       the_Models         : in Id_Maps_of_Model        .Map;
                       the_physics_Models : in Id_Maps_of_physics_Model.Map;
                       the_World          : in mmi.World.view) return mmi.Sprite.view
   is
      the_graphics_Model : access openGL.      Model.item'Class;
      the_physics_Model  : access Standard.physics.Model.item'Class;
      the_Sprite         :        mmi.Sprite.view;

      use openGL;

   begin
      the_graphics_Model := openGL          .Model.view (the_Models        .Element (the_Pair.graphics_Model_Id));
      the_physics_Model  := Standard.physics.Model.view (the_physics_Models.Element (the_Pair. physics_Model_Id));

      the_Sprite := mmi.Sprite.forge.new_Sprite ("Sprite" & sprite_Id'Image (the_Pair.sprite_Id),
                                                 the_World,
                                                 the_graphics_Model,
                                                 the_physics_Model,
                                                 owns_Graphics => False,
                                                 owns_Physics  => False,
                                                 is_kinematic  => the_Pair.Mass /= 0.0);

      the_Sprite.Id_is           (now => the_Pair.sprite_Id);
      the_Sprite.is_Visible      (now => the_Pair.is_Visible);

      the_Sprite.Site_is         (get_Translation (the_Pair.Transform));
      the_Sprite.Spin_is         (get_Rotation    (the_Pair.Transform));

      the_Sprite.desired_Site_is (the_Sprite.Site);
      the_Sprite.desired_Spin_is (to_Quaternion (get_Rotation (the_Sprite.Transform)));

      return the_Sprite;
   end to_Sprite;




   --------------------------------
   --  'create_new_Sprite' Response
   --

   type create_new_Sprite is new lace.Response.item with
      record
         World          :        mmi.World.view;
         Models         : access id_Maps_of_model        .Map;
         physics_Models : access id_Maps_of_physics_model.Map;
      end record;

   overriding
   function Name (Self : in create_new_Sprite) return String;


   overriding
   procedure respond (Self : in out create_new_Sprite;   to_Event : in lace.Event.Item'Class)
   is
   begin
      declare
         the_Event  : constant mmi.events.new_sprite_Event := mmi.events.new_sprite_Event (to_Event);
         the_Sprite : constant mmi.Sprite.view             := to_Sprite (the_Event.Pair,
                                                                         Self.Models.all,
                                                                         Self.physics_Models.all,
                                                                         Self.World);
      begin
         Self.World.add (the_Sprite, and_children => False);
      end;
   end respond;



   procedure define (Self : in out create_new_Sprite;    World  : in     mmi.World.view;
                                                         Models : access id_Maps_of_model.Map)
   is
   begin
      Self.World  := World;
      Self.Models := Models;
   end define;




   overriding
   function Name (Self : in create_new_Sprite) return String
   is
      pragma Unreferenced (Self);
   begin
      return "create_new_Sprite";
   end Name;




   ---------
   -- Define
   --

   procedure define  (Self : in out Item'Class;   Name       : in     String;
                                                  Id         : in     world_Id;
                                                  space_Kind : in     std_physics.space_Kind;
                                                  Renderer   : access openGL.Renderer.lean.Item'Class)
   is
      use lace.Subject_and_deferred_Observer.Forge;
   begin
      Self.local_Subject_and_deferred_Observer := new_Subject_and_Observer (name => Name & " world" & world_Id'Image (Id));

      Self.Id           := Id;
      Self.space_Kind   := space_Kind;
      Self.Renderer     := Renderer;
      Self.sprite_Count := 0;

--        Self.physics_Engine := new std_Physics.Engine.item;
   end define;



   -------------------------
   --  all_sprite_Transforms
   --

   function to_Integer is new ada.unchecked_Conversion (mmi.Sprite.view, Integer);


   protected
   body all_sprite_Transforms
   is

      procedure set (To : in sprite_Maps_of_transforms.Map)
      is
      begin
         sprite_Map_of_transforms := To;
      end set;


      function  Fetch return sprite_Maps_of_transforms.Map
      is
      begin
         return sprite_Map_of_transforms;
      end Fetch;

   end all_sprite_Transforms;




   -----------------
   --  Duration_safe
   --

   protected
   body Duration_safe
   is
      procedure Duration_is (Now : in standard.Duration)
      is
      begin
         the_Duration := Now;
      end Duration_is;

      function  Duration return standard.Duration
      is
      begin
         return the_Duration;
      end Duration;
   end Duration_safe;




   --------------------
   --- Engine Commands
   --

   protected body safe_command_Set
   is
      function  is_Empty return Boolean
      is
      begin
         return the_Count = 0;
      end is_Empty;


      procedure add   (the_Command : in     Command)
      is
      begin
         the_Count       := the_Count + 1;
         Set (the_Count) := the_Command;
      end add;


      procedure Fetch (To    :    out Commands;
                       Count :    out Natural)
      is
      begin
         To (1 .. the_Count) := Set (1 .. the_Count);
         Count               := the_Count;
         the_Count           := 0;
      end Fetch;
   end safe_command_Set;




   -------------------
   -- Breakable Joints
   --

   protected body safe_joint_Set
   is
      function  is_Empty return Boolean
      is
      begin
         return the_Count = 0;
      end is_Empty;


      procedure add (the_Joint : in     mmi.Joint.view)
      is
      begin
         the_Count       := the_Count + 1;
         Set (the_Count) := the_Joint;
      end add;


      procedure Fetch (To          :    out safe_Joints;
                       Count       :    out Natural)
      is
      begin
         To (1 .. the_Count) := Set (1 .. the_Count);
         Count               := the_Count;
         the_Count           := 0;
      end Fetch;

   end safe_joint_Set;





   --------------
   --  Collisions
   --

   task
   type impact_Responder
   is
      entry start (the_World      : in     mmi.World.view;
                   Filter         : in     impact_Filter;
                   Response       : in     impact_Response;
                   responses_Done : in     Signal_Object_view);
      entry stop;
      entry respond;                                     -- Filter and do responses.
   end impact_Responder;


   type impact_Responder_view is access all impact_Responder;

   procedure free (Self : in out impact_Responder_view)
   is
      procedure deallocate is new ada.Unchecked_Deallocation (impact_Responder, impact_Responder_view);
   begin
      deallocate (Self);
   end free;



   type filtered_impact_Response is
      record
         Filter         :        impact_Filter;
         Response       :        impact_Response;

         Responder      :        impact_Responder_view;
         responses_Done : access Signal_Object        := new Signal_Object;
      end record;

   function Hash (Self : in filtered_impact_Response) return ada.Containers.Hash_type;

   package  filtered_impact_Response_Sets is new ada.Containers.Hashed_Sets (filtered_impact_Response,
                                                                             Hash,  "=");




   -----------
   --- Engine
   --

   task body Engine
   is
      use type mmi.Joint.view,
               ada.Containers.Count_Type;

      Stopped                          : Boolean                   := True;
      Cycle                            : ada.Containers.Count_Type := 0;
      next_render_Time                 : ada.Calendar.Time;

      the_filtered_impact_Response_Set : filtered_impact_Response_Sets.Set;


      max_joint_Force,
      max_joint_Torque                 : Real                      := 0.0;



      procedure free_Sprites
      is
         the_free_Sprites : mmi.Sprite.views := the_World.free_sprite_Set;
      begin
         for Each in the_free_Sprites'Range
         loop
            log ("Engine is Freeing sprite id: " & sprite_Id'Image (the_free_Sprites (Each).Id));

            if the_free_Sprites (Each).owns_Graphics
            then
               the_World.Renderer.free (the_free_Sprites (Each).Visual.Model);
            end if;

            mmi.Sprite.free (the_free_Sprites (Each));
         end loop;
      end free_Sprites;



      procedure free_graphics_Models
      is
         use id_Maps_of_model;
         Cursor : id_Maps_of_model.Cursor := the_World.graphics_Models.First;
      begin
         while has_Element (Cursor)
         loop
            the_World.Renderer.free (Element (Cursor));
            next (Cursor);
         end loop;
      end free_graphics_Models;



      procedure evolve
      is
         the_sprite_Transforms : sprite_Maps_of_transforms.Map := the_World.all_sprite_Transforms.Fetch;
      begin
         Cycle := Cycle + 1;

         do_engine_Commands:
         declare
            the_Commands  : World.Commands;
            Count         : Natural;

            command_Count : array (command_Kind) of Natural := (others => 0);

         begin
            the_World.Commands.fetch (the_Commands, Count);

            for Each in 1 .. Count
            loop
               declare
                  use std_Physics.Engine;
                  the_Command : World.Command renames the_Commands (Each);
               begin
                  command_Count (the_Command.Kind) := command_Count (the_Command.Kind) + 1;

                  case the_Command.Kind
                  is
--                       when scale_Sprite =>
--                          the_World.physics_Engine.add (std_Physics.Engine.Command' (Kind   => scale_Object,
--                                                                                     Sprite => the_Command.Sprite.Solid,
--                                                                                     Scale  => the_Command.Scale));
--                          the_Command.Sprite.Solid.activate;
--                          the_Command.Sprite.Shape.Scale_is (the_Command.Scale);
--                          the_Command.Sprite.Solid.Scale_is (the_Command.Scale);
--
--                          the_World.physics_Space.update_Bounds (std_physics.Object.view (the_Command.Sprite.Solid));


--                       when update_Bounds =>
--                          the_World.physics_Space.update_Bounds (std_physics.Object.view (the_Command.Sprite.Solid));


                     when update_Site =>
                        the_World.physics_Engine.update_Site (std_physics.Object.view (the_Command.Sprite.Solid), the_Command.Site);
--                          std_physics.Object.view (the_Command.Sprite.Solid).Site_is (the_Command.Site);


--                       when set_Speed =>
--                          std_physics.Object.view (the_Command.Sprite.Solid).Speed_is (the_Command.Speed);


--                       when set_xy_Spin =>
--                          std_physics.Object.view (the_Command.Sprite.Solid).xy_Spin_is (the_Command.xy_Spin);


                     when add_Sprite =>
                        declare
                           procedure add (the_Sprite : in Sprite.view)
                           is
                           begin
                              if the_Sprite.Id = null_sprite_Id
                              then
                                 raise Program_Error;
                              end if;

                              the_World.add (the_Sprite.graphics_Model.all'Access);
                              the_World.add (the_Sprite. physics_Model.all'Access);

                              the_sprite_Transforms.insert  (the_Sprite, Identity_4x4);

                              the_Sprite.Solid.user_Data_is (the_Sprite);
                              the_Sprite.Solid.Model_is (the_Sprite.physics_Model);

                              if the_Sprite.physics_Model.is_Tangible
                              then
                                 the_World.physics_Engine.add (std_physics.Object.view (the_Sprite.Solid));
                              end if;

                              the_World.sprite_Count                     := the_World.sprite_Count + 1;
                              the_World.Sprites (the_World.sprite_Count) := the_Sprite;
                           end add;

                        begin
                           add (the_Command.Sprite);
                        end;


                     when rid_Sprite =>
                        declare
                           function find (the_Sprite : in Sprite.view) return Index
                           is
                           begin
                              for Each in 1 .. the_World.sprite_Count
                              loop
                                 if the_World.Sprites (Each) = the_Sprite
                                 then
                                    return Each;
                                 end if;
                              end loop;

                              raise constraint_Error with "no such sprite in world";
                              return 0;
                           end find;


                           procedure rid (the_Sprite : in Sprite.view)
                           is
                              use type std_physics.Object.view;
                           begin
                              if the_Sprite.Solid /= null
                              then
                                 if the_Sprite.physics_Model.is_Tangible
                                 then
                                    the_World.physics_Engine.rid (std_physics.Object.view (the_Sprite.Solid));
                                 end if;

                                 if the_sprite_Transforms.contains (the_Sprite) then
                                    the_sprite_Transforms.delete   (the_Sprite);
                                 end if;

                              else
                                 raise program_Error;
                              end if;


                              declare
                                 Id : Index;
                              begin
                                 Id := find (the_Sprite);

                                 if Id <= the_World.sprite_Count
                                 then
                                    the_World.Sprites (1 .. the_World.sprite_Count - 1)
                                      :=   the_World.Sprites (     1 .. Id - 1)
                                         & the_World.Sprites (Id + 1 .. the_World.sprite_Count);
                                 end if;

                                 the_World.sprite_Count := the_World.sprite_Count - 1;
                              end;
                           end rid;

                        begin
                           rid (the_Command.Sprite);
                        end;


--                       when apply_Force =>
--                          the_Command.Sprite.Solid.apply_Force (the_Command.Force);


                     when destroy_Sprite =>
                        declare
                           the_free_Set : free_Set renames the_World.free_Sets (the_World.current_free_Set);
                        begin
                           the_free_Set.Count                        := the_free_Set.Count + 1;
                           the_free_Set.Sprites (the_free_Set.Count) := the_Command.Sprite;
                        end;


--                       when add_Joint =>
--                          the_World.physics_Space.add            (the_Command.Joint.Physics.all'Access);
--                          the_Command.Joint.Physics.user_Data_is (the_Command.Joint);


--                       when rid_Joint =>
--                          the_World.physics_Space.rid (the_Command.Joint.Physics.all'Access);


--                       when set_Joint_local_Anchor =>
--                          the_World.physics_Space.set_Joint_local_Anchor (the_Command.anchor_Joint.Physics.all'Access,
--                                                                          the_Command.is_Anchor_A,
--                                                                          the_Command.local_Anchor);

                     when free_Joint =>
                        mmi.Joint.free (the_Command.Joint);


                     when cast_Ray =>
                        declare
                           function cast_Ray (Self : in Item'Class;   From, To : in math.Vector_3) return ray_Collision
                           is
                              use type std_physics.Object.view;

                              physics_Collision : constant standard.physics.Space.ray_Collision := Self.physics_Space.cast_Ray (From, To);
                           begin
                              if physics_Collision.near_Object = null
                              then
                                 return ray_Collision' (near_sprite => null,
                                                        others      => <>);
                              else
                                 return ray_Collision' (to_MMI (physics_Collision.near_Object),
                                                        physics_Collision.hit_Fraction,
                                                        physics_Collision.Normal_world,
                                                        physics_Collision.Site_world);
                              end if;
                           end cast_Ray;

                           the_Collision : constant ray_Collision := cast_Ray (the_World.all,
                                                                               the_Command.From,
                                                                               the_Command.To);
                        begin
                           if        the_Collision.near_Sprite = null
                             or else the_Collision.near_Sprite.is_Destroyed
                           then
                              free (the_Command.Context);

                           else
                              declare
                                 no_Params : aliased no_Parameters;
                                 the_Event :         raycast_collision_Event'Class
                                   := raycast_collision_Event_dispatching_Constructor (the_Command.event_Kind,
                                                                                       no_Params'Access);
                              begin
                                 the_Event.near_Sprite := the_Collision.near_Sprite;
                                 the_Event.Context     := the_Command.Context;
                                 the_Event.Site_world  := the_Collision.Site_world;

                                 the_Command.Observer.receive (the_Event, from_subject => the_World.Name);
                              end;
                           end if;
                        end;


                     when new_impact_Response =>
                        declare
                           the_impact_Responder      : constant impact_Responder_view := new impact_Responder;
                           the_responses_done_Signal : constant Signal_Object_view    := new signal_Object;
                        begin
                           the_filtered_impact_Response_Set.insert ((the_Command.Filter,
                                                                          the_Command.Response,
                                                                          the_impact_Responder,
                                                                          the_responses_done_Signal));
                           the_impact_Responder.start (the_World,
                                                       the_Command.Filter,
                                                       the_Command.Response,
                                                       the_responses_done_Signal);
                        end;


--                       when set_Gravity =>
--                          the_World.physics_Space.Gravity_is (the_Command.Gravity);
                  end case;
               end;
            end loop;
         end do_engine_Commands;


         --  Evolve the physics.
         --
--           if not the_World.is_a_Mirror
--           then
--              the_World.physics_Space.evolve (by => 1.0 / 60.0);     -- Evolve the world.
--           end if;


         --  Contact Manifolds
         --
         declare
            Count : Natural := 0;
         begin
            for Each in 1 .. the_World.physics_Space.manifold_Count
            loop
               declare
                  function to_Integer is new ada.unchecked_Conversion (physics_Object_view, Integer);

                  the_physics_Manifold : constant std_physics.Space.a_Manifold
                    := the_World.physics_Space.Manifold (Each);
               begin
                  Count                       := Count + 1;
                  the_World.Manifolds (Count) := (sprites => (to_MMI (the_physics_Manifold.Objects (1)),
                                                              to_MMI (the_physics_Manifold.Objects (2))),
                                                  contact => (Site => the_physics_Manifold.Contact.Site));
               exception
                  when others =>
                     put_Line ("Error in 'mmi.world.Engine.evolve' contact manifolds !");
                     Count := Count - 1;
               end;
            end loop;

            the_World.manifold_Count := the_World.physics_Space.manifold_Count;

         exception
            when E : others =>
               put_Line ("'mmi.World.local.Engine.Contact Manifolds' has an unhandled exception ...");
               put_Line (Exception_Information (E));
         end;


         --  For each registered impact response, tell the associated responder task to respond.
         --
         declare
            use filtered_impact_Response_Sets;
            Cursor : filtered_impact_Response_Sets.Cursor := the_filtered_impact_Response_Set.First;

         begin
            while has_Element (Cursor)
            loop
               Element (Cursor).Responder.respond;
               next (Cursor);
            end loop;

            --  Wait for all responders to complete.
            --
            Cursor := the_filtered_impact_Response_Set.First;

            while has_Element (Cursor)
            loop
               select
                  Element (Cursor).responses_Done.wait;
               or
                  delay Duration'Last;
               end select;

               next (Cursor);
            end loop;

         exception
            when E : others =>
               put_Line ("'mmi.World.local.Engine.impact response' has an unhandled exception ...");
               put_Line (Exception_Information (E));
         end;


         --  Update sprite transforms.
         --
         declare
            use sprite_Maps_of_transforms;

            Cursor     : sprite_Maps_of_transforms.Cursor := the_sprite_Transforms.First;
            the_Sprite : mmi.Sprite.view;
         begin
            while has_Element (Cursor)
            loop
               the_Sprite := Key (Cursor);
               declare
                  the_Transform : constant Matrix_4x4 := the_Sprite.Solid.get_Dynamics;
               begin
                  the_sprite_Transforms.replace_Element (Cursor, the_Transform);
               end;
               next (Cursor);
            end loop;
         end;

         the_World.all_sprite_Transforms.set (to => the_sprite_Transforms);

         free_Sprites;
      end evolve;


      use type std_physics.Space.view;

   begin
      accept start (space_Kind : in standard.physics.space_Kind)
      do
         Stopped                 := False;
         the_World.physics_Space := std_physics.Forge.new_Space (space_Kind);
      end start;


      next_render_Time := ada.Calendar.Clock;

      loop
         select
            accept stop
            do
               Stopped := True;


               -- Add 'destroy' commands for all sprites.
               --
               declare
                  the_Sprites : Sprite.views renames the_World.Sprites;
               begin
                  for i in 1 .. the_World.sprite_Count
                  loop
                     the_Sprites (i).destroy (and_Children => False);
                  end loop;
               end;

               -- Evolve the world til there are no commands left.
               --
               while not the_World.Commands.is_Empty
               loop
                  evolve;
               end loop;

               --  Stop all impact responders tasks.
               --
               declare
                  use filtered_impact_Response_Sets;

                  procedure free is new ada.Unchecked_Deallocation (Signal_Object, Signal_Object_view);

                  Cursor        : filtered_impact_Response_Sets.Cursor := the_filtered_impact_Response_Set.First;

                  the_Responder : impact_Responder_view;
                  the_Signal    : Signal_Object_view;

               begin
                  while has_Element (Cursor)
                  loop
                     the_Signal    := Element (Cursor).responses_Done;
                     the_Responder := Element (Cursor).Responder;
                     the_Responder.stop;

                     while not the_Responder.all'Terminated
                     loop
                        delay 0.01;
                     end loop;

                     free (the_Responder);
                     free (the_Signal);

                     next (Cursor);
                  end loop;
               end;

               -- Free both sets of freeable sprites.
               --
               free_Sprites;
               free_Sprites;
            end stop;

            exit when Stopped;

         or
            accept reset_Age
            do
               the_World.Age_is (0.0);
            end reset_Age;

         else
            null;
         end select;


         if not the_World.is_a_Mirror
         then
            evolve;
         end if;


         the_World.new_sprite_transforms_Available.signal;
         the_World.evolver_Done                   .signal;


         -- Check for joint breakage.
         --
         if the_World.broken_joints_Allowed
         then
            declare
               use mmi.Joint,
                   standard.physics.Space;

               the_Joint       : mmi.Joint.view;
               reaction_Force,
               reaction_Torque : math.Real;

               Cursor          : standard.physics.Space.joint_Cursor'Class := the_World.physics_Space.first_Joint;
            begin
               while has_Element (Cursor)
               loop
                  the_Joint := to_MMI (Element (Cursor));

                  if the_Joint /= null
                  then
                     reaction_Force  := abs (the_Joint.reaction_Force);
                     reaction_Torque := abs (the_Joint.reaction_Torque);

                     if   reaction_Force  >  50.0 / 8.0
                       or reaction_Torque > 100.0 / 8.0
                     then
                        begin
                           the_World.physics_Space      .rid (the_Joint.Physics.all'Access);
                           the_World.broken_Joints.add (the_Joint);

                        exception
                           when no_such_Child =>
                              put_Line ("Error when breaking joint due to reaction Force:  no_such_Child !");
                        end;
                     end if;

                     if reaction_Force > max_joint_Force
                     then
                        max_joint_Force := reaction_Force;
                     end if;

                     if reaction_Torque > max_joint_Torque
                     then
                        max_joint_Torque := reaction_Torque;
                     end if;
                  end if;

                  next (Cursor);
               end loop;
            end;
         end if;

         next_render_Time := next_render_Time + Duration (1.0 / 60.0);
      end loop;

   exception
      when E : others =>
         new_Line (2);
         put_Line ("Error in mmi.World.Engine");
         new_Line;
         put_Line (Exception_Information (E));
         put_Line ("Engine has terminated !");
         new_Line (2);
   end Engine;




   protected body Signal_Object
   is
      entry Wait
        when Open
      is
      begin
         Open := False;
      end Wait;

      procedure Signal
      is
      begin
         Open := True;
      end Signal;
   end Signal_Object;




   task body sprite_transform_Updater
   is
      Stopped : Boolean := False;

   begin
      while not the_World.is_a_Mirror
      loop
         select
            accept stop
            do
               Stopped := True;
            end stop;

         else
            null;
         end select;

         exit when Stopped;

         begin
            select
               the_World.new_sprite_transforms_Available.wait;

               declare
                  use sprite_Maps_of_transforms;

                  the_sprite_Transforms : constant sprite_Maps_of_transforms.Map
                    := the_World.all_sprite_Transforms.Fetch;

                  Cursor                :          sprite_Maps_of_transforms.Cursor
                    := the_sprite_Transforms.First;
               begin
                  while has_Element (Cursor)
                  loop
                     Key  (Cursor).Transform_is (Element (Cursor));
                     next (Cursor);
                  end loop;
               end;

            or
               delay 0.5;
            end select;
         end;
      end loop;

   exception
      when E : others =>
         put_Line ("sprite_transform_Updater unhandled exception ...");
         put_Line (Exception_Information (E));
         put_Line ("sprite_transform_Updater has terminated !");
   end sprite_transform_Updater;




   function local_graphics_Models (Self : in Item) return id_Maps_of_model.Map
   is
   begin
      return Self.graphics_Models;
   end local_graphics_Models;


   function local_physics_Models (Self : in Item) return id_Maps_of_physics_model.Map
   is
   begin
      return Self.physics_Models;
   end local_physics_Models;



   --------------
   --  Attributes
   --

   procedure wait_on_Evolve (Self : in out Item)
   is
   begin
      select
         Self.evolver_Done.Wait;
      or
         delay Duration'Last;
      end select;
   end wait_on_Evolve;



   function  space_Kind (Self : in     Item) return standard.physics.space_Kind
   is
   begin
      return Self.space_Kind;
   end space_Kind;



   function Space (Self : in Item) return standard.physics.Space.view
   is
   begin
      return Self.physics_Space;
   end Space;



   procedure update_Bounds (Self : in out Item;   of_Sprite : in mmi.Sprite.view)
   is
   begin
      Self.physics_Engine.update_Bounds (std_physics.Object.view (of_Sprite.Solid));

--        Self.Commands.add ((kind   => update_Bounds,
--                            sprite => of_Sprite));
   end update_Bounds;



   procedure update_Site   (Self : in out Item;   of_Sprite : in mmi.Sprite.view;
                                                  To        : in Vector_3)
   is
   begin
--      Self.physics_Engine.update_Site (of_Sprite.Solid, To);

      Self.Commands.add ((kind   => update_Site,
                          sprite => of_Sprite,
                          site   => To));
   end update_Site;



   procedure set_Speed   (Self : in out Item;   of_Sprite : in mmi.Sprite.view;
                                                To        : in Vector_3)
   is
   begin
      Self.physics_Engine.set_Speed (of_Sprite.Solid, To);

--        Self.Commands.add ((kind   => set_Speed,
--                            sprite => of_Sprite,
--                            speed  => To));
   end set_Speed;



   procedure set_xy_Spin   (Self : in out Item;   of_Sprite : in mmi.Sprite.view;
                                                  To        : in Radians)
   is
   begin
      Self.physics_Engine.set_xy_Spin (of_Sprite.Solid, To);

--        Self.Commands.add ((kind    => set_xy_Spin,
--                            sprite  => of_Sprite,
--                            xy_spin => To));
   end set_xy_Spin;


   procedure update_Scale (Self : in out Item;   of_Sprite : in mmi.Sprite.view;
                                                 To        : in Vector_3)
   is
   begin
      Self.physics_Engine.update_Scale (of_Sprite.Solid, To);

--        Self.physics_Engine.add (std_Physics.Engine.Command' (Kind   => scale_Object,
--                                                              Sprite => the_Command.Sprite.Solid,
--                                                              Scale  => the_Command.Scale));
--        Self.Commands.add ((kind   => scale_Sprite,
--                            sprite => of_Sprite,
--                            scale  => To));
   end update_Scale;



   procedure apply_Force (Self : in out Item;   to_Sprite : in mmi.Sprite.view;
                                                Force     : in Vector_3)
   is
   begin
      Self.physics_Engine.apply_Force (to_Sprite.Solid, Force);

--        Self.Commands.add ((kind   => apply_Force,
--                            sprite => to_Sprite,
--                            force  => Force));
   end apply_Force;



   function Age (Self : in Item) return Duration
   is
   begin
      return Self.Age;
   end Age;


   procedure Age_is (Self : in out Item;   Now : in Duration)
   is
   begin
      Self.Age := Now;
   end Age_is;


   procedure Gravity_is (Self : in out Item;   Now : in Vector_3)
   is
   begin
      Self.physics_Engine.set_Gravity (to => Now);

--        Self.Commands.add ((kind    => set_Gravity,
--                            sprite  => null,
--                            gravity => Now));
   end Gravity_is;



   procedure cast_Ray (Self : in Item;   From, To   : in     math.Vector_3;
                                         Observer   : in     lace.Observer.view;
                                         Context    : access lace.Any.limited_Item'Class;
                                         Event_Kind : in     raycast_collision_Event'Class)
   is
   begin
      Self.Commands.add ((kind     => cast_Ray,
                          sprite   => null,
                          from     => From,
                          to       => To,
                          observer => Observer,
                          context  => Context,
                          Event_Kind => Event_Kind'Tag));
   end cast_Ray;




   --  Collisions
   --

   function manifold_Count (Self : in Item) return Natural
   is
   begin
      return Self.manifold_Count;
   end manifold_Count;


   function Manifold (Self : in Item;   Index : in Positive) return a_Manifold
   is
   begin
      return Self.Manifolds (Index);
   end Manifold;


   function Manifolds (Self : in Item) return Manifold_array
   is
   begin
      return Self.Manifolds (1 .. Self.manifold_Count);
   end Manifolds;



   --  Sprites
   --

   function  new_sprite_Id   (Self : access Item) return sprite_Id
   is
   begin
      Self.last_used_sprite_Id := Self.last_used_sprite_Id + 1;

      return Self.last_used_sprite_Id;
   end new_sprite_Id;



   procedure destroy (Self : in out Item;   the_Sprite : in mmi.Sprite.view)
   is
   begin
      Self.Commands.add ((kind   => destroy_Sprite,
                          sprite => the_Sprite));
   end destroy;



   function free_sprite_Set (Self : access Item) return mmi.Sprite.views
   is
      prior_set_Index : Integer;
   begin
      if Self.current_free_Set = 1
      then   prior_set_Index := 2;
      else   prior_set_Index := 1;
      end if;

      declare
         the_Set : constant mmi.Sprite.views
           := Self.free_Sets (prior_set_Index).Sprites (1 .. Self.free_Sets (prior_set_Index).Count);
      begin
         Self.free_Sets (prior_set_Index).Count := 0;
         Self.current_free_Set                  := prior_set_Index;

         return the_Set;
      end;
   end free_sprite_Set;



   function Sprites (Self : in Item) return mmi.Sprite.views
   is
   begin
      return Self.Sprites (1 .. Self.sprite_Count);
   end Sprites;



   function fetch_Sprite  (Self : in Item;   Id : in sprite_Id) return mmi.Sprite.view
   is
   begin
      return Self.id_Map_of_Sprite.Element (Id);
   end fetch_Sprite;



   procedure set_Scale (Self : in out Item;   for_Sprite : in mmi.Sprite.view;
                                              To         : in Vector_3)
   is
      Pad : constant Vector_3 := for_Sprite.Site;
   begin
      Self.rid (for_Sprite, and_children => False);
      for_Sprite.Scale_is (To);
      Self.add (for_Sprite, and_children => False);

      for_Sprite.Site_is (Pad);   -- tbd: Hack !
   end set_Scale;



   function sprite_Transforms (Self : in Item) return sprite_transform_Pairs
   is
      use sprite_Maps_of_transforms;

      all_sprite_Transforms : constant sprite_Maps_of_transforms.Map    := Self.all_sprite_Transforms.Fetch;
      Cursor                :          sprite_Maps_of_transforms.Cursor := all_sprite_Transforms.First;

      the_sprite_Transforms :          sprite_transform_Pairs (1 .. Natural (all_sprite_Transforms.Length)) := (others => <>);
      Count                 :          Natural := 0;

   begin
      while has_Element (Cursor)
      loop
         declare
            the_Sprite : constant Sprite.view := Key (Cursor);
         begin
            if not the_Sprite.is_Destroyed
            then
               Count                         := Count + 1;
               the_sprite_Transforms (Count) := (sprite    => the_Sprite,
                                                 transform => Element (Cursor));
            end if;
         exception
            when others =>
               put_Line ("Exception in 'mmi.World.sprite_Transforms' !");
         end;

         next (Cursor);
      end loop;

      return the_sprite_Transforms (1 .. Count);
   end sprite_Transforms;



   --  Joints
   --

   procedure destroy (Self : in out Item;   the_Joint : in mmi.Joint.view)
   is
   begin
      Self.Commands.add ((kind   => free_Joint,
                          sprite => null,
                          joint  => the_Joint));
   end destroy;



   procedure set_local_Anchor_on_A (Self : in out Item;   for_Joint : in mmi.Joint.view;
                                                          To        : in math.Vector_3)
   is
   begin
      Self.physics_Engine.set_local_Anchor (for_Joint.Physics.all'Access,
                                            to => To,
                                            is_Anchor_A  => True);

--        the_World.physics_Space.set_Joint_local_Anchor (the_Command.anchor_Joint.Physics.all'Access,
--                                                        the_Command.is_Anchor_A,
--                                                        the_Command.local_Anchor);
--
--
--        Self.Commands.add ((Kind         => set_Joint_local_Anchor,
--                            Sprite       => null,
--                            anchor_Joint => for_Joint,
--                            is_Anchor_A  => True,
--                            local_Anchor => To));
   end set_local_Anchor_on_A;



   procedure set_local_Anchor_on_B (Self : in out Item;   for_Joint : in mmi.Joint.view;
                                                          To        : in math.Vector_3)
   is
   begin
      Self.physics_Engine.set_local_Anchor (for_Joint.Physics.all'Access,
                                            to => To,
                                            is_Anchor_A  => False);

--        Self.Commands.add ((Kind         => set_Joint_local_Anchor,
--                            Sprite       => null,
--                            anchor_Joint => for_Joint,
--                            is_Anchor_A  => False,
--                            local_Anchor => To));
   end set_local_anchor_on_B;





   --  new_model_Response
   --

   type new_model_Response is new lace.response.item with
      record
         World : mmi.World.view;
      end record;


   overriding
   function Name (Self : in new_model_Response) return String;


   overriding
   procedure respond (Self : in out new_model_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant remote.World.new_model_Event := remote.World.new_model_Event (to_Event);
   begin
      Self.World.add (new openGL.Model.item'Class' (openGL.Model.item'Class (the_Event.Model.all)));
   end respond;


   overriding
   function Name (Self : in new_model_Response) return String
   is
      pragma Unreferenced (Self);
   begin
      return "new_model_Response";
   end Name;


   the_new_model_Response : aliased new_model_Response;






   --  my_new_sprite_Response
   --
   type my_new_sprite_Response is new lace.Response.item with
      record
         World          :        mmi.World.view;
         Models         : access id_Maps_of_model.Map;
         physics_Models : access id_Maps_of_physics_model.Map;
      end record;


   overriding
   function Name (Self : in my_new_sprite_Response) return String;


   overriding
   procedure respond (Self : in out my_new_sprite_Response;   to_Event : in lace.Event.Item'Class)
   is
      the_Event  : constant mmi.events.my_new_sprite_added_to_world_Event
        := mmi.events.my_new_sprite_added_to_world_Event (to_Event);

      the_Sprite : constant mmi.Sprite.view
        := to_Sprite (the_Event.Pair,
                      Self.Models.all,
                      Self.physics_Models.all,
                      Self.World);
   begin
      Self.World.add (the_Sprite, and_children => False);
   end respond;



   procedure define (Self : in out my_new_sprite_Response;   World  : in     mmi.World.view;
                                                             Models : access id_Maps_of_model.Map)
   is
   begin
      Self.World  := World;
      Self.Models := Models;
   end define;



   overriding
   function Name (Self : in my_new_sprite_Response) return String
   is
      pragma Unreferenced (Self);
   begin
      return "my_new_sprite_Response";
   end Name;

   the_my_new_sprite_Response : aliased my_new_sprite_Response;



   type graphics_Model_iface_view is access all openGL.remote_Model.item'Class;
   type graphics_Model_view       is access all openGL.       Model.item'Class;

   type physics_Model_iface_view is access all Standard.physics.remote.Model.item'Class;
   type physics_Model_view       is access all Standard.physics.Model       .item'Class;



   procedure is_a_Mirror (Self : access Item'Class;   of_World : in remote.World.view)
   is
   begin
      Self.is_a_Mirror := True;

      the_new_model_Response.World := Self.all'Access;

      Self.add (the_new_model_Response'Access,
                to_Kind (remote.World.new_model_Event'Tag),
                of_World.Name);


      define   (the_my_new_sprite_Response, world  => Self.all'Access,
                                            models => Self.graphics_Models'Access);

      Self.add (the_my_new_sprite_Response'Access,
                to_Kind (mmi.Events.my_new_sprite_added_to_world_Event'Tag),
                of_World.Name);

      --  Obtain and make a local copy of models, sprites and humans from the mirrored world.
      --
      declare
         use remote.World.Id_Maps_of_Model_Plan;

         the_server_Models         : constant remote.World.graphics_Model_Set := of_World.graphics_Models;    -- Fetch graphics models from the server.
         the_server_physics_Models : constant remote.World.physics_model_Set  := of_World.physics_Models;     -- Fetch physics  models from the server.
      begin
         --  Create our local graphics models.
         --
         declare
            Cursor    : remote.World.Id_Maps_of_Model_Plan.Cursor := the_server_Models.First;
            new_Model : graphics_Model_iface_view;
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
            use remote.World.Id_Maps_of_physics_Model_Plan;

            Cursor    : remote.World.Id_Maps_of_physics_Model_Plan.Cursor := the_server_physics_Models.First;
            new_Model : physics_Model_iface_view;

         begin
            while has_Element (Cursor)
            loop
               new_Model := new Standard.physics.remote.Model.item'Class' (Element (Cursor));
               Self.add (Standard.physics.Model.view (new_Model));

               next (Cursor);
            end loop;
         end;

         --  Fetch sprites from the server.
         --
         declare
            the_Sprite         :          mmi.Sprite.view;
            the_server_Sprites : constant remote.World.sprite_model_Pairs := of_World.Sprites;
         begin
            for Each in the_server_Sprites'Range
            loop
               the_Sprite := to_Sprite (the_server_Sprites (Each),
                                        Self.graphics_Models,
                                        Self.physics_Models,
                                        mmi.World.view (Self));
               Self.add (the_Sprite, and_children => False);
            end loop;
         end;
      end;
   end is_a_Mirror;




   procedure add (Self : access Item;   the_Sprite   : in mmi.Sprite.view;
                                        and_Children : in Boolean        := False)
   is
      procedure add_the_Sprite (the_Sprite : in out Sprite.item'Class)
      is
      begin
         Self.Commands.add ((kind         => add_Sprite,
                             sprite       => the_Sprite'unchecked_Access,
                             add_children => False));

         Self.id_Map_of_Sprite.insert (the_Sprite.Id,
                                       the_Sprite'unchecked_Access);
      end add_the_Sprite;

   begin
      pragma assert (the_Sprite.World = Self, "Trying to add Sprite to the wrong world");

      if and_Children
      then
         declare
            procedure add_the_Joint (the_Sprite : in out Sprite.item'Class)
            is
               use type mmi.Joint.view;
            begin
               if the_Sprite.parent_Joint /= null
               then
                  Self.physics_Engine.add (the_Sprite.parent_Joint.Physics.all'Access);
               end if;
            end add_the_Joint;

         begin
            the_Sprite.apply (add_the_Sprite'unrestricted_Access);
            the_Sprite.apply (add_the_Joint 'unrestricted_Access);
         end;
      else
         add_the_Sprite (the_Sprite.all);
      end if;
   end add;



   procedure rid (Self : in out Item;   the_Sprite   : in mmi.Sprite.view;
                                        and_Children : in Boolean := False)
   is
      procedure rid_the_Sprite (the_Sprite : in out Sprite.item'Class)
      is
      begin
         Self.Commands.add ((kind         => rid_Sprite,
                             sprite       => the_Sprite'unchecked_Access,
                             rid_children => False));

         Self.id_Map_of_Sprite.delete (the_Sprite.Id);
      end rid_the_Sprite;

   begin
      if and_Children
      then
         the_Sprite.apply (rid_the_Sprite'unrestricted_Access);
      else
         rid_the_Sprite (the_Sprite.all);
      end if;
   end rid;



   procedure add (Self : in out Item;   the_Model : in openGL.Model.view)
   is
   begin
      if the_Model.Id = null_graphics_model_Id
      then
         Self.last_used_model_Id := Self.last_used_model_Id + 1;
         the_Model.Id_is (Self.last_used_model_Id);
      end if;

      if not Self.graphics_Models.contains (the_Model.Id)
      then
         Self.graphics_Models.insert (the_Model.Id, the_Model);

         --  Emit a new model event.
         --
         declare
            the_Event : remote.World.new_model_Event;
         begin
            the_Event.Model := the_Model;
            Self.emit (the_Event);
         end;
      end if;
   end add;



   procedure add (Self : in out Item;   the_Model    : in Standard.physics.Model.view)
   is
   begin
      if the_Model.Id = Standard.Physics.null_physics_model_Id
      then
         Self.last_used_physics_model_Id := Self.last_used_physics_model_Id + 1;
         the_Model.Id_is (Self.last_used_physics_model_Id);
      end if;

      if not Self.physics_Models.contains (the_Model.Id)
      then
         Self.physics_Models.insert (the_Model.Id, the_Model);
      end if;
   end add;



   procedure add (Self : in out Item;   the_Joint : in mmi.Joint.view)
   is
   begin
      the_Joint.Physics.user_Data_is (the_Joint);
      Self.physics_Engine.add        (the_Joint.Physics.all'Access);

--        Self.Commands.add ((kind   => add_Joint,
--                            sprite => null,
--                            joint  => the_Joint));
   end add;



   procedure rid (Self : in out Item;   the_Joint : in mmi.Joint.view)
   is
   begin
      Self.physics_Engine.rid (the_Joint.Physics.all'Access);

--        Self.Commands.add ((kind   => rid_Joint,
--                            sprite => null,
--                            joint  => the_Joint));
   end rid;




   --------------
   --  Operations
   --

   procedure start (Self : access Item)
   is
   begin
      Self.Engine.start (Self.space_Kind);
      Self.physics_Engine.start (Self.physics_Space);
   end start;


   overriding
   procedure motion_Updates_are (Self : in Item;   Now : in remote.World.motion_Updates)
   is
   begin
      for Each in Now'Range
      loop
         declare
            use remote.World;

            the_Id             : constant mmi.sprite_Id := Now (Each).Id;
            the_Sprite         :          Sprite.view;

            new_Site           : constant Vector_3      := refined (Now (Each).Site);
            site_Delta         :          Vector_3;

            min_teleport_Delta : constant               := 20.0;
            new_Spin           : constant Quaternion    := refined (Now (Each).Spin);

         begin
            the_Sprite := Self.id_Map_of_Sprite.Element (the_Id);
            site_Delta := new_Site - the_Sprite.desired_Site;

            if        abs site_Delta (1) > min_teleport_Delta
              or else abs site_Delta (2) > min_teleport_Delta
              or else abs site_Delta (3) > min_teleport_Delta
            then
               the_Sprite.Site_is (new_Site);   -- Sprite has been 'teleported', so move it now
            end if;                             -- to prevent later interpolation.

            the_Sprite.desired_Site_is (new_Site);
            the_Sprite.desired_Spin_is (new_Spin);
         end;
      end loop;
   end motion_Updates_are;





   procedure allow_broken_Joints (Self :    out Item)
   is
   begin
      Self.broken_joints_Allowed := True;
   end allow_broken_Joints;


   procedure handle_broken_Joints (Self : in out Item;   the_Joints :in Joint.views)
   is
   begin
      for i in the_Joints'Range
      loop
         begin
            if         (    the_Joints (i).Sprite_A /= null
                        and the_Joints (i).Sprite_B /= null)
              and then (    not the_Joints (i).Sprite_A.is_Destroyed
                        and not the_Joints (i).Sprite_B.is_Destroyed)
            then
               begin
                  the_Joints (i).Sprite_A.detach (the_Joints (i).Sprite_B);
               exception
                  when no_such_Child =>
                     put_Line ("handle_broken_Joints: cannot detach sprite:  no_such_Child !" );
               end;
            end if;

         exception
            when Storage_Error =>
               put_Line ("handle_broken_Joints: cannot tell if sprite exists:  Storage_Error !" );
         end;
      end loop;
   end handle_broken_Joints;




   procedure evolve (Self : in out Item;   By : in Duration)
   is
      use sprite_Maps_of_transforms;
   begin
      Self.Age := Self.Age + By;

      Self.respond;
      Self.local_Subject_and_deferred_Observer.respond;

      -- Broken joints.
      --
      declare
         the_Joints : safe_Joints;
         Count      : Natural;
      begin
         Self.broken_Joints.fetch  (the_Joints, Count);
         Self.handle_broken_Joints (the_Joints (1 .. Count));
      end;


      --  Perform responses to events, for all sprites.
      --
      for Each in 1 .. Self.sprite_Count
      loop
         begin
            if not Self.Sprites (Each).is_Destroyed
            then
               Self.Sprites (Each).respond;
            end if;

         exception
            when E : others =>
               new_Line (2);
               put_Line ("Error in mmi.World.local.evolve ~ Self.Sprites (" & Integer'Image (Each) & ").respond;");
               new_Line;
               put_Line (ada.exceptions.Exception_Information (E));
               new_Line (2);
         end;
      end loop;


      if Self.is_a_Mirror
      then
         --  Interpolate sprite transforms.
         --
         declare
            the_sprite_Transforms : sprite_Maps_of_transforms.Map    := Self.all_sprite_Transforms.Fetch;
            Cursor                : sprite_Maps_of_transforms.Cursor := the_sprite_Transforms.First;
            the_Sprite            : mmi.Sprite.view;

            new_Transform         : Matrix_4x4;
         begin
            while has_Element (Cursor)
            loop
               the_Sprite := Sprite.view (Key (Cursor));

               the_Sprite.interpolate_Motion;

               set_Translation (new_Transform, the_Sprite.Site);
               set_Rotation    (new_Transform, the_Sprite.Spin);

               the_sprite_Transforms.replace_Element (Cursor,  new_Transform);

               next (Cursor);
            end loop;

            Self.all_sprite_Transforms.set (to => the_sprite_Transforms);
         end;

      else
         --  Update all_sprite_Transforms.
         --
         declare
            use remote.World;

            the_sprite_Transforms    : constant sprite_Maps_of_transforms.Map    := Self.all_sprite_Transforms.Fetch;
            Cursor                   :          sprite_Maps_of_transforms.Cursor := the_sprite_Transforms.First;
            the_Sprite               :          mmi.Sprite.view;

            is_a_mirrored_World      : constant Boolean                          := not Self.Mirrors.Is_Empty;
            mirror_Updates_are_due   : constant Boolean                          := Self.Age >= Self.Age_at_last_mirror_update + 0.25;
            updates_Count            :          Natural                          := 0;

            the_sprite_id_Transforms :          remote.World.motion_Updates (1 .. Integer (the_sprite_Transforms.Length));

         begin
            while has_Element (Cursor)
            loop
               begin
                  the_Sprite := Sprite.view (Key (Cursor));

                  if         is_a_mirrored_World
                    and then mirror_Updates_are_due
                  then
                     updates_Count                            := updates_Count + 1;
                     the_sprite_id_Transforms (updates_Count) := (the_Sprite.Id,
                                                                  coarsen (the_Sprite.Site),
                                                                  coarsen (to_Quaternion (the_Sprite.Spin)));
                  end if;

               exception
                  when others =>
                     put_Line ("Exception during update of mirrored sprite transforms !");
               end;

               next (Cursor);
            end loop;

            --  Send updated sprite motions to any registered mirror worlds.
            --
            if         is_a_mirrored_World
              and then mirror_Updates_are_due
            then
               Self.Age_at_last_mirror_update := Self.Age;

               if updates_Count > 0
               then
                  declare
                     use World.world_vectors;

                     Cursor     : world_vectors.Cursor := Self.Mirrors.First;
                     the_Mirror : remote.World.view;
                  begin
                     while has_Element (Cursor)
                     loop
                        the_Mirror := Element (Cursor);
                        the_Mirror.motion_Updates_are (the_sprite_id_Transforms (1 .. updates_Count));

                        next (Cursor);
                     end loop;
                  end;
               end if;
            end if;
         end;

      end if;

   end evolve;




   -----------------------
   --  Mirror Registration
   --

   overriding
   procedure register (Self : access Item;   the_Mirror         : in remote.World.view;
                                             Mirror_as_observer : in lace.Observer.view)
   is
   begin
      Self.Mirrors.append (the_Mirror);

      Self.register (Mirror_as_observer,  to_Kind (remote.World.                 new_model_Event'Tag));
      Self.register (Mirror_as_observer,  to_Kind (mmi.events.                  new_sprite_Event'Tag));
      Self.register (Mirror_as_observer,  to_Kind (mmi.events.my_new_sprite_added_to_world_Event'Tag));
   end register;


   overriding
   procedure deregister (Self : access Item;   the_Mirror : in remote.World.view)
   is
   begin
      Self.Mirrors.delete (Self.Mirrors.find_Index (the_Mirror));
   end deregister;



   overriding
   function graphics_Models (Self : in Item) return remote.World.graphics_Model_Set
   is
      use id_Maps_of_model;

      the_Models  : remote.World.graphics_Model_Set;
      Cursor      : id_Maps_of_model.Cursor        := Self.graphics_Models.First;
   begin
      while has_Element (Cursor)
      loop
         the_Models.include (Element (Cursor).Id,
                             Element (Cursor).all);
         next (Cursor);
      end loop;

      return the_Models;
   end graphics_Models;



   overriding
   function physics_Models (Self : in Item) return remote.World.physics_Model_Set
   is
      use id_Maps_of_physics_model;

      the_Models  : remote.World.physics_Model_Set;
      Cursor      : id_Maps_of_physics_model.Cursor := Self.physics_Models.First;
   begin
      while has_Element (Cursor)
      loop
         the_Models.include (Element (Cursor).Id,
                             Element (Cursor).all);
         next (Cursor);
      end loop;

      return the_Models;
   end physics_Models;



   overriding
   function Sprites (Self : in Item) return remote.World.sprite_model_Pairs
   is
      the_Pairs : remote.World.sprite_model_Pairs (1 .. Self.sprite_Count);
   begin
      for Each in the_Pairs'Range
      loop
         the_Pairs (Each) := (sprite_id         => Self.Sprites (Each).Id,
                              graphics_model_Id => Self.Sprites (Each).graphics_Model.Id,
                              physics_model_id  => Self.Sprites (Each).physics_Model .Id,
                              mass              => Self.Sprites (Each).Mass,
                              transform         => Self.Sprites (Each).Transform,
                              is_visible        => Self.Sprites (Each).is_Visible);
      end loop;

      return the_Pairs;
   end Sprites;




   --------------
   --  Collisions
   --

   function Hash (Self : in filtered_impact_Response) return ada.Containers.Hash_type
   is
      use type ada.Containers.Hash_type;

      function to_Hash is new ada.Unchecked_Conversion (impact_Filter,   ada.Containers.Hash_type);
      function to_Hash is new ada.Unchecked_Conversion (impact_Response, ada.Containers.Hash_type);
   begin
      return   to_Hash (Self.Filter)
             + to_Hash (Self.Response);
   end Hash;



   procedure add_impact_Response (Self : in out Item;   Filter   : in impact_Filter;
                                                        Response : in impact_Response)
   is
   begin
      Self.Commands.add ((new_impact_Response,
                          null,
                          Filter,
                          Response));
   end add_impact_Response;



   task body impact_Responder
   is
      the_World          :        mmi.World.view;
      Done               :        Boolean        := False;

      Filters_through    :        impact_Filter;
      the_Response       :        impact_Response;

      the_responses_Done : access Signal_Object;

   begin
      accept start (the_World      : in     mmi.World.view;
                    Filter         : in     impact_Filter;
                    Response       : in     impact_Response;
                    responses_Done : in     Signal_Object_view)
      do
         impact_Responder.the_World := the_World;
         Filters_through            := Filter;
         the_Response               := Response;
         the_responses_Done         := responses_Done;
      end start;

      loop
         begin
            select
               accept stop
               do
                  Done := True;
               end stop;
            or
               accept respond;
            end select;

            exit when Done;

            --  Filter and call response.
            --
            for Each in 1 .. the_World.manifold_Count
            loop
               if         not the_World.Manifolds (Each).Sprites (1).is_Destroyed
                 and then not the_World.Manifolds (Each).Sprites (2).is_Destroyed
                 and then     Filters_through (the_World.Manifolds (Each))
               then
                  the_Response (the_World.Manifolds (Each),
                                the_World);
               end if;
            end loop;

            the_responses_Done.signal;

         exception
            when E : others =>
               put_Line ("Exception in impact_Responder !");
               put_Line (Exception_Information (E));

               the_responses_Done.signal;
         end;
      end loop;

   end impact_Responder;



   ----------
   --  Events
   --

   function to_raycast_collision_Event (Params : not null access no_Parameters) return raycast_collision_Event
   is
   begin
      return raycast_collision_Event' (others => <>);
   end to_raycast_collision_Event;


   overriding
   procedure destruct (Self : in out raycast_collision_Event)
   is
   begin
      free (Self.Context);
   end destruct;




   -----------
   --  Testing
   --

   overriding
   procedure kick_Sprite (Self : in out Item;   sprite_Id : in mmi.Sprite_Id)
   is
      the_Sprite : constant mmi.Sprite.view := Self.id_Map_of_Sprite.Element (sprite_Id);
   begin
      the_Sprite.Speed_is ((0.0, 10.0, 0.0));
   end kick_Sprite;


end mmi.World;
