with
     gel_demo_Server;


package body gel_demo_Services
is

   function World return gel.remote.World.view
   is
   begin
      return gel_demo_Server.the_server_World.all'Access;
   end World;



   procedure stop_Server
   is
   begin
      gel_demo_Server.item.stop;
   end stop_Server;


end gel_demo_Services;
