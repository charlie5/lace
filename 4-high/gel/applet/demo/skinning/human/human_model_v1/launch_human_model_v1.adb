with
     gel.Window.setup,
     gel.Applet.gui_world,
     gel.Sprite,
     gel.Human,
     gel.Forge,

     ada.Calendar;

pragma Unreferenced (gel.Window.setup);


procedure launch_human_Model_v1
--
-- Animates the 'human-default' model, showing its bones rather than its skin.
--
is
   use ada.Calendar;

   the_Applet : constant gel.Applet.gui_World.view := gel.Forge.new_gui_Applet ("human Model", 1920, 1200);

   the_Ground : constant gel.Sprite.view := gel.Forge.new_box_Sprite (the_Applet.gui_World,
                                                                      Mass => 0.0,
                                                                      Size => [50.0, 1.0, 50.0]);
   my_Human : aliased gel.Human.item;

   frame_Period     : constant Duration := 0.016_666_667;     -- ~ 1/60th of a second.
   next_render_Time :          ada.Calendar.Time;

begin
   the_Applet.gui_World.Gravity_is ([0.0, 0.0, 0.0]);
   the_Applet.gui_Camera.Site_is ([0.0, 0.0, 5.0]);                             -- Position the camera.
   the_Applet.enable_simple_Dolly (1);                                          -- Enable user camera control via keyboard.
   the_Applet.Dolly.Speed_is (0.1);
   the_Applet.enable_Mouse (detect_Motion => False);                            -- Enable mouse events.

   my_Human.define (the_Applet.gui_World,
                    Model   => "assets/human-default-animated-01_01.dae",
                    Mass    => 1.0,
                    Display => gel.Human.Bones);
   my_Human.motion_Mode_is (gel.Human.Animation);

   the_Applet.gui_World.add (the_Ground);
   the_Ground.Site_is ([0.0, -10.0, 0.0]);

   next_render_Time := ada.Calendar.Clock;

   while the_Applet.is_open
   loop
      the_Applet.gui_World.evolve;                                              -- Evolve the world.
      my_Human.evolve (the_Applet.gui_World.Age);                               -- Evolve the human.
      the_Applet.freshen;                                                       -- Handle any new events and update the screen.

      next_render_Time := next_render_Time + frame_Period;
      delay until next_render_Time;
   end loop;

   the_Applet.destroy;
   my_Human  .destroy;     -- After the world has freed its sprites.
end launch_human_Model_v1;
