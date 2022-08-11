with
     ada.Characters.latin_1,
     ada.Characters.handling,
     ada.Strings.fixed,
     ada.Strings.Maps;

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
                                            Case_sensitive : in Boolean := True)
   is
   begin
      for Count in 1 .. Repeat + 1
      loop
         declare
            use ada.Characters.handling;
            delimiter_Position : Natural;
         begin
            if Case_sensitive
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
                  Self.Current := delimiter_Position - 1;

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
                  or  Self.Target.Data (Self.Current) = ada.Characters.Latin_1.CR
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


   function  next_Token  (Self : in out item;   Delimiter : in String;
                                                Trim      : in Boolean := False) return String
   is
   begin
      if at_End (Self)
      then
         raise at_end_Error;
      end if;

      declare
         use ada.Strings.fixed;
         delimiter_Position : constant Natural := Index (Self.Target.Data, Delimiter, from => Self.Current);
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
      end;
   end next_Token;



   function next_Line (Self : in out item;   Trim : in Boolean := False) return String
   is
      use ada.Characters;
      Token : constant String := next_Token (Self, Delimiter => latin_1.LF,
                                                   Trim      => Trim);
   begin
      if Token (Token'Last) = latin_1.CR
      then
         return Token (Token'First .. Token'Last - 1);
      else
         return Token;
      end if;
   end next_Line;



   procedure skip_Token (Self : in out Item;   Delimiter : in String := " ")
   is
      ignored_Token : String := Self.next_Token (Delimiter);
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
      Last : constant Natural := (if Length = Natural'Last then Self.Target.Length
                                                           else Self.Current + Length - 1);
   begin
      if at_End (Self)
      then
         return "";
      end if;

      return Self.Target.Data (Self.Current .. Last);
   end peek;



   function peek_Line (Self : in Item) return String
   is
      C : Cursor.item := Self;
   begin
      return next_Line (C);
   end peek_Line;


end lace.text.Cursor;
