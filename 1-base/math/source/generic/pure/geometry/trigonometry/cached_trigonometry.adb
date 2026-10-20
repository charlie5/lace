with
     ada.Numerics.generic_elementary_Functions;


package body cached_Trigonometry
is
   cos_Cache    : array (0 .. slot_Count - 1) of Float_Type;
   sin_Cache    : array (0 .. slot_Count - 1) of Float_Type;
   --
   -- Declared whatever 'prefer_Cache' says, but left unfilled and unread when it is False.
   -- Pages never touched cost nothing worth saving a branch for.

   arcCos_Cache : array (0 .. slot_Count - 1) of Float_Type;
   arcSin_Cache : array (0 .. slot_Count - 1) of Float_Type;

   Pi_x_2       : constant Float_Type := 2.0 * ada.Numerics.Pi;

   angle_Factor : constant Float_Type := Float_Type (slot_Count) / Pi_x_2;
   --
   -- Slot 'i' holds the angle 'i * Pi_x_2 / slot_Count', so the slots divide a whole
   -- revolution and none repeats another. An index may then be wrapped with 'mod', which
   -- is an exact period. Dividing instead by 'slot_Count - 1' would make the last slot a
   -- second copy of the first, and the wrap would then slip by a slot every revolution.

   safe_Limit   : constant Float_Type := Float_Type (Long_Long_Integer'Last / 2) / angle_Factor;
   --
   -- The largest angle whose product with 'angle_Factor' is sure to fit a 'Long_Long_Integer',
   -- with a factor of two to spare. Reducing an angle below it costs one integer conversion
   -- rather than a call to 'Remainder', which is several times dearer than the whole of the
   -- library's cosine.

   ratio_Factor : constant Float_Type := Float_Type (slot_Count - 1) / 2.0;
   --
   -- Slot 'i' holds the ratio '-1.0 + 2.0 * i / (slot_Count - 1)', so the slots span
   -- -1.0 .. 1.0 with both ends included. This domain does not wrap, so here the last slot
   -- is an end point rather than a repeat of the first.

   package Functions is new ada.Numerics.generic_elementary_Functions (Float_Type);



   function angle_Slot (Angle : in Float_Type) return standard.Integer
   is
      wide_slot_Count : constant Long_Long_Integer := Long_Long_Integer (slot_Count);
   begin
      -- 'mod' takes the sign of its right operand, which is positive, so either result below
      -- is already a slot index and needs no further correction.
      --
      if abs Angle < safe_Limit
      then
         return standard.Integer (Long_Long_Integer (Angle * angle_Factor) mod wide_slot_Count);
         --
         -- Revolutions fall away with the 'mod', which is exact, so no reduction of the angle
         -- itself is needed. What the multiplication rounds away is no more than the angle's
         -- own representation had already lost.
      end if;

      return standard.Integer (Float_Type'Remainder (Angle, Pi_x_2) * angle_Factor) mod slot_Count;
      --
      -- Beyond that, the angle is reduced first, so that an angle of any size at all is
      -- answered rather than overflowing the conversion. Such an angle carries no phase worth
      -- the name, its own representation being coarser than a whole revolution.
   end angle_Slot;



   function ratio_Slot (Ratio : in Float_Type) return standard.Integer
   is
   begin
      -- Clamped, rather than refused: the usual caller is a normalised dot product, which
      -- rounding can carry a little beyond either end of -1.0 .. 1.0. The ratio is clamped
      -- before any arithmetic, since a ratio far outside the range would overflow the
      -- conversion below long before an index could be examined.
      --
      if Ratio <= -1.0
      then
         return 0;
      end if;

      if Ratio >= 1.0
      then
         return slot_Count - 1;
      end if;

      return standard.Integer ((Ratio + 1.0) * ratio_Factor);
      --
      -- Strictly within the range, the product lies in 0.0 .. slot_Count - 1, so the
      -- conversion can neither overflow nor leave the table.
   end ratio_Slot;



   function Cos (Angle : in Float_Type) return Float_Type
   is
   begin
      if prefer_Cache
      then
         return cos_Cache (angle_Slot (Angle));
      end if;

      return Functions.Cos (Angle);
   end Cos;



   function Sin (Angle : in Float_Type) return Float_Type
   is
   begin
      if prefer_Cache
      then
         return sin_Cache (angle_Slot (Angle));
      end if;

      return Functions.Sin (Angle);
   end Sin;



   function Tan (Angle : in Float_Type) return Float_Type
   --
   -- Not cached, and deliberately so. Each pole falls between two slots, where the tangent
   -- changes sign and grows without bound, so taking the nearest slot can answer with the
   -- wrong sign and a magnitude out by any factor at all. No sampling of a uniform grid of
   -- angles avoids that, so the library function serves instead.
   --
   is
   begin
      return Functions.Tan (Angle);
   end Tan;



   procedure get (Angle : in Float_Type;   the_Cos : out Float_Type;
                                           the_Sin : out Float_Type)
   is
   begin
      if prefer_Cache
      then
         declare
            Index : constant standard.Integer := angle_Slot (Angle);
         begin
            the_Cos := cos_Cache (Index);
            the_Sin := sin_Cache (Index);
         end;

      else
         the_Cos := Functions.Cos (Angle);
         the_Sin := Functions.Sin (Angle);
      end if;
   end get;



   function arcCos (Ratio : in Float_type) return Float_type
   is
   begin
      return arcCos_Cache (ratio_Slot (Ratio));
   end arcCos;



   function arcSin (Ratio : in Float_type) return Float_type
   is
   begin
      return arcSin_Cache (ratio_Slot (Ratio));
   end arcSin;


begin
   if prefer_Cache
   then
      for Each in cos_Cache'Range
      loop
         declare
            Angle : constant Float_Type := Float_Type (Each) / Float_Type (slot_Count) * Pi_x_2;
         begin
            cos_Cache (Each) := Functions.Cos (Angle);
            sin_Cache (Each) := Functions.Sin (Angle);
         end;
      end loop;
   end if;


   for Each in arcCos_Cache'Range
   loop
      declare
         Ratio : constant Float_Type := -1.0 + 2.0 * Float_Type (Each) / Float_Type (slot_Count - 1);
      begin
         arcCos_Cache (Each) := Functions.arcCos (Ratio);
         arcSin_Cache (Each) := Functions.arcSin (Ratio);
      end;
   end loop;

end cached_Trigonometry;
