with
     gel.Sprite,
     gel.Human,
     gel.Window.setup,
     gel.Applet.gui_world,
     gel.Forge,

     openGL.Palette,

     float_math.Random,
     ada.Calendar;

pragma Unreferenced (gel.Window.setup);


procedure launch_simple_Animation
--
-- Animates the 'human-default' model, showing both its skin and its bones.
--
is
   package Math renames float_Math;

   use
        openGL,
        ada.Calendar;

   add_Balls : constant Boolean := False;

   the_Applet : constant gel.Applet.gui_World.view := gel.Forge.new_gui_Applet ("Simple Animation", 1800, 1100);

   human_model_Name : constant String   := "assets/human-default-animated-01_01.dae";
   frame_Period     : constant Duration := 0.016_666_667;     -- ~ 1/60th of a second.
   next_render_Time :          ada.Calendar.Time;

begin
   the_Applet.gui_World.Gravity_is ([0.0, -10.0, 0.0]);
   the_Applet.gui_Camera.Site_is ([0.0, 0.0, 8.0]);                             -- Position the camera.
   the_Applet.enable_simple_Dolly (in_World => 1);                              -- Enable user camera control via keyboard.
   the_Applet.enable_Mouse (detect_Motion => False);                            -- Enable mouse events.

   declare
      the_Human : gel.Human.view := gel.Human.Forge.new_Human (the_Applet.gui_World,
                                                               Model        => human_model_Name,
                                                               Mass         => 0.0,
                                                               is_Kinematic => True,
                                                               Display      => gel.Human.Skin_and_Bones);
   begin
      the_Human.motion_Mode_is (gel.Human.Animation);

      if add_Balls
      then
         declare
            the_Balls : constant array (1 .. 150) of gel.Sprite.view
              := [others => gel.Forge.new_ball_Sprite (in_World => the_Applet.gui_World,
                                                       Mass     => 1.0,
                                                       Radius   => 0.5,
                                                       Color    => (openGL.Palette.random_Color, Opaque))];

            function random_Site return math.Vector_3
            is
               use math.Random;

               half_Extent : constant math.Real := 25.0 / 2.0;
            begin
               return [random_Real (-half_Extent, half_Extent),
                       0.0,
                       random_Real (-half_Extent, half_Extent)];
            end random_Site;

         begin
            for i in the_Balls'Range
            loop
               the_Balls (i).Site_is (random_Site);
               the_Applet.gui_World.add (the_Balls (i));
            end loop;
         end;
      end if;

      next_render_Time := ada.Calendar.Clock;

      while the_Applet.is_open
      loop
         the_Applet.gui_World.evolve;                                           -- Evolve the world.
         the_Human.evolve (the_Applet.gui_World.Age);                           -- Evolve the human.
         the_Applet.freshen;                                                    -- Handle any new events and update the screen.

         next_render_Time := next_render_Time + frame_Period;
         delay until next_render_Time;
      end loop;

      the_Applet.destroy;
      gel.Human.free (the_Human);     -- After the world has freed its sprites.
   end;
end launch_simple_Animation;
