with
     openGL.Errors,
     openGL.Tasks,
     openGL.IO,

     GL.lean,
     GL.Pointers;


package body openGL.Texture
is
   use GL,
       GL.lean,
       GL.Pointers;


   ----------------
   --  Texture Name
   --

   function new_texture_Name return texture_Name
   is
      check_is_OK : constant Boolean     := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      the_Name    : aliased  texture_Name;
   begin
      glGenTextures (1, the_Name'unchecked_Access);
      return the_Name;
   end new_texture_Name;


   procedure free (the_texture_Name : in texture_Name)
   is
      check_is_OK : constant Boolean      := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      the_Name    : aliased  texture_Name := the_texture_Name;
   begin
      glDeleteTextures (1, the_Name'unchecked_Access);
   end free;



   ------------------
   --  Texture Object
   --

   function to_Texture (Name : in texture_Name) return Object
   is
      Self : Texture.Object;
   begin
      Self.Name := Name;
      --  tbd: Fill in remaining fields by querying gl.

      return Self;
   end to_Texture;



   function to_Texture (Dimensions : in Texture.Dimensions) return Object
   is
      check_is_OK : constant Boolean       := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      Self        : aliased  Texture.Object;

   begin
      Self.Dimensions := Dimensions;
      Self.Name       := new_texture_Name;

      enable (Self);

      glPixelStorei   (GL_UNPACK_ALIGNMENT, 1);

      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

      return Self;
   end to_Texture;



   function to_Texture (the_Image   : in openGL.Image;
                        use_Mipmaps : in Boolean     := True) return Object
   is
      Self : aliased Texture.Object;
   begin
      Self.Name := new_texture_Name;
      set_Image (Self, the_Image, use_Mipmaps);

      return Self;
   end to_Texture;



   function to_Texture (the_Image   : in openGL.lucid_Image;
                        use_Mipmaps : in Boolean           := True) return Object
   is
      Self : aliased Texture.Object;
   begin
      Self.Name := new_texture_Name;
      set_Image (Self, the_Image, use_Mipmaps);

      return Self;
   end to_Texture;



   procedure destroy (Self : in out Object)
   is
   begin
      free (Self.Name);
   end destroy;



   procedure free (Self : in out Object)
   is
   begin
      free (Self.Pool.all, Self);
   end free;



   function  is_Defined (Self : in     Object) return Boolean
   is
      use type texture_Name;
   begin
      return Self.Name /= 0;
   end is_Defined;



   procedure set_Name (Self : in out Object;   To : in texture_Name)
   is
   begin
      Self.Name := To;
   end set_Name;


   function Name (Self : in Object) return texture_Name
   is
   begin
      return Self.Name;
   end Name;



   procedure set_Image (Self : in out Object;   To          : in openGL.Image;
                                                use_Mipmaps : in Boolean     := True)
   is
      check_is_OK : constant Boolean      :=      openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
      the_Image   :          openGL.Image renames To;
   begin
      declare
         min_Width   : constant Positive := the_Image'Length (2);
         min_Height  : constant Positive := the_Image'Length (1);
      begin
         Self.is_Transparent := False;

         Self.Dimensions.width  := min_Width;
         Self.Dimensions.height := min_Height;

         enable (Self);

         glPixelStorei   (GL_UNPACK_ALIGNMENT, 1);

         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

         openGL.Errors.log;

         glTexImage2D (GL_TEXTURE_2D,
                       0,
                       GL_RGB,
                       GLsizei (Self.Dimensions.Width),
                       GLsizei (Self.Dimensions.Height),
                       0,
                       GL_RGB,
                       GL_UNSIGNED_BYTE,
                       +the_Image (1, 1).Red'Address);
         openGL.Errors.log;

         if use_Mipmaps
         then
            glGenerateMipmap (GL_TEXTURE_2D);
            openGL.Errors.log;
         end if;
      end;
   end set_Image;



   procedure set_Image (Self : in out Object;   To          : in openGL.lucid_Image;
                                                use_Mipmaps : in Boolean           := True)
   is
      check_is_OK : constant Boolean  := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);

      the_Image   :          openGL.lucid_Image renames To;

      min_Width   : constant Positive := the_Image'Length (2);
      min_Height  : constant Positive := the_Image'Length (1);

   begin
      Self.is_Transparent := True;

      Self.Dimensions.width  := min_width;
      Self.Dimensions.height := min_height;

      enable (Self);

      glPixelStorei   (GL_UNPACK_ALIGNMENT, 1);

      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

      openGL.Errors.log;

      glTexImage2D (GL_TEXTURE_2D,
                    0,
                    GL_RGBA,
                    GLsizei (Self.Dimensions.Width),
                    GLsizei (Self.Dimensions.Height),
                    0,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    +the_Image (1, 1).Primary.Red'Address);
      openGL.Errors.log;

      if use_Mipmaps
      then
         glGenerateMipmap (GL_TEXTURE_2D);
         openGL.Errors.log;
      end if;
   end set_Image;



   function is_Transparent (Self : in Object) return Boolean
   is
   begin
      return Self.is_Transparent;
   end is_Transparent;



   procedure enable (Self : in Object)
   is
      use type GL.GLuint;
      pragma Assert (Self.Name > 0);

      check_is_OK : constant Boolean := openGL.Tasks.Check;     pragma Unreferenced (check_is_OK);
   begin
      glBindTexture (GL.GL_TEXTURE_2D, Self.Name);
   end enable;



   function power_of_2_Ceiling (From : in Positive) return GL.GLsizei
   is
      use type GL.GLsizei;
   begin
      if    From <=         2 then   return         2;
      elsif From <=         4 then   return         4;
      elsif From <=         8 then   return         8;
      elsif From <=        16 then   return        16;
      elsif From <=        32 then   return        32;
      elsif From <=        64 then   return        64;
      elsif From <=       128 then   return       128;
      elsif From <=       256 then   return       256;
      elsif From <=       512 then   return       512;
      elsif From <=      1024 then   return      1024;
      elsif From <=  2 * 1024 then   return  2 * 1024;
      elsif From <=  4 * 1024 then   return  4 * 1024;
      elsif From <=  8 * 1024 then   return  8 * 1024;
      elsif From <= 16 * 1024 then   return 16 * 1024;
      elsif From <= 32 * 1024 then   return 32 * 1024;
      end if;

      raise Constraint_Error with "texture size too large";
   end power_of_2_Ceiling;



   function  Size (Self : in Object) return Texture.Dimensions
   is
   begin
      return Self.Dimensions;
   end Size;



   -----------------------
   -- Name Maps of Texture
   --

   function fetch (From : access name_Map_of_texture'Class;   texture_Name : in asset_Name) return Object
   is
      Name : constant unbounded_String := to_unbounded_String (to_String (texture_Name));
   begin
      if From.Contains (Name)
      then
         return From.Element (Name);
      else
         declare
            new_Texture : constant Object := openGL.IO.to_Texture (texture_Name);
         begin
            From.insert (Name, new_Texture);
            return new_Texture;
         end;
      end if;
   end fetch;



   --------
   --  Pool
   --

   procedure destroy (the_Pool : in out Pool)
   is
--        procedure free is new ada.Unchecked_Deallocation (pool_texture_List, pool_texture_List_view);
   begin
      raise Program_Error with "destroy texture pool ~ TODO";
--        for i in the_Pool.unused_Textures_for_size'Range (1)
--        loop
--           for j in the_Pool.unused_Textures_for_size'Range (2)
--           loop
--              free (the_Pool.unused_Textures_for_size (i, j));
--           end loop;
--        end loop;
   end destroy;



   function new_Texture (From : access Pool;   Size : in Dimensions) return Object
   is
      check_is_OK         : constant Boolean := openGL.Tasks.Check;   pragma Unreferenced (check_is_OK);

      the_Pool            : access  Pool renames From;
      the_Texture         : aliased Object;

      unused_texture_List : pool_texture_List_view;

   begin
      if the_Pool.Map.contains (Size)
      then
         unused_texture_List := the_Pool.Map.Element (Size);
      else
         unused_texture_List := new pool_texture_List;
         the_Pool.Map.insert (Size, unused_texture_List);
      end if;

      -- Search for existing, but unused, object.
      --
      if unused_texture_List.Last > 0
      then     -- An existing unused texture has been found.
         the_Texture              := unused_texture_List.Textures (unused_texture_List.Last);
         unused_texture_List.Last := unused_texture_List.Last - 1;

         enable (the_Texture);

         gltexImage2D  (GL_TEXTURE_2D,  0,  GL_RGBA,
                        GLsizei (Size.Width),
                        GLsizei (Size.Height),
                        0,
                        GL_RGBA, GL_UNSIGNED_BYTE,
                        null);                             -- nb: Actual image is not initialised.
      else     -- No existing, unused texture found, so create a new one.
         the_Texture.Pool        := From.all'unchecked_Access;
         the_Texture.Name        := new_texture_Name;

         enable (the_Texture);

         glPixelStorei   (GL_UNPACK_ALIGNMENT, 1);
         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
                          GL_CLAMP_TO_EDGE);
         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
                          GL_CLAMP_TO_EDGE);

         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
                          GL_LINEAR);
         glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                          GL_LINEAR);

         gltexImage2D  (gl_TEXTURE_2D,  0,  gl_RGBA,
--                          power_of_2_Ceiling (min_Width),
--                          power_of_2_Ceiling (min_Height),
                        GLsizei (Size.Width),
                        GLsizei (Size.Height),
                        0,
                        GL_RGBA, GL_UNSIGNED_BYTE,
                        null);                             -- nb: Actual image is not initialised.
      end if;

      the_Texture.Dimensions := Size;

      return the_Texture;
   end new_Texture;



   procedure free (Self : in out Pool;   the_Texture : in Object)
   is
      use type texture_Name;
   begin
      if the_Texture.Name = 0 then
         return;
      end if;

      raise Program_Error with "free texture from pool ~ TODO";
