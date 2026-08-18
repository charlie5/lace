with
     ada.Text_IO,
     xml.Writer;


procedure launch_Write
is
   use ada.Text_IO, xml.Writer;

begin
   start_Document (standard_Output);

   start  (standard_Output, "foo",  "bar" + "bing");
   empty  (standard_Output, "frodo", MkAtt ("hobbit" + "true", "ring" + "1") & ("purpose" + "To rule them all."));
   finish (standard_Output, "foo");

   end_Document (standard_Output);
end launch_Write;
