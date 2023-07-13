with
     lace.wide_Text.all_Tokens,
     ada.Characters.wide_latin_1;


package body lace.wide_Text.all_Lines
is
   use lace.wide_Text.all_Tokens,
       ada.Characters.wide_latin_1;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_2
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_4
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_8
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_16
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_32
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_64
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_128
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_256
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_512
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_1k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_2k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_4k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_8k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_16k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_32k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_64k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_128k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_256k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return wide_Text.items_512k
   is
   begin
      return Tokens (Self, LF, Trim, max_Lines);
   end Lines;


end lace.wide_Text.all_Lines;
