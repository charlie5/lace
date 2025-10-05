package body openGL.texture_Set
is

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



   --  procedure animate (the_Animation   : in out Animation;
   --                     texture_Applies : in out texture_Apply_array)
   --  is
   --     use ada.Calendar;
   --
   --     Now : constant ada.Calendar.Time := Clock;
   --
   --  begin
   --     if Now >= the_Animation.next_frame_Time
   --     then
   --        declare
   --           next_frame_Id : constant frame_Id := (if the_Animation.Current < the_Animation.frame_Count then the_Animation.Current + 1
   --                                                                                                      else 1);
   --           old_Frame     :          Frame renames the_Animation.Frames (the_Animation.Current);
   --           new_Frame     :          Frame renames the_Animation.Frames (next_frame_Id);
   --        begin
   --           texture_Applies (old_Frame.texture_Id) := False;
   --           texture_Applies (new_Frame.texture_Id) := True;
   --
   --           the_Animation.Current         := next_frame_Id;
   --           the_Animation.next_frame_Time := Now + the_Animation.frame_Duration;
   --        end;
   --     end if;
   --  end animate;



   procedure animate (Self : in out Item)
   is
      use ada.Calendar;

      Now : constant ada.Calendar.Time := Clock;

   begin
      if Now >= Self.Animation.next_frame_Time
      then
         declare
            next_frame_Id : constant frame_Id := (if Self.Animation.Current < Self.Animation.frame_Count then Self.Animation.Current + 1
                                                                                                         else 1);
            old_Frame     :          Frame renames Self.Animation.Frames (Self.Animation.Current);
            new_Frame     :          Frame renames Self.Animation.Frames (next_frame_Id);
         begin
            Self.Details (detail_Count (old_Frame.texture_Id)).texture_Apply := False;
            Self.Details (detail_Count (new_Frame.texture_Id)).texture_Apply := True;

            Self.Animation.Current         := next_frame_Id;
            Self.Animation.next_frame_Time := Now + Self.Animation.frame_Duration;
         end;
      end if;
   end animate;



   -----------
   --- Details
   --

   --  function to_Details (texture_Assets : in asset_Names;
   --                       Animation      : in Animation_view := null) return Details
   --  is
   --     Result : Details;
   --  begin
   --     Result.texture_Count := texture_Assets'Length;
   --
   --     for i in 1 .. texture_Assets'Length
   --     loop
   --        Result.Textures (i) := texture_Assets (i);
   --     end loop;
   --
   --     Result.Animation := Animation;
   --
   --     return Result;
   --  end to_Details;



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

      Result.Animation := Animation;

      return Result;
   end to_Set;



   --------------
   --- Attributes
   --

   --  function get_Details (Self : in Item) return Detail_array
   --  is
   --  begin
   --     return Self.Details;
   --  end get_Details;
   --
   --
   --
   --  procedure Details_are (Self : in out Item;   Now : in Detail_array)
   --  is
   --  begin
   --     Self.Details := Now;
   --  end Details_are;
   --
   --
   --
   --  function get_Animation (Self : in Item) return Animation_view
   --  is
   --  begin
   --     return Self.Animation;
   --  end get_Animation;
   --
   --
   --
   --  procedure Animation_is (Self : in out Item;   Now : in Animation_view)
   --  is
   --  begin
   --     Self.Animation := Now;
   --  end Animation_is;



   -----------
   --- Streams
   --

   procedure write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
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



   procedure read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                   Item   : out             Animation_view)
   is
      Item_not_null : Boolean;
   begin
      Boolean'read (Stream, Item_not_null);

      if Item_not_null
      then
         Item := new Animation' (Animation'Input (Stream));
      else
         Item := null;
      end if;
   end read;


end openGL.texture_Set;
