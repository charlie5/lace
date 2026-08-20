with
     interfaces.C.Pointers,
     interfaces.C.Strings,

     system.Address_To_Access_Conversions;


package swig.Pointers
--
-- Contains pointers to Swig related C type definitions not found in the 'interfaces.C' family.
--
is
   -- void_ptr
   --
   package c_void_ptr_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                             Element            => swig.void_ptr,
                                                             Element_array      => void_ptr_array,
                                                             default_Terminator => system.null_Address);
   subtype void_ptr_pointer is c_void_ptr_Pointers.Pointer;


   -- opaque struct_ptr
   --
   type opaque_structure_ptr       is access swig.opaque_structure;
   type opaque_structure_ptr_array is array (interfaces.c.size_t range <>) of aliased opaque_structure_ptr;

   package c_opaque_structure_ptr_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                         Element            => opaque_structure_ptr,
                                                                         Element_array      => opaque_structure_ptr_array,
                                                                         default_Terminator => null);
   subtype opaque_structure_ptr_pointer is c_opaque_structure_ptr_Pointers.Pointer;


   -- incomplete class
   --
   type incomplete_class_ptr is access swig.incomplete_class;
   type incomplete_class_ptr_array is array (interfaces.c.size_t range <>) of aliased incomplete_class_ptr;

   package c_incomplete_class_ptr_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                         Element            => incomplete_class_ptr,
                                                                         Element_array      => incomplete_class_ptr_array,
                                                                         default_Terminator => null);
   subtype incomplete_class_ptr_pointer is c_incomplete_class_ptr_Pointers.Pointer;


   -- bool*
   --
   package c_bool_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                         Element            => swig.bool,
                                                         Element_array      => bool_array,
                                                         default_Terminator => 0);
   subtype bool_pointer       is c_bool_Pointers.Pointer;
   type    bool_pointer_array is array (interfaces.c.size_t range <>) of aliased bool_pointer;


   -- bool**
   --
   package c_bool_pointer_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                 Element            => bool_pointer,
                                                                 Element_array      => bool_pointer_array,
                                                                 default_Terminator => null);
   subtype bool_pointer_pointer is c_bool_pointer_Pointers.Pointer;



   -- char* []
   --
   type chars_ptr_array is array (interfaces.c.size_t range <>) of aliased interfaces.c.strings.chars_ptr;   -- standard Ada does not have 'aliased'

   package c_chars_ptr_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                              Element            => interfaces.c.strings.chars_ptr,
                                                              Element_array      => chars_ptr_array,
                                                              default_Terminator => interfaces.c.strings.null_ptr);
   subtype chars_ptr_pointer is c_chars_ptr_Pointers.Pointer;


   -- char** []
   --
   type chars_ptr_pointer_array is array (interfaces.c.size_t range <>) of aliased chars_ptr_pointer;

   package c_chars_ptr_pointer_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                      Element            => chars_ptr_pointer,
                                                                      Element_array      => chars_ptr_pointer_array,
                                                                      default_Terminator => null);
   subtype chars_ptr_pointer_pointer is c_chars_ptr_pointer_Pointers.Pointer;


   -- wchar_t*
   --
   package c_wchar_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                            Element            => interfaces.c.wchar_t,
                                                            Element_array      => interfaces.c.wchar_array,
                                                            default_Terminator => interfaces.c.wchar_t'First);
   subtype wchar_t_pointer is c_wchar_t_Pointers.Pointer;


   -- signed char*
   --
   package c_signed_char_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                Element            => interfaces.c.signed_Char,
                                                                Element_array      => swig.signed_char_array,
                                                                default_Terminator => 0);
   subtype signed_char_pointer is c_signed_char_Pointers.Pointer;


   -- unsigned char*
   --
   package c_unsigned_char_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                  Element            => interfaces.c.unsigned_Char,
                                                                  Element_array      => unsigned_char_array,
                                                                  default_Terminator => 0);
   subtype unsigned_char_pointer is c_unsigned_char_Pointers.Pointer;


   -- short*
   --
   package c_short_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                          Element            => interfaces.c.Short,
                                                          Element_array      => short_array,
                                                          default_Terminator => 0);
   subtype short_pointer is c_short_Pointers.Pointer;



   -- unsigned short*
   --
   package c_unsigned_short_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                   Element            => interfaces.c.unsigned_Short,
                                                                   Element_array      => unsigned_short_array,
                                                                   default_Terminator => 0);
   subtype unsigned_short_pointer is c_unsigned_short_Pointers.Pointer;


   -- int*
   --
   package c_int_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                        Element            => interfaces.c.Int,
                                                        Element_array      => int_array,
                                                        default_Terminator => 0);
   subtype int_pointer is c_int_Pointers.Pointer;


   -- int**
   --
   type int_pointer_array is array (interfaces.c.size_t range <>) of aliased int_pointer;

   package c_int_pointer_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                Element            => int_pointer,
                                                                Element_array      => int_pointer_array,
                                                                default_Terminator => null);
   subtype int_pointer_pointer is c_int_pointer_Pointers.Pointer;


   -- size_t*
   --
   package c_size_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                           Element            => interfaces.c.size_t,
                                                           Element_array      => size_t_array,
                                                           default_Terminator => 0);
   subtype size_t_pointer is c_size_t_Pointers.Pointer;



   -- unsigned*
   --
   package c_unsigned_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                             Element            => interfaces.c.Unsigned,
                                                             Element_array      => unsigned_array,
                                                             default_Terminator => 0);
   subtype unsigned_pointer is c_unsigned_Pointers.Pointer;


   -- long*
   --
   package c_long_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                         Element            => interfaces.c.Long,
                                                         Element_array      => long_array,
                                                         default_Terminator => 0);
   subtype long_pointer is c_long_Pointers.Pointer;


   -- unsigned long*
   --
   package c_unsigned_long_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                  Element            => interfaces.c.unsigned_Long,
                                                                  Element_array      => unsigned_long_array,
                                                                  default_Terminator => 0);
   subtype unsigned_long_pointer is c_unsigned_long_Pointers.Pointer;


   -- long long*
   --
   package c_long_long_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                              Element            => swig.long_Long,
                                                              Element_array      => long_long_array,
                                                              default_Terminator => 0);
   subtype long_long_pointer is c_long_long_Pointers.Pointer;


   -- unsigned long long*
   --
   package c_unsigned_long_long_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                       Element            => swig.unsigned_long_Long,
                                                                       Element_array      => unsigned_long_long_array,
                                                                       default_Terminator => 0);
   subtype unsigned_long_long_pointer is c_unsigned_long_long_Pointers.Pointer;



   -- int8_t*
   --
   package c_int8_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                           Element            => swig.int8_t,
                                                           Element_array      => swig.int8_t_array,
                                                           default_Terminator => 0);
   subtype int8_t_pointer is c_int8_t_Pointers.Pointer;


   -- int16_t*
   --
   package c_int16_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                            Element            => swig.int16_t,
                                                            Element_array      => swig.int16_t_array,
                                                            default_Terminator => 0);
   subtype int16_t_pointer is c_int16_t_Pointers.Pointer;


   -- int32_t*
   --
   package c_int32_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                            Element            => swig.int32_t,
                                                            Element_array      => swig.int32_t_array,
                                                            default_Terminator => 0);
   subtype int32_t_pointer is c_int32_t_Pointers.Pointer;


   -- int64_t*
   --
   package c_int64_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                            Element            => swig.int64_t,
                                                            Element_array      => swig.int64_t_array,
                                                            default_Terminator => 0);
   subtype int64_t_pointer is c_int64_t_Pointers.Pointer;



   -- uint8_t*'
   --
   package c_uint8_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                            Element            => swig.uint8_t,
                                                            Element_array      => swig.uint8_t_array,
                                                            default_Terminator => 0);
   subtype uint8_t_pointer is c_uint8_t_Pointers.Pointer;


   -- uint16_t*'
   --
   package c_uint16_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                             Element            => swig.uint16_t,
                                                             Element_array      => swig.uint16_t_array,
                                                             default_Terminator => 0);
   subtype uint16_t_pointer is c_uint16_t_Pointers.Pointer;


   -- uint32_t*'
   --
   package c_uint32_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                             Element            => swig.uint32_t,
                                                             Element_array      => swig.uint32_t_array,
                                                             default_Terminator => 0);
   subtype uint32_t_pointer is c_uint32_t_Pointers.Pointer;


   -- uint64_t*'
   --
   package c_uint64_t_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                             Element            => swig.uint64_t,
                                                             Element_array      => swig.uint64_t_array,
                                                             default_Terminator => 0);
   subtype uint64_t_pointer is c_uint64_t_Pointers.Pointer;



   -- float*'
   --
   package c_float_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                          Element            => interfaces.c.c_Float,
                                                          Element_array      => float_array,
                                                          default_Terminator => 0.0);
   subtype float_pointer is c_float_Pointers.Pointer;



   -- double*'
   --
   package c_double_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                           Element            => interfaces.c.Double,
                                                           Element_array      => double_array,
                                                           default_Terminator => 0.0);
   subtype double_pointer is c_double_Pointers.Pointer;



   -- long double*'
   --
   package c_long_double_Pointers is new interfaces.c.Pointers (Index              => interfaces.c.size_t,
                                                                Element            => interfaces.c.long_Double,
                                                                Element_array      => long_double_array,
                                                                default_Terminator => 0.0);
   subtype long_double_pointer is c_long_double_Pointers.Pointer;



   -- std::string
   --
   type std_String         is private;
   type std_string_pointer is access all std_String;
   type std_string_array   is array (interfaces.c.size_t range <>) of aliased std_String;



   -- Utility
   --
   package void_Conversions is new system.Address_To_Access_Conversions (swig.Void);



private

   type std_String is
      record
         M_dataplus : swig.void_ptr;    -- which is a subtype of system.Address
      end record;


end swig.Pointers;


-- tbd: use sensible default_Terminator's.
