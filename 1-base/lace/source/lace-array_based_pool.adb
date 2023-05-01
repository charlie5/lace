with
     ada.Containers.Vectors,
     ada.Directories,
     ada.Finalization,
     ada.Streams.Stream_IO,

     system.storage_Elements;


package body lace.array_based_Pool
is
   type Items is array (Positive range <>) of aliased Item with Convention => C;     -- Convention is to ensure contiguity.
   type Views is array (Positive range <>) of         View;

   package View_Vectors is new ada.Containers.Vectors (Positive, View);
   subtype View_Vector  is     View_Vectors.Vector;




   protected Pool
   is
      procedure Size_is (Now : in Positive);

      entry new_Item (the_Item :    out View);
      entry free     (the_Item : in     View);

      function max_array_Size return Natural;
      function  max_heap_Size return Natural;

   private
      my_Items   : access Items;
      used_Count :        Natural := 0;

      array_Freed       : access Views;
      array_freed_Count :        Natural:= 0;

      heap_Freed : View_Vector;
      heap_Max   : Natural    := 0;
   end Pool;



   protected body Pool
   is

      procedure Size_is (Now : in Positive)
      is
      begin
         my_Items    := new Items (1 .. Now);
         array_Freed := new Views (1 .. Now);
      end Size_is;



      entry new_Item (the_Item : out View)
        when my_Items /= null
      is
         use ada.Containers,
             View_Vectors;
      begin
         if array_freed_Count > 0
         then
            -- Use a freed array item.
            --
            the_Item          := array_Freed (array_freed_Count);
            array_freed_Count := array_freed_Count - 1;
            return;
         end if;


         if used_Count < my_Items'Length
         then
            -- Use a fresh array item.
            --
            used_Count := used_Count + 1;
            the_Item   := my_Items (used_Count)'Access;
            return;
         end if;


         if heap_Freed.Length > 0
         then
            -- Use a freed heap item.
            --
            the_Item := heap_Freed.last_Element;
            heap_Freed.delete_Last;
            return;
         end if;


         -- Use a fresh heap item.
         --
         the_Item := new Item;
         heap_max := heap_Max + 1;
      end new_Item;



      entry free (the_Item : in View)
        when array_Freed /= null
      is
         use system.storage_Elements;

         item_Address  : constant integer_Address := to_Integer (the_Item.all             'Address);
         first_Address : constant integer_Address := to_Integer (my_Items (my_Items'First)'Address);
         last_Address  : constant integer_Address := to_Integer (my_Items (my_Items'Last) 'Address);

         is_an_array_Item : constant Boolean :=     item_Address >= first_Address
                                                and item_Address <=  last_Address;
      begin
         if is_an_array_Item
         then
            array_freed_Count               := array_freed_Count + 1;
            array_Freed (array_freed_Count) := the_Item;
         else
            heap_Freed.append (the_Item);
         end if;
      end free;



      function max_array_Size return Natural
      is
      begin
         return used_Count;
      end max_array_Size;



      function max_heap_Size return Natural
      is
      begin
         return heap_Max;
      end max_heap_Size;

   end Pool;




   function new_Item return View
   is
      Self : View;
   begin
      Pool.new_Item (Self);
      define (Self.all);

      return Self;
   end new_Item;




   procedure free (Self : in out View)
   is
   begin
      destroy (Self.all);
      Pool.free (Self);

      Self := null;
   end free;





   -- HWM: High water mark.


   actual_pool_Size : Positive;
   prior_HWM        : Positive;
   HWM_Filename     : constant String := "." & Name & "-high_water_mark";



   type Closure is new ada.finalization.Controlled with null record;

   overriding
   procedure finalize (Self : in out Closure)
   is
      use ada.Streams,
          ada.Streams.Stream_IO;

      HWM  : constant Positive := Pool.max_array_Size + Pool.max_heap_Size;
      File :          File_type;
      S    : access   Root_Stream_Type;
   begin
      if HWM > prior_HWM     -- TODO: Consider using the median of the last 5 HWM's.
      then
         create (File, out_File, HWM_Filename);

         S := Stream (File);
         String'output (S, HWM'Image);
         close (File);
      end if;
   end finalize;

   Closer : Closure with Unreferenced;



   use ada.Directories;

begin
   if not Exists (HWM_Filename)
   then
      actual_pool_Size := initial_pool_Size;
   else
      declare
         use ada.Streams,
             ada.Streams.Stream_IO;

         File :        File_type;
         S    : access Root_Stream_Type;
      begin
         open (File, in_File, HWM_Filename);

         S         := Stream (File);
         prior_HWM := Positive'Value (String'input (S));

         close (File);

         actual_pool_Size := prior_HWM;
      end;
   end if;

   Pool.Size_is (actual_pool_Size);


end lace.array_based_Pool;
