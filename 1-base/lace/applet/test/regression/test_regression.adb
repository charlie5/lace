with
     lace.Time,
     lace.Text.Cursor,
     lace.Text.utility,
     lace.Text.all_Tokens,
     lace.wide_Text.forge,
     lace.Job.Manager,
     lace.Dice.any,
     lace.Dice.d6,
     lace.Containers.shuffle_Vector,
     lace.fast_Pool,
     lace.Environ.Paths,

     ada.Calendar,
     ada.Command_Line,
     ada.Containers.Vectors,
     ada.Directories,
     ada.Streams.Stream_IO,
     ada.Strings.fixed,
     ada.Text_IO;


procedure test_Regression
--
-- Regression tests for the defects recorded in FIXES.md.
--
is
   use lace.Text,
       ada.Text_IO;

   Failures : Natural := 0;

   procedure check (Ok : in Boolean;   Label : in String)
   is
   begin
      if Ok
      then
         put_Line ("PASS: " & Label);
      else
         Failures := Failures + 1;
         put_Line ("FAIL: " & Label);
      end if;
   end check;


   type quiet_Job is new lace.Job.item with null record;   -- Inherits the base 'perform'.

   the_Job     : aliased quiet_Job;
   never_Job   : aliased quiet_Job;
   the_Manager :         lace.Job.Manager.item;

   Root : constant String := ada.Directories.current_Directory & "/work";

