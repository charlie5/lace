with
     freetype_c.Pointers;


package freetype_c.FT_Face
is

   subtype Item       is Pointers.FT_FaceRec_pointer;
   type    Item_array is array (C.Size_t range <>) of aliased FT_Face.Item;


   type Pointer       is access all FT_Face.Item;
   type Pointer_array is array (C.Size_t range <>) of aliased FT_Face.Pointer;

   type Pointer_pointer is access all FT_Face.Pointer;


end freetype_c.FT_Face;
