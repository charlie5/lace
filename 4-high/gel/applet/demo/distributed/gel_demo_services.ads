with
     gel.remote.World;


package gel_demo_Services
--
-- Provides RCI services.
--
is
   pragma remote_call_Interface;

   function World return gel.remote.World.view;

   procedure stop_Server;


end gel_demo_Services;