begin
   if ada.Directories.Exists (Root)
   then
      ada.Directories.delete_Tree (Root);
   end if;

   ada.Directories.create_Path (Root);

   put_Line ("Begin Test");
   new_Line;


   --- lace.Time
   --
   declare
      use lace.Time;

      all_Hours_Ok : Boolean := True;
   begin
      for H in Hours'Range
      loop
         if to_Duration (to_Time (Hours => H)) /= Duration (H) * 3_600
         then
            all_Hours_Ok := False;
         end if;
      end loop;

      check (all_Hours_Ok, "time: to_Duration over all hours");
      check (to_Duration (to_Time (Hours => 23, Minutes => 59, Seconds => 59)) = 86_399.0,
             "time: to_Duration composite");

      declare
         T : constant lace.Time.item := to_Time (3599.999_999);
      begin
         check (         T.Hours   = 0
                and then T.Minutes = 59
                and then T.Seconds = 59,
                "time: to_Time at an hour boundary");
      end;

      declare
         T : constant lace.Time.item := to_Time (Hours => 22) + to_Time (Hours => 1);
      begin
         check (T.Hours = 23, "time: '+' operator");
      end;
   end;


   --- lace.Text
   --
   check (to_String (delete (to_Text ("abcdef"), From => 3, Through => 4)) = "abef",
          "text: delete function form");

   declare
      use lace.Text.utility;
   begin
      check (to_String (replace (to_Text ("/a/b"), Pattern => "/some/long/folder/",
                                                   By      => "")) = "/a/b",
             "text: replace with a pattern longer than the text");
      check (to_String (replace (to_Text ("hello world"), Pattern => "world",
                                                          By      => "there")) = "hello there",
             "text: replace basic");
   end;

   declare
      use lace.Text.all_Tokens;

      the_Tokens : constant lace.Text.items_1k := Tokens (to_Text ("a b"));
   begin
      check (         the_Tokens'Length = 2
             and then to_String (the_Tokens (1)) = "a"
             and then to_String (the_Tokens (2)) = "b",
             "text: 1k tokens of a small input fit the stack");
   end;

   declare
      use lace.Text.all_Tokens;

      the_Tokens : constant lace.Text.items_1k := Tokens (to_Text ("a b "));
   begin
      check (         the_Tokens'Length = 3
             and then to_String (the_Tokens (3)) = "",
             "text: trailing delimiter yields an empty token");
   end;


   --- Below-cap: text fixes
   --
   declare
      T : lace.Text.item := to_Text ("abcdef");
   begin
      delete (T, From => 5, Through => 2);
      check (to_String (T) = "abcdef", "text: delete of an inverted range is a no-op");

      delete (T, From => 20, Through => 30);
      check (to_String (T) = "abcdef", "text: delete of a past-the-end range is a no-op");
   end;

   declare
      use ada.Streams;

      F : Stream_IO.File_type;
   begin
      Stream_IO.create (F, Stream_IO.out_File, Root & "/empty_text.stream");
      lace.Text.item'output (Stream_IO.Stream (F), to_Text (""));
      Stream_IO.close  (F);

      Stream_IO.open (F, Stream_IO.in_File, Root & "/empty_text.stream");

      declare
         T : constant lace.Text.item := lace.Text.item'input (Stream_IO.Stream (F));
      begin
         Stream_IO.close (F);
         check (Length (T) = 0, "text: empty text survives a stream round-trip");
      end;
   end;

   declare
      use lace.Text.Cursor;

      T : aliased constant lace.Text.item := to_Text ("a,b,c");
      C :         lace.Text.Cursor.item   := First (T'Access);
   begin
      C.advance (Delimiter => ",", Repeat => 1, skip_Delimiter => False);
      check (C.peek (Length => 1) = ",", "cursor: advance with Repeat finds the next delimiter");
      check (C.Length = 2,               "cursor: advance with Repeat stops at the right spot");
   end;

   declare
      use lace.Text.Cursor;

      T      : aliased constant lace.Text.item := to_Text ("42");
      C      :         lace.Text.Cursor.item   := First (T'Access);
      Value  :         Integer;
      Got_it :         Boolean                 := False;
   begin
      Value := C.get_Integer;
      check (Value = 42, "cursor: get_Integer reads a value");

      begin
         Value  := C.get_Integer;
         Got_it := True;

      exception
         when no_data_Error =>
            null;
      end;

      check (not Got_it, "cursor: get_Integer at end raises no_data_Error");
   end;

   declare
      use lace.Text.utility;

      long_A : constant String := [1 .. 2_000 => 'x'];
      long_B : constant String := [1 .. 2_000 => 'y'];
   begin
      check (to_String (replace (to_Text (long_A & "|" & long_B),
                                 Pattern => "|",
                                 By      => "-")) = long_A & "-" & long_B,
             "text: replace handles segments beyond the old 1k ceiling");

      check (to_String (replace (to_Text (""), Pattern => "x", By => "y")) = "",
             "text: replace of an empty text is empty");
   end;

   declare
      use lace.Text.all_Tokens;

      the_Tokens : constant lace.Text.items_1k := Tokens (to_Text ("a::"), Delimiter => "::");
   begin
      check (         the_Tokens'Length = 2
             and then to_String (the_Tokens (2)) = "",
             "text: string-delimiter tokens match the char variant on a trailing delimiter");
   end;

   declare
      use lace.wide_Text;
   begin
      lace.Environ.Paths.save (lace.Environ.Paths.to_File (Root & "/wide.txt"), "hello wide");

      check (forge.to_String (forge.Filename (Root & "/wide.txt")) = "hello wide",
             "wide text: forge.to_String reads a file");
   end;


   --- Below-cap: dice, shuffle, pools
   --
   declare
      use lace.Dice;

      d   : constant any.item := any.to_Dice (Sides => 6, Rolls => 1);
      bad : constant any.item := any.to_Dice (Sides => 6, Rolls => 1, Modifier => -10);

      the_Roll : Natural;
      Ok       : Boolean  := True;
      seen_Min : Boolean  := False;
      seen_Max : Boolean  := False;
   begin
      for i in 1 .. 10_000
      loop
         the_Roll := d.Roll;

         if the_Roll not in 1 .. 6
         then
            Ok := False;
         end if;

         seen_Min := seen_Min or the_Roll = 1;
         seen_Max := seen_Max or the_Roll = 6;
      end loop;

      check (Ok,                   "dice: every roll is within 1 .. side_Count");
      check (seen_Min and seen_Max, "dice: rolls reach both extremes");
      check (bad.Roll = 0,          "dice: a large negative modifier floors at 0");

      declare
         six : constant d6.item := d6.to_Dice (Rolls => 3);
      begin
         Ok := True;

         for i in 1 .. 1_000
         loop
            if six.Roll not in 3 .. 18
            then
               Ok := False;
            end if;
         end loop;

         check (Ok, "dice: 3d6 stays within 3 .. 18");
      end;
   end;

   declare
      package int_Vectors is new ada.Containers.Vectors (Positive, Integer);
      procedure shuffle   is new lace.Containers.shuffle_Vector (int_Vectors);

      use type int_Vectors.Vector;

      Original : int_Vectors.Vector;
      A, B     : int_Vectors.Vector;

      function sorted (V : in int_Vectors.Vector) return int_Vectors.Vector
      is
         package Sorter is new int_Vectors.generic_Sorting;

         Result : int_Vectors.Vector := V;
      begin
         Sorter.sort (Result);
         return Result;
      end sorted;

   begin
      for i in 1 .. 12
      loop
         Original.append (i);
      end loop;

      A := Original;   shuffle (A);
      B := Original;   shuffle (B);

      check (sorted (A) = Original and sorted (B) = Original,
             "shuffle: the elements are preserved");
      check (A /= B or A /= Original,
             "shuffle: two shuffles are not both the identity");
   end;

   declare
      type int_View is access all Integer;

      package tiny_Pool is new lace.fast_Pool (Item      => Integer,
                                               View      => int_View,
                                               pool_Size => 2);

      Items : array (1 .. 4) of int_View;
   begin
      for Each of Items
      loop
         Each := tiny_Pool.new_Item;
      end loop;

      for Each of Items
      loop
         tiny_Pool.free (Each);     -- Two more frees than the pool can hold.
      end loop;

      check (tiny_Pool.new_Item /= null, "pools: freeing beyond the pool size is harmless");
   end;


   --- lace.Job
   --
   declare
      use ada.Calendar;
   begin
      the_Job  .Due_is (Clock - 60.0);
      never_Job.Due_is (lace.Job.Never);

      the_Manager.add (never_Job'unchecked_Access);
      the_Manager.add (the_Job  'unchecked_Access);

      the_Manager.do_Jobs;
      check (the_Job.performed_Count = 1, "jobs: due job performed once per pass");

      the_Manager.do_Jobs;
      check (the_Job.performed_Count = 2, "jobs: due job performed again next pass");
   end;


   --- lace.Environ
   --
   declare
      use lace.Environ.Paths;

      use type ada.Streams.stream_Element_array;

      F : constant File               := to_File (Root & "/bin_test.dat");
      D : constant lace.Environ.Data := [1, 2, 3, 255];
   begin
      save (F, D);

      declare
         L : constant lace.Environ.Data := load (F);
      begin
         check (L = D, "environ: binary save/load round-trip on a new file");
      end;
   end;

   declare
      use lace.Environ.Paths,
          ada.Strings.fixed;
   begin
      ensure_Folder (to_Folder (Root & "/glob"));

      save (to_File (Root & "/glob/g1.txt"),   "one");
      save (to_File (Root & "/glob/g2.txt"),   "two");
      save (to_File (Root & "/glob/skip.dat"), "three");

      declare
         Expanded : constant String := expand_GLOB (Root & "/glob/*.txt");
      begin
         check (         Index (Expanded, "g1.txt")   > 0
                and then Index (Expanded, "g2.txt")   > 0
                and then Index (Expanded, "skip.dat") = 0,
                "environ: expand_GLOB");
      end;

      ensure_Folder (to_Folder (Root & "/globbed"));
      copy_Files    (Root & "/glob/*.txt", To => to_Folder (Root & "/globbed"));

      check (         Exists (to_File (Root & "/globbed/g1.txt"))
             and then Exists (to_File (Root & "/globbed/g2.txt")),
             "environ: copy_Files with a GLOB");
   end;

   declare
      use lace.Environ.Paths;

      spacey_Folder : constant Folder := to_Folder (Root & "/my folder");
      Dest          : constant Folder := to_Folder (Root & "/dest");
   begin
      ensure_Folder (spacey_Folder);
      save          (to_File (Root & "/my folder/inner.txt"), "hi");
      ensure_Folder (Dest);
      copy_Folder   (spacey_Folder, To => Dest);

      check (Exists (to_File (Root & "/dest/my folder/inner.txt")),
             "environ: copy_Folder of a folder containing a space");

      touch (to_File (Root & "/sp ace.txt"));
      check (Exists (to_File (Root & "/sp ace.txt")),
             "environ: touch of a file containing a space");
   end;


   ada.Directories.delete_Tree (Root);

   new_Line;

   if Failures = 0
   then
      put_Line ("Success");
   else
      put_Line ("Failures:" & Failures'Image);
      ada.Command_Line.set_Exit_Status (1);
   end if;

   put_Line ("End Test");
end test_Regression;
