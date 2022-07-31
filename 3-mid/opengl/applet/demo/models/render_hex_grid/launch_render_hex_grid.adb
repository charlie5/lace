with
     openGL.Model.hex_grid,
     openGL.Visual,
     openGL.Light,
     openGL.Palette,
     openGL.IO,
     openGL.Demo;


procedure launch_render_Hex_Grid
--
--  Renders a hexagon grid.
--
is
   use openGL,
       openGL.Math,
       openGL.linear_Algebra_3D,
       openGL.Palette;

begin
   Demo.print_Usage;
   Demo.define ("openGL 'Render Hex Grid' Demo",
                Width => 1_000,
                Height =>1_000);

   Demo.Camera.Position_is ([0.0, 40.0, 0.0],
                            x_Rotation_from (to_Radians (90.0)));

   --  declare
   --     use openGL.Light;
   --     the_Light : openGL.Light.item := Demo.Renderer.new_Light;
   --  begin
   --     the_Light.Site_is ([5_000.0, 2_000.0, 5_000.0]);
   --     the_Light.Color_is (White);
   --
   --     Demo.Renderer.set (the_Light);
   --  end;


   declare
      --  The models.
      --

      heights_File       : constant asset_Name         := to_Asset ("assets/kidwelly-terrain-127x127.png");

      heights_File_1x1   : constant asset_Name         := to_Asset ("assets/test-1x1.png");

      heights_File_2x1   : constant asset_Name         := to_Asset ("assets/test-2x1.png");
      heights_File_1x2   : constant asset_Name         := to_Asset ("assets/test-1x2.png");
      heights_File_2x2   : constant asset_Name         := to_Asset ("assets/test-2x2.png");

      heights_File_3x1   : constant asset_Name         := to_Asset ("assets/test-3x1.png");
      heights_File_1x3   : constant asset_Name         := to_Asset ("assets/test-1x3.png");


      heights_File_3x3   : constant asset_Name         := to_Asset ("assets/test-3x3.png");
      heights_File_4x4   : constant asset_Name         := to_Asset ("assets/test-4x4.png");
      heights_File_5x5   : constant asset_Name         := to_Asset ("assets/test-5x5.png");


      the_Region         : constant IO.height_Map_view := IO.to_height_Map (heights_File,     10.0);

      the_Region_1x1     : constant IO.height_Map_view := IO.to_height_Map (heights_File_1x1, 10.0);

      the_Region_2x1     : constant IO.height_Map_view := IO.to_height_Map (heights_File_2x1, 10.0);
      the_Region_1x2     : constant IO.height_Map_view := IO.to_height_Map (heights_File_1x2, 10.0);
      the_Region_2x2     : constant IO.height_Map_view := IO.to_height_Map (heights_File_2x2, 10.0);

      the_Region_3x1     : constant IO.height_Map_view := IO.to_height_Map (heights_File_3x1, 10.0);
      the_Region_1x3     : constant IO.height_Map_view := IO.to_height_Map (heights_File_1x3, 10.0);

      the_Region_3x3     : constant IO.height_Map_view := IO.to_height_Map (heights_File_3x3, 10.0);
      the_Region_4x4     : constant IO.height_Map_view := IO.to_height_Map (heights_File_4x4, 10.0);
      the_Region_5x5     : constant IO.height_Map_view := IO.to_height_Map (heights_File_5x5, 10.0);

      Color              : constant openGL.lucid_Color := (Green, Opaque);

      the_grid_Model     : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File,
                                    Heights       => the_Region.all'Access,
                                    Color         => Color);

      the_grid_Model_1x1 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_1x1,
                                    Heights       =>   the_Region_1x1.all'Access,
                                    Color         => Color);

      the_grid_Model_2x1 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_2x1,
                                    Heights       =>   the_Region_2x1.all'Access,
                                    Color         => Color);

      the_grid_Model_1x2 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_1x2,
                                    Heights       =>   the_Region_1x2.all'Access,
                                    Color         => Color);

      the_grid_Model_2x2 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_2x2,
                                    Heights       =>   the_Region_2x2.all'Access,
                                    Color         => Color);

      the_grid_Model_3x1 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_3x1,
                                    Heights       =>   the_Region_3x1.all'Access,
                                    Color         => Color);

      the_grid_Model_1x3 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_1x3,
                                    Heights       =>   the_Region_1x3.all'Access,
                                    Color         => Color);

      the_grid_Model_3x3 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_3x3,
                                    Heights       =>   the_Region_3x3.all'Access,
                                    Color         => Color);

      the_grid_Model_4x4 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_4x4,
                                    Heights       =>   the_Region_4x4.all'Access,
                                    Color         => Color);

      the_grid_Model_5x5 : constant Model.hex_grid.view
        := Model.hex_grid.new_Grid (heights_Asset => heights_File_5x5,
                                    Heights       =>   the_Region_5x5.all'Access,
                                    Color         => Color);

      --  The visual.
      --
      use openGL.Visual.Forge;

      the_Grid     : constant openGL.Visual.view := new_Visual (the_grid_Model    .all'Access);

      the_Grid_1x1 : constant openGL.Visual.view := new_Visual (the_grid_Model_1x1.all'Access);

      the_Grid_2x1 : constant openGL.Visual.view := new_Visual (the_grid_Model_2x1.all'Access);
      the_Grid_1x2 : constant openGL.Visual.view := new_Visual (the_grid_Model_1x2.all'Access);
      the_Grid_2x2 : constant openGL.Visual.view := new_Visual (the_grid_Model_2x2.all'Access);

      the_Grid_3x1 : constant openGL.Visual.view := new_Visual (the_grid_Model_3x1.all'Access);
      the_Grid_1x3 : constant openGL.Visual.view := new_Visual (the_grid_Model_1x3.all'Access);

      the_Grid_3x3 : constant openGL.Visual.view := new_Visual (the_grid_Model_3x3.all'Access);
      the_Grid_4x4 : constant openGL.Visual.view := new_Visual (the_grid_Model_4x4.all'Access);
      the_Grid_5x5 : constant openGL.Visual.view := new_Visual (the_grid_Model_5x5.all'Access);

   begin
      the_Grid    .Site_is ([  0.0, 0.0,   0.0]);

      the_Grid_1x1.Site_is ([  0.0, 0.0, -10.0]);

      the_Grid_2x1.Site_is ([  0.0, 0.0,   0.0]);
      the_Grid_1x2.Site_is ([  0.0, 0.0,   5.0]);
      the_Grid_2x2.Site_is ([  0.0, 0.0,  -5.0]);

      the_Grid_3x1.Site_is ([  5.0, 0.0,   0.0]);
      the_Grid_1x3.Site_is ([  5.0, 0.0,   5.0]);

      the_Grid_3x3.Site_is ([-10.0, 0.0,  -10.0]);
      the_Grid_4x4.Site_is ([-10.0, 0.0,    0.0]);
      the_Grid_5x5.Site_is ([-10.0, 0.0,   10.0]);


      --  Main loop.
      --
      while not Demo.Done
      loop
         Demo.Dolly.evolve;
         Demo.Done := Demo.Dolly.quit_Requested;

         --  Render all visuals.
         --

         Demo.Camera.render ([1 => the_Grid]);

         --  Demo.Camera.render ([1 => the_Grid_1x1]);
         --  Demo.Camera.render ([1 => the_Grid_2x1]);
         --  Demo.Camera.render ([1 => the_Grid_1x2]);
         --  Demo.Camera.render ([1 => the_Grid_3x1]);

         --  Demo.Camera.render ([the_Grid_1x1,
         --
         --                       the_Grid_2x1,
         --                       the_Grid_1x2,
         --                       the_Grid_2x2,
         --
         --                       the_Grid_3x1,
         --                       the_Grid_1x3,
         --
         --                       the_Grid_3x3,
         --                       the_Grid_4x4,
         --                       the_Grid_5x5]);

         while not Demo.Camera.cull_Completed
         loop
            delay Duration'Small;
         end loop;

         Demo.Renderer.render;
         Demo.FPS_Counter.increment;    -- Frames per second display.
         --  delay 1.0 / 60.0;
      end loop;
   end;

   Demo.destroy;
end launch_render_Hex_Grid;
