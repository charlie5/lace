package body lace.Dice
is

   function Extent (Self : in Item'Class) return an_Extent
   is
   begin
      return (Min => Self.roll_Count                   + Self.Modifier,
              Max => Self.roll_Count * Self.side_Count + Self.Modifier);
   end Extent;



   function Image (Self : in Item'Class) return String
   is
      roll_count_Image : constant String := Integer'Image (Self.roll_Count);


      function side_count_Image return String
      is
      begin
         if Self.side_Count = 6
         then
            return "";
         else
            declare
               the_Image : constant String := Integer'Image (Self.side_Count);
            begin
               return the_Image (the_Image'First + 1 .. the_Image'Last);
            end;
         end if;
      end side_count_Image;



      function modifier_Image return String
      is
      begin
         if Self.Modifier = 0
         then
            return "";
         else
            declare
               the_Image : String := Integer'Image (Self.Modifier);
            begin
               if Self.Modifier > 0
               then
                  the_Image (the_Image'First) := '+';
               end if;

               return the_Image;
            end;
         end if;
      end modifier_Image;


   begin
      return   roll_count_Image (roll_count_Image'First + 1 .. roll_count_Image'Last)
             & "d"
             & side_count_Image
             & modifier_Image;
   end Image;


end lace.Dice;
