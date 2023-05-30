with
     openGL.Program,
     openGL.Texture,
     openGL.Variable.uniform;


package openGL.texture_Set
--
-- Facilitates texturing of geometries.
--
is
   max_Textures : constant := 32;

   type texture_Id is range 1 .. max_Textures;



   type fade_Level  is delta 0.001 range 0.0 .. 1.0      -- '0.0' is no fading, '1.0' is fully faded (ie invisible).
     with Atomic;

   type fade_Levels is array (texture_Id range <>) of fade_Level;


   type fadeable_Texture is
      record
         Fade            : fade_Level                       := 0.0;
         Object          : openGL.Texture.Object            := openGL.Texture.null_Object;
         --  texture_Uniform : openGL.Variable.uniform.sampler2D;
         --  fade_Uniform    : openGL.Variable.uniform.float;
      end record;

   type fadeable_Textures is array (texture_Id range 1 .. max_Textures) of fadeable_Texture;

   type texture_Set is
      record
         Textures       : fadeable_Textures;
         Count          : Natural          := 0;
         is_Transparent : Boolean          := False;     -- Any of the textures contains lucid colors.
         initialised    : Boolean          := False;
      end record;

   procedure enable (the_Textures : in out texture_Set;
                     Program      : in     openGL.Program.view);



   procedure Texture_is      (in_Set : in out texture_Set;   Which : texture_ID;   Now : in openGL.Texture.Object);
   function  Texture         (in_Set : in     texture_Set;   Which : texture_ID)     return openGL.Texture.Object;

   procedure Texture_is      (in_Set : in out texture_Set;   Now : in openGL.Texture.Object);
   function  Texture         (in_Set : in     texture_Set)     return openGL.Texture.Object;


end openGL.texture_Set;
