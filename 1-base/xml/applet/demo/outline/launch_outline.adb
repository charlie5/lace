with
     ada.command_Line,

     ada.Text_IO,
     ada.Strings.unbounded,

     xml.Reader;


procedure launch_Outline
is
   use
        ada.command_Line,
        ada.Text_IO,
        ada.Strings.unbounded,

        XML.Reader;

   Line_Max      : constant := 60000;

   Depth         : Natural               := 0;
   XML_File      : File_type;
   MyParser      : Parser;
   Done          : Boolean;
   Buffer        : String (1 .. Line_Max);
   Buffer_Length : Natural;


   procedure Starter (Name : in unbounded_String;
                      Atts : in XML.Attributes_view)
   is
   begin
      for Pad in 1 .. Depth
      loop
         put ("   ");
      end loop;

      put (to_String (Name));

      for Att in Atts'Range
      loop
         put (  " "
              & Atts (Att).Name
              & " = "
              & Atts (Att).Value);
      end loop;

      new_Line;

      Depth := Depth + 1;
   end Starter;



   procedure Ender (Name : in unbounded_String)
   is
      pragma Unreferenced (Name);
   begin
      Depth := Depth - 1;
   end Ender;



   procedure my_data_Handler (Data : in unbounded_String)
   is
   begin
      put_Line ("my_data_Handler: '" & to_String (Data) & "'");
   end my_data_Handler;


begin
   if Argument_Count < 1
   then
      put_Line (standard_Error, "usage:  outline  xml-file");
   else
      open (XML_File, In_File, Argument (1));

      MyParser := Create_Parser;
      set_Element_Handler (MyParser, Starter'unrestricted_Access,
                                     Ender  'unrestricted_Access);

      set_Character_Data_Handler (MyParser, my_data_Handler'unrestricted_Access);

      loop
         get_Line (XML_File, Buffer, Buffer_Length);

         Done := end_of_File (XML_File);

         parse (MyParser,
                Buffer (1 .. Buffer_Length),
                Done);

         exit when Done;
      end loop;
   end if;
end launch_Outline;
