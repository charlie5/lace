with
     gel_demo_Services,

     gel.Applet.client_World,
     gel.Window.setup,
     gel.Forge,
     gel.Camera,

     openGL.Light,

     ada.Calendar,
     ada.Text_IO,
     ada.Exceptions;

pragma Unreferenced (gel.Window.setup);


package body gel_demo_Client
is
   use ada.Text_IO;


   task
   body Item
   is
      use type ada.Calendar.Time;

      the_Applet       : gel.Applet.client_World.view;
      next_render_Time : ada.calendar.Time;

   begin
      accept start;

      the_Applet := gel.Forge.new_client_Applet ("distributed Demo ~ Client", 1920, 1200);

      -- Register the client world as a mirror of the server world.
      --
      the_Applet.client_World.is_a_Mirror (of_World => gel_demo_Services.World);

      -- Setup.
      --
      the_Applet.client_Camera.Site_is ([0.0, 0.0, 20.0]);
      the_Applet.enable_simple_Dolly (1);


      -- Set the lights position.
      --
      declare
         Light : openGL.Light.item := the_Applet.Renderer.new_Light;
      begin
         Light.Site_is ([0.0, -1000.0, 0.0]);
         the_Applet.Renderer.set (Light);
      end;


      next_render_Time := ada.Calendar.clock;

      -- Begin processing.
      --
      while the_Applet.is_open
      loop
         the_Applet.freshen;

         next_render_Time := next_render_Time + 0.016_666_667;     -- ~ 1/60th of a second.
         delay until next_render_Time;
      end loop;

      -- Close.
      --
      gel_demo_services.World.deregister (the_Mirror         => the_Applet.client_World.all'Access,
                                          Mirror_as_Observer => the_Applet.client_World.all'Access);
      the_Applet.destroy;
      gel_demo_Services.stop_Server;     -- Reaches the task in the server partition.

      put_Line ("Client done.");

   exception
      when E : others =>
         put_Line ("Client unhandled exception ...");
         put_Line (ada.exceptions.Exception_Information (E));
         put_Line ("Client has terminated !");
   end Item;


end gel_demo_Client;
