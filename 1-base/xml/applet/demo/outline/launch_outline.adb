with
     xml.Reader,

     ada.command_Line,
     ada.Text_IO;


procedure launch_Outline
--
-- Outlines an xml file, feeding the parser a line at a time.
--
is
   use
        ada.command_Line,
        ada.Text_IO,

        XML.Reader;

   Line_Max      : constant := 60_000;

   Depth         : Natural   := 0;
   XML_File      : File_type;
   the_Parser    : Parser;
   Done          : Boolean;
   Buffer        : String (1 .. Line_Max);
   Buffer_Length : Natural;


   procedure Starter (Name : in String;
                      Atts : in XML.Attributes_t)
   is
   begin
      for Pad in 1 .. Depth
      loop
         put ("   ");
      end loop;

      put (Name);

      for Each of Atts
      loop
         put (  " "
              & Each.Name
              & " = "
              & Each.Value);
      end loop;

      new_Line;

      Depth := Depth + 1;
   end Starter;



   procedure Ender (Name : in String)
   is
      pragma Unreferenced (Name);
   begin
      Depth := Depth - 1;
   end Ender;



   procedure my_data_Handler (Data : in String)
   is
   begin
      put_Line ("my_data_Handler: '" & Data & "'");
   end my_data_Handler;


begin
   if Argument_Count < 1
   then
      put_Line (standard_Error, "usage:  outline  xml-file");
   else
      open (XML_File, In_File, Argument (1));

      the_Parser := new_Parser;
      set_Element_Handler        (the_Parser, Starter'unrestricted_Access,
                                              Ender  'unrestricted_Access);
      set_Character_Data_Handler (the_Parser, my_data_Handler'unrestricted_Access);

      loop
         get_Line (XML_File, Buffer, Buffer_Length);

         Done := end_of_File (XML_File);

         parse (the_Parser,
                Buffer (1 .. Buffer_Length) & ASCII.LF,     -- Restore the terminator get_Line dropped.
                Done);

         exit when Done;
      end loop;

      close (XML_File);
      free  (the_Parser);
   end if;
end launch_Outline;
