with
     lace.Dice.d6,
     lace.Dice.any,
     ada.Text_IO;


procedure test_Dice
is
   procedure log (Message : in String) renames ada.Text_IO.put_Line;

   test_Error : exception;

begin
   log ("Begin Test");


   -- d6x1
   --
   log ("");
   log ("d6x1_less5 Roll:" & lace.Dice.d6.d6x1_less5.Roll'Image);
   log ("d6x1_less4 Roll:" & lace.Dice.d6.d6x1_less4.Roll'Image);
   log ("d6x1_less3 Roll:" & lace.Dice.d6.d6x1_less3.Roll'Image);
   log ("d6x1_less2 Roll:" & lace.Dice.d6.d6x1_less2.Roll'Image);
   log ("d6x1_less1 Roll:" & lace.Dice.d6.d6x1_less1.Roll'Image);
   log ("d6x1       Roll:" & lace.Dice.d6.d6x1      .Roll'Image);
   log ("d6x1_plus1 Roll:" & lace.Dice.d6.d6x1_plus1.Roll'Image);
   log ("d6x1_plus2 Roll:" & lace.Dice.d6.d6x1_plus2.Roll'Image);


   -- d6x2
   --
   log ("");
   log ("d6x2_less1 Roll:" & lace.Dice.d6.d6x2_less1.Roll'Image);
   log ("d6x2       Roll:" & lace.Dice.d6.d6x2      .Roll'Image);
   log ("d6x2_plus1 Roll:" & lace.Dice.d6.d6x2_plus1.Roll'Image);
   log ("d6x2_plus2 Roll:" & lace.Dice.d6.d6x2_plus2.Roll'Image);


   -- any
   --
   declare
      use lace.Dice,
          lace.Dice.any;

      d100 : constant lace.Dice.any.item := to_Dice (Sides    => 100,
                                                     Rolls    => 1,
                                                     Modifier => 0);
      the_Roll      : Natural;
      one_Count     : Natural := 0;
      hundred_Count : Natural := 0;
   begin
      for i in 1 .. 1_000
      loop
         the_Roll := d100.Roll;

         case the_Roll
         is
            when      0 => raise test_Error with "Roll was 0.";
            when      1 =>     one_Count :=     one_Count + 1;
            when    100 => hundred_Count := hundred_Count + 1;
            when    101 => raise test_Error with "Roll was 101.";
            when others => null;
         end case;
      end loop;

      log ("");
      log ("1   rolled" &     one_Count'Image & " times.");
      log ("100 rolled" & hundred_Count'Image & " times.");
   end;


   log ("");
   log ("End Test");
end test_Dice;
