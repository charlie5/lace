package lace.Text.utility
--
-- Provides utility subprograms.
--
is
   function  Contains (Self : in     Text.item;   Pattern : in String) return Boolean;


   function  replace  (Self : in     Text.item;   Pattern : in String;
                                                  By      : in String) return Text.item;
   --
   -- Replaces all occurences of 'Pattern' with 'By'.
   -- If the replacement exceeds the capacity of 'Self', the result will be expanded.

   procedure replace  (Self : in out Text.item;   Pattern : in String;
                                                  By      : in String);
   --
   -- Replaces all occurences of 'Pattern' with 'By'.
   -- 'Text.Error' will be raised if the replacement exceeds the capacity of 'Self'.

end lace.Text.utility;
