package body XML.Writer
is
   use ada.Text_IO;


   function escaped (Text : in String;   in_Attribute : in Boolean := False) return String
   is
      Result : unbounded_String;
   begin
      for Each of Text
      loop
         case Each
         is
            when '&'    =>   append (Result, "&amp;");
            when '<'    =>   append (Result, "&lt;");
            when '>'    =>   append (Result, "&gt;");
            when '"'    =>   append (Result, (if in_Attribute then "&quot;" else """"));
            when others =>   append (Result, Each);
         end case;
      end loop;

      return to_String (Result);
   end escaped;



   function Image (Atts : in Attributes_t) return String
   is
      Result : unbounded_String;
   begin
      for Each of Atts
      loop
         append (Result,   " "
                         & to_String (Each.Name)
                         & "="""
                         & escaped (to_String (Each.Value), in_Attribute => True)
                         & """");
      end loop;

      return to_String (Result);
   end Image;



   procedure indent (Self : in Item)
   is
   begin
      for Each in 1 .. Self.Depth
      loop
         put (Self.File.all, "   ");
      end loop;
   end indent;



   procedure end_open_Tag (Self : in out Item)
   --
   -- Ends the line of a start tag when the next output goes on a line of its own.
   --
   is
   begin
      if Self.open_Tag
      then
         new_Line (Self.File.all);
         Self.open_Tag := False;
      end if;
   end end_open_Tag;



   procedure start_Document (Self : in out Item;   File : in ada.Text_IO.File_access)
   is
   begin
      Self.File     := File;
      Self.Depth    := 0;
      Self.open_Tag := False;

      put_Line (Self.File.all, "<?xml version=""1.0"" standalone=""yes""?>");
   end start_Document;



   procedure end_Document (Self : in out Item)
   is
   begin
      if Self.Depth /= 0
      then
         raise unbalanced_Error with Self.Depth'Image & " element(s) still open";
      end if;
   end end_Document;



   procedure start (Self : in out Item;   Name : in String;
                                          Atts : in Attributes_t := no_Attributes)
   is
   begin
      Self.end_open_Tag;
      Self.indent;

      put (Self.File.all, "<" & Name & Image (Atts) & ">");

      Self.Depth    := Self.Depth + 1;
      Self.open_Tag := True;
   end start;



   procedure finish (Self : in out Item;   Name : in String)
   is
   begin
      if Self.Depth = 0
      then
         raise unbalanced_Error with "'" & Name & "' finished with no element open";
      end if;

      Self.Depth := Self.Depth - 1;

      if Self.open_Tag
      then
         Self.open_Tag := False;
      else
         Self.indent;
      end if;

      put_Line (Self.File.all, "</" & Name & ">");
   end finish;



   procedure empty (Self : in out Item;   Name : in String;
                                          Atts : in Attributes_t := no_Attributes)
   is
   begin
      Self.end_open_Tag;
      Self.indent;

      put_Line (Self.File.all, "<" & Name & Image (Atts) & "/>");
   end empty;



   procedure put (Self : in out Item;   Data : in String)
   is
   begin
      if Self.open_Tag
      then
         put (Self.File.all, escaped (Data));
      else
         Self.indent;
         put_Line (Self.File.all, escaped (Data));
      end if;
   end put;



   function "+" (Name, Value : in String) return Attribute_t
   is
   begin
      return (Name  => to_unbounded_String (Name),
              Value => to_unbounded_String (Value));
   end "+";


end XML.Writer;
