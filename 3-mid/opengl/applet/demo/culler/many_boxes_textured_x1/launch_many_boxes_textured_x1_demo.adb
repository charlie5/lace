with
     openGL.Palette,
     openGL.Model.Box.lit_colored_textured_x1,
     openGL.Visual,
     openGL.Light,

     openGL.Demo;


procedure launch_many_Boxes_textured_x1_Demo
--
--  Exercise the culler with many lit, colored and single textured boxes.
--
is
   use openGL,
       openGL.Model,
       openGL.Model.box,
       openGL.Palette,
       openGL.Math,
       openGL.linear_Algebra_3d;

begin
   Demo.print_Usage;
   Demo.define ("openGL 'many Boxes' Demo");

   --  Setup the camera.
   --
   Demo.Camera.Position_is ([0.0, 0.0, 5.0],
                            y_Rotation_from (to_Radians (0.0)));

   declare
      -- Create the box sprites.
      --
      face_Texture : constant asset_Name := to_Asset ("assets/Face1.bmp");

      the_box_Model : constant Box.lit_colored_textured_x1.view
        := Box.lit_colored_textured_x1.new_Box
          (size   => [0.5, 0.5, 0.5],
           faces  => [front => (colors => [others => (White,    Opaque)]),
                      rear  => (colors => [others => (Blue,     Opaque)]),
                      upper => (colors => [others => (Green,    Opaque)]),
                      lower => (colors => [others => (Green,    Opaque)]),
                      left  => (colors => [others => (Dark_Red, Opaque)]),
                      right => (colors => [others => (Red,      Opaque)])],
          Texture => face_Texture);

      Size : constant Integer     :=  70;
      x    :          openGL.Real := -openGL.Real (Size) / 2.0;
      z    :          openGL.Real :=  0.0;

      Sprites : constant Visual.views (1 .. Size * Size) := [others => Visual.Forge.new_Visual (Model.view (the_box_Model))];

   begin
      -- Position the sprites.
      --
      for i in Sprites'Range
      loop
         x := x + 1.0;

         if i mod Size = 0
         then
            z := z - 1.0;
            x := -openGL.Real (Size) / 2.0;
         end if;

         Sprites (i).Site_is ([x, 0.0, z]);
      end loop;


      -- Set up the light.
      --
      declare
         the_Light : openGL.Light.item := Demo.Renderer.Light (1);
      begin
         the_Light.Site_is ([0.0, 5_000.0, 5_000.0]);     -- TODO: Lighting is incorrect. The site appears to be the exact opposite of where it should be !
         Demo.Renderer.set (the_Light);
      end;

      --  openGL.Demo.Camera.allow_Impostors;


      --  Main loop.
      --
      while not Demo.Done
      loop
         Demo.Dolly.evolve;
         Demo.Done := Demo.Dolly.quit_Requested;

         Demo.Camera.render (Sprites);

         while not Demo.Camera.cull_Completed
         loop
            delay Duration'Small;
         end loop;

         Demo.Renderer.render;
         Demo.FPS_Counter.increment;    -- Frames per second display.
      end loop;
   end;

   Demo.destroy;
end launch_many_Boxes_textured_x1_Demo;
