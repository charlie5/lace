package openGL.API
--
-- Names the client API which openGL targets.
--
-- The API is chosen by the 'opengl_api' scenario variable, which selects this
-- package from one of the folders in 'source/api'.
--
is
   pragma Pure;


   ----------
   --- Kind.
   --

   type Kind is (desktop_GL, GLES);

   Current : constant Kind := desktop_GL;


   -------------
   --- Shaders.
   --

   shader_Folder : constant String := "assets/opengl/shader/";
   --
   -- Shader sources are dialect-specific, so each API has its own folder of them.


end openGL.API;
