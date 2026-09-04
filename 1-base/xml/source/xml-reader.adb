with
     ada.unchecked_Conversion,
     ada.unchecked_Deallocation,
     interfaces.C.Strings,
     system.Storage_Elements;


package body XML.Reader
is
   package C renames interfaces.C;
   package S renames interfaces.C.Strings;

   use ada.Exceptions;


   -------------
   --- Expat API
   --

   XML_STATUS_OK : constant C.int := 1;     -- Of 'enum XML_Status'.


   function  XML_ParserCreate (Encoding : in S.chars_ptr) return System.Address;
   pragma import (C, XML_ParserCreate, "XML_ParserCreate");

   procedure XML_ParserFree (Expat : in System.Address);
   pragma import (C, XML_ParserFree, "XML_ParserFree");

   procedure XML_SetUserData (Expat     : in System.Address;
                              user_Data : in Parser);
   pragma import (C, XML_SetUserData, "XML_SetUserData");

   function  XML_Parse (Expat    : in System.Address;
                        Text     : in System.Address;
                        Length   : in C.int;
                        is_Final : in C.int) return C.int;
   pragma import (C, XML_Parse, "XML_Parse");

   procedure XML_StopParser (Expat     : in System.Address;
                             Resumable : in C.unsigned_char);
   pragma import (C, XML_StopParser, "XML_StopParser");

   function  XML_GetErrorCode (Expat : in System.Address) return C.int;
   pragma import (C, XML_GetErrorCode, "XML_GetErrorCode");

   function  XML_ErrorString (Code : in C.int) return S.chars_ptr;
   pragma import (C, XML_ErrorString, "XML_ErrorString");

   function  XML_GetCurrentLineNumber (Expat : in System.Address) return C.unsigned_long;
   pragma import (C, XML_GetCurrentLineNumber, "XML_GetCurrentLineNumber");

   function  XML_GetCurrentColumnNumber (Expat : in System.Address) return C.unsigned_long;
   pragma import (C, XML_GetCurrentColumnNumber, "XML_GetCurrentColumnNumber");



   ------------
   --- Handlers
   --

   procedure fail (Self : in Parser;   Error : in Exception_Occurrence)
   --
   -- Keeps the first exception raised by a handler and stops expat, so that no
   -- exception crosses its C frames; 'parse' re-raises it.
   --
   is
   begin
      if exception_Identity (Self.Failure) = Null_Id
      then
         save_Occurrence (Self.Failure, Error);
      end if;

      XML_StopParser (Self.Expat, Resumable => 0);
   end fail;



   procedure start_Handler (Self : in Parser;
                            Name : in S.chars_ptr;
                            Atts : in System.Address);
   pragma Convention (C, start_Handler);

   procedure start_Handler (Self : in Parser;
                            Name : in S.chars_ptr;
                            Atts : in System.Address)
   --
   -- 'Atts' is a null-terminated array of name and value string pointers.
   --
   is
      use System,
          System.Storage_Elements;
      use type S.chars_ptr;

      type chars_ptr_view is access all S.chars_ptr;
      function to_View is new ada.unchecked_Conversion (System.Address, chars_ptr_view);

      pointer_Size : constant Storage_Offset := S.chars_ptr'Size / System.Storage_Unit;


      function attribute_Count return Natural
      is
         Count   : Natural := 0;
         Address : System.Address := Atts;
      begin
         while to_View (Address).all /= S.null_ptr
         loop
            Count   := Count   + 1;
            Address := Address + 2 * pointer_Size;
         end loop;

         return Count;
      end attribute_Count;


      the_Attributes : Attributes_t (1 .. attribute_Count);
      Address        : System.Address := Atts;

   begin
      for Each of the_Attributes
      loop
         Each.Name  := to_unbounded_String (S.Value (to_View (Address).all));
         Address    := Address + pointer_Size;

         Each.Value := to_unbounded_String (S.Value (to_View (Address).all));
         Address    := Address + pointer_Size;
      end loop;

      Self.start_Handler (S.Value (Name), the_Attributes);

   exception
      when E : others =>
         fail (Self, E);
   end start_Handler;



   procedure end_Handler (Self : in Parser;
                          Name : in S.chars_ptr);
   pragma Convention (C, end_Handler);

   procedure end_Handler (Self : in Parser;
                          Name : in S.chars_ptr)
   is
   begin
      Self.end_Handler (S.Value (Name));

   exception
      when E : others =>
         fail (Self, E);
   end end_Handler;



   procedure data_Handler (Self   : in Parser;
                           Data   : in System.Address;
                           Length : in C.int);
   pragma Convention (C, data_Handler);

   procedure data_Handler (Self   : in Parser;
                           Data   : in System.Address;
                           Length : in C.int)
   --
   -- 'Data' is not null-terminated.
   --
   is
      the_Data : String (1 .. Natural (Length))
        with Import, Address => Data;
   begin
      Self.data_Handler (the_Data);

   exception
      when E : others =>
         fail (Self, E);
   end data_Handler;



   ---------
   --- Forge
   --

   function new_Parser return Parser
   is
      Self : constant Parser := new Parser_Rec;
   begin
      Self.Expat := XML_ParserCreate (S.null_ptr);
      save_Occurrence (Self.Failure, Null_Occurrence);

      XML_SetUserData (Self.Expat, Self);
      return Self;
   end new_Parser;



   procedure free (Self : in out Parser)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Parser_Rec, Parser);
   begin
      if Self /= null
      then
         XML_ParserFree (Self.Expat);
         deallocate (Self);
      end if;
   end free;



   --------------
   --- Attributes
   --

   procedure set_Element_Handler (Self          : in Parser;
                                  start_Handler : in start_element_Handler;
                                  end_Handler   : in end_element_Handler)
   is
      type start_Callback is access procedure (Self : in Parser;
                                               Name : in S.chars_ptr;
                                               Atts : in System.Address);
      pragma Convention (C, start_Callback);

      type end_Callback   is access procedure (Self : in Parser;
                                               Name : in S.chars_ptr);
      pragma Convention (C, end_Callback);

      procedure XML_SetElementHandler (Expat : in System.Address;
                                       Start : in start_Callback;
                                       Stop  : in end_Callback);
      pragma import (C, XML_SetElementHandler, "XML_SetElementHandler");

   begin
      Self.start_Handler := start_Handler;
      Self.end_Handler   := end_Handler;

      XML_SetElementHandler (Self.Expat, Reader.start_Handler'Access,
                                         Reader.end_Handler  'Access);
   end set_Element_Handler;



   procedure set_Character_Data_Handler (Self         : in Parser;
                                         data_Handler : in character_data_Handler)
   is
      type data_Callback is access procedure (Self   : in Parser;
                                              Data   : in System.Address;
                                              Length : in C.int);
      pragma Convention (C, data_Callback);

      procedure XML_SetCharacterDataHandler (Expat : in System.Address;
                                             Data  : in data_Callback);
      pragma import (C, XML_SetCharacterDataHandler, "XML_SetCharacterDataHandler");

   begin
      Self.data_Handler := data_Handler;
      XML_SetCharacterDataHandler (Self.Expat, Reader.data_Handler'Access);
   end set_Character_Data_Handler;



   --------------
   --- Operations
   --

   procedure parse (Self     : in Parser;
                    Text     : in String;
                    is_Final : in Boolean)
   is
      use type C.int;

      Status : constant C.int := XML_Parse (Self.Expat,
                                            Text'Address,
                                            C.int (Text'Length),
                                            Boolean'Pos (is_Final));
   begin
      if exception_Identity (Self.Failure) /= Null_Id
      then
         declare
            Failure : Exception_Occurrence;
         begin
            save_Occurrence (Failure,      Self.Failure);
            save_Occurrence (Self.Failure, Null_Occurrence);
            reraise_Occurrence (Failure);
         end;
      end if;

      if Status /= XML_STATUS_OK
      then
         raise parse_Error with   "line"     & XML_GetCurrentLineNumber   (Self.Expat)'Image
                                & ", column" & XML_GetCurrentColumnNumber (Self.Expat)'Image
                                & ": "       & S.Value (XML_ErrorString (XML_GetErrorCode (Self.Expat)));
      end if;
   end parse;


end XML.Reader;
