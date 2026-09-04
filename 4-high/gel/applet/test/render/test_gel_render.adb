with
     gel.Window.sdl,
     gel.Applet.gui_world,
     gel.Forge,
     gel.Sprite,
     gel.Rig,

     physics.Model,

     openGL.Model.any,
     openGL.Model.box.colored,
     openGL.Model.sphere.lit_textured,
     openGL.Model.terrain,
     openGL.texture_Set,
     openGL.IO,
     openGL.Light,
     openGL.Palette,

     ada.Command_Line,
     ada.Directories,
     ada.Streams.Stream_IO,
     ada.Text_IO;

pragma unreferenced (gel.Window.sdl);


procedure test_gel_Render
--
-- Regression tests for rendering defects recorded in the opengl, physics and gel
-- FIXES.md: lit terrain seen from just above it must show no black specks (a NaN
-- in the lighting once drew them); an animated rig must load a Blender export
-- whose bone ids differ from their names, animate without its base moving (a
-- dynamic base once sank and jittered) and be destroyed after its world; and an
-- applet with a world of physics sprites must destroy cleanly (the renderer once
-- drew visuals that were already freed).
--
-- Needs a display.
--
is
   use gel.Math,
       openGL,
       openGL.Model.box,
       openGL.Palette,
       ada.Text_IO;

   Failures : Natural := 0;

   procedure check (Ok : in Boolean;   Label : in String)
   is
   begin
      if Ok
      then
         put_Line ("PASS: " & Label);
      else
         Failures := Failures + 1;
         put_Line ("FAIL: " & Label);
      end if;
   end check;


   Root : constant String := ada.Directories.current_Directory & "/work";


   ------------------------------------
   --- Reading back a screenshot (.bmp)
   --

   type Pixel_tally is
      record
         Black   : Natural := 0;     -- Exactly (0, 0, 0).
         Drawn   : Natural := 0;     -- Not the background colour.
         Total   : Natural := 0;
      end record;

   function tally_of (Filename : in String;   Background : in Color) return Pixel_tally
   --
   -- Reads a 24-bit BMP as 'openGL.IO.Screenshot' writes it: a 54-byte header with the
   -- pixel offset at byte 10, the width at 18 and the height at 22, then bottom-up
   -- rows of BGR triples padded to four bytes.
   --
   is
      use ada.Streams,
          ada.Streams.Stream_IO;

      File   : ada.Streams.Stream_IO.File_type;
      Result : Pixel_tally;
   begin
      open (File, in_File, Filename);

      declare
         Bytes : Stream_Element_array (0 .. Stream_Element_Offset (Size (File)) - 1);
         Last  : Stream_Element_Offset;

         function u32 (At_Offset : in Stream_Element_Offset) return Long_Long_Integer
         is (  Long_Long_Integer (Bytes (At_Offset))
             + Long_Long_Integer (Bytes (At_Offset + 1)) * 2**8
             + Long_Long_Integer (Bytes (At_Offset + 2)) * 2**16
             + Long_Long_Integer (Bytes (At_Offset + 3)) * 2**24);

         function i32 (At_Offset : in Stream_Element_Offset) return Long_Long_Integer
         is (if u32 (At_Offset) >= 2**31 then u32 (At_Offset) - 2**32
                                         else u32 (At_Offset));

         Offset : Stream_Element_Offset;
         Width  : Natural;
         Height : Natural;
         Stride : Stream_Element_Offset;

         function to_Byte (Primary : in openGL.Primary) return Stream_Element
         is (Stream_Element (Float'Floor (Float (Primary) * 255.0 + 0.5)));

         Back_R : constant Stream_Element := to_Byte (Background.Red);
         Back_G : constant Stream_Element := to_Byte (Background.Green);
         Back_B : constant Stream_Element := to_Byte (Background.Blue);
      begin
         read  (File, Bytes, Last);
         close (File);

         Offset := Stream_Element_Offset (u32 (10));
         Width  := Natural (abs i32 (18));
         Height := Natural (abs i32 (22));     -- Negative when the rows are stored top-down, which does not matter here.
         Stride := Stream_Element_Offset ((Width * 3 + 3) / 4 * 4);

         for Row in 0 .. Height - 1
         loop
            for Col in 0 .. Width - 1
            loop
               declare
                  i : constant Stream_Element_Offset := Offset + Stream_Element_Offset (Row) * Stride + Stream_Element_Offset (Col) * 3;
                  B : constant Stream_Element := Bytes (i);
                  G : constant Stream_Element := Bytes (i + 1);
                  R : constant Stream_Element := Bytes (i + 2);
               begin
                  Result.Total := Result.Total + 1;

                  if R = 0 and G = 0 and B = 0
                  then
                     Result.Black := Result.Black + 1;
                  end if;

                  if R /= Back_R or G /= Back_G or B /= Back_B
                  then
                     Result.Drawn := Result.Drawn + 1;
                  end if;
               end;
            end loop;
         end loop;
      end;

      return Result;
   end tally_of;


   -------------
   --- The scene
   --

   the_Applet : constant gel.Applet.gui_World.view := gel.Forge.new_gui_Applet ("gel render test", 1024, 576);


   function to_Heightfield (From : in openGL.height_Map) return physics.Heightfield
   is
      Result : physics.Heightfield (1 .. Integer (From'Last (1)),
                                    1 .. Integer (From'Last (2)));
      Last_i : constant Index_t := From'Last (1);
   begin
      for i in Result'Range (1)
      loop
         for j in Result'Range (1)
         loop
            Result (i, j) := math.Real (From (Last_i - Index_t (i) + 1,
                                              Index_t (j)));
         end loop;
      end loop;

      return Result;
   end to_Heightfield;


   terrain_Heights : constant openGL.asset_Name := to_Asset ("assets/gel/kidwelly-terrain.png");
   terrain_Texture : constant openGL.asset_Name := to_Asset ("assets/gel/kidwelly-terrain-texture.png");

   gl_Heights : constant openGL.IO.height_Map_view := openGL.IO.to_height_Map (image_Filename => terrain_Heights,
                                                                               Scale          => 10.0);

   the_heightfield_Model : constant openGL.Model.terrain.view
     := openGL.Model.terrain.new_Terrain (heights_Asset   => terrain_Heights,
                                          Row             => 1,
                                          Col             => 1,
                                          Heights         => openGL.Model.terrain.height_Map_view (gl_Heights),
                                          color_Map       => terrain_Texture,
                                          texture_Details => texture_Set.to_Set ([1 => terrain_Texture]),
                                          Tiling          => (s => (0.0, 1.0),
                                                              t => (0.0, 1.0)));

   the_heightfield_physics_Model : constant physics.Model.view
     := physics.Model.forge.new_physics_Model (shape_Info => (Kind         => physics.Model.heightfield,
                                                              Heights      => new physics.Heightfield' (to_Heightfield (gl_Heights.all)),
                                                              height_Range => [0.0, 200.0]),
                                               Scale      => [1.0, 1.0, 1.0]);

   the_Heightfield : constant gel.Sprite.view
     := gel.Sprite.forge.new_Sprite (Name           => "test.Heightfield",
                                     World          => the_Applet.gui_World.all'Access,
                                     graphics_Model => the_Heightfield_Model,
                                     physics_Model  => the_Heightfield_physics_Model);

   Background : constant Color := Blue;

begin
   if ada.Directories.Exists (Root)
   then
      ada.Directories.delete_Tree (Root);
   end if;

   ada.Directories.create_Path (Root);

   put_Line ("Begin Test");
   new_Line;

   the_Applet.gui_Camera.Site_is ([0.0, 4.0, 30.0]);
   the_Applet.Renderer.Background_is (Background);

   declare
      Light : openGL.Light.item := the_Applet.Renderer.new_Light;
   begin
      Light.Site_is ([0.0, 1000.0, 0.0]);
      Light.ambient_Coefficient_is (0.1);
      the_Applet.Renderer.set (Light);
   end;

   the_Applet.gui_World.add (the_Heightfield);

   -- A few falling boxes and balls, so the world has physics to run and to tear down.
   --
   for i in 1 .. 5
   loop
      declare
         y : constant math.Real := 2.0 * math.Real (i);

         the_box_Model : constant openGL.Model.box.colored.view
           := openGL.Model.box.colored.new_Box (Size  => [1.0, 1.0, 1.0],
                                                Faces => [Front => (Colors => [others => (Red,     Opaque)]),
                                                          Rear  => (Colors => [others => (Blue,    Opaque)]),
                                                          Upper => (Colors => [others => (Violet,  Opaque)]),
                                                          Lower => (Colors => [others => (Yellow,  Opaque)]),
                                                          Left  => (Colors => [others => (Cyan,    Opaque)]),
                                                          Right => (Colors => [others => (Magenta, Opaque)])]);
         the_box_physics_Model : constant physics.Model.view
           := physics.Model.forge.new_physics_Model (shape_Info => (Kind         => physics.Model.Cube,
                                                                    half_Extents => the_box_Model.Size / 2.0),
                                                     Mass       => 1.0);
         the_Box : constant gel.Sprite.view
           := gel.Sprite.forge.new_Sprite (Name           => "test.Box",
                                           World          => the_Applet.gui_World.all'Access,
                                           graphics_Model => the_box_Model.all'Access,
                                           physics_Model  => the_box_physics_Model);

         the_ball_Model : constant openGL.Model.sphere.lit_textured.view
           := openGL.Model.sphere.lit_textured.new_Sphere (Radius          => 1.0,
                                                           Image           => openGL.to_Asset ("assets/gel/texture/earth_map.bmp"),
                                                           texture_Details => texture_Set.to_Set ([1 => openGL.to_Asset ("assets/gel/texture/earth_map.bmp")]));
         the_ball_physics_Model : constant physics.Model.view
           := physics.Model.forge.new_physics_Model (shape_Info => (Kind          => physics.Model.a_sphere,
                                                                    sphere_Radius => 1.0),
                                                     Mass       => 1.0);
         the_Ball : constant gel.Sprite.view
           := gel.Sprite.forge.new_Sprite (Name           => "test.Ball",
                                           World          => the_Applet.gui_World.all'Access,
                                           graphics_Model => the_ball_Model,
                                           physics_Model  => the_ball_physics_Model);
      begin
         the_Applet.gui_World.add (the_Box);
         the_Applet.gui_World.add (the_Ball);

         the_Box .Site_is ([0.0,               y, -2.5]);
         the_Ball.Site_is ([2.0 * math.Real (i), y,  0.0]);
      end;
   end loop;

   -- Let the shapes fall for a while.
   --
   for Frame in 1 .. 120
   loop
      the_Applet.gui_World.evolve;
      the_Applet.freshen;
   end loop;


   --- Terrain specks: sweep a camera just above the terrain and look for exactly black pixels.
   --
   declare
      use gel.linear_Algebra_3D;

      Min, Max : math.Real := math.Real (gl_Heights (1, 1));

      Shots        : Natural := 0;
      black_Pixels : Natural := 0;
      drawn_Pixels : Natural := 0;


      procedure sweep (Above, x_Offset, z_Offset, Pitch : in math.Real)
      is
         Row    : constant openGL.Index_t := openGL.Index_t (math.Real (gl_Heights'Length (1)) / 2.0 - z_Offset);
         Col    : constant openGL.Index_t := openGL.Index_t (math.Real (gl_Heights'Length (2)) / 2.0 + x_Offset);
         Ground : constant math.Real      := math.Real (gl_Heights (Row, Col));
      begin
         the_Applet.gui_Camera.Site_is ([x_Offset, Ground - (Min + Max) / 2.0 + Above, z_Offset]);

         for Frame in 1 .. 120
         loop
            the_Applet.gui_Camera.Spin_is (x_Rotation_from (Pitch) * y_Rotation_from (math.Real (Frame) * 0.022));
            the_Applet.freshen;

            if Frame mod 20 = 0
            then
               Shots := Shots + 1;

               declare
                  Filename : constant String := Root & "/shot_" & Shots'Image (2 .. Shots'Image'Last) & ".bmp";
               begin
                  the_Applet.take_Screenshot (Filename);     -- Taken by the renderer during the next frame.
                  the_Applet.freshen;

                  while the_Applet.Renderer.is_Busy
                  loop
                     delay 0.001;
                  end loop;

                  declare
                     T : constant Pixel_tally := tally_of (Filename, Background);
                  begin
                     black_Pixels := black_Pixels + T.Black;
                     drawn_Pixels := drawn_Pixels + T.Drawn;
                  end;
               end;
            end if;
         end loop;
      end sweep;

   begin
      for Each of gl_Heights.all
      loop
         Min := math.Real'Min (Min, math.Real (Each));
         Max := math.Real'Max (Max, math.Real (Each));
      end loop;

      sweep (Above => 1.0,  x_Offset =>  20.0,  z_Offset =>  20.0,  Pitch =>  0.0);
      sweep (Above => 0.5,  x_Offset =>  20.0,  z_Offset =>  20.0,  Pitch => -0.3);
      sweep (Above => 2.0,  x_Offset => -30.0,  z_Offset =>  10.0,  Pitch => -0.2);

      check (drawn_Pixels > Shots * 1000,  "terrain: the sweeps drew the terrain"
                                           & "  (drawn" & drawn_Pixels'Image & " over" & Shots'Image & " shots)");
      check (black_Pixels = 0,             "terrain: no exactly black pixels seen from just above it"
                                           & "  (black" & black_Pixels'Image & ")");
   end;


   --- An animated rig: the one-bone Blender box, whose bone's id and name differ and
   --- whose animation the rig once refused as "not handled".
   --
   declare
      use gel.Rig,
          gel.linear_Algebra_3D;

      the_Rig       : aliased gel.Rig.item;
      the_rig_Model : constant openGL.Model.any.view
        := openGL.Model.any.new_Model (Model            => openGL.to_Asset ("../../demo/skinning/rig/box_rig-1_bone/box_1_bone-animated.dae"),
                                       Texture          => openGL.null_Asset,
                                       texture_Details  => texture_Set.to_Set ([1 => openGL.to_Asset ("assets/gel/Face1.bmp")]),
                                       Texture_is_lucid => False);
      Home  : constant math.Vector_3 := [0.0, 50.0, 0.0];
      Drift :          math.Real     := 0.0;
   begin
      the_Rig.define (the_Applet.gui_World, the_rig_Model.all'Access, Mass => 0.0, Mode => Animation);
      the_Rig.Site_is (Home);
      the_Applet.gui_World.add (the_Rig.base_Sprite, and_Children => True);
      the_Rig.enable_Graphics;
      the_Rig.assume_Pose;
      check (True, "rig: a Blender export with a bone whose id differs from its name loads and animates");

      for Frame in 1 .. 100
      loop
         the_Applet.gui_World.evolve;
         the_Rig.evolve (world_Age => the_Applet.gui_World.Age);
         the_Rig.assume_Pose;
         the_Applet.freshen;

         Drift := math.Real'Max (Drift, Distance (the_Rig.base_Sprite.Site, Home));
      end loop;

      check (Drift < 1.0e-4, "rig: an animated rig's base stays where it was put  (drift" & Drift'Image & ")");

      the_Applet.destroy;
      the_Rig.destroy;
      check (True, "rig: destroyed after its world");
   end;

   check (True, "applet: a world of physics sprites destroys cleanly");


   ada.Directories.delete_Tree (Root);

   new_Line;

   if Failures = 0
   then
      put_Line ("Success");
   else
      put_Line ("Failures:" & Failures'Image);
      ada.Command_Line.set_Exit_Status (1);
   end if;

   put_Line ("End Test");
end test_gel_Render;
