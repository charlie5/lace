package lace.text.Cursor
--
-- Provides a cursor for traversing and interrogating text.
--
is
   type Item is tagged private;


   -- Forge
   --

   function First (of_Text : access constant Text.item) return Cursor.item;


   -- Attributes
   --

   function  Length (Self : in Item) return Natural;
   --
   -- Returns the length of the remaining text.

   function  has_Element (Self : in     Item) return Boolean;

   function  next_Token  (Self : in out item;   Delimiter  : in Character := ' ';
                                                Trim       : in Boolean   := False) return String;
   function  next_Token  (Self : in out item;   Delimiter  : in String;
                                                match_Case : in Boolean   := True;
                                                Trim       : in Boolean   := False) return String;

   function  next_Line   (Self : in out item;   Trim       : in Boolean   := False) return String;

   procedure skip_Token  (Self : in out Item;   Delimiter  : in String    := " ";
                                                match_Case : in Boolean   := True);

   procedure skip_White  (Self : in out Item);
   procedure skip_Line   (Self : in out Item);

   procedure advance     (Self : in out Item;   Delimiter      : in String  := " ";
                                                Repeat         : in Natural := 0;
                                                skip_Delimiter : in Boolean := True;
                                                match_Case     : in Boolean := True);
   --
   -- Search begins at the cursors current position.
   -- Advances to the position immediately after Delimiter.
   -- Sets Iterator to 0 if Delimiter is not found.
   -- Search is repeated 'Repeat' times.

   function  get_Integer (Self : in out Item) return      Integer;
   function  get_Integer (Self : in out Item) return long_Integer;
   --
   -- Skips whitespace and reads the next legal 'integer' value.
   -- Cursor is positioned at the next character following the integer.
   -- Raises no_data_Error if no legal integer exists.

   function  get_Real (Self : in out Item) return long_Float;
   --
   -- Skips whitespace and reads the next legal 'real' value.
   -- Cursor is positioned at the next character following the real.
   -- Raises no_data_Error if no legal real exists.

   Remaining : constant Natural;
   function  peek      (Self : in Item;   Length : in Natural := Remaining) return String;
   function  peek_Line (Self : in Item)                                     return String;


   at_end_Error  : exception;
   no_data_Error : exception;



private

   type Item is tagged
      record
         Target  : access constant Text.item;
         Current : Natural  := 0;
      end record;

   Remaining : constant Natural := Natural'Last;

end lace.text.Cursor;
