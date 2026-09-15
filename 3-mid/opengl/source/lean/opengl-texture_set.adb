with
     ada.unchecked_Deallocation;


package body openGL.texture_Set
is
   procedure free is new ada.unchecked_Deallocation (Animation, Animation_view);


   --------------------
   --- Animation holder
   --

   overriding
   procedure Adjust (Self : in out animation_Holder)
   is
   begin
      if Self.View /= null
      then
         Self.View := new Animation' (Self.View.all);
      end if;
   end Adjust;



   overriding
   procedure Finalize (Self : in out animation_Holder)
   is
   begin
      free (Self.View);
   end Finalize;



   procedure write (Stream : not null access ada.Streams.Root_Stream_Type'Class;
                    Item   : in              animation_Holder)
   is
   begin
      Animation_view'write (Stream, Item.View);
   end write;



   procedure read (Stream : not null access ada.Streams.Root_Stream_Type'Class;
                   Item   : out             animation_Holder)
   is
   begin
      Animation_view'read (Stream, Item.View);
   end read;



   -------------
   --- Animation
   --

   function to_Frames (From : in texture_Set.texture_Ids) return Frames
   is
      Result : Frames (1 .. From'Length);
   begin
      for i in From'Range
      loop
         Result (i).texture_Id := From (i);
      end loop;

      return Result;
   end to_Frames;



   procedure animate (Self : in out Item)
   is
      use ada.Calendar;

      Now : constant ada.Calendar.Time := Clock;

   begin
      if Now >= Self.Animation.View.next_frame_Time
      then
         declare
            the_Animation : Animation renames Self.Animation.View.all;

            next_frame_Id : constant frame_Id := (if the_Animation.Current < the_Animation.frame_Count then the_Animation.Current + 1
                                                                                                       else 1);
            old_Frame     :          Frame renames the_Animation.Frames (the_Animation.Current);
            new_Frame     :          Frame renames the_Animation.Frames (next_frame_Id);
         begin
            Self.Details (detail_Count (old_Frame.texture_Id)).texture_Apply := False;
            Self.Details (detail_Count (new_Frame.texture_Id)).texture_Apply := True;

            the_Animation.Current         := next_frame_Id;
            the_Animation.next_frame_Time := Now + the_Animation.frame_Duration;
         end;
      end if;
   end animate;


   ---------
   --- Forge
   --

   function to_Set (texture_Assets  : in asset_Names;
                    texture_Tilings : in Tilings        := [others => (S => 1.0,
                                                                       T => 1.0)];
                    Animation       : in Animation_view := null) return Item
   is
      Result : Item (Count => texture_Assets'Length);

   begin
      for i in 1 .. Result.Count
      loop
         Result.Details (i).Object         := texture.null_Object;
         Result.Details (i).Texture        := texture_Assets (Integer (i));
         Result.Details (i).Fade           := 0.0;
         Result.Details (i).texture_Tiling := texture_Tilings (texture_Id (i));

         if i = 1
         then
            Result.Details (i).texture_Apply := True;
         else
            Result.Details (i).texture_Apply := False;
         end if;
      end loop;

      Result.Animation.View := Animation;     -- Now the set's own.

      return Result;
   end to_Set;


   -----------
   --- Streams
   --

   procedure write (Stream : not null access ada.Streams.Root_Stream_Type'Class;
                    Item   : in              Animation_view)
   is
   begin
      if Item = null
      then
         Boolean'write (Stream, False);
      else
         Boolean'write (Stream, True);
         Animation'output (Stream, Item.all);
      end if;
   end write;



   procedure read (Stream : not null access ada.Streams.Root_Stream_Type'Class;
                   Item   : out             Animation_view)
   is
      Item_not_null : Boolean;
   begin
      Boolean'read (Stream, Item_not_null);

      if Item_not_null
      then
         Item := new Animation' (Animation'input (Stream));
      else
         Item := null;
      end if;
   end read;


end openGL.texture_Set;
