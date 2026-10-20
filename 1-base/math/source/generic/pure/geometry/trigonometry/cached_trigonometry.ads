generic
   type Float_type is digits <>;

   slot_Count : standard.Positive;
   --
   -- How many samples are taken of each cached function. Two or more.

   prefer_Cache : standard.Boolean := Float_type'Digits > 10;
   --
   -- Whether Cos, Sin and 'get' answer from the table, or hand the angle to the library.
   --
   -- The default follows measurement on a current x86-64, where the library's single precision
   -- sine and cosine are quicker than any table lookup can be, while its double precision ones
   -- are not. Measure before trusting that on another target.
   --
   -- The three move together, so that an angle's cosine is the same number whichever of them
   -- is asked for it.

package cached_Trigonometry
--
-- Caches trig functions for speed at the cost of precision.
--
-- Cos, Sin and 'get' answer from a table of 'slot_Count' samples spanning one revolution,
-- taking the sample nearest the angle asked for. The angle used is at worst half a slot from
-- the one given, and so is the answer, since neither sin nor cos changes faster than its
-- angle. Any angle is accepted, whatever revolutions it carries. Given 'prefer_Cache' as
-- False, these three call the library instead and are exact, and the table is never built.
--
-- arcCos and arcSin always answer from a table spanning the ratios -1.0 .. 1.0, a lookup
-- being the quicker at every precision measured. A ratio outside that range is clamped rather
-- than refused, the usual caller being a normalised dot product which rounding can carry a
-- little past either end. Both functions steepen without bound towards those ends, where the
-- cached answer is correspondingly coarse.
--
-- Tan is never cached. See the body for why.
--
is
   function  Cos (Angle : in Float_type) return Float_type;
   function  Sin (Angle : in Float_type) return Float_type;
   function  Tan (Angle : in Float_type) return Float_type;


   procedure get (Angle : in Float_type;   the_Cos : out Float_type;
                                           the_Sin : out Float_type);

   function  arcCos (Ratio : in Float_type) return Float_type;
   function  arcSin (Ratio : in Float_type) return Float_type;



private

   pragma inline_Always (Cos);
   pragma inline_Always (Sin);
   pragma inline_Always (Tan);
   pragma inline_Always (Get);

   pragma inline_Always (arcCos);
   pragma inline_Always (arcSin);

end cached_Trigonometry;
