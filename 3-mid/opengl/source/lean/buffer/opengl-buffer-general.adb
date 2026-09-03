with
     openGL.Errors,
     openGL.Tasks,

     GL.Pointers;


package body openGL.Buffer.general
is
   --------------------------
   --- 'vertex buffer' Object
   --

   package body Forge
   is
      function to_Buffer (From  : access constant Element_array;
                          Usage : in              Buffer.Usage) return  Object
      is
      begin
         return to_Buffer (From.all, Usage);
      end to_Buffer;



      function to_Buffer (From  : in Element_array;
                          Usage : in Buffer.Usage) return  Object
      is
         use GL.Pointers;
      begin
         Tasks.check;

         return new_Buffer : Object
         do
            new_Buffer.Usage  := Usage;
            new_Buffer.Length := From'Length;
            new_Buffer.verify_Name;
            new_Buffer.enable;

            if From'Length = 0
            then
               glBufferData (to_GL_Enum (new_Buffer.Kind),
                             0,
                             null,
                             to_GL_Enum (Usage));
            else
               glBufferData (to_GL_Enum (new_Buffer.Kind),
                             From'Size / 8,
                            +From (From'First)'Address,
                             to_GL_Enum (Usage));
            end if;

            Errors.log;
         end return;
      end to_Buffer;

   end Forge;



   procedure set (Self : in out Object;   Position : in Positive     := 1;
                                          To       : in Element_array)
   is
      use GL.Pointers;

      element_Size : constant Natural := Element_array'Component_Size / 8;     -- In bytes.

   begin
      Tasks.check;

      if To'Length = 0
      then
         return;

      elsif Position + To'Length - 1 <= Self.Length
      then     -- The slice fits within the buffer, so update it in place.
         Self.enable;
         glBufferSubData (Target =>  to_GL_Enum (Self.Kind),
                          Offset =>  GLintptr ((Position - 1) * element_Size),
                          Size   =>  To'Size / 8,
                          Data   => +To (To'First)'Address);
         Errors.log;

      elsif Position = 1
      then     -- Replace the whole buffer.
         Self.destroy;

         Self.verify_Name;
         Self.Length := To'Length;
         Self.enable;

         glBufferData (to_GL_Enum (Self.Kind),
                       To'Size / 8,
                      +To (To'First)'Address,
                       to_GL_Enum (Self.Usage));
         Errors.log;

      else
         raise openGL.Error with   "Buffer.set: a slice of" & Integer'Image (To'Length)
                                 & " elements at position" & Integer'Image (Position)
                                 & " exceeds the buffer length of" & Integer'Image (Self.Length) & ".";
      end if;
   end set;



   procedure set (Self : in out Object;   Position : in              Positive     := 1;
                                          To       : access constant Element_array)
   is
   begin
      Self.set (Position, To.all);
   end set;


end openGL.Buffer.general;
