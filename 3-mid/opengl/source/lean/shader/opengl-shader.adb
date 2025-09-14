with
     openGL.Tasks,
     openGL.Errors,
     GL.lean,
     GL.Pointers,

     ada.Characters.latin_1,
     ada.Strings.unbounded,
     ada.Text_IO,
     ada.IO_Exceptions,

     interfaces.C.Strings;

 use ada.Text_IO;


package body openGL.Shader
is
   use GL.lean,
       openGL.Errors,
       Interfaces;

   -----------
   --  Utility
   --
   function read_text_File (Filename : in String) return C.char_array;




   ---------
   --  Forge
   --

   function to_C_char_array (shader_Filename : in String) return C.char_array
   is
      use type interfaces.C.char_array;
   begin
      return   read_text_File (shader_Filename)
             & (1 => C.char (ada.Characters.Latin_1.NUL));
   end to_C_char_array;




   function to_C_char_array (shader_Snippets : in asset_Names) return C.char_array
   is
      use type interfaces.C.char_array;

      snippet_Id : Natural := 0;

      function combine_Snippets return C.char_array
      is
      begin
         snippet_Id := snippet_Id + 1;

         if snippet_Id < shader_Snippets'Last
         then
            return read_text_File (to_String (shader_Snippets (snippet_Id))) & combine_Snippets;
         else
            return read_text_File (to_String (shader_Snippets (snippet_Id)));
         end if;
      end combine_Snippets;

   begin
      return   combine_Snippets
             & (1 => C.char (ada.Characters.Latin_1.NUL));
   end to_C_char_array;




   procedure create_Shader (Self : in out Item;   Kind   : in Shader.Kind;
                                                  Source : in C.char_array)
   is
      use GL.Pointers,
          C.Strings;
      --  use ada.Text_IO;

      use type interfaces.C.char_array;

      the_Source       : aliased          C.char_array    := Source;
      the_Source_ptr   : aliased constant chars_ptr       := to_chars_ptr (the_Source'unchecked_Access);
      the_Source_Array : aliased          chars_ptr_array := [1 => the_Source_ptr];

   begin
      Tasks.check;

      Self.Kind := Kind;

      if Kind = Vertex
      then   Self.gl_Shader := glCreateShader (GL_VERTEX_SHADER);
      else   Self.gl_Shader := glCreateShader (GL_FRAGMENT_SHADER);
      end if;

      Errors.log;

      glShaderSource (Self.gl_Shader,
                      1,
                      to_GLchar_Pointer_access (the_Source_array'Access),
                      null);
      Errors.log;

      glCompileShader (Self.gl_Shader);
      Errors.log;

      declare
         use interfaces.C;
         Status : aliased gl.glInt;
      begin
         glGetShaderiv (self.gl_Shader,
                        GL_COMPILE_STATUS,
                        Status'unchecked_Access);
         if    Status = 0
           and Debugging
           --  and False
         then
            declare
               use ada.Text_IO;
               compile_Log : constant String := Self.shader_info_Log;
            begin
               new_Line;
               put_Line ("Shader compile log:");
               put_Line (compile_Log);
               Self.destroy;
               raise Error with "'" & to_Ada (the_Source) & "' compilation failed ~ " & compile_Log;
            end;
         end if;
      end;
   end create_Shader;




   procedure define (Self : in out Item;   Kind            : in Shader.Kind;
                                           shader_Filename : in String)
   is
      the_Source : aliased constant C.char_array := to_C_char_array (shader_Filename);
   begin
      --  put_Line ("SHADER NAME: " & shader_Filename);
      --  put_Line (interfaces.C.to_Ada (the_Source));

      create_Shader (Self, Kind, the_Source);
   end define;




   procedure define (Self : in out Item;   Kind            : in Shader.Kind;
                                           shader_Snippets : in asset_Names)
   is
      use ada.Text_IO,
          interfaces.C;

      the_Source : aliased constant C.char_array := to_C_char_array (shader_Snippets);
   begin
      if Debugging
        and False
      then
         new_Line;
         put_Line ("Shader snippets:");

         for Each of shader_Snippets
         loop
            put_Line (to_String (Each));
         end loop;

         new_Line;
         new_Line;
         new_Line;
         new_Line;
         put_Line ("Shader source code:");
         put_Line (to_Ada (the_Source));
         put_Line ("End source code!");
         new_Line;
         new_Line;
         new_Line;
         new_Line;
      end if;

      create_Shader (Self, Kind, the_Source);
   end define;




   procedure destroy (Self : in out Item)
   is
   begin
      Tasks.check;
      glDeleteShader (self.gl_Shader);
   end destroy;



   --------------
   --  Attributes
   --

   function shader_info_Log (Self : in Item) return String
   is
      use C, GL;

      info_log_Length : aliased  glInt   := 0;
      chars_Written   : aliased  glSizei := 0;
   begin
      Tasks.check;

      glGetShaderiv (Self.gl_Shader,
                     GL_INFO_LOG_LENGTH,
                     info_log_Length'unchecked_Access);

      if info_log_Length = 0
      then
         return "";
      end if;

      declare
         use gl.Pointers;
         info_Log     : aliased  C.char_array        := C.char_array' [1 .. C.size_t (info_log_Length) => <>];
         info_Log_ptr : constant C.Strings.chars_Ptr := C.Strings.to_chars_ptr (info_Log'unchecked_Access);
      begin
         glGetShaderInfoLog (self.gl_Shader,
                             glSizei (info_log_Length),
                             chars_Written'unchecked_Access,
                             to_GLchar_access (info_Log_ptr));

         return C.to_Ada (info_Log);
      end;
   end shader_info_Log;




   ----------
   --  Privvy
   --

   function gl_Shader (Self : in Item) return a_gl_Shader
   is
   begin
      return Self.gl_Shader;
   end gl_Shader;




   -----------
   --  Utility
   --

   function read_text_File (Filename : in String) return C.char_array
   is
      use ada.Text_IO,
          ada.Strings.unbounded;

      use type interfaces.C.size_t;

      NL        : constant String      := "" & ada.characters.latin_1.LF;
      the_File  : ada.Text_IO.File_type;
      Pad       : unbounded_String;

   begin
      if Filename = ""
      then
         return C.char_array' (1 .. 0 => <>);
      else
         open (the_File, in_File, Filename);

         while not end_of_File (the_File)
         loop
            append (Pad, get_Line (the_File) & NL);
         end loop;

         close (the_File);

         if Length (Pad) = 0
         then
            return C.char_array' (1 .. 0 => <>);
         else
            declare
               the_Data : C.char_array (0 .. C.size_t (Length (Pad) - 1));
            begin
               for i in the_Data'Range
               loop
                  the_Data (i) := C.char (Element (Pad, Integer (i) + 1));
               end loop;

               --  the_Data (the_Data'Last) := C.char'Val (0);

               return the_Data;
            end;
         end if;
      end if;

   exception
      when ada.IO_Exceptions.name_Error =>
         raise Error with "Unable to locate shader asset named '" & Filename & "'.";
   end read_text_File;


end openGL.Shader;
