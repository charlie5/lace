with
     ada.Numerics.discrete_Random;


package body openGL.Palette
is
   package random_Colors is new ada.Numerics.discrete_Random (Color_Value);
   use     random_Colors;

   the_Generator : random_Colors.Generator;



   function random_Color return Color
   is
   begin
      return +(random (the_Generator),
               random (the_Generator),
               random (the_Generator));
   end random_Color;



   function Shade_of (Self : in Color;   Level : in Shade_Level) return Color
   is
   begin
      return (Self.Red   * Primary (Level),
              Self.Green * Primary (Level),
              Self.Blue  * Primary (Level));
   end Shade_of;



   function Mixed (Self : in Color;   Other : in Color;
                                      Mix   : in mix_Factor := 0.5) return Color
   is
      function Interpolate (Value_1, Value_2 : in Primary) return Primary     -- Linear interpolate.
      is
      begin
         return    Value_1
                + (Value_2 - Value_1) * Primary (Mix);
      end Interpolate;

   begin
      return (Interpolate (Self.Red,   Other.Red),
              Interpolate (Self.Green, Other.Green),
              Interpolate (Self.Blue,  Other.Blue));
   end Mixed;



   function is_Similar (Self : in Color;   To         : in Color;
                                           Similarity : in Primary := default_Similarity) return Boolean
   is
   begin
      return     Self.Red   <= to.Red   + Similarity
        and then Self.Red   >= to.Red   - Similarity
        and then Self.Green <= to.Green + Similarity
        and then Self.Green >= to.Green - Similarity
        and then Self.Blue  <= to.Blue  + Similarity
        and then Self.Blue  >= to.Blue  - Similarity;
   end is_Similar;


begin
   reset (the_Generator);
end openGL.Palette;
