with
     lace.Text.Cursor;


package body lace.Text.all_Tokens
is
   -----------------------
   --- Character Delimiter
   --

   function next_Token (Self : in Item;   Delimiter : in     Character;
                                          From      : in out Positive) return String
   is
      Cursor : Positive renames From;
   begin
      if Self.Data (Cursor) = Delimiter
      then
         Cursor := Cursor + 1;
         return "";

      elsif Cursor = Self.Length
      then
         Cursor := Cursor + 1;
         return Self.Data (Cursor - 1 .. Cursor - 1);

      else
         declare
            First : constant Positive := Cursor;
         begin
            loop
               Cursor := Cursor + 1;

               if Self.Data (Cursor) = Delimiter
               then
                  Cursor := Cursor + 1;
                  return Self.Data (First .. Cursor - 2);

               elsif Cursor = Self.Length
               then
                  Cursor := Cursor + 1;
                  return Self.Data (First .. Cursor - 1);
               end if;
            end loop;
         end;
      end if;
   end next_Token;



   generic
      Text_Capacity : Positive;
      type Component  is private;
      type Array_type is array (Positive range <>) of Component;

      with function any_to_Text (From : in String;   Capacity : in Natural;
                                                     Trim     : in Boolean := False) return Component;

   function any_Tokens_chr (Self : in Item;   Delimiter  : in Character := ' ';
                                              Trim       : in Boolean   := False;
                                              max_Tokens : in Positive  := 8 * 1024) return Array_type;



   function any_Tokens_chr (Self : in Item;   Delimiter  : in Character := ' ';
                                              Trim       : in Boolean   := False;
                                              max_Tokens : in Positive  := 8 * 1024) return Array_type
   is
      Count : Natural  := 0;
      From  : Positive := 1;
   begin
      -- Count the tokens, so the token array need be no larger than required.
      --
      while From <= Self.Length
      loop
         declare
            Token : constant String := next_Token (Self, Delimiter, From) with Unreferenced;
         begin
            Count := Count + 1;
         end;
      end loop;

      if         Self.Length > 0
        and then Self.Data (Self.Length) = Delimiter
      then                                                      -- Handle case where final character is the delimiter.
         Count := Count + 1;                                    -- Allow for an empty token.
      end if;

      if Count > max_Tokens
      then
         raise Error with   "Token count"
                          & Count'Image
                          & " exceeds max_Tokens"
                          & max_Tokens'Image
                          & ".";
      end if;

      declare
         the_Tokens : Array_type (1 .. Count);
         Index      : Natural := 0;
      begin
         From := 1;

         while From <= Self.Length
         loop
            Index              := Index + 1;
            the_Tokens (Index) := any_to_Text (next_Token (Self,
                                                           Delimiter,
                                                           From),
                                               Capacity => Text_Capacity,
                                               Trim     => Trim);
         end loop;

         if Index < Count
         then                                                      -- Final character is the delimiter.
            the_Tokens (Count) := any_to_Text ("", Capacity => Text_Capacity);     -- Add an empty token.
         end if;

         return the_Tokens;
      end;

   exception
      when storage_Error =>
         raise stack_Error with "Stack size exceeded. Increase stack size via '$ ulimit -s unlimited' or similar.";
   end any_Tokens_chr;



   function Tokens_1 is new any_Tokens_chr (Text_Capacity => 1,
                                            Component     => Text.item_1,
                                            Array_type    => Text.items_1,
                                            any_to_Text   => to_Text);

   function Tokens_2 is new any_Tokens_chr (Text_Capacity => 2,
                                            Component     => Text.item_2,
                                            Array_type    => Text.items_2,
                                            any_to_Text   => to_Text);

   function Tokens_4 is new any_Tokens_chr (Text_Capacity => 4,
                                            Component     => Text.item_4,
                                            Array_type    => Text.items_4,
                                            any_to_Text   => to_Text);

   function Tokens_8 is new any_Tokens_chr (Text_Capacity => 8,
                                            Component     => Text.item_8,
                                            Array_type    => Text.items_8,
                                            any_to_Text   => to_Text);

   function Tokens_16 is new any_Tokens_chr (Text_Capacity => 16,
                                             Component     => Text.item_16,
                                             Array_type    => Text.items_16,
                                             any_to_Text   => to_Text);

   function Tokens_32 is new any_Tokens_chr (Text_Capacity => 32,
                                             Component     => Text.item_32,
                                             Array_type    => Text.items_32,
                                             any_to_Text   => to_Text);

   function Tokens_64 is new any_Tokens_chr (Text_Capacity => 64,
                                             Component     => Text.item_64,
                                             Array_type    => Text.items_64,
                                             any_to_Text   => to_Text);

   function Tokens_128 is new any_Tokens_chr (Text_Capacity => 128,
                                              Component     => Text.item_128,
                                              Array_type    => Text.items_128,
                                              any_to_Text   => to_Text);

   function Tokens_256 is new any_Tokens_chr (Text_Capacity => 256,
                                              Component     => Text.item_256,
                                              Array_type    => Text.items_256,
                                              any_to_Text   => to_Text);

   function Tokens_512 is new any_Tokens_chr (Text_Capacity => 512,
                                              Component     => Text.item_512,
                                              Array_type    => Text.items_512,
                                              any_to_Text   => to_Text);

   function Tokens_1k is new any_Tokens_chr (Text_Capacity => 1024,
                                             Component     => Text.item_1k,
                                             Array_type    => Text.items_1k,
                                             any_to_Text   => to_Text);

   function Tokens_2k is new any_Tokens_chr (Text_Capacity => 2 * 1024,
                                             Component     => Text.item_2k,
                                             Array_type    => Text.items_2k,
                                             any_to_Text   => to_Text);

   function Tokens_4k is new any_Tokens_chr (Text_Capacity => 4 * 1024,
                                             Component     => Text.item_4k,
                                             Array_type    => Text.items_4k,
                                             any_to_Text   => to_Text);

   function Tokens_8k is new any_Tokens_chr (Text_Capacity => 8 * 1024,
                                             Component     => Text.item_8k,
                                             Array_type    => Text.items_8k,
                                             any_to_Text   => to_Text);

   function Tokens_16k is new any_Tokens_chr (Text_Capacity => 16 * 1024,
                                              Component     => Text.item_16k,
                                              Array_type    => Text.items_16k,
                                              any_to_Text   => to_Text);

   function Tokens_32k is new any_Tokens_chr (Text_Capacity => 32 * 1024,
                                              Component     => Text.item_32k,
                                              Array_type    => Text.items_32k,
                                              any_to_Text   => to_Text);

   function Tokens_64k is new any_Tokens_chr (Text_Capacity => 64 * 1024,
                                              Component     => Text.item_64k,
                                              Array_type    => Text.items_64k,
                                              any_to_Text   => to_Text);

   function Tokens_256k is new any_Tokens_chr (Text_Capacity => 256 * 1024,
                                               Component     => Text.item_256k,
                                               Array_type    => Text.items_256k,
                                               any_to_Text   => to_Text);

   function Tokens_128k is new any_Tokens_chr (Text_Capacity => 128 * 1024,
                                               Component     => Text.item_128k,
                                               Array_type    => Text.items_128k,
                                               any_to_Text   => to_Text);

   function Tokens_512k is new any_Tokens_chr (Text_Capacity => 512 * 1024,
                                               Component     => Text.item_512k,
                                               Array_type    => Text.items_512k,
                                               any_to_Text   => to_Text);


   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_1 renames Tokens_1;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_2 renames Tokens_2;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_4 renames Tokens_4;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_8 renames Tokens_8;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_16 renames Tokens_16;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_32 renames Tokens_32;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_64 renames Tokens_64;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_128 renames Tokens_128;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_256 renames Tokens_256;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_512 renames Tokens_512;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_1k renames Tokens_1k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_2k renames Tokens_2k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_4k renames Tokens_4k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_8k renames Tokens_8k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_16k renames Tokens_16k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_32k renames Tokens_32k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_64k renames Tokens_64k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_128k renames Tokens_128k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_256k renames Tokens_256k;

   function Tokens (Self : in Item;   Delimiter  : in Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return Text.items_512k renames Tokens_512k;


   --------------------
   --- String Delimiter
   --

   generic
      Text_Capacity : Positive;
      type Component  is private;
      type Array_type is array (Positive range <>) of Component;

      with function any_to_Text (From : in String;   Capacity : in Natural;
                                                     Trim     : in Boolean := False) return Component;

   function any_Tokens_str (Self : in Item;   Delimiter  : in String;
                                              Trim       : in Boolean  := False;
                                              max_Tokens : in Positive := default_Max) return Array_type;



   function any_Tokens_str (Self : in Item;   Delimiter  : in String;
                                              Trim       : in Boolean  := False;
                                              max_Tokens : in Positive := default_Max) return Array_type
   is
      use Text.Cursor;

      mySelf : aliased Item             := Self;
      Cursor :         Text.Cursor.item := First (mySelf'Access);
      Count  :         Natural          := 0;
   begin
      -- Count the tokens, so the token array need be no larger than required.
      --
      while Cursor.has_Element
      loop
         declare
            Token : constant String := Cursor.next_Token (Delimiter) with Unreferenced;
         begin
            Count := Count + 1;
         end;
      end loop;

      if         Self.Length > 0
        and then not Cursor.at_End
      then                                                      -- The scan ended by consuming a delimiter at the very end.
         Count := Count + 1;                                    -- Allow for a final empty token.
      end if;

      if Count > max_Tokens
      then
         raise Error with   "Token count"
                          & Count'Image
                          & " exceeds max_Tokens"
                          & max_Tokens'Image
                          & ".";
      end if;

      declare
         the_Tokens : Array_type (1 .. Count);
         Index      : Natural := 0;
      begin
         Cursor := First (mySelf'Access);

         while Cursor.has_Element
         loop
            Index              := Index + 1;
            the_Tokens (Index) := any_to_Text (Cursor.next_Token (Delimiter),
                                               Capacity => Text_Capacity,
                                               Trim     => Trim);
         end loop;

         if Index < Count
         then                                                      -- Final characters are the delimiter.
            the_Tokens (Count) := any_to_Text ("", Capacity => Text_Capacity);     -- Add an empty token.
         end if;

         return the_Tokens;
      end;

   exception
      when storage_Error =>
         raise stack_Error with "Stack size exceeded. Increase stack size via '$ ulimit -s unlimited' or similar.";
   end any_Tokens_str;



   function Tokens_1 is new any_Tokens_str (Text_Capacity => 1,
                                            Component     => Text.item_1,
                                            Array_type    => Text.items_1,
                                            any_to_Text   => to_Text);

   function Tokens_2 is new any_Tokens_str (Text_Capacity => 2,
                                            Component     => Text.item_2,
                                            Array_type    => Text.items_2,
                                            any_to_Text   => to_Text);

   function Tokens_4 is new any_Tokens_str (Text_Capacity => 4,
                                            Component     => Text.item_4,
                                            Array_type    => Text.items_4,
                                            any_to_Text   => to_Text);

   function Tokens_8 is new any_Tokens_str (Text_Capacity => 8,
                                            Component     => Text.item_8,
                                            Array_type    => Text.items_8,
                                            any_to_Text   => to_Text);

   function Tokens_16 is new any_Tokens_str (Text_Capacity => 16,
                                             Component     => Text.item_16,
                                             Array_type    => Text.items_16,
                                             any_to_Text   => to_Text);

   function Tokens_32 is new any_Tokens_str (Text_Capacity => 32,
                                             Component     => Text.item_32,
                                             Array_type    => Text.items_32,
                                             any_to_Text   => to_Text);

   function Tokens_64 is new any_Tokens_str (Text_Capacity => 64,
                                             Component     => Text.item_64,
                                             Array_type    => Text.items_64,
                                             any_to_Text   => to_Text);

   function Tokens_128 is new any_Tokens_str (Text_Capacity => 128,
                                              Component     => Text.item_128,
                                              Array_type    => Text.items_128,
                                              any_to_Text   => to_Text);

   function Tokens_256 is new any_Tokens_str (Text_Capacity => 256,
                                              Component     => Text.item_256,
                                              Array_type    => Text.items_256,
                                              any_to_Text   => to_Text);

   function Tokens_512 is new any_Tokens_str (Text_Capacity => 512,
                                              Component     => Text.item_512,
                                              Array_type    => Text.items_512,
                                              any_to_Text   => to_Text);

   function Tokens_1k is new any_Tokens_str (Text_Capacity => 1024,
                                             Component     => Text.item_1k,
                                             Array_type    => Text.items_1k,
                                             any_to_Text   => to_Text);

   function Tokens_2k is new any_Tokens_str (Text_Capacity => 2 * 1024,
                                             Component     => Text.item_2k,
                                             Array_type    => Text.items_2k,
                                             any_to_Text   => to_Text);

   function Tokens_4k is new any_Tokens_str (Text_Capacity => 4 * 1024,
                                             Component     => Text.item_4k,
                                             Array_type    => Text.items_4k,
                                             any_to_Text   => to_Text);

   function Tokens_8k is new any_Tokens_str (Text_Capacity => 8 * 1024,
                                             Component     => Text.item_8k,
                                             Array_type    => Text.items_8k,
                                             any_to_Text   => to_Text);

   function Tokens_16k is new any_Tokens_str (Text_Capacity => 16 * 1024,
                                              Component     => Text.item_16k,
                                              Array_type    => Text.items_16k,
                                              any_to_Text   => to_Text);

   function Tokens_32k is new any_Tokens_str (Text_Capacity => 32 * 1024,
                                              Component     => Text.item_32k,
                                              Array_type    => Text.items_32k,
                                              any_to_Text   => to_Text);

   function Tokens_64k is new any_Tokens_str (Text_Capacity => 64 * 1024,
                                              Component     => Text.item_64k,
                                              Array_type    => Text.items_64k,
                                              any_to_Text   => to_Text);

   function Tokens_128k is new any_Tokens_str (Text_Capacity => 128 * 1024,
                                               Component     => Text.item_128k,
                                               Array_type    => Text.items_128k,
                                               any_to_Text   => to_Text);

   function Tokens_256k is new any_Tokens_str (Text_Capacity => 256 * 1024,
                                               Component     => Text.item_256k,
                                               Array_type    => Text.items_256k,
                                               any_to_Text   => to_Text);

   function Tokens_512k is new any_Tokens_str (Text_Capacity => 512 * 1024,
                                               Component     => Text.item_512k,
                                               Array_type    => Text.items_512k,
                                               any_to_Text   => to_Text);


   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_1 renames Tokens_1;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_2 renames Tokens_2;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_4 renames Tokens_4;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_8 renames Tokens_8;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_16 renames Tokens_16;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_32 renames Tokens_32;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_64 renames Tokens_64;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_128 renames Tokens_128;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_256 renames Tokens_256;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_512 renames Tokens_512;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_1k renames Tokens_1k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_2k renames Tokens_2k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_4k renames Tokens_4k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_8k renames Tokens_8k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_16k renames Tokens_16k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_32k renames Tokens_32k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_64k renames Tokens_64k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_128k renames Tokens_128k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_256k renames Tokens_256k;

   function Tokens (Self : in Item;   Delimiter  : in String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return Text.items_512k renames Tokens_512k;


end lace.Text.all_Tokens;
