with
     GL;

package openGL.Shader
--
--  Models an openGL shader.
--
is
   type Item  is tagged limited private;
   type Items is array (Positive range <>) of aliased Item;

   type View  is access all Item'class;
   type Views is array (Positive range <>) of View;

   type Kind is (Vertex, Fragment);


   ---------
   --  Forge
   --
   procedure define  (Self : in out Item;   Kind            : in Shader.Kind;
                                            shader_Filename : in String);

   procedure define  (Self : in out Item;   Kind            : in Shader.Kind;
                                            shader_Snippets : in asset_Names);
   procedure destroy (Self : in out Item);


   --------------
   --  Attributes
   --

   function shader_info_Log (Self : in Item) return String;


   ----------
   --  Privvy
   --

   subtype a_gl_Shader is gl.GLuint;
   function  gl_Shader (Self : in Item) return a_gl_Shader;



private

   type Item is tagged limited
      record
         Kind      : shader.Kind;
         gl_Shader : a_gl_Shader;
      end record;

end openGL.Shader;
