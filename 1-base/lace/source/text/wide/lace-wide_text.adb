with
     --  lace.Strings.fixed,
     ada.wide_Characters.handling,
     ada.Strings.wide_fixed.wide_Hash;


package body lace.wide_Text
is
   ---------------
   -- Construction
   --

   function to_Text (From : in wide_String;
                     Trim : in Boolean := False) return Item
   is
   begin
      return to_Text (From,
                      Capacity => From'Length,
                      Trim     => Trim);
   end to_Text;



   function to_Text (From     : in wide_String;
                     Capacity : in Natural;
                     Trim     : in Boolean := False) return Item
   is
      use ada.Strings;

      the_String : constant wide_String := (if Trim then wide_fixed.Trim (From, Both)
                                                    else From);
      Self       : Item (Capacity);
   begin
      Self.Length                  := the_String'Length;
      Self.Data (1 .. Self.Length) := the_String;

      return Self;
   end to_Text;



   function "+" (From : in wide_String) return Item
   is
   begin
      return to_Text (From);
   end "+";


   -------------
   -- Attributes
   --

   procedure String_is (Self : in out Item;
                        Now  : in     wide_String)
   is
   begin
      Self.Data (1 .. Now'Length) := Now;
      Self.Length                 := Now'Length;
   end String_is;



   function to_String (Self : in Item) return wide_String
   is
   begin
      return Self.Data (1 .. Self.Length);
   end to_String;



   function is_Empty (Self : in Item) return Boolean
   is
   begin
      return Self.Length = 0;
   end is_Empty;



   function Length (Self : in Item) return Natural
   is
   begin
      return Self.Length;
   end Length;



   function Image (Self : in Item) return wide_String
   is
   begin
      return
        "(Capacity =>"  & Self.Capacity'wide_Image  & "," &
        " Length =>"    & Self.Length  'wide_Image  & "," &
        " Data => '"    & to_String (Self)     & "')";
   end Image;



   function Hashed (Self : in Item) return ada.Containers.Hash_type
   is
   begin
      return ada.Strings.wide_fixed.wide_Hash (Self.Data (1 .. Self.Length));
   end Hashed;



   overriding
   function "=" (Left, Right : in Item) return Boolean
   is
   begin
      if Left.Length /= Right.Length
      then
         return False;
      end if;

      return to_String (Left) = to_String (Right);
   end "=";



   function to_Lowercase (Self : in Item) return Item
   is
      use ada.wide_Characters.handling;
      Result : Item := Self;
   begin
      for i in 1 .. Self.Length
      loop
         Result.Data (i) := to_Lower (Self.Data (i));
      end loop;

      return Result;
   end to_Lowercase;



   function mono_Spaced (Self : in Item) return Item
   is
      Result : Item (Self.Capacity);
      Prior  : wide_Character := 'a';
      Length : Natural        := 0;
   begin
      for i in 1 .. Self.Length
      loop
         if    Self.Data (i) = ' '
           and Prior = ' '
         then
            null;
         else
            Length               := Length + 1;
            Result.Data (Length) := Self.Data (i);
            Prior                := Self.Data (i);
         end if;
      end loop;

      Result.Length := Length;
      return Result;
   end mono_Spaced;



   function Element (Self : in Item;   Index : in Positive) return wide_Character
   is
   begin
      if Index > Self.Length
      then
         raise Error with "Index" & Index'Image & " exceeds length of" & Self.Length'Image;
      end if;

      return Self.Data (Index);
   end Element;



   procedure append (Self : in out Item;   Extra : in wide_String)
   is
      First : constant Positive := Self.Length + 1;
      Last  : constant Positive := First + Extra'Length - 1;
   begin
      Self.Length               := Last;
      Self.Data (First .. Last) := Extra;

   exception
      when constraint_Error =>
         raise Error with "Appending 'Extra'" & Extra'Length'Image & " characters to 'Text's" & Self.Length'Image & " characters exceeds capacity of" & Self.Capacity'Image & ".";
         --  raise Error with "Appending '" & Extra & "' to '" & to_String (Self) & "' exceeds capacity of" & Self.Capacity'wide_Image & ".";
   end append;



   function delete (Self : in Item;   From    : Positive;
                                      Through : Natural := Natural'Last) return Item
   is
      Result : Item (Self.Capacity);
   begin
      delete (Result, From, Through);
      return Result;
   end delete;



   procedure delete (Self : in out Item;   From    : Positive;
                                           Through : Natural := Natural'Last)
   is
      Thru : constant Natural      := Natural'Min (Through, Self.Length);
      Tail : constant wide_String  := Self.Data (Thru + 1 .. Self.Length);
   begin
      Self.Data (From .. From + Tail'Length - 1) := Tail;
      Self.Length                                :=   Self.Length
                                                    - (Natural'Min (Thru,
                                                                    Self.Length) - From + 1);
   end delete;



   --  procedure delete (Self : in out Text.item;   From    : Positive;
   --                                               Through : Natural := Natural'Last)
   --  is
   --     Thru : constant Natural := Natural'Min (Through, Self.Length)
   --     Tail : constant String  := Self.Data (Through + 1 .. Self.Length);
   --  begin
   --     Self.Data (From .. From + Tail'Length - 1) := Tail;
   --     Self.Length                                :=   Self.Length
   --                                                   - (Natural'Min (Through,
   --                                                                   Self.Length) - From + 1);
   --  end delete;



   ----------
   -- Streams
   --

   function Item_input (Stream : access ada.Streams.root_Stream_type'Class) return Item
   is
      Capacity : Positive;
      Length   : Natural;
   begin
      Positive'read (Stream, Capacity);
      Natural 'read (Stream, Length);

      declare
         Data : wide_String (1 .. Capacity);
      begin
         wide_String'read (Stream, Data (1 .. Length));

         return (Capacity => Capacity,
                 Data     => Data,
                 Length   => Length);
      end;
   end Item_input;



   procedure Item_output (Stream   : access ada.Streams.root_Stream_type'Class;
                          the_Item : in     Item)
   is
   begin
      Positive   'write (Stream, the_Item.Capacity);
      Natural    'write (Stream, the_Item.Length);
      wide_String'write (Stream, the_Item.Data (1 .. the_Item.Length));
   end Item_output;



   procedure Write (Stream : access ada.Streams.root_Stream_type'Class;
                    Self   : in     Item)
   is
   begin
      Natural    'write (Stream, Self.Length);
      wide_String'write (Stream, Self.Data (1 .. Self.Length));
   end Write;



   procedure Read (Stream : access ada.Streams.root_Stream_type'Class;
                   Self   :    out Item)
   is
   begin
      Natural    'read (Stream, Self.Length);
      wide_String'read (Stream, Self.Data (1 .. Self.Length));
   end Read;


end lace.wide_Text;
