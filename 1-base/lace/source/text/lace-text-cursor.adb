with
     ada.Characters.latin_1,
     ada.Characters.handling,
     ada.Strings.fixed,
     ada.Strings.Maps.Constants;

--  with ada.text_IO; use ada.Text_IO;


package body lace.text.Cursor
is
   use ada.Strings;

   Integer_Numerals : constant maps.character_Set := maps.to_Set ("+-0123456789");
   Float_Numerals   : constant maps.character_Set := maps.to_Set ("+-0123456789.");


   --------
   -- Forge
   --

   function First (of_Text : access constant Text.item) return Cursor.item
   is
      the_Cursor : constant Cursor.item := (of_Text.all'unchecked_Access, 1);
   begin
      return the_Cursor;
   end First;


   -------------
   -- Attributes
   --

   function at_End (Self : in Item) return Boolean
   is
   begin
      return Self.Current = 0;
   end at_End;


   function has_Element (Self : in Item) return Boolean
   is
   begin
      return not at_End (Self)
        and      Self.Current <= Self.Target.Length;
   end has_Element;


   procedure advance (Self : in out Item;   Delimiter      : in String  := " ";
                                            Repeat         : in Natural := 0;
                                            skip_Delimiter : in Boolean := True;
                                            match_Case     : in Boolean := True)
   is
   begin
      for Count in 1 .. Repeat + 1
      loop
         declare
            use ada.Characters.handling;
            delimiter_Position : Natural;
         begin
            if match_Case
            then
               delimiter_Position := fixed.Index (Self.Target.Data (1 .. Self.Target.Length),
                                                  Delimiter,
                                                  From => Self.Current);
            else
               delimiter_Position := fixed.Index (to_Lower (Self.Target.Data (1 .. Self.Target.Length)),
                                                  to_Lower (Delimiter),
                                                  From => Self.Current);
            end if;

            if delimiter_Position = 0
            then
               Self.Current := 0;
               return;
            else
               if skip_Delimiter
               then
                  Self.Current := delimiter_Position + Delimiter'Length;

               elsif Count = Repeat + 1
               then
                  Self.Current := delimiter_Position;

               else
                  Self.Current := delimiter_Position + Delimiter'Length - 1;
               end if;
            end if;
         end;
      end loop;

   exception
      when constraint_Error =>
         raise at_end_Error;
   end advance;



   procedure skip_White (Self : in out Item)
   is
   begin
      while      has_Element (Self)
        and then (    Self.Target.Data (Self.Current) = ' '
                  or  Self.Target.Data (Self.Current) = ada.Characters.Latin_1.LF
                  or  Self.Target.Data (Self.Current) = ada.Characters.Latin_1.HT)
      loop
         Self.Current := Self.Current + 1;
      end loop;
   end skip_White;



   procedure skip_Line (Self : in out Item)
   is
      Line : String := next_Line (Self) with Unreferenced;
   begin
      null;
   end skip_Line;



   function next_Token (Self      : in out Item;
                        Delimiter : in     Character := ' ';
                        Trim      : in     Boolean   := False) return String
   is
   begin
      return next_Token (Self, "" & Delimiter, Trim);
   end next_Token;



   function next_Token (Self : in out item;   Delimiter  : in String;
                                              match_Case : in Boolean := True;
                                              Trim       : in Boolean := False) return String
   is
      use ada.Characters.handling;
   begin
      if at_End (Self)
      then
         raise at_end_Error;
      end if;

      declare
         function get_String return String
         is
            use ada.Strings.fixed,
                ada.Strings.Maps.Constants;
            delimiter_Position : constant Natural := (if match_Case then Index (Self.Target.Data (Self.Current .. Self.Target.Length),           Delimiter,  from => Self.Current)
                                                                    else Index (Self.Target.Data (Self.Current .. Self.Target.Length), to_Lower (Delimiter), from => Self.Current,
                                                                                                                                       mapping => lower_case_Map));
         begin
            if delimiter_Position = 0
            then
               return the_Token : constant String := (if Trim then fixed.Trim (Self.Target.Data (Self.Current .. Self.Target.Length), Both)
                                                              else             Self.Target.Data (Self.Current .. Self.Target.Length))
               do
                  Self.Current := 0;
               end return;
            end if;

            return the_Token : constant String := (if Trim then fixed.Trim (Self.Target.Data (Self.Current .. delimiter_Position - 1), Both)
                                                           else             Self.Target.Data (Self.Current .. delimiter_Position - 1))
            do
               Self.Current := delimiter_Position + Delimiter'Length;
            end return;
         end get_String;


         unslid_String : constant String                             := get_String;
         slid_String   : constant String (1 .. unslid_String'Length) := unslid_String;

      begin
         return slid_String;
      end;
   end next_Token;



   function next_Line (Self : in out Item;   Trim : in Boolean := False) return String
   is
      use ada.Characters;
      Token : constant String := next_Token (Self, Delimiter => latin_1.LF,
                                                   Trim      => Trim);
      Pad   : constant String := Token; --(if Token (Token'Last) = latin_1.CR then Token (Token'First .. Token'Last - 1)
                                          --                           else Token);
   begin
      if Trim then return fixed.Trim (Pad, Both);
              else return Pad;
      end if;
   end next_Line;



   procedure skip_Token (Self : in out Item;   Delimiter  : in String    := " ";
                                               match_Case : in Boolean   := True)
   is
      ignored_Token : String := Self.next_Token (Delimiter, match_Case);
   begin
      null;
   end skip_Token;



   function get_Integer (Self : in out Item) return Integer
   is
      use ada.Strings.fixed;

      Text  : String (1 .. Self.Length);
      First : Positive;
      Last  : Natural;
   begin
      Text := Self.Target.Data (Self.Current .. Self.Target.Length);
      find_Token (Text, integer_Numerals, Inside, First, Last);

      if Last = 0 then
         raise No_Data_Error;
      end if;

      Self.Current := Self.Current + Last;

      return Integer'Value (Text (First .. Last));
   end get_Integer;



   function get_Integer (Self : in out Item) return long_Integer
   is
      use ada.Strings.fixed;

      Text  : String (1 .. Self.Length);
      First : Positive;
      Last  : Natural;
   begin
      Text := Self.Target.Data (Self.Current .. Self.Target.Length);
      find_Token (Text, integer_Numerals, Inside, First, Last);

      if Last = 0 then
         raise No_Data_Error;
      end if;

      Self.Current := Self.Current + Last;

      return long_Integer'Value (Text (First .. Last));
   end get_Integer;



   function get_Real (Self : in out Item) return long_Float
   is
      use ada.Strings.fixed;

      Text  : String (1 .. Self.Length);
      First : Positive;
      Last  : Natural;
   begin
      Text := Self.Target.Data (Self.Current .. Self.Target.Length);
      find_Token (Text, float_Numerals, Inside, First, Last);

      if Last = 0 then
         raise No_Data_Error;
      end if;

      Self.Current := Self.Current + Last;

      return long_Float'Value (Text (First .. Last));
   end get_Real;



   function Length (Self : in Item) return Natural
   is
   begin
      return Self.Target.Length - Self.Current + 1;
   end Length;



   function peek (Self : in Item;   Length : in Natural := Remaining) return String
   is
      Last : Natural := (if Length = Remaining then Self.Target.Length
                                               else Self.Current + Length - 1);
   begin
      if at_End (Self)
      then
         return "";
      end if;

      Last := Natural'Min (Last,
                           Self.Target.Length);

      return Self.Target.Data (Self.Current .. Last);
   end peek;



   function peek_Line (Self : in Item) return String
   is
      C : Cursor.item := Self;
   begin
      return next_Line (C);
   end peek_Line;


end lace.text.Cursor;
