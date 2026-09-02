with
     ada.Numerics.float_Random;


procedure lace.Containers.shuffle_Vector (the_Vector : in out Vectors.Vector)
is
   use ada.Numerics.float_Random;

   use type Vectors.Index_type;
   use type ada.Containers.Count_type;

   the_Generator : Generator;
begin
   if the_Vector.Length < 2
   then
      return;     -- Nothing to shuffle.
   end if;

   reset (the_Generator);

   for i in reverse 2 .. Vectors.Index_type (the_Vector.Length)    -- Start from 2, since swapping the
   loop                                                            -- first element with itself is useless.
      declare
         First  : constant Vectors.Index_type := Vectors.Index_type'First;
         Last   : constant Vectors.Index_type := First + i - 1;

         Offset : constant Vectors.Index_type'Base
           := Vectors.Index_type'Base (Float'Floor (  Random (the_Generator)
                                                    * Float (i)));

         Pick   : constant Vectors.Index_type
           := Vectors.Index_type'Min (Last,               -- 'Random' can return 1.0, so clamp to 'Last'.
                                      First + Offset);
      begin
         the_Vector.swap (Pick, Last);
      end;
   end loop;
end lace.Containers.shuffle_Vector;
