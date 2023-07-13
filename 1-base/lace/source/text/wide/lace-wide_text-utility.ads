package lace.wide_Text.utility
--
-- Provides utility subprograms.
--
is
   function  contains (Self : in     wide_Text.item;   Pattern : in wide_String) return Boolean;


   function  replace  (Self : in     wide_Text.item;   Pattern : in wide_String;
                                                       By      : in wide_String) return wide_Text.item;
   --
   -- Replaces all occurences of 'Pattern' with 'By'.
   -- If the replacement exceeds the capacity of 'Self', the result will be expanded.

   procedure replace  (Self : in out wide_Text.item;   Pattern : in wide_String;
                                                       By      : in wide_String);
   --
   -- Replaces all occurences of 'Pattern' with 'By'.
   -- 'Text.Error' will be raised if the replacement exceeds the capacity of 'Self'.

end lace.wide_Text.utility;
