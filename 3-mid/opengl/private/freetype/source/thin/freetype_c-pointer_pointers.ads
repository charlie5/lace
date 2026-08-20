with
     freetype_c.Pointers;


package freetype_c.pointer_Pointers
is
   use freetype_c.Pointers;

   type FT_UShort_pointer_pointer       is access all FT_UShort_pointer;
   type FT_Int_pointer_pointer          is access all FT_Int_pointer;
   type FT_UInt_pointer_pointer         is access all FT_UInt_pointer;
   type FT_Long_pointer_pointer         is access all FT_Long_pointer;
   type FT_ULong_pointer_pointer        is access all FT_ULong_pointer;
   type FT_Fixed_pointer_pointer        is access all FT_Fixed_pointer;
   type FT_Pos_pointer_pointer          is access all FT_Pos_pointer;
   type FT_Error_pointer_pointer        is access all FT_Error_pointer;
   type FT_Encoding_pointer_pointer     is access all FT_Encoding_pointer;
   type FT_F26Dot6_pointer_pointer      is access all FT_F26Dot6_pointer;
   type FT_Int32_pointer_pointer        is access all FT_Int32_pointer;
   type FT_UInt32_pointer_pointer       is access all FT_UInt32_pointer;
   type FT_Render_Mode_pointer_pointer  is access all FT_Render_Mode_pointer;
   type FT_Outline_pointer_pointer      is access all FT_Outline_pointer;
   type FT_LibraryRec_pointer_pointer   is access all FT_LibraryRec_pointer;
   type FT_GlyphSlotRec_pointer_pointer is access all FT_GlyphSlotRec_pointer;
   type FT_FaceRec_pointer_pointer      is access all FT_FaceRec_pointer;
   type FT_Kerning_Mode_pointer_pointer is access all FT_Kerning_Mode_pointer;
   type FT_SizeRec_pointer_pointer      is access all FT_SizeRec_pointer;


end freetype_c.pointer_Pointers;
