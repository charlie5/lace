package lace.Text.all_Lines
is
   default_Max : constant := 8 * 1024;


   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_2;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_4;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_8;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_16;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_32;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_64;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_128;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_256;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_512;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_1k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_2k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_4k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_8k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_16k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_32k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_64k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_128k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_256k;
   function Lines (Self : in Item; Trim      : in Boolean  := False;
                                   max_Lines : in Positive := default_Max) return Text.items_512k;

end lace.Text.all_Lines;
