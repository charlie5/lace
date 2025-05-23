with
     ada.Characters.latin_1,
     ada.Directories,
     ada.Direct_IO,
     ada.Streams.Stream_IO,
     ada.Text_IO;


package body lace.Text.forge
is
   --------
   -- Files
   --

   function File_to_String (Filename : in forge.Filename) return String
   is
      use ada.Characters,
          ada.Directories;

      Length : constant Natural := Natural (Size (String (Filename)));

      subtype sized_String is String (1 .. Length);

      package my_IO is new ada.Direct_IO (sized_String);
      use my_IO;

      the_File : my_IO.File_type;
      Pad      : sized_String;
      Result   : sized_String;
      i        : Natural := 0;
   begin
      if Length = 0
      then
         return "";
      end if;

      open  (the_File, in_File, String (Filename));
      read  (the_File, Pad);
      close (the_File);

      for Each of Pad
      loop
         if Each /= latin_1.CR
         then
            i          := i + 1;
            Result (i) := Each;
         end if;
      end loop;

      return Result (1 .. i);
   end File_to_String;



   function File_to_Text (Filename : in forge.Filename) return Item
   is
   begin
      return to_Text (File_to_String (Filename));
   end File_to_Text;



   procedure store (Filename : in forge.Filename;   the_String : in String)
   is
      use ada.Streams.Stream_IO;

      File : File_type;
      S    : Stream_access;
   begin
      create       (File, out_File, String (Filename));
      S := Stream  (File);
      String'write (S, the_String);
      close        (File);
   end store;



   --------------
   -- Stock Items
   --

   function to_Text_1 (From : in String) return Item_1
   is
   begin
      return to_Text (From, capacity => 1);
   end to_Text_1;

   function to_Text_1 (From : in Text.item) return Item_1
   is
   begin
      return to_Text (to_String (From), capacity => 1);
   end to_Text_1;


   function to_Text_2 (From : in String) return Item_2
   is
   begin
      return to_Text (From, capacity => 2);
   end to_Text_2;

   function to_Text_2 (From : in Text.item) return Item_2
   is
   begin
      return to_Text (to_String (From), capacity => 2);
   end to_Text_2;


   function to_Text_4 (From : in String) return Item_4
   is
   begin
      return to_Text (From, capacity => 4);
   end to_Text_4;

   function to_Text_4 (From : in Text.item) return Item_4
   is
   begin
      return to_Text (to_String (From), capacity => 4);
   end to_Text_4;


   function to_Text_8 (From : in String) return Item_8
   is
   begin
      return to_Text (From, capacity => 8);
   end to_Text_8;

   function to_Text_8 (From : in Text.item) return Item_8
   is
   begin
      return to_Text (to_String (From), capacity => 8);
   end to_Text_8;


   function to_Text_16 (From : in String) return Item_16
   is
   begin
      return to_Text (From, capacity => 16);
   end to_Text_16;

   function to_Text_16 (From : in Text.item) return Item_16
   is
   begin
      return to_Text (to_String (From), capacity => 16);
   end to_Text_16;


   function to_Text_32 (From : in String) return Item_32
   is
   begin
      return to_Text (From, capacity => 32);
   end to_Text_32;

   function to_Text_32 (From : in Text.item) return Item_32
   is
   begin
      return to_Text (to_String (From), capacity => 32);
   end to_Text_32;


   function to_Text_64 (From : in String) return Item_64
   is
   begin
      return to_Text (From, capacity => 64);
   end to_Text_64;

   function to_Text_64 (From : in Text.item) return Item_64
   is
   begin
      return to_Text (to_String (From), capacity => 64);
   end to_Text_64;


   function to_Text_128 (From : in String) return Item_128
   is
   begin
      return to_Text (From, capacity => 128);
   end to_Text_128;

   function to_Text_128 (From : in Text.item) return Item_128
   is
   begin
      return to_Text (to_String (From), capacity => 128);
   end to_Text_128;


   function to_Text_256 (From : in String) return Item_256
   is
   begin
      return to_Text (From, capacity => 256);
   end to_Text_256;

   function to_Text_256 (From : in Text.item) return Item_256
   is
   begin
      return to_Text (to_String (From), capacity => 256);
   end to_Text_256;


   function to_Text_512 (From : in String) return Item_512
   is
   begin
      return to_Text (From, capacity => 512);
   end to_Text_512;

   function to_Text_512 (From : in Text.item) return Item_512
   is
   begin
      return to_Text (to_String (From), capacity => 512);
   end to_Text_512;



   function to_Text_1k (From : in String) return Item_1k
   is
   begin
      return to_Text (From, capacity => 1024);
   end to_Text_1k;

   function to_Text_1k (From : in Text.item) return Item_1k
   is
   begin
      return to_Text (to_String (From), capacity => 1024);
   end to_Text_1k;


   function to_Text_2k (From : in String) return Item_2k
   is
   begin
      return to_Text (From, capacity => 2 * 1024);
   end to_Text_2k;

   function to_Text_2k (From : in Text.item) return Item_2k
   is
   begin
      return to_Text (to_String (From), capacity => 2 * 1024);
   end to_Text_2k;


   function to_Text_4k (From : in String) return Item_4k
   is
   begin
      return to_Text (From, capacity => 4 * 1024);
   end to_Text_4k;

   function to_Text_4k (From : in Text.item) return Item_4k
   is
   begin
      return to_Text (to_String (From), capacity => 4 * 1024);
   end to_Text_4k;


   function to_Text_8k (From : in String) return Item_8k
   is
   begin
      return to_Text (From, capacity => 8 * 1024);
   end to_Text_8k;

   function to_Text_8k (From : in Text.item) return Item_8k
   is
   begin
      return to_Text (to_String (From), capacity => 8 * 1024);
   end to_Text_8k;


   function to_Text_16k (From : in String) return Item_16k
   is
   begin
      return to_Text (From, capacity => 16 * 1024);
   end to_Text_16k;

   function to_Text_16k (From : in Text.item) return Item_16k
   is
   begin
      return to_Text (to_String (From), capacity => 16 * 1024);
   end to_Text_16k;


   function to_Text_32k (From : in String) return Item_32k
   is
   begin
      return to_Text (From, capacity => 32 * 1024);
   end to_Text_32k;

   function to_Text_32k (From : in Text.item) return Item_32k
   is
   begin
      return to_Text (to_String (From), capacity => 32 * 1024);
   end to_Text_32k;


   function to_Text_64k (From : in String) return Item_64k
   is
   begin
      return to_Text (From, capacity => 64 * 1024);
   end to_Text_64k;

   function to_Text_64k (From : in Text.item) return Item_64k
   is
   begin
      return to_Text (to_String (From), capacity => 64 * 1024);
   end to_Text_64k;


   function to_Text_128k (From : in String) return Item_128k
   is
   begin
      return to_Text (From, capacity => 128 * 1024);
   end to_Text_128k;

   function to_Text_128k (From : in Text.item) return Item_128k
   is
   begin
      return to_Text (to_String (From), capacity => 128 * 1024);
   end to_Text_128k;


   function to_Text_256k (From : in String) return Item_256k
   is
   begin
      return to_Text (From, capacity => 256 * 1024);
   end to_Text_256k;

   function to_Text_256k (From : in Text.item) return Item_256k
   is
   begin
      return to_Text (to_String (From), capacity => 256 * 1024);
   end to_Text_256k;


   function to_Text_512k (From : in String) return Item_512k
   is
   begin
      return to_Text (From, capacity => 512 * 1024);
   end to_Text_512k;

   function to_Text_512k (From : in Text.item) return Item_512k
   is
   begin
      return to_Text (to_String (From), capacity => 512 * 1024);
   end to_Text_512k;



   function to_Text_1m (From : in String) return Item_1m
   is
   begin
      return to_Text (From, capacity => 1024 * 1024);
   end to_Text_1m;

   function to_Text_1m (From : in Text.item) return Item_1m
   is
   begin
      return to_Text (to_String (From), capacity => 1024 * 1024);
   end to_Text_1m;


   function to_Text_2m (From : in String) return Item_2m
   is
   begin
      return to_Text (From, capacity => 2 * 1024 * 1024);
   end to_Text_2m;

   function to_Text_2m (From : in Text.item) return Item_2m
   is
   begin
      return to_Text (to_String (From), capacity => 2 * 1024 * 1024);
   end to_Text_2m;


   function to_Text_4m (From : in String) return Item_4m
   is
   begin
      return to_Text (From, capacity => 4 * 1024 * 1024);
   end to_Text_4m;

   function to_Text_4m (From : in Text.item) return Item_4m
   is
   begin
      return to_Text (to_String (From), capacity => 4 * 1024 * 1024);
   end to_Text_4m;


   function to_Text_8m (From : in String) return Item_8m
   is
   begin
      return to_Text (From, capacity => 8 * 1024 * 1024);
   end to_Text_8m;

   function to_Text_8m (From : in Text.item) return Item_8m
   is
   begin
      return to_Text (to_String (From), capacity => 8 * 1024 * 1024);
   end to_Text_8m;


   function to_Text_16m (From : in String) return Item_16m
   is
   begin
      return to_Text (From, capacity => 16 * 1024 * 1024);
   end to_Text_16m;

   function to_Text_16m (From : in Text.item) return Item_16m
   is
   begin
      return to_Text (to_String (From), capacity => 16 * 1024 * 1024);
   end to_Text_16m;


   function to_Text_32m (From : in String) return Item_32m
   is
   begin
      return to_Text (From, capacity => 32 * 1024 * 1024);
   end to_Text_32m;

   function to_Text_32m (From : in Text.item) return Item_32m
   is
   begin
      return to_Text (to_String (From), capacity => 32 * 1024 * 1024);
   end to_Text_32m;


   function to_Text_64m (From : in String) return Item_64m
   is
   begin
      return to_Text (From, capacity => 64 * 1024 * 1024);
   end to_Text_64m;

   function to_Text_64m (From : in Text.item) return Item_64m
   is
   begin
      return to_Text (to_String (From), capacity => 64 * 1024 * 1024);
   end to_Text_64m;


   function to_Text_128m (From : in String) return Item_128m
   is
   begin
      return to_Text (From, capacity => 128 * 1024 * 1024);
   end to_Text_128m;

   function to_Text_128m (From : in Text.item) return Item_128m
   is
   begin
      return to_Text (to_String (From), capacity => 128 * 1024 * 1024);
   end to_Text_128m;


   function to_Text_256m (From : in String) return Item_256m
   is
   begin
      return to_Text (From, capacity => 256 * 1024 * 1024);
   end to_Text_256m;

   function to_Text_256m (From : in Text.item) return Item_256m
   is
   begin
      return to_Text (to_String (From), capacity => 256 * 1024 * 1024);
   end to_Text_256m;


   function to_Text_512m (From : in String) return Item_512m
   is
   begin
      return to_Text (From, capacity => 512 * 1024 * 1024);
   end to_Text_512m;

   function to_Text_512m (From : in Text.item) return Item_512m
   is
   begin
      return to_Text (to_String (From), capacity => 512 * 1024 * 1024);
   end to_Text_512m;


end lace.Text.forge;
