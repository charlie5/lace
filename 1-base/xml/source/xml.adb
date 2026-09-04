with
     xml.Reader,

     ada.Streams.Stream_IO,
     ada.Directories,
     ada.Exceptions,
     ada.unchecked_Deallocation;


package body XML
is

   ------------------
   --- Attribute type
   --

   function no_Attributes return Attributes_t
   is
   begin
      return [];
   end no_Attributes;



   function Name (Self : in Attribute_t) return String
   is
   begin
      return to_String (Self.Name);
   end Name;



   function Value (Self : in Attribute_t) return String
   is
   begin
      return to_String (Self.Value);
   end Value;


   ----------------
   --- Element type
   --

   --- Forge
   --

   type String_view is access String;

   procedure free is new ada.unchecked_Deallocation (String,       String_view);
   procedure free is new ada.unchecked_Deallocation (Attributes_t, Attributes_view);
   procedure deallocate is new ada.unchecked_Deallocation (Element, Element_view);



   function text_of (Filename : in String) return String_view
   --
   -- Returns the whole file, which is parsed in one call: parsing it line by line
   -- would lose the line terminators inside character data.
   --
   is
      use ada.Streams,
          ada.Streams.Stream_IO;

      Size     : constant ada.Directories.File_Size := ada.Directories.Size (Filename);
      the_Text :          String_view := new String (1 .. Natural (Size));
      the_File :          File_type;
   begin
      declare
         the_Buffer : Stream_Element_Array (1 .. Stream_Element_Offset (Size))
           with Import, Address => the_Text.all'Address;
         Last       : Stream_Element_Offset;
      begin
         open (the_File, In_File, Filename);
         read (the_File, the_Buffer, Last);
         close (the_File);

         if Last /= the_Buffer'Last
         then
            raise End_Error with Filename & ": short read";
         end if;
      end;

      return the_Text;

   exception
      when others =>
         if is_Open (the_File)
         then
            close (the_File);
         end if;

         free (the_Text);
         raise;
   end text_of;



   function is_Whitespace (Text : in unbounded_String) return Boolean
   is
   begin
      for i in 1 .. Length (Text)
      loop
         if ada.Strings.unbounded.Element (Text, i) not in ' ' | ASCII.HT | ASCII.LF | ASCII.CR
         then
            return False;
         end if;
      end loop;

      return True;
   end is_Whitespace;



   function to_XML (Filename : in String) return Element_view
   is
      use xml.Reader;

      the_Text    : String_view := text_of (Filename);
      the_Parser  : Parser      := new_Parser;

      the_Root    : Element_view;     -- The document element.
      the_Current : Element_view;     -- The element being built, null until the document element opens.


      procedure Starter (Name : in String;
                         Atts : in Attributes_t)
      is
         new_Element : constant Element_view := new Element' (Name       => to_unbounded_String (Name),
                                                              Attributes => new Attributes_t' (Atts),
                                                              Data       => <>,
                                                              Parent     => <>,
                                                              Children   => <>);
      begin
         if the_Current = null
         then   the_Root := new_Element;
         else   the_Current.add_Child (new_Element);
         end if;

         the_Current := new_Element;
      end Starter;



      procedure Ender (Name : in String)
      is
         pragma Unreferenced (Name);
      begin
         if is_Whitespace (the_Current.Data)
         then
            the_Current.Data := null_unbounded_String;
         end if;

         the_Current := the_Current.Parent;
      end Ender;



      procedure data_Handler (Data : in String)
      is
      begin
         append (the_Current.Data, Data);
      end data_Handler;



      procedure clean_up
      is
      begin
         free (the_Text);
         free (the_Parser);
      end clean_up;


   begin
      set_Element_Handler        (the_Parser, Starter     'unrestricted_Access,
                                              Ender       'unrestricted_Access);
      set_Character_Data_Handler (the_Parser, data_Handler'unrestricted_Access);

      parse (the_Parser, the_Text.all, is_Final => True);

      clean_up;
      return the_Root;

   exception
      when E : parse_Error =>
         clean_up;
         free (the_Root);
         raise parse_Error with Filename & ": " & ada.Exceptions.exception_Message (E);

      when others =>
         clean_up;
         free (the_Root);
         raise;
   end to_XML;



   procedure free (Self : in out Element_view)
   is
   begin
      if Self = null
      then
         return;
      end if;

      for Each of Self.Children
      loop
         free (Each);
      end loop;

      free (Self.Attributes);
      deallocate (Self);
   end free;



   --- Attributes
   --

   function Name (Self : in Element) return String
   is
   begin
      return to_String (Self.Name);
   end Name;



   function Attributes (Self : in Element) return Attributes_t
   is
   begin
      if Self.Attributes = null
      then
         return no_Attributes;
      end if;

      return Self.Attributes.all;
   end Attributes;



   function Data (Self : in Element) return String
   is
   begin
      return to_String (Self.Data);
   end Data;



   function Attribute (Self : in Element;   Named : in String) return access Attribute_t'Class
   is
   begin
      if Self.Attributes /= null
      then
         for Each in Self.Attributes'Range
         loop
            if Self.Attributes (Each).Name = Named
            then
               return Self.Attributes (Each)'Access;
            end if;
         end loop;
      end if;

      return null;
   end Attribute;



   --- Hierarchy
   --

   function Parent (Self : in Element) return Element_view
   is
   begin
      return Self.Parent;
   end Parent;



   function Children (Self : in Element) return Elements
   is
      the_Children : Elements (1 .. Integer (Self.Children.Length));
   begin
      for Each in the_Children'Range
      loop
         the_Children (Each) := Self.Children.Element (Each);
      end loop;

      return the_Children;
   end Children;



   function Children (Self : in Element;   Named : in String) return Elements
   is
      the_Children : Elements (1 .. Integer (Self.Children.Length));
      Count        : Natural := 0;
   begin
      for Each in the_Children'Range
      loop
         if Self.Children.Element (Each).Name = Named
         then
            Count                := Count + 1;
            the_Children (Count) := Self.Children.Element (Each);
         end if;
      end loop;

      return the_Children (1 .. Count);
   end Children;



   function Child (Self : in Element;   Named : in String) return Element_view
   is
   begin
      for Each of Self.Children
      loop
         if Each.Name = Named
         then
            return Each;
         end if;
      end loop;

      return null;
   end Child;



   procedure add_Child (Self : in out Element;   the_Child : in Element_view)
   is
   begin
      the_Child.Parent := Self'unchecked_Access;
      Self.Children.append (the_Child);
   end add_Child;


end XML;
