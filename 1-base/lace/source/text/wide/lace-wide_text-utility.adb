with
     ada.Strings.wide_fixed,
     ada.Strings.wide_unbounded;


package body lace.wide_Text.utility
is

   function contains (Self : in wide_Text.item;   Pattern : in wide_String) return Boolean
   is
      use ada.Strings.wide_fixed;
   begin
      return Index (+Self, Pattern) /= 0;
   end contains;



   function replace (Self : in wide_Text.item;   Pattern : in wide_String;
                                                 By      : in wide_String) return wide_Text.item
   is
      use ada.Strings.wide_unbounded;

      Result : unbounded_wide_String;
      First  : Positive := 1;
   begin
      if Pattern = ""
      then
         return Self;
      end if;

      while First <= Self.Length
      loop
         if          First + Pattern'Length - 1 <= Self.Length
            and then Self.Data (First .. First + Pattern'Length - 1) = Pattern
         then
            append (Result, By);
            First := First + Pattern'Length;

         else
            append (Result, Self.Data (First));
            First := First + 1;
         end if;
      end loop;

      declare
         Image : constant wide_String := to_wide_String (Result);
      begin
         return to_Text (Image, Capacity => Natural'Max (Image'Length,
                                                         Self.Capacity));
      end;
   end replace;



   procedure replace (Self : in out Item;   Pattern : in wide_String;
                                            By      : in wide_String)
   is
      Result : Item (Self.Capacity);

      Cursor : Positive := 1;
      First  : Natural  := 1;
      Last   : Natural;
   begin
      if Pattern = ""
      then
         return;
      end if;

      while First <= Self.Length
      loop
         Last := First + Pattern'Length - 1;

         if Last > Self.Length
         then
            Last := Self.Length;
         end if;

         if Self.Data (First .. Last) = Pattern
         then
            Result.Data (Cursor .. Cursor + By'Length - 1) := By;
            Cursor                                         := Cursor + By'Length;
            First                                          := Last + 1;

         else
            Result.Data (Cursor) := Self.Data (First);
            Cursor               := Cursor + 1;
            First                := First  + 1;
         end if;
      end loop;

      Self.Length                  := Cursor - 1;
      Self.Data (1 .. Self.Length) := Result.Data (1 .. Self.Length);

   exception
      when constraint_Error =>
         raise wide_Text.Error with "'replace' failed ~ insufficient capacity";
   end replace;


end lace.wide_Text.utility;
