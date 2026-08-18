with
     ada.unchecked_Deallocation;


package body XML.Writer
is


   Depth : Natural;

   procedure free is new ada.unchecked_Deallocation (Attributes_t,
                                                     Attributes_view);



   procedure start_Document (F : in ada.Text_IO.File_type)
   is
   begin
      ada.Text_IO.put_Line (F, "<?xml version=""1.0"" standalone=""yes""?>");
      Depth := 0;
   end start_Document;



   procedure end_Document (F : in ada.Text_IO.File_type)
   is
   begin
      null;
   end end_Document;



   procedure start (F    : in ada.Text_IO.File_type;
                    Name : in String;
                    Atts : in Attributes_view)
   is
   begin
      for Pad in 1 .. Depth
      loop
         ada.Text_IO.put (F, "   ");
      end loop;

      Depth := Depth + 1;
      ada.Text_IO.put (F, "<" & Name);

      for Att in Atts'Range
      loop
         ada.Text_IO.put (F,   " "
                             & to_String (Atts (Att).Name)
                             & "="""
                             & to_String (Atts (Att).Value)
                             & """");
      end loop;

      ada.Text_IO.put_Line (F, ">");
   end start;



   procedure start (F    : in ada.Text_IO.File_type;
                    Name : in unbounded_String;
                    Atts : in Attributes_view)
   is
   begin
      start (F, to_String (Name), Atts);
   end start;



   procedure finish (F    : in ada.Text_IO.File_type;
                     Name : in String)
   is
   begin
      Depth := Depth - 1;

      for Pad in 1 .. Depth
      loop
         ada.Text_IO.put (F, "   ");
      end loop;

      ada.Text_IO.put_Line (F, "</" & Name & ">");
   end finish;



   procedure finish (F    : in ada.Text_IO.File_type;
                     Name : in unbounded_String)
   is
   begin
      finish (F, to_String (Name));
   end finish;



   procedure empty (F    : in ada.Text_IO.File_type;
                    Name : in String;
                    Atts : in Attributes_view)
   is
   begin
      for Pad in 1 .. Depth
      loop
         ada.Text_IO.put (F, "   ");
      end loop;

      ada.Text_IO.put (F, "<" & Name);

      for Att in Atts'Range
      loop
         ada.Text_IO.put (F,   " "
                             & to_String (Atts (Att).Name)
                             & "="""
                             & to_String (Atts (Att).Value)
                             & """");
      end loop;

      ada.Text_IO.put_Line (F, "/>");
   end empty;



   procedure empty (F    : in ada.Text_IO.File_type;
                    Name : in unbounded_String;
                    Atts : in Attributes_view)
   is
   begin
      empty (F, to_String (Name), Atts);
   end empty;



   function "+" (K, V : in String) return Attribute_t
   is
   begin
      return Attribute_t' (to_unbounded_String (K),
                           to_unbounded_String (V));
   end "+";



   function "+" (K, V : in String) return Attributes_view
   is
   begin
      return new Attributes_t' (1 => Attribute_t' (to_unbounded_String (K),
                                                   to_unbounded_String (V)));
   end "+";



   function "+" (K : in unbounded_String;
                 V : in String) return Attribute_t
   is
   begin
      return Attribute_t' (K, to_unbounded_String (V));
   end "+";



   function "+" (K : in unbounded_String;
                 V : in String) return Attributes_view
   is
   begin
      return new Attributes_t' (1 => Attribute_t' (K, to_unbounded_String (V)));
   end "+";



   function "+" (K : in String;
                 V : in unbounded_String) return Attribute_t
   is
   begin
      return Attribute_t' (to_unbounded_String (K), V);
   end "+";



   function "+" (K : in String;
                 V : in unbounded_String) return Attributes_view
   is
   begin
      return new Attributes_t' (1 => Attribute_t' (to_unbounded_String (K), V));
   end "+";



   function MkAtt (L, R : in Attribute_t) return Attributes_view
   is
   begin
      return new Attributes_t' (L, R);
   end MkAtt;



   function "&" (L, R : in Attribute_t) return Attributes_view
   is
   begin
      return new Attributes_t' (L, R);
   end "&";



   function "&" (L : in Attributes_view;   R : in Attribute_t) return Attributes_view
   is

      Result : Attributes_view;
      ByeBye : Attributes_view;

   begin
      Result                 := new Attributes_t (1 .. L'Length + 1);
      Result (1 .. L'Length) := L.all;
      Result (L'Length + 1)  := R;
      ByeBye                 := L;

      free (ByeBye);
      return Result;
   end "&";


end XML.Writer;
