with
     openGL.Camera,
     openGL.Texture,

     ada.unchecked_Deallocation;


package body openGL.Impostor.terrain
is

   overriding
   procedure set_Target (Self : in out Item;   Target : in openGL.Visual.view)
   is
   begin
      set_Target (openGL.impostor.item (Self), Target);     -- Base class call.

      Self.expand_X := 0.02;
      Self.expand_Y := 0.02;
   end set_Target;



   procedure free (Self : in out View)
   is

      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      destroy    (Self.all);
      deallocate (Self);
   end free;



   overriding
   function current_Camera_look_at_Rotation (Self : in Item) return Matrix_3x3
   is
   begin
      return Self.current_Camera_look_at_Rotation;
   end current_Camera_look_at_Rotation;



   overriding
   function update_Required (Self : access Item;   the_Camera : access Camera.item'Class) return Boolean
   is
   begin
      Self.current_pixel_Region := Self.get_pixel_Region (camera_Spin                 => the_Camera.Spin,
                                                          camera_Site                 => the_Camera.Site,
                                                          camera_projection_Transform => the_Camera.projection_Transform,
                                                          camera_Viewport             => the_Camera.Viewport);
      declare
         use GL;

         use type GL.glInt;

         update_Required : Boolean    := Self.general_Update_required (the_Camera.Site, Self.current_pixel_Region);

         copy_x_Offset   : gl.glInt   := 0;
         copy_y_Offset   : gl.glInt   := 0;
         copy_X          : gl.glInt   := Self.current_pixel_Region.X;
         copy_Y          : gl.glInt   := Self.current_pixel_Region.Y;
         copy_Width      : gl.glSizeI := Self.current_pixel_Region.Width;
         copy_Height     : gl.glSizeI := Self.current_pixel_Region.Height;

         viewport_Width  : constant Integer := the_Camera.Viewport.Max (1) - the_Camera.Viewport.Min (1) + 1;
         viewport_Height : constant Integer := the_Camera.Viewport.Max (2) - the_Camera.Viewport.Min (2) + 1;

         complete_Left   : Boolean;
         complete_Right  : Boolean;
         complete_Top    : Boolean;
         complete_Bottom : Boolean;
         now_Complete    : Boolean;

      begin
         if copy_X < 0
         then
            copy_x_Offset := -copy_X;
            copy_X        := 0;
            copy_Width    := copy_Width - glSizeI (copy_x_Offset);

            complete_Left  := False;
            complete_Right := True;

            if copy_Width < 1
            then
               Self.is_Valid := False;
               return False;             -- NB: Short circuit return !
            end if;

         elsif copy_X + glInt (copy_Width) >  glInt (Viewport_Width)
         then
            copy_Width     := glSizeI (viewport_Width) - glSizeI (copy_X);

            complete_Left  := True;
            complete_Right := False;

            if copy_Width < 1
            then
               Self.is_Valid := False;
               return False;             -- NB: Short circuit return !
            end if;

         else
            complete_Left  := True;
            complete_Right := True;
         end if;


         if copy_Y < 0
         then
            copy_y_Offset := -copy_Y;
            copy_Y        := 0;
            copy_Height   := copy_Height - glSizeI (copy_y_Offset);

            complete_Top    := True;
            complete_Bottom := False;

            if copy_Height < 1
            then
               Self.is_Valid := False;
               return False;             -- NB: Short circuit return !
            end if;

         elsif copy_Y + glInt (copy_Height)  >  glInt (Viewport_Height)
         then
            copy_Height     := glSizeI (viewport_Height) - glSizeI (copy_Y);

            complete_Top    := False;
            complete_Bottom := True;

            if copy_Height < 1
            then
               Self.is_Valid := False;
               return False;             -- NB: Short circuit return !
            end if;

         else
            complete_Top    := True;
            complete_Bottom := True;
         end if;

         now_Complete :=     complete_Left
                         and complete_Right
                         and complete_Top
                         and complete_Bottom;

         if not update_Required
         then   -- Only do further tests if update not already required.
            if Self.prior_Complete
            then
               if         now_Complete
                 and then Self.size_Update_required (Self.current_pixel_Region)
               then
                  update_Required := True;
               end if;

            else
               if copy_Width > Self.prior_copy_Width
               then
                  update_Required := True;
               end if;

               if copy_Height > Self.prior_copy_Height
               then
                  update_Required := True;
               end if;
            end if;
         end if;


         if update_Required
         then
            Self.current_Width_pixels  := Self.current_pixel_Region.Width;       -- Cache current state.
            Self.current_Height_pixels := Self.current_pixel_Region.Height;

            Self.current_copy_X_Offset := copy_X_Offset;
            Self.current_copy_Y_Offset := copy_Y_Offset;

            Self.current_copy_X := copy_X;
            Self.current_copy_Y := copy_Y;

            Self.current_copy_Width  := copy_Width;
            Self.current_copy_Height := copy_Height;

            Self.current_Complete      := now_Complete;

            Self.prior_copy_Width  := Self.current_copy_Width;               -- Set prior state.
            Self.prior_copy_Height := Self.current_copy_Height;
            Self.prior_Complete    := Self.current_Complete;
         end if;

         Self.is_Valid                        := True;
         Self.current_Camera_look_at_Rotation := the_Camera.Spin;

         return update_Required;
      end;
   end update_Required;



   overriding
   procedure pre_update (Self : in out Item;   the_Camera : access Camera.item'Class)
   is
      pragma unreferenced (the_Camera);
   begin
      Self.expand_X := 0.0;
      Self.expand_Y := 0.0;
   end pre_update;



   overriding
   procedure update (Self : in out Item;   the_Camera   : access Camera.item'Class;
                                           texture_Pool : in     Texture.Pool_view)
   is
   begin
      Self.expand_X := 0.0;
      Self.expand_Y := 0.0;

      Impostor.item (Self).update (the_Camera, texture_Pool);     -- Base class 'update'.
   end update;



   overriding
   procedure post_update (Self : in out Item;   the_Camera : access Camera.item'Class)
   is
   begin
      null;
   end post_update;


end openGL.Impostor.terrain;
