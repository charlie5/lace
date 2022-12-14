with
     openGL.Font,

     freetype_c.Binding,
     freetype_c.FT_GlyphSlot,
     freetype_c.Pointers,
     freetype_c.FT_Size_Metrics,

     ada.Unchecked_Deallocation;


package body openGL.FontImpl
is
   use freetype_c.Pointers;


   -----------
   --  Utility
   --
   procedure free is new ada.Unchecked_Deallocation (openGL.Glyph.Container.item'Class, glyph_Container_view);



   ---------
   --  Forge
   --

   procedure define (Self : access Item;   ftFont       : access openGL.Font.item'Class;
                                           fontFilePath : in     String)
   is
      use      freetype.Face, openGL.Glyph.container,
               freetype_c,    freetype_c.Binding;
      use type FT_Error;

   begin
      Self.face       := to_Face (fontFilePath, precomputeKerning => True);
      Self.load_Flags := FT_Int (FT_LOAD_DEFAULT_flag);
      Self.intf       := ftFont;
      Self.err        := Self.face.Error;

      if Self.err = 0
      then
         Self.glyphList := new openGL.Glyph.Container.item' (to_glyph_Container (Self.face'Access));
      else
         raise openGL.Error with "Unable to create face for font.";
      end if;
   end define;



   procedure define (Self : in out Item;   ftFont            : access  openGL.Font.item'Class;
                                           pBufferBytes      : access  interfaces.c.unsigned_char;
                                           bufferSizeInBytes : in      Integer)
   is
      use      freetype.Face, openGL.Glyph.container,
               freetype_c,    freetype_c.Binding;
      use type FT_Error;
   begin
      Self.face       := to_Face (pBufferBytes, bufferSizeInBytes, precomputeKerning => True);
      Self.load_Flags := FT_Int (FT_LOAD_DEFAULT_flag);
      Self.intf       := ftFont;
      Self.err        := Self.face.Error;

      if Self.err = 0
      then
         self.glyphList := new openGL.Glyph.Container.item'(to_glyph_Container (Self.face'Access));
      end if;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      if Self.glyphList /= null
      then
         Self.glyphList.destruct;
         free (Self.glyphList);
      end if;
   end destruct;




   --------------
   --  Attributes
   --

   function err (Self : in Item) return freetype_c.FT_Error
   is
   begin
      return Self.err;
   end err;



   function  Attach (Self : access Item;   fontFilePath : in String) return Boolean
   is
   begin
      if not Self.Face.attach (fontFilePath)
      then
         Self.err := Self.face.Error;
         return False;
      end if;

      Self.err := 0;
      return True;
   end Attach;



   function  Attach (Self : access Item;   pBufferBytes      : access interfaces.c.unsigned_char;
                                           bufferSizeInBytes : in     Integer) return Boolean
   is
   begin
      if not Self.Face.attach (pBufferBytes, bufferSizeInBytes)
      then
         Self.err := Self.face.Error;
         return False;
      end if;

      Self.err := 0;
      return True;
   end Attach;



   procedure GlyphLoadFlags (Self : in out Item;   flags : in freetype_c.FT_Int)
   is
   begin
      Self.load_Flags := flags;
   end GlyphLoadFlags;



   function CharMap (Self : access Item;   encoding : in freetype_c.FT_Encoding) return Boolean
   is
      result : constant Boolean := Self.glyphList.CharMap (encoding);
   begin
      Self.err := Self.glyphList.Error;
      return result;
   end CharMap;



   function CharMapCount (Self : in Item) return Natural
   is
   begin
      return Self.face.CharMapCount;
   end CharMapCount;



   function CharMapList (Self : access Item) return freetype.face.FT_Encodings_view
   is
   begin
      return Self.face.CharMapList;
   end CharMapList;



   function Ascender (Self : in Item) return Real
   is
   begin
      return Real (Self.charSize.Ascender);
   end Ascender;



   function Descender (Self : in Item) return Real
   is
   begin
      return Real (Self.charSize.Descender);
   end Descender;



   function LineHeight (Self : in Item) return Real
   is
   begin
      return Real (Self.charSize.Height);
   end LineHeight;



   function FaceSize (Self : access Item;   size         : in Natural;
                                            x_res, y_res : in Natural) return Boolean
   is
      use      openGL.Glyph.Container;
      use type freetype_c.FT_Error;

   begin
      if Self.glyphList /= null
      then
         Self.glyphList.destruct;
         free (Self.glyphList);
         Self.glyphList := null;
      end if;

      Self.charSize := Self.face.Size (size, x_res, y_res);
      Self.err      := Self.face.Error;

      if Self.err /= 0 then
         return False;
      end if;

      Self.glyphList := new Glyph.Container.item' (to_glyph_Container (Self.face'Access));
      return True;
   end FaceSize;



   function FaceSize (Self : in Item) return Natural
   is
   begin
      return Self.charSize.CharSize;
   end FaceSize;



   procedure Depth  (Self : in out Item;   depth  : in Real)
   is
   begin
      null;   -- nb: This is 'null' in FTGL also.
   end Depth;



   procedure Outset (Self : in out Item;   outset : in Real)
   is
   begin
      null;   -- nb: This is 'null' in FTGL also.
   end Outset;



   procedure Outset (Self : in out Item;   front  : in Real;
                                           back   : in Real)

   is
   begin
      null;   -- nb: This is 'null' in FTGL also.
   end Outset;



   function CheckGlyph (Self : access Item;   character : in freetype.charmap.CharacterCode) return Boolean
   is
      use type glyph.Container.Glyph_view,
               freetype_c.FT_Error;

      glyphIndex : freetype.charMap.glyphIndex;
      ftSlot     : freetype_c.FT_GlyphSlot.item;
      tempGlyph  : glyph.Container.Glyph_view;

   begin
      if Self.glyphList.Glyph (character) /= null
      then
         return True;
      end if;

      glyphIndex := freetype.charMap.glyphIndex (Self.glyphList.FontIndex (character));
      ftSlot     := Self.face.Glyph             (glyphIndex,  Self.load_flags);

      if ftSlot = null
      then
         Self.err := Self.face.Error;
         return False;
      end if;

      if Self.intf = null
      then
         raise Program_Error with "Self.intf = null";
      end if;

      tempGlyph := Self.intf.MakeGlyph (ftSlot);

      if tempGlyph = null
      then
         if Self.err = 0 then
            Self.err := 16#13#;
         end if;

         return False;
      end if;

      if Self.glyphList.Glyph (character) = null then
         Self.glyphList.add (tempGlyph, character);
      end if;

      return True;
   end CheckGlyph;



   function BBox (Self : access Item;   s        : in String;
                                        len      : in Integer;
                                        Position : in Vector_3;
                                        Spacing  : in Vector_3) return Bounds
   is
      pragma Unreferenced (len);

      use freetype.charMap, Geometry_3d;

      Pos       : Vector_3 := Position;
      totalBBox : Bounds   := null_Bounds;
   begin
      if s = ""
      then
         totalBBox.Box := totalBBox.Box or Pos;
         set_Ball_from_Box (totalBBox);

         return totalBBox;
      end if;


      --  Only compute the bounds if string is non-empty.
      --
      if s'Length > 0
      then
         --  for multibyte - we can't rely on sizeof(T) == character
         --
         declare
            use type freetype.charmap.characterCode;

            thisChar : Character;
            nextChar : Character;

         begin
            --  Expand totalBox by each glyph in string
            --
            for Each in s'Range
            loop
               thisChar := s (Each);

               if Each /= s'Last
               then   nextChar := s (Each + 1);
               else   nextChar := ' ';
               end if;


               if Self.CheckGlyph (to_characterCode (thisChar))
               then
                  declare
                     tempBBox : Bounds := Self.glyphList.BBox (to_characterCode (thisChar));
                  begin
                     tempBBox.Box  := tempBBox.Box + Pos;
                     totalBBox.Box := totalBBox.Box or tempBBox.Box;

                     Pos           := Pos  +  spacing;
                     Pos           := Pos  +  Vector_3' (Self.glyphList.Advance (to_characterCode (thisChar),
                                                                                 to_characterCode (nextChar)),
                                                         0.0,
                                                         0.0);
                  end;
               end if;
            end loop;
         end;
      end if;

      set_Ball_from_Box (totalBBox);
      return totalBBox;
   end BBox;



   function kern_Advance (Self : in Item;   From, To : in Character) return openGL.Real
   is
      use freetype.charMap;
   begin
      return Self.glyphList.Advance (to_characterCode (From),
                                     to_characterCode (To));
   end kern_Advance;



   function x_PPEM (Self : in Item) return openGL.Real
   is
      use freetype_c.Binding;

      ft_Size    : constant FT_SizeRec_Pointer              := FT_Face_Get_Size    (Self.Face.freetype_Face).all'Access;
      ft_Metrics : constant freetype_c.FT_Size_Metrics.item := FT_Size_Get_Metrics (ft_Size);
   begin
      return Real (ft_Metrics.x_ppem);
   end x_PPEM;



   function x_Scale (Self : in Item) return openGL.Real
   is
      use freetype_c.Binding;

      ft_Size    : constant FT_SizeRec_Pointer              := FT_Face_Get_Size    (Self.Face.freetype_Face).all'Access;
      ft_Metrics : constant freetype_c.FT_Size_Metrics.item := FT_Size_Get_Metrics (ft_Size);
   begin
      return Real (ft_Metrics.x_scale);
   end x_Scale;



   function y_Scale (Self : in Item) return openGL.Real
   is
      use freetype_c.Binding;

      ft_Size    : constant FT_SizeRec_Pointer              := FT_Face_Get_Size    (Self.Face.freetype_Face).all'Access;
      ft_Metrics : constant freetype_c.FT_Size_Metrics.item := FT_Size_Get_Metrics (ft_Size);
   begin
      return Real (ft_Metrics.y_scale);
   end y_Scale;



   function Advance (Self : access     Item;   s        : in String;
                                               len      : in Integer;
                                               Spacing  : in Vector_3) return Real
   is
      pragma Unreferenced (len);

      advance : Real    := 0.0;
      ustr    : Integer := 1;
      i       : Integer := 0;

   begin
      while i < s'Length
      loop
         declare
            use      freetype.charMap;
            use type freetype.charmap.characterCode;

            thisChar : constant Character := s (ustr);
            nextChar :          Character;

         begin
            ustr := ustr + 1;

            if ustr <= s'Length
            then   nextChar := s (ustr);
            else   nextChar := Character'Val (0);
            end if;

            if         nextChar /= Character'Val (0)
              and then Self.CheckGlyph (to_characterCode (thisChar))
            then
               advance := advance + Self.glyphList.Advance (to_characterCode (thisChar),
                                                            to_characterCode (nextChar));
            end if;

            if nextChar /= Character'Val (0)
            then
               advance := advance + spacing (1);
            end if;

            i := i + 1;
         end;
      end loop;

      return advance;
   end Advance;




   --- Operations
   --

   function Render (Self : access Item;   s          : in String;
                                          len        : in Integer;
                                          Position   : in Vector_3;
                                          Spacing    : in Vector_3;
                                          renderMode : in Integer) return Vector_3
   is
      use type freetype.charmap.characterCode;

      ustr : Integer  := 1;
      i    : Integer  := 0;
      Pos  : Vector_3 := Position;

   begin
      while     (len <  0  and then  i <  s'Length)
        or else (len >= 0  and then  i <  len)
      loop
         declare
            use freetype.charMap;

            thisChar : constant Character := s (ustr);
            nextChar :          Character;

         begin
            ustr := ustr + 1;

            if ustr <= s'Length
            then   nextChar := s (ustr);
            else   nextChar := Character'Val (0);
            end if;

            if         nextChar /= Character'Val (0)
              and then Self.CheckGlyph (to_characterCode (thisChar))
            then
               Pos := Pos + Self.glyphList.Render (to_characterCode (thisChar),
                                                   to_characterCode (nextChar),
                                                   position,
                                                   renderMode);
            end if;

            if nextChar /= Character'Val (0)
            then
               Pos := Pos + spacing;
            end if;

            i := i + 1;
         end;
      end loop;

      return Pos;
   end Render;


end openGL.FontImpl;
