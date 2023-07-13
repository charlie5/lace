package lace.wide_Text.all_Tokens
--
-- Some of these functions require a very large stack size.
-- If a Storage_Error is raised, try setting stack size to 'unlimited'.
--
-- $ ulimit -s unlimited
--
is
   default_Max : constant := 8 * 1024;
   stack_Error : exception;


   ----------------------
   -- Character Delimiter
   --
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_1;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_2;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_4;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_8;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_16;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_32;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_64;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_128;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_256;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_512;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_1k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_2k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_4k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_8k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_16k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_32k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_64k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_128k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_256k;
   function Tokens (Self : in Item;   Delimiter  : in wide_Character := ' ';
                                      Trim       : in Boolean   := False;
                                      max_Tokens : in Positive  := default_Max) return wide_Text.items_512k;

   -------------------
   -- String Delimiter
   --
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_1;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_2;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_4;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_8;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_16;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_32;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_64;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_128;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_256;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_512;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_1k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_2k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_4k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_8k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_16k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_32k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_64k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_128k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_256k;
   function Tokens (Self : in Item;   Delimiter  : in wide_String;
                                      Trim       : in Boolean  := False;
                                      max_Tokens : in Positive := default_Max) return wide_Text.items_512k;

end lace.wide_Text.all_Tokens;
