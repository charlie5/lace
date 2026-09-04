with
     xml.Writer,
     ada.Text_IO;


procedure launch_Write
is
   use xml.Writer;

   the_Writer : xml.Writer.item;

begin
   the_Writer.start_Document (ada.Text_IO.standard_Output);

   the_Writer.start  ("foo",   ["bar" + "bing"]);
   the_Writer.empty  ("frodo", ["hobbit"  + "true",
                                "ring"    + "1",
                                "purpose" + "To rule them all."]);
   the_Writer.start  ("gollum");
   the_Writer.put    ("My <precious> & mine!");
   the_Writer.finish ("gollum");
   the_Writer.finish ("foo");

   the_Writer.end_Document;
end launch_Write;
