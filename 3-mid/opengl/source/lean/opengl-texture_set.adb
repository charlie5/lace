with
     openGL.Tasks,

     GL.Binding,
     GL.lean,

     ada.Strings.fixed;

with ada.Text_IO;   use ada.Text_IO;


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

      Now           : constant ada.Calendar.Time := Clock;

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
   --
   --  type Details is
   --     record
   --        Fades           : fade_Levels                (texture_Id)       := [others => 0.0];
   --        Textures        : asset_Names (1 .. Positive (texture_Id'Last)) := [others => null_Asset];     -- The textures to be applied to the hex.
   --        texture_Count   : Natural                                       := 0;
   --        texture_Tiling  : Real                                          := 1.0;                        -- The number of times the texture should be wrapped.
   --        texture_Applies : texture_Apply_array                           := [others => True];
   --        Animation       : Animation_view;
   --     end record;
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





   --------
   --- Item
   --

   procedure Texture_is (in_Set : in out Item;   Which : texture_ID;   Now : in openGL.Texture.Object)
   is
   begin
      in_Set.Textures (Which).Object := Now;

      in_Set.is_Transparent   :=    in_Set.is_Transparent
                                 or Now   .is_Transparent;

      if Natural (Which) > in_Set.Count
      then
         in_Set.Count := Natural (Which);
      end if;
   end Texture_is;




   function Texture (in_Set : in  Item;   Which : texture_ID) return openGL.Texture.Object
   is
   begin
      return in_Set.Textures (Which).Object;
   end Texture;




   function Texture (in_Set : in Item) return openGL.Texture.Object
   is
   begin
      return in_Set.Textures (1).Object;
   end Texture;




   procedure Texture_is (in_Set : in out Item;   Now : in openGL.Texture.Object)
   is
   begin
      in_Set.Textures (1).Object := Now;
      in_Set.is_Transparent      :=    in_Set.is_Transparent
                                    or Now .is_Transparent;

      if in_Set.Count = 0
      then
         in_Set.Count := 1;
      end if;
   end Texture_is;



   procedure enable (the_Textures : in out Item;
                     Program      : in     openGL.Program.view)
   is
      use GL,
          GL.Binding,
          openGL.Texture;

   begin
      Tasks.check;

      if not the_Textures.initialised
      then
         for i in 1 .. the_Textures.Count
         loop
            declare
               use ada.Strings,
                   ada.Strings.fixed;

               Id : constant texture_Id := texture_Id (i);
            begin
               null;

               --  declare
               --     uniform_Name : aliased constant String :="Textures[" & Trim (Natural'Image (i - 1), Left) & "]";
               --  begin
               --     the_Textures.Textures (Id).texture_Uniform := Program.uniform_Variable (Named => uniform_Name);
               --  end;

               --  declare
               --     uniform_Name : constant String := "Fade[" & Trim (Natural'Image (i - 1), Left) & "]";
               --  begin
               --     the_Textures.Textures (Id).fade_Uniform := Program.uniform_Variable (Named => uniform_Name);
               --  end;
            end;
         end loop;

         the_Textures.Initialised := True;
      end if;


      for i in 1 .. the_Textures.Count
      loop
         declare
            use GL.lean;

            use type GL.GLint;

            type texture_Units is array (texture_Id) of GLenum;

            all_texture_Units : constant texture_Units := (GL_TEXTURE0,
                                                           GL_TEXTURE1,
                                                           GL_TEXTURE2,
                                                           GL_TEXTURE3,
                                                           GL_TEXTURE4,
                                                           GL_TEXTURE5,
                                                           GL_TEXTURE6,
                                                           GL_TEXTURE7,
                                                           GL_TEXTURE8,
                                                           GL_TEXTURE9,
                                                           GL_TEXTURE10,
                                                           GL_TEXTURE11,
                                                           GL_TEXTURE12,
                                                           GL_TEXTURE13,
                                                           GL_TEXTURE14,
                                                           GL_TEXTURE15,
                                                           GL_TEXTURE16,
                                                           GL_TEXTURE17,
                                                           GL_TEXTURE18,
                                                           GL_TEXTURE19,
                                                           GL_TEXTURE20,
                                                           GL_TEXTURE21,
                                                           GL_TEXTURE22,
                                                           GL_TEXTURE23,
                                                           GL_TEXTURE24,
                                                           GL_TEXTURE25,
                                                           GL_TEXTURE26,
                                                           GL_TEXTURE27,
                                                           GL_TEXTURE28,
                                                           GL_TEXTURE29,
                                                           GL_TEXTURE30,
                                                           GL_TEXTURE31);

            Id : constant texture_Id := texture_Id (i);
         begin
            null;
            --  glUniform1i     (the_Textures.Textures (Id).texture_Uniform.gl_Variable,
            --                   GLint (i) - 1);
            --  glActiveTexture (all_texture_Units (Id));
            --  glBindTexture   (GL_TEXTURE_2D,
            --                   the_Textures.Textures (Id).Object.Name);
         end;


         --  declare
         --     use ada.Strings,
         --         ada.Strings.fixed;
         --
         --     uniform_Name : constant String                        := "Fade[" & Trim (Natural'Image (i - 1), Left) & "]";
         --     Uniform      : constant openGL.Variable.uniform.float := Program.uniform_Variable (uniform_Name);
         --     Id : constant texture_Id := texture_Id (i);
         --  begin
         --     --  put_Line ("Fade:" & the_Textures.Textures (texture_Id (i)).Fade'Image);
         --
         --     --  the_Textures.Textures (Id).fade_Uniform.Value_is (Real (the_Textures.Textures (texture_Id (i)).Fade));
         --     --  Uniform.Value_is (Real (the_Textures.Textures (texture_Id (i)).Fade));
         --     null;
         --  end;
      end loop;


      --  declare
      --     the_texture_count_Uniform : constant openGL.Variable.uniform.int := Program.uniform_Variable ("texture_Count");
      --  begin
      --     the_texture_count_Uniform.Value_is (the_Textures.Count);
      --  end;
   end enable;



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
