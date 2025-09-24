with
     openGL.Model.polygon.lit_textured,
     openGL.texture_Set,
     openGL.Visual,
     openGL.Light,
     openGL.Palette,
     openGL.Demo;


procedure launch_tiling_Demo
--
--  Exercise the renderer with an example of all the models.
--
is
   use openGL,
       openGL.Math,
       openGL.linear_Algebra_3D,
       openGL.Palette;

begin
   Demo.print_Usage ("Use space ' ' to cycle through models.");
   Demo.define ("openGL 'Render Models' Demo");
   Demo.Camera.Position_is ([0.0, 0.0, 2.0],
                            y_Rotation_from (to_Radians (0.0)));

   declare
      use openGL.Light;
      the_Light : openGL.Light.item := Demo.Renderer.new_Light;
   begin
      the_Light.Site_is ([0.0, 0.0, 5.0]);
      the_Light.Color_is (White);

      Demo.Renderer.set (the_Light);
   end;


   declare
      the_Texture : constant asset_Name                 := to_Asset ("assets/opengl/texture/Face1.bmp");
      Details     :          openGL.texture_Set.Details := openGL.texture_Set.to_Details ([1 => the_Texture]);

      the_Model   : Model.polygon.lit_textured.view;
        --  := Model.polygon.lit_textured.new_Polygon (vertex_Sites    => [[-1.0, -1.0], [1.0, -1.0], [1.0, 1.0], [-1.0, 1.0]],
        --                                             texture_Details => openGL.texture_Set.to_Details ([1 => the_Texture]));


      --  The visuals.
      --
      use openGL.Visual.Forge;

      the_Visual : openGL.Visual.view;

   begin
      Details.texture_Tilings (1) := (S => 5.0, T => 4.0);

      the_Model  := Model.polygon.lit_textured.new_Polygon (vertex_Sites    => [[-1.0, -1.0], [1.0, -1.0], [1.0, 1.0], [-1.0, 1.0]],
                                                            texture_Details => Details);
      the_Visual := new_Visual (the_Model.all'Access);

      --  Main loop.
      --
      while not Demo.Done
      loop
         Demo.Dolly.evolve;
         Demo.Done := Demo.Dolly.quit_Requested;


         --  Render all visuals.
         --
         Demo.Camera.render ([1 => the_Visual]);

         while not Demo.Camera.cull_Completed
         loop
            delay Duration'Small;
         end loop;

         Demo.Renderer.render;
         Demo.FPS_Counter.increment;    -- Frames per second display.

         delay 1.0 / 60.0;
      end loop;
   end;

   Demo.destroy;
end launch_tiling_Demo;