--        declare
--           unused_texture_List : constant pool_texture_List_view
--             := Self.unused_Textures_for_size (the_Texture.Size_width,
--                                               the_Texture.Size_height);
--        begin
--           unused_texture_List.Last                                := unused_texture_List.Last + 1;
--           unused_texture_List.Textures (unused_texture_List.Last) := the_Texture;
--        end;
   end free;



   procedure vacuum (Self : in out Pool)
   is
   begin
      for Each of Self.Map
      loop
         declare
            unused_texture_List : constant pool_texture_List_view := Each;
         begin
            if unused_texture_List /= null
            then
               for Each in 1 .. unused_texture_List.Last
               loop
                  free (unused_texture_List.Textures (Each).Name);
               end loop;

               unused_texture_List.Last := 0;
            end if;
         end;
      end loop;

--        for each_Width in Self.unused_Textures_for_size'Range (1)
--        loop
--           for each_Height in self.unused_Textures_for_size'Range (2)
--           loop
--              declare
--                 unused_texture_List : constant pool_texture_List_view
--                   := Self.unused_Textures_for_size (each_Width, each_Height);
--              begin
--                 if unused_texture_List /= null
--                 then
--                    for Each in 1 .. unused_texture_List.Last
--                    loop
--                       free (unused_texture_List.Textures (Each).Name);
--                    end loop;
--
--                    unused_texture_List.Last := 0;
--                 end if;
--              end;
--           end loop;
--        end loop;
   end vacuum;



   function Hash (the_Dimensions : in Texture.Dimensions) return ada.Containers.Hash_Type
   is
   begin
      return   Ada.Containers.Hash_Type (  the_Dimensions.Width  * 13
                                         + the_Dimensions.Height * 17);
   end Hash;


end openGL.Texture;
