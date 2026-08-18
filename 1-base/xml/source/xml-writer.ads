with
     ada.Strings.unbounded,
     ada.Text_IO;


package XML.Writer
is
   use ada.Strings.unbounded;


   procedure start_Document (F : in ada.Text_IO.File_type);
   procedure end_Document   (F : in ada.Text_IO.File_type);

   procedure start (F     : in ada.Text_IO.File_type;
                    Name  : in String;
                    Atts  : in Attributes_view);

   procedure start (F     : in ada.Text_IO.File_type;
                    Name  : in unbounded_String;
                    Atts  : in Attributes_view);

   procedure finish (F    : in ada.Text_IO.File_type;
                     Name : in String);

   procedure finish (F    : in ada.Text_IO.File_type;
                     Name : in unbounded_String);

   procedure empty (F     : in ada.Text_IO.File_type;
                    Name  : in String;
                    Atts  : in Attributes_view);

   procedure empty (F     : in ada.Text_IO.File_type;
                    Name  : in unbounded_String;
                    Atts  : in Attributes_view);

   function "+"    (K, V : in String)                                  return Attribute_t;
   function "+"    (K, V : in String)                                  return Attributes_view;
   function "+"    (K    : in unbounded_String;
                    V    : in String)                                  return Attribute_t;
   function "+"    (K    : in unbounded_String;
                    V    : in String)                                  return Attributes_view;
   function "+"    (K    : in String;
                    V    : in unbounded_String)                        return Attribute_t;
   function "+"    (K    : in String;
                    V    : in unbounded_String)                        return Attributes_view;

   function MkAtt  (L, R : in Attribute_t)                             return Attributes_view;
   function "&"    (L, R : in Attribute_t)                             return Attributes_view;
   function "&"    (L    : in Attributes_view;   R : in Attribute_t)   return Attributes_view;


end XML.Writer;
