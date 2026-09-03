with
     ada.Numerics.discrete_Random;


package body openGL.Palette
is
   package random_Colors is new ada.Numerics.discrete_Random (Color_Value);


   protected safe_Generator     -- Random generators are not task safe, and any task may ask for a random color.
   is
      procedure reset;
      procedure next (Value : out color_Value);
   private
      the_Generator : random_Colors.Generator;
   end safe_Generator;


   protected
   body safe_Generator
   is
      procedure reset
      is
      begin
         random_Colors.reset (the_Generator);
      end reset;


      procedure next (Value : out color_Value)
      is
      begin
         Value := random_Colors.random (the_Generator);
      end next;
   end safe_Generator;



   function random_Color return Color
   is
      Red, Green, Blue : color_Value;
   begin
      safe_Generator.next (Red);
      safe_Generator.next (Green);
      safe_Generator.next (Blue);

      return +(Red, Green, Blue);
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
         return   Value_1
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
      return          Self.Red   <= To.Red   + Similarity
             and then Self.Red   >= To.Red   - Similarity
             and then Self.Green <= To.Green + Similarity
             and then Self.Green >= To.Green - Similarity
             and then Self.Blue  <= To.Blue  + Similarity
             and then Self.Blue  >= To.Blue  - Similarity;
   end is_Similar;


begin
   safe_Generator.reset;
end openGL.Palette;
