with
     openGL.Palette,
     openGL.Light;


package openGL.Program.lit
--
-- Models an openGL program which uses lighting.
--
is
   type Item is new openGL.Program.item with private;
   type View is access all Item'Class;


   ------------
   --- Uniforms
   --

   overriding
   procedure camera_Site_is  (Self : in out Item;   Now : in Vector_3);

   overriding
   procedure model_Matrix_is (Self : in out Item;   Now : in Matrix_4x4);

   overriding
   procedure Lights_are      (Self : in out Item;   Now : in Light.items);

   overriding
   procedure set_Uniforms    (Self : in     Item);

   overriding
   procedure destroy         (Self : in out Item);

   procedure specular_Color_is (Self : in out Item;   Now : in Color);



private

   -- The uniform locations are stable once the program is linked. Fetching one by
   -- name allocates and asks GL, so each program caches its locations, filled on
   -- first use ~ 'set_Uniforms' runs on the GL thread, after linking. A light's
   -- locations are filled when a light with its index first appears.
   --
   type light_uniform_Set is
      record
         Site                : Variable.uniform.vec4;
         Strength            : Variable.uniform.float;
         Color               : Variable.uniform.vec3;
         Attenuation         : Variable.uniform.float;
         ambient_Coefficient : Variable.uniform.float;
         cone_Angle          : Variable.uniform.float;
         cone_Direction      : Variable.uniform.vec3;
      end record;

   type light_uniform_Sets is array (1 .. 50) of light_uniform_Set;

   type lit_uniform_Cache is
      record
         Filled                 : Boolean := False;
         model_Transform        : Variable.uniform.mat4;
         inverse_model_Rotation : Variable.uniform.mat3;
         camera_Site            : Variable.uniform.vec3;
         light_Count            : Variable.uniform.int;
         specular_Color         : Variable.uniform.vec3;

         Lights                 : light_uniform_Sets;
         lights_Filled          : Natural := 0;
      end record;

   type lit_uniform_Cache_view is access lit_uniform_Cache;


   type Item is new openGL.Program.item with
      record
         Lights          : Light.items (1 .. 50);
         light_Count     : Natural              := 0;
         specular_Color  : Color                := Palette.Grey;     -- The materials specular color.

         camera_Site     : Vector_3;
         model_Transform : Matrix_4x4 := Identity_4x4;

         lit_Cache       : lit_uniform_Cache_view := new lit_uniform_Cache;
      end record;


end openGL.Program.lit;
