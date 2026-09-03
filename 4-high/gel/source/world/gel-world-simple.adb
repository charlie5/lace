with
     openGL.Renderer.lean;


package body gel.World.simple
is

   ---------
   --- Forge
   --

   package body Forge
   is

      function to_World (Name       : in     String;
                         Id         : in     world_Id;
                         space_Kind : in     physics.space_Kind;
                         Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.simple.item
      is
         use lace.Subject_and_deferred_Observer.Forge;
      begin
         return Self : gel.World.simple.item := (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                                 with others => <>)
         do
            Self.define (Name, Id, space_Kind, Renderer);
         end return;
      end to_World;



      function new_World (Name       : in     String;
                          Id         : in     world_Id;
                          space_Kind : in     physics.space_Kind;
                          Renderer   : access openGL.Renderer.lean.item'Class) return gel.World.simple.view
      is
         use lace.Subject_and_deferred_Observer.Forge;

         Self : constant gel.World.simple.view
           := new gel.World.simple.item' (to_Subject_and_Observer (Name => Name & " world" & Id'Image)
                                              with others => <>);
      begin
         Self.define (Name, Id, space_Kind, Renderer);
         return Self;
      end new_World;

   end Forge;


end gel.World.simple;
