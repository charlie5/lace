with
     openGL.Renderer.lean,

     gtk.Widget,
     gtk.Main,
     gtk.Window,
     gtk.Handlers,

     gdk.Types.Keysyms,
     gdk.Event,

     ada.Text_IO;


package body gel.Window.gtk
is
   use gdk.Event,
       std_gtk.Widget,
       std_gtk.Window,
       ada.Text_IO;

   function to_gel_Key (From : in gdk.Types.gdk_Key_Type) return gel.keyboard.Key;


   -------------
   --- Callbacks
   --

   package Callbacks_with_gel_Window_user_Data                    is new std_gtk.Handlers.user_Callback (gtk_Widget_record,
                                                                                                         User_type => gel.Window.gtk.view);

   package Callbacks_with_gel_Window_user_Data_and_return_Boolean is new std_Gtk.Handlers.User_Return_Callback (gtk_Widget_record,
                                                                                                                Return_type => Boolean,
                                                                                                                User_type   => Window.gtk.view);

   function key_press_Event_Cb (Self      : access gtk_Widget_record'Class;
                                Event     : in     gdk.Event.gdk_Event;
                                user_Data : in     Window.gtk.view) return Boolean
   is
      pragma Unreferenced (Self);

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("key_press_Event_Cb ~ " & Event.Key'Image);

      gel_Window.Keyboard.emit_key_press_Event (Key      => to_gel_Key (Event.Key.keyVal),
                                                key_Code => Integer    (Event.Key.hardware_Keycode));

      return True;
   end key_press_Event_Cb;



   function key_release_Event_Cb (Self      : access gtk_Widget_record'Class;
                                  Event     : in     gdk.Event.gdk_Event;
                                  user_Data : in     Window.gtk.view) return Boolean
   is
      pragma Unreferenced (Self);
      use type Gdk.Types.Gdk_key_type;

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("key_release_Event_Cb ~ " & Event.Key'Image);

      gel_Window.Keyboard.emit_key_release_Event (Key => to_gel_Key (Event.Key.keyVal));

      if Event.Key.keyVal = gdk.Types.keySyms.gdk_Escape     -- TODO: Make this user-configurable.
      then
         gel_Window.is_Open := False;
      end if;

      return True;
   end key_release_Event_Cb;



   procedure realize_Event_Cb (Widget    : access gtk_Widget_Record'Class;
                               user_Data : in     Window.gtk.view)
   is
      gl_Area    : constant std_gtk.glArea.gtk_glArea  := std_gtk.glArea.gtk_glArea (Widget);
      gel_Window :          Window.gtk.item'Class renames user_Data.all;
      top_Window :          gtk_Window;
   begin
      -- put_Line ("realize_Event_Cb");

      gel_Window.is_Open := True;
      top_Window         := gtk_Window (gl_Area.get_Toplevel);

      Callbacks_with_gel_Window_user_Data_and_return_Boolean.connect (top_Window,
                                                                      "key_press_event",
                                                                      Callbacks_with_gel_Window_user_Data_and_return_Boolean.to_Marshaller (key_press_Event_Cb'Access),
                                                                      user_Data => user_Data);

      Callbacks_with_gel_Window_user_Data_and_return_Boolean.connect (top_Window,
                                                                      "key_release_event",
                                                                      Callbacks_with_gel_Window_user_Data_and_return_Boolean.to_Marshaller (key_release_Event_Cb'Access),
                                                                      user_Data => user_Data);
   end realize_Event_Cb;



   procedure gl_Area_resize_Event_Cb (Widget    : access gtk_Widget_record'Class;
                                      user_Data : in     Window.gtk.view)
   is
      gel_Window : Window.gtk.item'Class renames user_Data.all;

      Width      : constant Integer := Integer (Widget.get_allocated_Width);
      Height     : constant Integer := Integer (Widget.get_allocated_Height);
   begin
      --  put_Line ("gl_Area_resize_Event_Cb ~ Height =>" & Height'Image & "   Width =>" & Width'Image);

      gel_Window.Size_is (Width, Height);
   end gl_Area_resize_Event_Cb;



   procedure unrealize_Event_Cb (Self      : access gtk_Widget_record'Class;
                                 user_Data : in     Window.gtk.view)
   is
      pragma Unreferenced (Self);

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("unrealize_Event_Cb");

      gel_Window.is_Open := False;
   end unrealize_Event_Cb;



   function render_Event_Cb (Self    :          access std_gtk.glArea   .gtk_glArea_record   'Class;
                             Context : not null access     gdk.glContext.gdk_glContext_record'Class) return Boolean
   is
      pragma Unreferenced (Self, Context);
   begin
      return True;
   end render_Event_Cb;



   function Button_press_Event_Cb (Self      : access gtk_Widget_record'Class;
                                   Event     : in     gdk.Event .gdk_Event;
                                   user_Data : in     gel.Window.gtk.view) return Boolean
   is
      pragma Unreferenced (Self);

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("Button_press_Event_Cb ~ Button =>"
      --            & Event.Button.Button'Image
      --            & "   X =>" & Integer (Event.Button.X)'Image
      --            & "   Y =>" & Integer (Event.Button.Y)'Image);

      gel_Window.Mouse.emit_button_press_Event (Button    => gel.mouse.button_Id (Event.Button.Button),
                                                Modifiers => gel_Window.Keyboard.Modifiers,
                                                Site      => [Integer (Event.Button.X),
                                                              Integer (Event.Button.Y)]);
      return True;
   end Button_press_Event_Cb;



   function Button_release_Event_Cb (Self      : access gtk_Widget_record'Class;
                                     Event     : in     gdk.Event .gdk_Event;
                                     user_Data : in     gel.Window.gtk.view) return Boolean
   is
      pragma Unreferenced (Self);

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("Button_release_Event_Cb ~ Button =>"
      --            & Event.Button.Button'Image
      --            & "   X =>" & Integer (Event.Button.X)'Image
      --            & "   Y =>" & Integer (Event.Button.Y)'Image);

      gel_Window.Mouse.emit_button_release_Event (Button    => gel.mouse.button_Id (Event.Button.Button),
                                                  Modifiers => gel_Window.Keyboard.Modifiers,
                                                  Site      => [Integer (Event.Button.X),
                                                                Integer (Event.Button.Y)]);
      return True;
   end Button_release_Event_Cb;



   function Pointer_motion_Event_Cb (Self      : access gtk_Widget_record'Class;
                                     Event     : in     gdk.Event .gdk_Event;
                                     user_Data : in     gel.Window.gtk.view) return Boolean
   is
      pragma Unreferenced (Self);

      gel_Window : Window.gtk.item'Class renames user_Data.all;
   begin
      --  put_Line ("Pointer_motion_Event_Cb ~ Button =>"
      --            & Event.Button.Button'Image
      --            & "   X =>"      & Integer (Event.Button.X)'Image
      --            & "   Y =>"      & Integer (Event.Button.Y)'Image);
      --            --  & "   X_root =>" & Integer (Event.Button.X_root)'Image
      --            --  & "   Y_root =>" & Integer (Event.Button.Y_root)'Image);

      gel_Window.Mouse.emit_motion_Event (Site => [Integer (Event.Button.X),
                                                   Integer (Event.Button.Y)]);
      return True;
   end Pointer_motion_Event_Cb;



   ---------
   --- Forge
   --

   procedure define  (Self : access Item;   Title  : in String;
                                            Width  : in Natural;
                                            Height : in Natural)
   is
      pragma Unreferenced (Title, Width, Height);

      use std_gtk.glArea,
          gdk    .glContext;
   begin
      Self.gl_Area := gtk_glArea_new;
      Self.gl_Area.set_use_ES (True);

      Callbacks_with_gel_Window_user_Data.connect (Self.gl_Area,
                                                  "realize",
                                                  Callbacks_with_gel_Window_user_Data.to_Marshaller (realize_Event_Cb'Access),
                                                  user_Data => View (Self));

      Callbacks_with_gel_Window_user_Data.connect (Self.gl_Area,
                                                  "resize",
                                                  Callbacks_with_gel_Window_user_Data.to_Marshaller (gl_Area_resize_Event_Cb'Access),
                                                  user_Data => View (Self));

      Callbacks_with_gel_Window_user_Data.connect (Self.gl_Area,
                                                  "unrealize",
                                                  Callbacks_with_gel_Window_user_Data.to_Marshaller (unrealize_Event_Cb'Access),
                                                  user_Data => View (Self));

      Self.gl_Area.on_Render (render_Event_Cb'Access);

      Self.gl_Area.add_Events (Button_press_Mask);
      Callbacks_with_gel_Window_user_Data_and_return_Boolean.connect (Self.gl_Area,
                                                                     "button-press-event",
                                                                     Callbacks_with_gel_Window_user_Data_and_return_Boolean.to_Marshaller (Button_press_Event_Cb'Access),
                                                                     user_Data => View (Self));
      Self.gl_Area.add_Events (Button_release_Mask);
      Callbacks_with_gel_Window_user_Data_and_return_Boolean.connect (Self.gl_Area,
                                                                     "button-release-event",
                                                                     Callbacks_with_gel_Window_user_Data_and_return_Boolean.to_Marshaller (Button_release_Event_Cb'Access),
                                                                     user_Data => View (Self));
      Self.gl_Area.add_Events (Pointer_Motion_Mask);
      Callbacks_with_gel_Window_user_Data_and_return_Boolean.connect (Self.gl_Area,
                                                                     "motion-notify-event",
                                                                     Callbacks_with_gel_Window_user_Data_and_return_Boolean.to_Marshaller (Pointer_motion_Event_Cb'Access),
                                                                     user_Data => View (Self));
      Self.gl_Context := Self.gl_Area.get_Context;
   end define;



   overriding
   procedure destroy (Self : in out Item)
   is
   begin
      destroy (gel.Window.item (Self));     -- Destroy base class.
   end destroy;



   package body Forge
   is
      function to_Window (Title  : in String;
                          Width  : in Natural;
                          Height : in Natural) return gel.Window.gtk.item
      is
      begin
         return Self : gel.Window.gtk.item := (gel.Window.private_Forge.to_Window (Title, Width, Height)
                                               with others => <>)
         do
            define (Self'unchecked_Access, Title, Width, Height);
         end return;
      end to_Window;


      function new_Window (Title  : in String;
                           Width  : in Natural;
                           Height : in Natural) return Window.gtk.view
      is
         Self : constant gel.Window.gtk.view := new Window.gtk.item' (to_Window (Title, Width, Height));
      begin
         return Self;
      end new_Window;
   end Forge;



   --------------
   --- Operations
   --

   use gel.Keyboard;


   function gl_Area (Self : in Item) return std_gtk.GLArea.Gtk_GLArea
   is
   begin
      return Self.gl_Area;
   end gl_Area;



   --  procedure set_Context (Self : in out Item;   To : in gdk.glContext.gdk_glContext)
   --  is
   --  begin
   --     Self.gl_Context := To;
   --  end set_Context;



   overriding
   procedure enable_GL (Self : in Item)
   is
      use gdk.GLContext;
      use type std_gtk.glArea.gtk_GLArea;
   begin
      --  ada.Text_IO.Put_Line ("gel.window.gtk.enble_GL: attempting to make context current");

      if          Self.is_Open
        and then (         Self.gl_Area             /= null
                  and then Self.gl_Area.get_Context /= null)
      then
         Self.gl_Area.make_Current;
      end if;
   end enable_GL;



   overriding
   procedure disable_GL (Self : in Item)
   is
   begin
      gdk.glContext.clear_Current;
   end disable_GL;



   overriding
   procedure swap_GL (Self : in out Item)
   is
   begin
      null;
   end swap_GL;



   overriding
   procedure freshen (Self : in Item)
   is
   begin
      while std_gtk.Main.Events_pending
      loop
         declare
            Ignore : Boolean;
         begin
            openGL.Renderer.lean.gl_Lock.acquire;
            Ignore := std_gtk.Main.main_Iteration;
            openGL.Renderer.lean.gl_Lock.release;
         end;
      end loop;

      if Self.is_Open
      then
         Self.gl_Area.queue_Render;
      end if;
   end freshen;




   function to_gel_Key (From : in gdk.Types.gdk_Key_Type) return gel.Keyboard.Key
   is
      package Key renames gdk.Types.keySyms;
   begin
      case From
      is
      when Key.GDK_Return     => return gel.Keyboard.Enter;
      when Key.GDK_Escape     => return gel.Keyboard.Escape;
      when Key.GDK_Backspace  => return gel.Keyboard.BackSpace;
      when Key.GDK_Tab        => return gel.Keyboard.Tab;
      when Key.GDK_Space      => return gel.Keyboard.Space;
      when Key.GDK_Exclam     => return gel.Keyboard.Exclaim;
      when Key.GDK_QuoteDbl   => return gel.Keyboard.QuoteDbl;
      when Key.GDK_NumberSign => return gel.Keyboard.Hash;
      when Key.GDK_Percent    => return gel.Keyboard.Percent;
      when Key.GDK_Dollar     => return gel.Keyboard.Dollar;
      when Key.GDK_Ampersand  => return gel.Keyboard.Ampersand;
      when Key.GDK_QuoteRight => return gel.Keyboard.Quote;
      when Key.GDK_ParenLeft  => return gel.Keyboard.leftParen;
      when Key.GDK_ParenRight => return gel.Keyboard.rightParen;
      when Key.GDK_Asterisk   => return gel.Keyboard.Asterisk;
      when Key.GDK_Plus       => return gel.Keyboard.Plus;
      when Key.GDK_Comma      => return gel.Keyboard.Comma;
      when Key.GDK_Minus      => return gel.Keyboard.Minus;
      when Key.GDK_Period     => return gel.Keyboard.Period;
      when Key.GDK_Slash      => return gel.Keyboard.Slash;

      when Key.GDK_0 => return gel.Keyboard.'0';
      when Key.GDK_1 => return gel.Keyboard.'1';
      when Key.GDK_2 => return gel.Keyboard.'2';
      when Key.GDK_3 => return gel.Keyboard.'3';
      when Key.GDK_4 => return gel.Keyboard.'4';
      when Key.GDK_5 => return gel.Keyboard.'5';
      when Key.GDK_6 => return gel.Keyboard.'6';
      when Key.GDK_7 => return gel.Keyboard.'7';
      when Key.GDK_8 => return gel.Keyboard.'8';
      when Key.GDK_9 => return gel.Keyboard.'9';

      when Key.GDK_colon        => return gel.Keyboard.Colon;
      when Key.GDK_semicolon    => return gel.Keyboard.semiColon;
      when Key.GDK_less         => return gel.Keyboard.Less;
      when Key.GDK_equal        => return gel.Keyboard.Equals;
      when Key.GDK_greater      => return gel.Keyboard.Greater;
      when Key.GDK_question     => return gel.Keyboard.Question;
      when Key.GDK_at           => return gel.Keyboard.At_key;

      when Key.GDK_bracketLeft  => return gel.Keyboard.leftBracket;
      when Key.GDK_backslash    => return gel.Keyboard.backSlash;
      when Key.GDK_bracketRight => return gel.Keyboard.rightBracket;
      when Key.GDK_caret        => return gel.Keyboard.Caret;
      when Key.GDK_underscore   => return gel.Keyboard.Underscore;
      when Key.GDK_quoteleft    => return gel.Keyboard.backQuote;

      when Key.GDK_a | Key.GDK_lc_a => return gel.Keyboard.A;
      when Key.GDK_b | Key.GDK_lc_b => return gel.Keyboard.B;
      when Key.GDK_c | Key.GDK_lc_c => return gel.Keyboard.C;
      when Key.GDK_d | Key.GDK_lc_d => return gel.Keyboard.D;
      when Key.GDK_e | Key.GDK_lc_e => return gel.Keyboard.E;
      when Key.GDK_f | Key.GDK_lc_f => return gel.Keyboard.F;
      when Key.GDK_g | Key.GDK_lc_g => return gel.Keyboard.G;
      when Key.GDK_h | Key.GDK_lc_h => return gel.Keyboard.H;
      when Key.GDK_i | Key.GDK_lc_i => return gel.Keyboard.I;
      when Key.GDK_j | Key.GDK_lc_j => return gel.Keyboard.J;
      when Key.GDK_k | Key.GDK_lc_k => return gel.Keyboard.K;
      when Key.GDK_l | Key.GDK_lc_l => return gel.Keyboard.L;
      when Key.GDK_m | Key.GDK_lc_m => return gel.Keyboard.M;
      when Key.GDK_n | Key.GDK_lc_n => return gel.Keyboard.N;
      when Key.GDK_o | Key.GDK_lc_o => return gel.Keyboard.O;
      when Key.GDK_p | Key.GDK_lc_p => return gel.Keyboard.P;
      when Key.GDK_q | Key.GDK_lc_q => return gel.Keyboard.Q;
      when Key.GDK_r | Key.GDK_lc_r => return gel.Keyboard.R;
      when Key.GDK_s | Key.GDK_lc_s => return gel.Keyboard.S;
      when Key.GDK_t | Key.GDK_lc_t => return gel.Keyboard.T;
      when Key.GDK_u | Key.GDK_lc_u => return gel.Keyboard.U;
      when Key.GDK_v | Key.GDK_lc_v => return gel.Keyboard.V;
      when Key.GDK_w | Key.GDK_lc_w => return gel.Keyboard.W;
      when Key.GDK_x | Key.GDK_lc_x => return gel.Keyboard.X;
      when Key.GDK_y | Key.GDK_lc_y => return gel.Keyboard.Y;
      when Key.GDK_z | Key.GDK_lc_z => return gel.Keyboard.Z;

      when Key.GDK_caps_lock => return gel.Keyboard.CapsLock;

      when Key.GDK_F1  => return gel.Keyboard.F1;
      when Key.GDK_F2  => return gel.Keyboard.F2;
      when Key.GDK_F3  => return gel.Keyboard.F3;
      when Key.GDK_F4  => return gel.Keyboard.F4;
      when Key.GDK_F5  => return gel.Keyboard.F5;
      when Key.GDK_F6  => return gel.Keyboard.F6;
      when Key.GDK_F7  => return gel.Keyboard.F7;
      when Key.GDK_F8  => return gel.Keyboard.F8;
      when Key.GDK_F9  => return gel.Keyboard.F9;
      when Key.GDK_F10 => return gel.Keyboard.F10;
      when Key.GDK_F11 => return gel.Keyboard.F11;
      when Key.GDK_F12 => return gel.Keyboard.F12;

      when Key.GDK_print        => return gel.Keyboard.Print;
      when Key.GDK_scroll_lock  => return gel.Keyboard.ScrollLock;
      when Key.GDK_pause        => return gel.Keyboard.Pause;
      when Key.GDK_insert       => return gel.Keyboard.Insert;
      when Key.GDK_home         => return gel.Keyboard.Home;
      when Key.GDK_page_up      => return gel.Keyboard.PageUp;
      when Key.GDK_delete       => return gel.Keyboard.Delete;
      when Key.GDK_end          => return gel.Keyboard.End_key;
      when Key.GDK_page_down    => return gel.Keyboard.PageDown;
      when Key.GDK_right        => return gel.Keyboard.Right;
      when Key.GDK_left         => return gel.Keyboard.Left;
      when Key.GDK_down         => return gel.Keyboard.Down;
      when Key.GDK_up           => return gel.Keyboard.Up;

      when Key.GDK_num_lock     => return gel.Keyboard.NumLock;

      when Key.GDK_KP_Divide   => return gel.Keyboard.KP_Divide;
      when Key.GDK_KP_Multiply => return gel.Keyboard.KP_Multiply;
      when Key.GDK_KP_Subtract => return gel.Keyboard.KP_Minus;
      when Key.GDK_KP_Add      => return gel.Keyboard.KP_Plus;
      when Key.GDK_KP_Enter    => return gel.Keyboard.KP_Enter;
      when Key.GDK_KP_1        => return gel.Keyboard.KP1;
      when Key.GDK_KP_2        => return gel.Keyboard.KP2;
      when Key.GDK_KP_3        => return gel.Keyboard.KP3;
      when Key.GDK_KP_4        => return gel.Keyboard.KP4;
      when Key.GDK_KP_5        => return gel.Keyboard.KP5;
      when Key.GDK_KP_6        => return gel.Keyboard.KP6;
      when Key.GDK_KP_7        => return gel.Keyboard.KP7;
      when Key.GDK_KP_8        => return gel.Keyboard.KP8;
      when Key.GDK_KP_9        => return gel.Keyboard.KP9;
      when Key.GDK_KP_0        => return gel.Keyboard.KP0;
      when Key.GDK_KP_Decimal  => return gel.Keyboard.KP_Period;

         --  when Key.GDK_application     => return gel.Keyboard.;
         --  when Key.GDK_power           => return gel.Keyboard.Power;
      when Key.GDK_KP_equal        => return gel.Keyboard.KP_Equals;
      when Key.GDK_F13             => return gel.Keyboard.F13;
      when Key.GDK_F14             => return gel.Keyboard.F14;
      when Key.GDK_F15             => return gel.Keyboard.F15;
         --  when Key.GDK_F16             => return gel.Keyboard.;
         --  when Key.GDK_F17             => return gel.Keyboard.;
         --  when Key.GDK_F18             => return gel.Keyboard.;
         --  when Key.GDK_F19             => return gel.Keyboard.;
         --  when Key.GDK_F20             => return gel.Keyboard.;
         --  when Key.GDK_F21             => return gel.Keyboard.;
         --  when Key.GDK_F22             => return gel.Keyboard.;
         --  when Key.GDK_F23             => return gel.Keyboard.;
         --  when Key.GDK_F24             => return gel.Keyboard.;
         --  when Key.GDK_execute         => return gel.Keyboard.;
      when Key.GDK_help            => return gel.Keyboard.Help;
      when Key.GDK_menu            => return gel.Keyboard.Menu;
         --  when Key.GDK_select          => return gel.Keyboard.;
         --  when Key.GDK_stop            => return gel.Keyboard.;
         --  when Key.GDK_again           => return gel.Keyboard.;
      when Key.GDK_undo            => return gel.Keyboard.Undo;
         --  when Key.GDK_cut             => return gel.Keyboard.;
         --  when Key.GDK_copy            => return gel.Keyboard.;
         --  when Key.GDK_paste           => return gel.Keyboard.;
         --  when Key.GDK_find            => return gel.Keyboard.;
         --  when Key.GDK_mute            => return gel.Keyboard.;
         --  when Key.GDK_volume_up       => return gel.Keyboard.;
         --  when Key.GDK_volume_down     => return gel.Keyboard.;
         --  when Key.GDK_KP_comma        => return gel.Keyboard.;
         --  when Key.GDK_KP_equals_AS400 => return gel.Keyboard.;

         --  when Key.GDK_alt_erase   => return gel.Keyboard.;
      when Key.GDK_sys_req     => return gel.Keyboard.SysReq;
         --  when Key.GDK_cancel      => return gel.Keyboard.;
      when Key.GDK_clear       => return gel.Keyboard.Clear;
         --  when Key.GDK_prior       => return gel.Keyboard.;
         --  when Key.GDK_return_2    => return gel.Keyboard.;
         --  when Key.GDK_separator   => return gel.Keyboard.;
         --  when Key.GDK_out         => return gel.Keyboard.;
         --  when Key.GDK_oper        => return gel.Keyboard.;
         --  when Key.GDK_clear_again => return gel.Keyboard.;
         --  when Key.GDK_CR_sel      => return gel.Keyboard.;
         --  when Key.GDK_Ex_sel      => return gel.Keyboard.;

         --  when Key.GDK_KP_00                  => return gel.Keyboard.;
         --  when Key.GDK_KP_000                 => return gel.Keyboard.;
         --  when Key.GDK_thousands_separator    => return gel.Keyboard.;
         --  when Key.GDK_decimal_separator      => return gel.Keyboard.;
         --  when Key.GDK_currency_unit          => return gel.Keyboard.;
         --  when Key.GDK_KP_left_parenthesis    => return gel.Keyboard.;
         --  when Key.GDK_KP_right_parentheesis  => return gel.Keyboard.;
         --  when Key.GDK_KP_left_brace          => return gel.Keyboard.;
         --  when Key.GDK_KP_right_brace         => return gel.Keyboard.;
         --  when Key.GDK_KP_tab                 => return gel.Keyboard.;
         --  when Key.GDK_KP_backspace           => return gel.Keyboard.;
         --  when Key.GDK_KP_A                   => return gel.Keyboard.;
         --  when Key.GDK_KP_B                   => return gel.Keyboard.;
         --  when Key.GDK_KP_C                   => return gel.Keyboard.;
         --  when Key.GDK_KP_D                   => return gel.Keyboard.;
         --  when Key.GDK_KP_E                   => return gel.Keyboard.;
         --  when Key.GDK_KP_F                   => return gel.Keyboard.;
         --  when Key.GDK_KP_xor                 => return gel.Keyboard.;
         --  when Key.GDK_KP_power               => return gel.Keyboard.;
         --  when Key.GDK_KP_percent             => return gel.Keyboard.;
         --  when Key.GDK_KP_less                => return gel.Keyboard.;
         --  when Key.GDK_KP_greater             => return gel.Keyboard.;
         --  when Key.GDK_KP_ampersand           => return gel.Keyboard.;
         --  when Key.GDK_KP_double_ampersand    => return gel.Keyboard.;
         --  when Key.GDK_KP_vertical_bar        => return gel.Keyboard.;
         --  when Key.GDK_KP_double_vertical_bar => return gel.Keyboard.;
         --  when Key.GDK_KP_colon               => return gel.Keyboard.;
         --  when Key.GDK_KP_hash                => return gel.Keyboard.;
         --  when Key.GDK_KP_space               => return gel.Keyboard.;
         --  when Key.GDK_KP_at                  => return gel.Keyboard.;
         --  when Key.GDK_KP_exclamation         => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_store        => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_recall       => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_clear        => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_add          => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_subtract     => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_multiply     => return gel.Keyboard.;
         --  when Key.GDK_KP_memory_divide       => return gel.Keyboard.;
         --  when Key.GDK_KP_plus_minus          => return gel.Keyboard.;
         --  when Key.GDK_KP_clear               => return gel.Keyboard.;
         --  when Key.GDK_KP_clear_entry         => return gel.Keyboard.;
         --  when Key.GDK_KP_binary              => return gel.Keyboard.;
         --  when Key.GDK_KP_octal               => return gel.Keyboard.;
         --  when Key.GDK_KP_decimal             => return gel.Keyboard.;
         --  when Key.GDK_KP_hexadecimal         => return gel.Keyboard.;

      when Key.GDK_control_L  => return gel.Keyboard.lCtrl;
      when Key.GDK_shift_L    => return gel.Keyboard.lShift;
      when Key.GDK_alt_L      => return gel.Keyboard.lAlt;
      when Key.GDK_control_R  => return gel.Keyboard.rCtrl;
      when Key.GDK_shift_R    => return gel.Keyboard.rShift;
      when Key.GDK_alt_R      => return gel.Keyboard.rAlt;

         --  when Key.GDK_left_gui      => return gel.Keyboard.;
         --  when Key.GDK_right_gui     => return gel.Keyboard.;
         --  when Key.GDK_mode          => return gel.Keyboard.;

         --  when Key.GDK_audio_next     => return gel.Keyboard.;
         --  when Key.GDK_audio_previous => return gel.Keyboard.;
         --  when Key.GDK_audio_stop     => return gel.Keyboard.;
         --  when Key.GDK_audio_play     => return gel.Keyboard.;
         --  when Key.GDK_audio_mute     => return gel.Keyboard.;
         --  when Key.GDK_media_select   => return gel.Keyboard.;
         --  when Key.GDK_www            => return gel.Keyboard.;
         --  when Key.GDK_mail           => return gel.Keyboard.;
         --  when Key.GDK_calculator     => return gel.Keyboard.;
         --  when Key.GDK_computer       => return gel.Keyboard.;
         --  when Key.GDK_AC_search      => return gel.Keyboard.;
         --  when Key.GDK_AC_home        => return gel.Keyboard.;
         --  when Key.GDK_AC_back        => return gel.Keyboard.;
         --  when Key.GDK_AC_forward     => return gel.Keyboard.;
         --  when Key.GDK_AC_stop        => return gel.Keyboard.;
         --  when Key.GDK_AC_refresh     => return gel.Keyboard.;
         --  when Key.GDK_AC_bookmarks   => return gel.Keyboard.;

         --  when Key.GDK_brightness_down     => return gel.Keyboard.;
         --  when Key.GDK_brightness_up       => return gel.Keyboard.;
         --  when Key.GDK_display_switch      => return gel.Keyboard.;
         --  when Key.GDK_illumination_toggle => return gel.Keyboard.;
         --  when Key.GDK_illumination_down   => return gel.Keyboard.;
         --  when Key.GDK_illumination_up     => return gel.Keyboard.;
         --  when Key.GDK_eject               => return gel.Keyboard.;
         --  when Key.GDK_sleep               => return gel.Keyboard.;

      when others =>
         ada.Text_IO.put_Line ("Gtk window ~ unhandled key: " & From'Image);     -- TODO: Remaining key codes.
      end case;

      return gel.Keyboard.Key'First;
   end to_gel_Key;



   -------------------
   --- Window Creator
   --

   function window_Creator (Name          : in String;
                            Width, Height : in Positive) return gel.Window.view
   is
   begin
      return gel.Window.view (Forge.new_Window (Name, Width, Height));
   end window_Creator;



begin
   gel.Window.use_create_Window (window_Creator'Access);
end gel.Window.gtk;
