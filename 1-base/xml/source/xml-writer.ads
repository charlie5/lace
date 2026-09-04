with
     ada.Text_IO;


package XML.Writer
--
-- Writes an XML document to a text file, indenting nested elements. Character
-- data put directly after a start tag stays on the tag's line.
--
is
   type Item is tagged limited private;


   procedure start_Document (Self : in out Item;   File : in ada.Text_IO.File_access);
   --
   -- Writes the XML declaration to the file, which must be open for output.

   procedure end_Document   (Self : in out Item);
   --
   -- Raises unbalanced_Error if any element is still open.


   procedure start  (Self : in out Item;   Name : in String;
                                           Atts : in Attributes_t := no_Attributes);
   procedure finish (Self : in out Item;   Name : in String);

   procedure empty  (Self : in out Item;   Name : in String;
                                           Atts : in Attributes_t := no_Attributes);

   procedure put    (Self : in out Item;   Data : in String);
   --
   -- Writes character data, escaped.


   function "+" (Name, Value : in String) return Attribute_t;
   --
   -- An attribute, for aggregates such as ["id" + "1", "name" + "box"].


   unbalanced_Error : exception;



private

   type Item is tagged limited
      record
         File     : ada.Text_IO.File_access;
         Depth    : Natural := 0;
         open_Tag : Boolean := False;     -- The cursor sits on the line of a start tag.
      end record;

end XML.Writer;
