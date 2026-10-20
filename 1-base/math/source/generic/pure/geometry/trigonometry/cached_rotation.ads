with
     ada.Numerics.generic_elementary_Functions;


generic
   type Float_type      is digits <>;
   type Matrix_2x2_type is private;

   with package  float_elementary_Functions is new ada.Numerics.generic_elementary_Functions (Float_type);
   with function to_Matrix_2x2 (m11, m12,
                                m21, m22 : in Float_type) return Matrix_2x2_type;
   --
   -- Builds the matrix whose first row is 'm11, m12' and whose second is 'm21, m22'.
   --
   -- The cache calls this with the column-vector form of a rotation by its angle:
   --
   --    m11 =  Cos (Angle)     m12 = -Sin (Angle)
   --    m21 =  Sin (Angle)     m22 =  Cos (Angle)
   --
   -- which turns a column vector anticlockwise, as 'M * v'. An instantiation which wants the
   -- row-vector form, turning 'v * M', must transpose as it builds: lace works in row vectors,
   -- so 'any_Math.any_fast_Rotation' passes a constructor which swaps 'm12' and 'm21', giving
   -- the same matrix 'any_Math.any_Algebra.any_linear.any_d2.to_rotation_Matrix' returns.
   --
   -- Taking the four in the order given, and then using the matrix on a row vector, turns by
   -- minus the angle. That is the one mistake this formal invites, and nothing here can catch
   -- it, 'Matrix_2x2_type' being private to the cache.

   slot_Count : standard.Positive;

package cached_Rotation
--
-- Caches 2x2 rotation matrices of angles for speed at the cost of precision.
--
-- The matrices come in the column-vector convention. An instantiation wanting the row-vector
-- one transposes them as it builds them: see 'to_Matrix_2x2' above.
--
-- A slot is taken by nearest neighbour, so the angle used is at worst half a slot from the one
-- asked for, and each matrix is the exact rotation of its own slot's angle, orthonormal to
-- within the rounding of its cosine and sine. Any angle is accepted, whatever revolutions it
-- carries.
--
is
   function to_Rotation (Angle : in Float_type) return Matrix_2x2_type;



private

   pragma inline_Always (to_Rotation);


end cached_Rotation;
