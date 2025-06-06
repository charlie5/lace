with
     openGL.Tasks,
     GL.Binding,
     ada.Text_IO;


package body openGL.Errors
is
   use GL;


   function Current return String
   is
   begin
      if Debugging
      then
         declare
            use GL.Binding;
            check_is_OK : constant Boolean   := openGL.Tasks.Check;   pragma Unreferenced (check_is_OK);
            the_Error   : constant GL.GLenum := glGetError;
         begin
            case the_Error
            is
               when GL.GL_NO_ERROR                   =>   return "no error";
               when GL_INVALID_ENUM                  =>   return "invalid Enum";
               when GL_INVALID_VALUE                 =>   return "invalid Value";
               when GL_INVALID_OPERATION             =>   return "invalid Operation";
               when GL_STACK_OVERFLOW                =>   return "Stack overflow";
               when GL_STACK_UNDERFLOW               =>   return "Stack underflow";
               when GL_OUT_OF_MEMORY                 =>   return "out of Memory";
               when GL_INVALID_FRAMEBUFFER_OPERATION =>   return "invalid framebuffer Operation";
               when GL_CONTEXT_LOST                  =>   return "Context lost";
               when others                           =>   return "unknown openGL error detected (Code:" & the_Error'Image & ")";
            end case;
         end;
      end if;

      return "";
   end Current;




   procedure log (Prefix : in String := "")
   is
   begin
      if Debugging
      then
         declare
            current_Error : constant String := Current;

            function Error_Message return String
            is
            begin
               if Prefix = ""
               then   return "openGL error: '" & current_Error & "'";
               else   return Prefix    & ": '" & current_Error & "'";
               end if;
            end Error_Message;

         begin
            if current_Error = "no error"
            then
               return;
            end if;

            raise openGL.Error with Error_Message;
         end;
      end if;
   end log;



   procedure log (Prefix : in String := "";   Error_occurred : out Boolean)
   is
   begin
      if Debugging
      then
         declare
            use ada.Text_IO;
            current_Error : constant String := Current;
         begin
            if current_Error = "no error"
            then
               error_Occurred := False;
               return;
            end if;

            error_Occurred := True;

            if Prefix = ""
            then   put_Line ("openGL error: '" & current_Error & "'");
            else   put_Line (Prefix    & ": '" & current_Error & "'");
            end if;
         end;
      end if;
   end log;




   function Debugging return Boolean is separate;


end openGL.Errors;
