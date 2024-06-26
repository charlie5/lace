with
     openGL.Model.hexagon.lit_textured_x2,
     openGL.Visual,
     openGL.Light,
     openGL.Palette,
     openGL.Geometry.texturing,
     --  openGL.IO,
     openGL.Demo;

with Ada.Text_IO; use Ada.Text_IO;


procedure launch_render_two_Textures
--
--  Renders a hexagon grid.
--
is
   use openGL,
       openGL.Math,
       openGL.linear_Algebra_3D,
       openGL.Palette,
       openGL.Light;


   --------------
   --  The model.
   --
   --  the_1st_Texture : constant asset_Name :=  to_Asset ("assets/opengl/texture/blobber_floor.png");
   the_1st_Texture : constant asset_Name :=  to_Asset ("assets/crawl-blob-1.png");
   the_2nd_Texture : constant asset_Name :=  to_Asset ("assets/crawl-blob-2.png");

   the_textured_hexagon_Model : constant Model.hexagon.lit_textured_x2.view
     := Model.hexagon.lit_textured_x2.new_Hexagon (Radius => 0.5,
                                                   Face   => (Texture_1 => the_1st_Texture,
                                                              Texture_2 => the_2nd_Texture,
                                                              Fade_1    => 0.5,
                                                              Fade_2    => 0.5));
   ----------------
   ---  The visual.
   --
   use openGL.Visual.Forge;

   the_Hex : constant openGL.Visual.view := new_Visual (the_textured_hexagon_Model.all'Access);

   --------------
   --- The light.
   --
   the_Light      :          openGL.Light.item := Demo.Renderer.new_Light;
   light_Site     : constant openGL.Vector_3   := [0.0, 0.0, 15.0];
   cone_Direction : constant openGL.Vector_3   := [0.0, 0.0, -1.0];

   use openGL.Geometry.texturing;
   Fade           : fade_Level := fade_Level'First;
   increment_Fade : Boolean    := True;
   Epoch          : Natural    := 0;

begin
   Demo.print_Usage;
   Demo.define ("openGL 'render two Textures' Demo",
                Width => 1_000,
                Height =>1_000);

   Demo.Camera.Position_is ([0.0, 2.0, 0.0],
                            x_Rotation_from (to_Radians (90.0)));

   -- Set up the light.
   --
   the_Light.        Kind_is        (Diffuse);
   the_Light.        Site_is        (light_Site);
   the_Light.        Color_is       (White);
   the_Light.ambient_Coefficient_is (0.8);
   the_Light.   cone_Angle_is       (5.0);
   the_Light.   cone_Direction_is   (cone_Direction);

   Demo.Renderer.set (the_Light);


   --  Main loop.
   --
   while not Demo.Done
   loop
      Demo.Dolly.evolve;
      Demo.Done := Demo.Dolly.quit_Requested;

      Demo.Camera.render ([1 => the_Hex]);

      while not Demo.Camera.cull_Completed
      loop
         delay Duration'Small;
      end loop;

      Demo.Renderer.render;
      Demo.FPS_Counter.increment;    -- Frames per second display.


      if Epoch mod 20 = 0
      then
         --  the_textured_hexagon_Model.Fade_is (which => 1, now => Fade);
         --  the_textured_hexagon_Model.Fade_is (which => 2, now => 1.0 - Fade);

         the_textured_hexagon_Model.Fade_1_is (Fade);
         the_textured_hexagon_Model.Fade_2_is (1.0 - Fade);
         --  the_textured_hexagon_Model.needs_Rebuild;
         --
         --  the_textured_hexagon_Model.Fade_1_is (1.0);
         --  the_textured_hexagon_Model.Fade_2_is (0.0);

         --  put_Line ("my Fade: " & Fade'Image);

         if increment_Fade
         then
            Fade := Fade + fade_Level'Small;
         else
            Fade := Fade - fade_Level'Small;
         end if;

         if    Fade = fade_Level'Last  then increment_Fade := False;
         elsif Fade = fade_Level'First then increment_Fade := True;
         end if;

      end if;

      Epoch := Epoch + 1;
   end loop;

   Demo.destroy;
end launch_render_two_Textures;
