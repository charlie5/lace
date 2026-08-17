generic
   type Float_type is digits <>;

   slot_Count : standard.Positive;

package cached_Trigonometry
--
-- Caches trig functions for speed at the cost of precision.
--
is
   pragma optimize (Time);

   function  Cos (Angle : in Float_type) return Float_type;
   function  Sin (Angle : in Float_type) return Float_type;


   procedure get (Angle : in Float_type;   the_Cos : out Float_type;
                                           the_Sin : out Float_type);

   -- TODO: tan, arccos, etc



private

   pragma inline_Always (Cos);
   pragma inline_Always (Sin);
   pragma inline_Always (Get);


end cached_Trigonometry;
