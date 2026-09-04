private
with
     ada.Exceptions;

with
     System;


package XML.Reader
--
-- Binds the expat parser. The handlers are called back from within 'parse'; an
-- exception raised by a handler stops the parse and is re-raised by 'parse'.
--
is
   type Parser is private;


   ---------
   --- Forge
   --

   function  new_Parser return Parser;
   procedure free (Self : in out Parser);


   --------------
   --- Attributes
   --

   type start_element_Handler  is access procedure (Name : in String;
                                                    Atts : in Attributes_t);
   type end_element_Handler    is access procedure (Name : in String);
   type character_data_Handler is access procedure (Data : in String);


   procedure set_Element_Handler        (Self          : in Parser;
                                         start_Handler : in start_element_Handler;
                                         end_Handler   : in end_element_Handler);

   procedure set_Character_Data_Handler (Self          : in Parser;
                                         data_Handler  : in character_data_Handler);


   --------------
   --- Operations
   --

   procedure parse (Self     : in Parser;
                    Text     : in String;
                    is_Final : in Boolean);
   --
   -- Raises parse_Error, with the line and column, when the text is not well-formed.



private

   type Parser_Rec is limited
      record
         Expat         : System.Address;                     -- The expat 'XML_Parser'.
         start_Handler : start_element_Handler;
         end_Handler   : end_element_Handler;
         data_Handler  : character_data_Handler;
         Failure       : ada.Exceptions.Exception_Occurrence; -- Raised by a handler, re-raised by 'parse'.
      end record;

   type Parser is access Parser_Rec;

end XML.Reader;
