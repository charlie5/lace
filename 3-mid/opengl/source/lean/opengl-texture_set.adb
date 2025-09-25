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



   procedure animate (the_Animation   : in out Animation;
                      texture_Applies : in out texture_Apply_array)
   is
      use ada.Calendar;

      Now : constant ada.Calendar.Time := Clock;

   begin
      if Now >= the_Animation.next_frame_Time
      then
         declare
            next_frame_Id : constant frame_Id := (if the_Animation.Current < the_Animation.frame_Count then the_Animation.Current + 1
                                                                                                       else 1);
            old_Frame     :          Frame renames the_Animation.Frames (the_Animation.Current);
            new_Frame     :          Frame renames the_Animation.Frames (next_frame_Id);
         begin
            texture_Applies (old_Frame.texture_Id) := False;
            texture_Applies (new_Frame.texture_Id) := True;

            the_Animation.Current         := next_frame_Id;
            the_Animation.next_frame_Time := Now + the_Animation.frame_Duration;
         end;
      end if;
   end animate;




   -----------
   --- Details
   --

   function to_Details (texture_Assets : in asset_Names;
                        Animation      : in Animation_view := null) return Details
   is
      Result : Details;
   begin
      Result.texture_Count := texture_Assets'Length;

      for i in 1 .. texture_Assets'Length
      loop
         Result.Textures (i) := texture_Assets (i);
      end loop;

      Result.Animation := Animation;

      return Result;
   end to_Details;




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
