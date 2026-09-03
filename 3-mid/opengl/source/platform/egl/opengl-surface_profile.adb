with
     eGL.binding,
     openGL.Display.privvy,
     openGL.API,
     interfaces.C,
     ada.Text_IO;


package body opengl.surface_Profile
is
   use
        openGL.Display.privvy,
        eGL,
        eGL.Binding,
        Interfaces;


   subtype egl_attribute_List is EGLint_array;


   EGL_OPENGL_ES3_BIT : constant := 16#40#;     -- Absent from the thin binding.

   renderable_Bit : constant EGLint := (case API.Current
                                        is
                                           when API.desktop_GL => EGL_OPENGL_BIT,
                                           when API.GLES       => EGL_OPENGL_ES3_BIT);
   --
   -- The kind of client API a config must be able to render.


   function to_egl_Attributes (Desired : in Qualities) return egl_attribute_List
   is
      use C;

      the_Attributes : egl_attribute_List (1 .. 50);
      Count          : c.size_t                    := 0;

      procedure add (Attribute : in EGLint;
                     Value     : in EGLint)
      is
      begin
         Count := Count + 1;   the_Attributes (Count) := Attribute;
         Count := Count + 1;   the_Attributes (Count) := Value;
      end add;

   begin
      add (EGL_SURFACE_TYPE,    EGL_WINDOW_BIT);
      add (EGL_RENDERABLE_TYPE, renderable_Bit);

      if Desired.color_Buffer.Bits_red /= Irrelevant
      then
         add (EGL_RED_SIZE,
              EGLint (Desired.color_Buffer.Bits_red));
      end if;

      if Desired.color_Buffer.Bits_blue /= Irrelevant
      then
         add (EGL_BLUE_SIZE,
              EGLint (Desired.color_Buffer.Bits_blue));
      end if;

      if Desired.color_Buffer.Bits_green /= Irrelevant
      then
         add (EGL_GREEN_SIZE,
              EGLint (Desired.color_Buffer.Bits_green));
      end if;

      if Desired.color_Buffer.Bits_luminence /= Irrelevant
      then
         add (EGL_LUMINANCE_SIZE,
              EGLint (Desired.color_Buffer.Bits_luminence));
      end if;

      if Desired.color_Buffer.Bits_alpha /= Irrelevant
      then
         add (EGL_ALPHA_SIZE,
              EGLint (Desired.color_Buffer.Bits_alpha));
      end if;

      if Desired.color_Buffer.Bits_alpha_mask /= Irrelevant
      then
         add (EGL_ALPHA_MASK_SIZE,
              EGLint (Desired.color_Buffer.Bits_alpha_mask));
      end if;

      if Desired.depth_buffer_Bits /= Irrelevant
      then
         add (EGL_DEPTH_SIZE,
              EGLint (Desired.depth_buffer_Bits));
      end if;

      if Desired.stencil_buffer_Bits /= Irrelevant
      then
         add (EGL_STENCIL_SIZE,
              EGLint (Desired.stencil_buffer_Bits));
      end if;

      Count                  := Count + 1;
      the_Attributes (Count) := EGL_NONE;       -- add 'end-of-list' token

      return the_Attributes (1 .. Count);
   end to_egl_Attributes;



   procedure define (Self : in out Item;   the_Display : access opengl.Display.item'Class;
                                           Screen      : access openGL.Screen .item'Class;
                                           Desired     : in     Qualities                := default_Qualities)
   is
      use C;

      config_Count : aliased EGLint;
      attribList   :         egl_attribute_List := to_egl_Attributes (Desired);
      Success      :         EGLBoolean;
   begin
      Self.Display := the_Display;
      Success      := eglChooseConfig (to_eGL (the_Display.all),
                                       attribList (attribList'First)'unchecked_Access,
                                       Self.egl_Config              'unchecked_Access,
                                       1,
                                       config_Count                 'unchecked_Access);
      if Success = EGL_FALSE
      then
         raise opengl.Error with "eglChooseConfig failed";
      end if;

      if config_Count = 0
      then
         raise desired_Qualities_unavailable;
      end if;
   end define;



   procedure define (Self : in out Item;   the_Display   : access opengl.Display.item'Class;
                                           native_Visual : in     Natural;
                                           Desired       : in     Qualities              := default_Qualities)
   is
      use type EGLBoolean,
               EGLint;

      function Attribute (Config : in EGLConfig;   Which : in EGLint) return EGLint
      is
         Value   : aliased EGLint := 0;
         Success :         EGLBoolean;
      begin
         Success := eglGetConfigAttrib (to_eGL (the_Display.all),
                                        Config,
                                        Which,
                                        Value'unchecked_Access);
         if Success = EGL_FALSE
         then
            raise opengl.Error with "eglGetConfigAttrib failed";
         end if;

         return Value;
      end Attribute;


      function has_Bit (Mask, Bit : in EGLint) return Boolean
      is
         use type Unsigned_32;
      begin
         return (Unsigned_32 (Mask) and Unsigned_32 (Bit)) /= 0;
      end has_Bit;


      min_Depth : constant EGLint := (if Desired.depth_buffer_Bits = Irrelevant
                                      then 0
                                      else EGLint (Desired.depth_buffer_Bits));
   begin
      Self.Display := the_Display;

      for Each of fetch_All (the_Display)
      loop
         if         Attribute (Each.egl_Config, EGL_NATIVE_VISUAL_ID) = EGLint (native_Visual)
           and then has_Bit (Attribute (Each.egl_Config, EGL_SURFACE_TYPE),    EGL_WINDOW_BIT)
           and then has_Bit (Attribute (Each.egl_Config, EGL_RENDERABLE_TYPE), renderable_Bit)
           and then Attribute (Each.egl_Config, EGL_DEPTH_SIZE) >= min_Depth
         then
            Self.egl_Config := Each.egl_Config;
            return;
         end if;
      end loop;

      -- No match: report what was sought and what is available, then fail.
      --
      ada.Text_IO.put_Line ("openGL.surface_Profile ~ no config matches native visual"
                            & native_Visual'Image & " with depth >=" & min_Depth'Image & ". Available:");
      for Each of fetch_All (the_Display)
      loop
         ada.Text_IO.put_Line ("   visual" & Attribute (Each.egl_Config, EGL_NATIVE_VISUAL_ID)'Image
                               & "   depth" & Attribute (Each.egl_Config, EGL_DEPTH_SIZE)'Image
                               & "   surface_type" & Attribute (Each.egl_Config, EGL_SURFACE_TYPE)'Image
                               & "   renderable" & Attribute (Each.egl_Config, EGL_RENDERABLE_TYPE)'Image);
      end loop;

      raise desired_Qualities_unavailable;
   end define;



   function fetch_All (the_Display : access opengl.Display.item'Class) return surface_Profile.items
   is
      use type EGLBoolean;

      Count   : aliased EGLint;
      Success :         EGLBoolean := eglGetConfigs (to_eGL (the_Display.all),
                                                     null,
                                                     1,
                                                     Count'unchecked_Access);
   begin
      if Success = EGL_FALSE
      then
         raise opengl.Error with "Failed to get egl Config count.";
      end if;

      if Count = 0
      then
         raise opengl.Error with "Found zero egl Configs.";
      end if;

      declare
         egl_Configs  : array (1 .. Count) of aliased EGLConfig;
         the_Profiles : surface_Profile.items (1 .. Positive (Count));
      begin
         Success := eglGetConfigs (to_eGL (the_Display.all),
                                   egl_Configs (1)'unchecked_Access,
                                   Count,
                                   Count'unchecked_Access);
         if Success = EGL_FALSE
         then
            raise opengl.Error with "Failed to get egl Configs.";
         end if;

         for Each in the_Profiles'Range
         loop
            the_Profiles (Each).egl_Config := egl_Configs (EGLint (Each));
            the_Profiles (Each).Display    := the_Display;
         end loop;

         return the_Profiles;
      end;
   end fetch_All;



   function native_Visual (Self : in Item) return Natural
   is
      use type EGLBoolean;

      Value   : aliased EGLint := 0;
      Success :         EGLBoolean;
   begin
      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),
                                     Self.egl_Config,
                                     EGL_NATIVE_VISUAL_ID,
                                     Value'unchecked_Access);
      if Success = EGL_FALSE
      then
         raise opengl.Error with "eglGetConfigAttrib failed";
      end if;

      return Natural (Value);
   end native_Visual;



   function Quality (Self : in Item) return Qualities
   is
      the_Qualities :         Qualities;
      Success       :         EGLBoolean;
      Value         : aliased EGLint;

      procedure check_Success
      is
         use type EGLBoolean;
      begin
         if Success = EGL_FALSE
         then
            raise openGL.Error with "Unable to get eGL surface configuration attribute.";
         end if;
      end check_Success;



      procedure set_Value (Attribute : out Natural)
      is
      begin
         if Value = EGL_DONT_CARE
         then
            Attribute := Irrelevant;
         else
            Attribute := Natural (Value);
         end if;
      end set_Value;

   begin
      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_RED_SIZE,        Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_red);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_GREEN_SIZE,      Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_green);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_BLUE_SIZE,       Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_blue);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_LUMINANCE_SIZE,  Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_luminence);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_ALPHA_SIZE,      Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_alpha);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_ALPHA_MASK_SIZE, Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.color_Buffer.Bits_alpha_mask);


      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_DEPTH_SIZE,      Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.depth_buffer_Bits);

      Success := eglGetConfigAttrib (to_eGL (Self.Display.all),  Self.egl_Config,  EGL_STENCIL_SIZE,    Value'unchecked_Access);
      check_Success;
      set_Value (the_Qualities.stencil_buffer_Bits);

      return the_Qualities;
   end Quality;



   function value_Image (Value : in Natural) return String
   is
   begin
      if Value = Irrelevant
      then
         return "Irrelevant";
      else
         return Natural'Image (Value);
      end if;
   end value_Image;



   function Image (Self : in color_Buffer) return String
   is
   begin
      return   "Bits_red =>"          & value_Image (Self.Bits_red)
             & "  Bits_green =>"      & value_Image (Self.Bits_green)
             & "  Bits_blue =>"       & value_Image (Self.Bits_blue)
             & "  Bits_luminence =>"  & value_Image (Self.Bits_luminence)
             & "  Bits_alpha =>"      & value_Image (Self.Bits_alpha)
             & "  Bits_alpha_mask =>" & value_Image (Self.Bits_alpha_mask);
   end Image;



   function Image (Self : in Qualities) return String
   is
   begin
      return   Image (Self.color_Buffer)
             & "  depth_buffer_Bits =>"    & value_Image (Self.depth_buffer_Bits)
             & "  stencil_buffer_Bits => " & value_Image (Self.stencil_buffer_Bits);
   end Image;


end opengl.surface_Profile;
