package body cached_Rotation
is
   use
        ada.Numerics,
        float_elementary_Functions;


   the_Cache    : array (0 .. slot_Count - 1) of Matrix_2x2_type;

   Pi_x_2       : constant Float_type := Pi * 2.0;

   index_Factor : constant Float_type := Float_type (slot_Count) / Pi_x_2;
   --
   -- Slot 'i' holds the angle 'i * Pi_x_2 / slot_Count', so the slots divide a whole
   -- revolution and none repeats another. An index may then be wrapped with 'mod', which is
   -- an exact period. Dividing instead by 'slot_Count - 1' would make the last slot a second
   -- copy of the first, and the wrap would then slip by a slot every revolution.

   safe_Limit   : constant Float_type := Float_type (Long_Long_Integer'Last / 2) / index_Factor;
   --
   -- The largest angle whose product with 'index_Factor' is sure to fit a 'Long_Long_Integer',
   -- with a factor of two to spare. Reducing an angle below it costs one integer conversion
   -- rather than a call to 'Remainder', which is several times dearer than the whole of the
   -- library's own cosine.



   function to_Rotation (Angle : in Float_type) return Matrix_2x2_type
   is
      wide_slot_Count : constant Long_Long_Integer := Long_Long_Integer (slot_Count);
      the_Index       :          standard.Integer;
   begin
      -- 'mod' takes the sign of its right operand, which is positive, so either index below
      -- is already a slot and needs no further correction.
      --
      if abs Angle < safe_Limit
      then
         the_Index := standard.Integer (  Long_Long_Integer (Angle * index_Factor)
                                        mod wide_slot_Count);
         --
         -- Revolutions fall away with the 'mod', which is exact, so no reduction of the angle
         -- itself is needed. What the multiplication rounds away is no more than the angle's
         -- own representation had already lost.
      else
         the_Index := standard.Integer (Float_type'Remainder (Angle, Pi_x_2) * index_Factor)
                      mod slot_Count;
         --
         -- Beyond that, the angle is reduced first, so that an angle of any size at all is
         -- answered rather than overflowing the conversion. Such an angle carries no phase
         -- worth the name, its own representation being coarser than a whole revolution.
      end if;

      return the_Cache (the_Index);
   end to_Rotation;



begin
   for Each in the_Cache'Range
   loop
      declare
         Angle : constant Float_type := Float_type (Each) / Float_type (slot_Count) * Pi_x_2;

         C : constant Float_type := Cos (Angle);
         S : constant Float_type := Sin (Angle);
      begin
         the_Cache (Each) := to_Matrix_2x2 (C, -S,
                                            S,  C);
      end;
   end loop;
end cached_Rotation;
