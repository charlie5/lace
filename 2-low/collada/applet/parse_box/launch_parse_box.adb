with
     collada.Document;


procedure launch_parse_Box
--
-- Loads an xml file, parses it into a collada document.
--
is
   the_Document : collada.Document.item := collada.Document.to_Document ("./box.dae");
begin
   the_Document.destroy;
end launch_parse_Box;
