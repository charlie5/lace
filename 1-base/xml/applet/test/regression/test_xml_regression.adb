with
     XML,
     xml.Reader,
     xml.Writer,

     ada.Command_Line,
     ada.Directories,
     ada.Exceptions,
     ada.Streams.Stream_IO,
     ada.Strings.fixed,
     ada.Text_IO;


procedure test_xml_Regression
--
-- Regression tests for the defects recorded in FIXES.md.
--
is
   use ada.Text_IO,
       ada.Exceptions;

   use type xml.Element_view;

   Failures : Natural := 0;

   procedure check (Ok : in Boolean;   Label : in String)
   is
   begin
      if Ok
      then
         put_Line ("PASS: " & Label);
      else
         Failures := Failures + 1;
         put_Line ("FAIL: " & Label);
      end if;
   end check;


   Root : constant String := ada.Directories.current_Directory & "/work";


   procedure write (Filename : in String;   Text : in String)
   is
      File : File_type;
   begin
      create (File, out_File, Root & "/" & Filename);
      put (File, Text);
      close (File);
   end write;


   function contains (Text, Pattern : in String) return Boolean
   is (ada.Strings.fixed.Index (Text, Pattern) /= 0);


   function contents_of (Filename : in String) return String
   is
      File : ada.Streams.Stream_IO.File_type;
   begin
      ada.Streams.Stream_IO.open (File, ada.Streams.Stream_IO.in_File, Root & "/" & Filename);

      return Result : String (1 .. Natural (ada.Streams.Stream_IO.Size (File)))
      do
         String'Read (ada.Streams.Stream_IO.Stream (File), Result);
         ada.Streams.Stream_IO.close (File);
      end return;
   end contents_of;


   LF : constant Character := ASCII.LF;

