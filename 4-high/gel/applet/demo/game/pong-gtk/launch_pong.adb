with
     gel.Window.setup,
     gel.Window.gtk,
     gel.Applet.gui_world,
     gel.Forge,
     gel.Sprite,
     gel.World,
     gel.Camera,
     gel.Keyboard,

     Physics,

     openGL.Palette,
     openGL.Light,
     openGL.Model.text,
     openGL.Renderer.lean,

     float_Math.Random,

     lace.Event,
     lace.Response,
     lace.Event.utility,

     gtk.Box,
     gtk.Label,
     gtk.Main,
     gtk.Window,
     gtk.glArea,

     ada.Text_IO,
     ada.Exceptions;

pragma Unreferenced (gel.Window.setup);


procedure launch_Pong
--
--  Basic pong game.
--
is
   use gel.Applet,
       gel.Applet.gui_world,
       gel.Keyboard,
       gel.Math,

       openGL.Palette,

       gtk.Box,
       gtk.Label,
       gtk.Window,

       ada.Text_IO;


   --- GtkAda objects.
   --
   top_Window : Gtk_Window;
   Label      : Gtk_Label;
   Box        : Gtk_Vbox;

begin
   -----------------
   --- Setup GtkAda.
   --

   --  Initialize GtkAda.
   --
   gtk.Main.init;

   --  Create a window with a size of 800 x 650.
   --
   gtk_new (top_Window);
   top_Window.set_default_Size (800, 650);

   --  Create a box to organize vertically the contents of the window.
   --
   gtk_New_vBox   (Box);
   top_Window.add (Box);

   --  Add a label.
   --
   gtk_new (Label, "Hello Pong.");
   Box.pack_Start (Label,
                   Expand  => False,
                   Fill    => False,
                   Padding => 10);

   --  Show the window.
   --
   top_Window.show_All;


   declare
      --- Applet
      --
      the_Applet : gel.Applet.gui_world.view
        := gel.Forge.new_gui_Applet (Named         => "Pong",
                                     window_Width  => 800,
                                     window_Height => 650,
                                     space_Kind    => physics.Box2d);

      --- Ball
      --
      the_Ball : constant gel.Sprite.view
        := gel.Forge.new_circle_Sprite (in_World => the_Applet.World,
                                        Site     => [0.0, 0.0],
                                        Mass     => 1.0,
                                        Bounce   => 1.0,
                                        Friction => 0.0,
                                        Radius   => 0.5,
                                        Color    => Grey,
                                        Texture  => openGL.to_Asset ("assets/opengl/texture/Face1.bmp"));

      court_Width  : constant := 30.0;
      court_Height : constant := 20.0;


      --- Players
      --
      type Player is
         record
            Paddle      : gel.Sprite.view;
            moving_Up   : Boolean         := False;
            moving_Down : Boolean         := False;

            Score       : Natural         := 0;
            score_Text  : gel.Sprite.view;
            score_Model : openGL.Model.text.view;
         end record;

      type player_Id is range 1 .. 2;
      type Players   is array (player_Id) of Player;

      the_Players : Players;


      procedure add_Player (Id   : in player_Id;
                            Site : in Vector_2)
      is
         the_Player :          Player renames the_Players (Id);
         score_Site : constant Vector_2    := Site + [0.0, court_Height / 2.0 + 0.8];
      begin
         the_Player.Paddle := gel.Forge.new_rectangle_Sprite (the_Applet.World,
                                                              Site     => Site,
                                                              Mass     => 0.0,
                                                              Bounce   => 1.0,
                                                              Friction => 0.0,
                                                              Width    => 0.7,
                                                              Height   => 3.0,
                                                              Color    => Red);

         the_Player.score_Text  := gel.Forge.new_text_Sprite (the_Applet.World,
                                                              Origin_3D,
                                                              " 0",
                                                              the_Applet.Font,
                                                              Green);
         the_Player.score_Model := openGL.Model.text.view (the_Player.score_Text.graphics_Model);

         the_Applet.World.add (the_Player.Paddle);
         the_Applet.World.add (the_Player.score_Text);

         the_Player.score_Text.Site_is (Vector_3 (score_Site & 0.0));
      end add_Player;


      --- Court Walls
      --
      procedure add_Wall (Site   : in Vector_2;
                          Width,
                          Height : in Real)
      is
         the_Wall : constant gel.Sprite.view
           := gel.Forge.new_rectangle_Sprite (the_Applet.World,
                                              Site     => Site,
                                              Mass     => 0.0,
                                              Bounce   => 1.0,
                                              Friction => 0.0,
                                              Width    => Width,
                                              Height   => Height,
                                              Color    => Blue);
      begin
         the_Applet.World.add (the_Wall);
      end add_Wall;


      --- Controls
      --
      relaunch_Ball : Boolean := True;


      --- Events
      --
      type key_press_Response is new lace.Response.item with null record;

      overriding
      procedure respond (Self : in out key_press_Response;   to_Event : in lace.Event.item'Class)
      is
         pragma Unreferenced (Self);
         the_Event :          gel.Keyboard.key_press_Event renames gel.Keyboard.key_press_Event (to_Event);
         the_Key   : constant gel.keyboard.Key := the_Event.modified_Key.Key;
      begin
         case the_Key
         is
            when up     => the_Players (2).moving_Up   := True;
            when down   => the_Players (2).moving_Down := True;
            when a      => the_Players (1).moving_Up   := True;
            when z      => the_Players (1).moving_Down := True;

            when SPACE  => relaunch_Ball := True;
            when others => null;
         end case;
      end respond;



      type key_release_Response is new lace.Response.item with null record;

      overriding
      procedure respond (Self : in out key_release_Response;   to_Event : in lace.Event.item'Class)
      is
         pragma Unreferenced (Self);
         the_Event :          gel.Keyboard.key_release_Event renames gel.Keyboard.key_release_Event (to_Event);
         the_Key   : constant gel.keyboard.Key := the_Event.modified_Key.Key;
      begin
         case the_Key
         is
         when up   =>   the_Players (2).moving_Up   := False;
         when down =>   the_Players (2).moving_Down := False;
         when a    =>   the_Players (1).moving_Up   := False;
         when z    =>   the_Players (1).moving_Down := False;
         when others => null;
         end case;
      end respond;



      function window_gl_Area return gtk.glArea.gtk_glArea
      is
      begin
         return gel.Window.gtk.view (the_Applet.Window).GL_Area;
      end window_gl_Area;


      use lace.Event.Utility;

      the_key_press_Response   : aliased key_press_Response;
      the_key_release_Response : aliased key_release_Response;

   begin
      --- Setup the game.
      --

      Box.pack_Start (window_gl_Area);


      --  Show the window and present it.
      --
      top_Window.Show_All;
      top_Window.Present;

      the_Applet.Camera.  Site_is ([0.0, 0.0, 20.0]);
      the_Applet.World.Gravity_is ([0.0, 0.0,  0.0]);
      the_Applet.World.add        (the_Ball);


      -- Set the lights position.
      --
      declare
         Light : openGL.Light.item := the_Applet.Renderer.new_Light;
      begin
         Light.Site_is ([0.0, -1000.0, 0.0]);
         the_Applet.Renderer.set (Light);
      end;


      --- Add the players.
      --
      declare
         paddle_X_Offset : constant := court_Width / 2.0 - 2.0;
      begin
         add_Player (1, Site => [-paddle_X_Offset, 0.0]);
         add_Player (2, Site => [ paddle_X_Offset, 0.0]);
      end;


      --- Build the court.
      --
      declare
         Thickness : constant :=  1.0;     -- Thickness of the walls.
         goal_Size : constant :=  6.0;

         side_wall_Height   : constant := (court_Height - goal_Size)     / 2.0;
         top_wall_Y_Offset  : constant := (court_Height - Thickness)     / 2.0;
         side_wall_X_Offset : constant :=  court_Width                   / 2.0;
         side_wall_Y_Offset : constant := (side_wall_Height + goal_Size) / 2.0;
      begin
         add_Wall (Site => [0.0,                  top_wall_Y_Offset],   Width => court_Width,  Height => Thickness);          -- Top
         add_Wall (Site => [0.0,                 -top_wall_Y_Offset],   Width => court_Width,  Height => Thickness);          -- Bottom

         add_Wall (Site => [-side_wall_X_Offset,  side_wall_Y_Offset],  Width => Thickness,    Height => side_wall_Height);   -- upper Left
         add_Wall (Site => [-side_wall_X_Offset, -side_wall_Y_Offset],  Width => Thickness,    Height => side_wall_Height);   -- lower Left

         add_Wall (Site => [ side_wall_X_Offset,  side_wall_Y_Offset],  Width => Thickness,    Height => side_wall_Height);   -- upper Right
         add_Wall (Site => [ side_wall_X_Offset, -side_wall_Y_Offset],  Width => Thickness,    Height => side_wall_Height);   -- lower Right
      end;


      -- Connect events.
      --
      connect ( the_Applet.local_Observer,
                the_Applet.Keyboard,
                the_key_press_Response'unchecked_Access,
               +gel.Keyboard.key_press_Event'Tag);

      connect ( the_Applet.local_Observer,
                the_Applet.Keyboard,
                the_key_release_Response'unchecked_Access,
               +gel.Keyboard.key_release_Event'Tag);


      --- Main loop.
      --
      while the_Applet.is_open
      loop
         the_Applet.World.evolve;     -- Advance the world.
         the_Applet.freshen;          -- Handle any new events and update the screen.


         --- Check goal scoring.
         --
         declare
            procedure award_Goal (Id : in player_Id)
            is
               the_Player :          Player renames the_Players (Id);
               new_Score  : constant String :=      Natural'Image (the_Player.Score + 1);
            begin
               relaunch_Ball    := True;
               the_Player.Score := the_Player.Score + 1;

               the_Player.score_Model.Text_is (new_Score);

               the_Ball.Site_is  (Origin_3d);
               the_Ball.Speed_is ([0.0, 0.0, 0.0]);
            end award_Goal;

            goal_X_Boundary : constant := court_Width / 2.0 + 1.0;

         begin
            if    the_Ball.Site (1) >  goal_X_Boundary then   award_Goal (Id => 1);
            elsif the_Ball.Site (1) < -goal_X_Boundary then   award_Goal (Id => 2);
            end if;
         end;


         --- Relauch the ball after a goal has been scored.
         --
         if relaunch_Ball
         then
            the_Ball.Site_is ([0.0, 0.0, 0.0]);

            declare
               the_Force : Vector_3 := [gel.Math.Random.random_Real (50.0, 200.0),
                                        gel.Math.Random.random_Real ( 5.0,  20.0),
                                        0.0];
            begin
               if gel.Math.Random.random_Boolean
               then
                  the_Force := -the_Force;
               end if;

               the_Ball.apply_Force (the_Force);
            end;

            relaunch_Ball := False;
         end if;


         --- Move the paddles.
         --
         for the_Player of the_Players
         loop
            declare
               paddle_Speed : constant Vector_3 := [0.0, 0.2, 0.0];
            begin
               if the_Player.moving_Up   then   the_Player.Paddle.Site_is (the_Player.Paddle.Site + paddle_Speed);   end if;
               if the_Player.moving_Down then   the_Player.Paddle.Site_is (the_Player.Paddle.Site - paddle_Speed);   end if;
            end;
         end loop;
      end loop;

      free (the_Applet);
   end;


exception
   when E : others =>
      new_Line;
      put_Line ("Unhandled exception in main task !");
      put_Line (ada.Exceptions.exception_Information (E));
      new_Line;
end launch_Pong;
