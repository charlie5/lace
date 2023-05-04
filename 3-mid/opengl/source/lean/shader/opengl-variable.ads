with
     GL;

package openGL.Variable
--
--  Models a shader variable.
--
is
   type Item  is abstract tagged private;


   ---------
   --  Forge
   --

   procedure define  (Self : in out Item);
   procedure destroy (Self : in out Item);



private

   null_Variable : constant gl.GLint := gl.GLint'Last;


   type Item is abstract tagged
      record
         gl_Variable : gl.GLint := null_Variable;
      end record;

end openGL.Variable;