begin
   if ada.Directories.Exists (Root)
   then
      ada.Directories.delete_Tree (Root);
   end if;

   ada.Directories.create_Path (Root);

   put_Line ("Begin Test");
   new_Line;


   --- The tree (H1, H2, M1, M7, L6, L7 and entity decoding).
   --
   write ("tree.xml",   "<?xml version=""1.0""?>" & LF
                      & "<doc a=""1"" b=""two"">" & LF
                      & "  <nums>1.0" & LF & "2.0" & LF & "3.0</nums>" & LF
                      & "  <t>a &amp; b &lt; c</t>" & LF
                      & "  <empty/>" & LF
                      & "</doc>" & LF);
   declare
      the_Doc  : xml.Element_view := xml.to_XML (Root & "/tree.xml");
      the_Nums : constant xml.Element_view := the_Doc.Child ("nums");
      the_T    : constant xml.Element_view := the_Doc.Child ("t");
   begin
      check (the_Doc.Name = "doc",                               "tree: to_XML returns the document element");
      check (the_Doc.Parent = null,                              "tree: the document element has no parent");
      check (the_Doc.Children'Length = 3,                        "tree: the document element's children");
      check (the_Nums /= null and then the_Nums.Parent = the_Doc, "tree: a child's parent is its element");
      check (the_Nums.Data = "1.0" & LF & "2.0" & LF & "3.0",    "tree: character data keeps its line breaks");
      check (the_T.Data = "a & b < c",                           "tree: entities are decoded");
      check (the_Doc.Data = "",                                  "tree: whitespace-only data is dropped");
      check (the_Doc.Child ("empty").Data = "",                  "tree: an empty element has empty data");
      check (the_Doc.Child ("nowhere") = null,                   "tree: a missing child is null");
      check (the_Doc.Attributes'Length = 2,                      "tree: attributes of the document element");
      check (the_Doc.Attribute ("b").Value = "two",              "tree: attribute lookup by name");
      check (the_Doc.Attribute ("x") = null,                     "tree: a missing attribute is null");
      check (the_Nums.Attributes'Length = 0,                     "tree: an element without attributes has none");
      check (the_Doc.Children ("nums")'Length = 1,               "tree: children by name");

      xml.free (the_Doc);
      check (the_Doc = null,                                     "tree: free nulls the view");
   end;


   --- Errors (M3).
   --
   write ("empty.xml", "");
   write ("bad.xml",   "<doc>" & LF & "  <a>" & LF & "</doc>" & LF);

   declare
      procedure expect_parse_Error (Filename, Fragment, Label : in String)
      is
         the_Doc : xml.Element_view;
      begin
         the_Doc := xml.to_XML (Root & "/" & Filename);
         xml.free (the_Doc);
         check (False, Label);
      exception
         when E : xml.parse_Error =>
            check (contains (exception_Message (E), Fragment) and then contains (exception_Message (E), Filename),
                   Label);
      end expect_parse_Error;
   begin
      expect_parse_Error ("empty.xml", "no element found",  "errors: an empty file is a parse error naming the file");
      expect_parse_Error ("bad.xml",   "line 3, column 2",  "errors: a malformed file reports its line and column");

      begin
         declare
            the_Doc : xml.Element_view := xml.to_XML (Root & "/missing.xml");
         begin
            xml.free (the_Doc);
            check (False, "errors: a missing file raises Name_Error");
         end;
      exception
         when ada.Directories.Name_Error =>
            check (True, "errors: a missing file raises Name_Error");
      end;
   end;


   --- The reader (L1, L5).
   --
   declare
      use xml.Reader;

      the_Parser : Parser := new_Parser;

      Names      : Natural := 0;
      Attributes : Natural := 0;
      Data       : Natural := 0;

      procedure Starter (Name : in String;   Atts : in xml.Attributes_t)
      is
      begin
         Names      := Names      + 1;
         Attributes := Attributes + Atts'Length;

         if Name = "boom"
         then
            raise Constraint_Error with "handler failed";
         end if;
      end Starter;

      procedure Ender (Name : in String)
      is
         pragma Unreferenced (Name);
      begin
         null;
      end Ender;

      procedure data_Handler (Text : in String)
      is
      begin
         Data := Data + Text'Length;
      end data_Handler;

   begin
      set_Element_Handler        (the_Parser, Starter'unrestricted_Access, Ender'unrestricted_Access);
      set_Character_Data_Handler (the_Parser, data_Handler'unrestricted_Access);

      parse (the_Parser, "<a x=""1"" y=""2""><b>hi</b>", is_Final => False);
      parse (the_Parser, "</a>",                          is_Final => True);

      check (Names = 2 and Attributes = 2 and Data = 2, "reader: handlers see elements, attributes and data across chunks");
      free (the_Parser);

      the_Parser := new_Parser;
      set_Element_Handler (the_Parser, Starter'unrestricted_Access, Ender'unrestricted_Access);

      begin
         parse (the_Parser, "<a><boom/><c/></a>", is_Final => True);
         check (False, "reader: an exception in a handler is re-raised by parse");
      exception
         when E : Constraint_Error =>
            check (exception_Message (E) = "handler failed", "reader: an exception in a handler is re-raised by parse");
      end;

      free (the_Parser);
   end;


   --- The writer (M4, M5, M6) and a round trip.
   --
   declare
      use xml.Writer;

      the_Writer : xml.Writer.item;
      File       : aliased File_type;
   begin
      create (File, out_File, Root & "/written.xml");

      the_Writer.start_Document (File'unchecked_Access);
      the_Writer.start  ("foo", ["bar" + "bing", "quote" + "say ""hi"" & <bye>"]);
      the_Writer.empty  ("frodo", ["ring" + "1"]);
      the_Writer.start  ("gollum");
      the_Writer.put    ("My <precious> & mine!");
      the_Writer.finish ("gollum");
      the_Writer.start  ("lines");
      the_Writer.put    ("one" & LF & "two");
      the_Writer.finish ("lines");
      the_Writer.finish ("foo");
      the_Writer.end_Document;

      close (File);

      declare
         Expected : constant String :=   "<?xml version=""1.0"" standalone=""yes""?>" & LF
                                       & "<foo bar=""bing"" quote=""say &quot;hi&quot; &amp; &lt;bye&gt;"">" & LF
                                       & "   <frodo ring=""1""/>" & LF
                                       & "   <gollum>My &lt;precious&gt; &amp; mine!</gollum>" & LF
                                       & "   <lines>one" & LF & "two</lines>" & LF
                                       & "</foo>" & LF;
      begin
         check (contents_of ("written.xml") = Expected, "writer: escaping, inline text and indentation");
      end;

      declare
         the_Doc : xml.Element_view := xml.to_XML (Root & "/written.xml");
      begin
         check (the_Doc.Attribute ("quote").Value = "say ""hi"" & <bye>",          "writer: escaped attributes read back");
         check (the_Doc.Child ("gollum").Data     = "My <precious> & mine!",       "writer: escaped text reads back");
         check (the_Doc.Child ("lines") .Data     = "one" & LF & "two",            "writer: text line breaks survive a round trip");
         xml.free (the_Doc);
      end;

      declare
         the_Writer : xml.Writer.item;
         Scratch    : aliased File_type;
      begin
         create (Scratch, out_File, Root & "/unbalanced.xml");
         the_Writer.start_Document (Scratch'unchecked_Access);
         the_Writer.start ("a");

         begin
            the_Writer.end_Document;
            check (False, "writer: end_Document with an element open raises unbalanced_Error");
         exception
            when unbalanced_Error =>
               check (True, "writer: end_Document with an element open raises unbalanced_Error");
         end;

         the_Writer.finish ("a");

         begin
            the_Writer.finish ("b");
            check (False, "writer: finish with nothing open raises unbalanced_Error");
         exception
            when unbalanced_Error =>
               check (True, "writer: finish with nothing open raises unbalanced_Error");
         end;

         close (Scratch);
      end;
   end;


   ada.Directories.delete_Tree (Root);

   new_Line;

   if Failures = 0
   then
      put_Line ("Success");
   else
      put_Line ("Failures:" & Failures'Image);
      ada.Command_Line.set_Exit_Status (1);
   end if;

   put_Line ("End Test");
end test_xml_Regression;
