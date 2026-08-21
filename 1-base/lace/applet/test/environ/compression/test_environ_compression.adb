with
     lace.Environ.Paths,
     ada.Text_IO;


procedure test_Environ_compression
is
   use
        lace.Environ.Paths,
        ada.Text_IO;

   test_Error  : exception;
   digits_Text : constant String := "0123456789";
begin
   put_Line ("Begin");

   ensure_Folder (+"tmp");
   go_to_Folder  (+"tmp");


   --- Compress single files.
   --

   save      (+"digits.txt-original", digits_Text);
   copy_File (+"digits.txt-original", To => +"digits.txt");

   for Each in compress_Format
   loop
      compress   (to_File ("digits.txt"), Each);
      rid_File   (+"digits.txt");
      decompress (+("digits.txt" & format_Suffix (Each)));

      if load (+"digits.txt") /= digits_Text
      then
         raise test_Error with "'" & load (+"digits.txt") & "'";
      end if;

      rid_File (+("digits.txt" & format_Suffix (Each)));
   end loop;


   --- Compress directories.
   --

   ensure_Folder (+"archive-original");
   move_Files    ("digits*",            To => +"archive-original");

   ensure_Folder (+"archive");
   copy_Files    ("archive-original/*", To => +"archive");

   for Each in folder_compress_Format
   loop
      compress   (to_Folder ("archive"), Each);
      rid_Folder (+"archive");
      decompress (+("archive" & format_Suffix (Each)));

      if   String'(load (+"archive/digits.txt"))
        /= String'(load (+"archive-original/digits.txt"))
      then
         raise test_Error with "'" & load (+"archive/digits.txt") & "'";
      end if;

      rid_File (+("archive" & format_Suffix (Each)));
   end loop;


   --- Tidy up.
   --

   go_to_Folder (+"..");
   rid_Folder   (+"tmp");

   put_Line ("Success");
end test_Environ_compression;
