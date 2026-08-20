with
     freetype_c.Pointers;


package freetype_c.FT_GlyphSlot
is

   subtype Item       is freetype_c.Pointers.FT_GlyphSlotRec_pointer;
   type    Item_array is array (C.Size_t range <>) of aliased freetype_c.FT_GlyphSlot.Item;


   type Pointer       is access all freetype_c.FT_GlyphSlot.Item;
   type Pointer_array is array (C.Size_t range <>) of aliased freetype_c.FT_GlyphSlot.Pointer;

   type Pointer_pointer is access all freetype_c.FT_GlyphSlot.Pointer;


end freetype_c.FT_GlyphSlot;
