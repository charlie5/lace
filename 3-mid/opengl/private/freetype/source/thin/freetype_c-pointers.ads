package freetype_c.Pointers
is
   type FT_UShort_pointer       is access all FT_UShort;
   type FT_Int_pointer          is access all FT_Int;
   type FT_UInt_pointer         is access all FT_UInt;
   type FT_Long_pointer         is access all FT_Long;
   type FT_ULong_pointer        is access all FT_ULong;
   type FT_Fixed_pointer        is access all FT_Fixed;
   type FT_Pos_pointer          is access all FT_Pos;
   type FT_Error_pointer        is access all FT_Error;
   type FT_Encoding_pointer     is access all FT_Encoding;
   type FT_Int32_pointer        is access all FT_Int32;
   type FT_F26Dot6_pointer      is access all FT_F26Dot6;
   type FT_UInt32_pointer       is access all FT_UInt32;
   type FT_Render_Mode_pointer  is access all FT_Render_Mode;
   type FT_Outline_pointer      is access all FT_Outline;
   type FT_LibraryRec_pointer   is access all FT_LibraryRec;
   type FT_GlyphSlotRec_pointer is access all FT_GlyphSlotRec;
   type FT_FaceRec_pointer      is access all FT_FaceRec;
   type FT_Kerning_Mode_pointer is access all FT_Kerning_Mode;
   type FT_SizeRec_pointer      is access all FT_SizeRec;


   type FT_UShort_pointers       is array (C.Size_t range <>) of aliased FT_UShort_pointer;
   type FT_Int_pointers          is array (C.Size_t range <>) of aliased FT_Int_pointer;
   type FT_UInt_pointers         is array (C.Size_t range <>) of aliased FT_UInt_pointer;
   type FT_Long_pointers         is array (C.Size_t range <>) of aliased FT_Long_pointer;
   type FT_ULong_pointers        is array (C.Size_t range <>) of aliased FT_ULong_pointer;
   type FT_Fixed_pointers        is array (C.Size_t range <>) of aliased FT_Fixed_pointer;
   type FT_Pos_pointers          is array (C.Size_t range <>) of aliased FT_Pos_pointer;
   type FT_Error_pointers        is array (C.Size_t range <>) of aliased FT_Error_pointer;
   type FT_Encoding_pointers     is array (C.Size_t range <>) of aliased FT_Encoding_pointer;
   type FT_F26Dot6_pointers      is array (C.Size_t range <>) of aliased FT_F26Dot6_pointer;
   type FT_Int32_pointers        is array (C.Size_t range <>) of aliased FT_Int32_pointer;
   type FT_UInt32_pointers       is array (C.Size_t range <>) of aliased FT_UInt32_pointer;
   type FT_Render_Mode_pointers  is array (C.Size_t range <>) of aliased FT_Render_Mode_pointer;
   type FT_Outline_pointers      is array (C.Size_t range <>) of aliased FT_Outline_pointer;
   type FT_LibraryRec_pointers   is array (C.Size_t range <>) of aliased FT_LibraryRec_pointer;
   type FT_GlyphSlotRec_pointers is array (C.Size_t range <>) of aliased FT_GlyphSlotRec_pointer;
   type FT_FaceRec_pointers      is array (C.Size_t range <>) of aliased FT_FaceRec_pointer;
   type FT_Kerning_Mode_pointers is array (C.Size_t range <>) of aliased FT_Kerning_Mode_pointer;
   type FT_SizeRec_pointers      is array (C.Size_t range <>) of aliased FT_SizeRec_pointer;


end freetype_c.Pointers;
