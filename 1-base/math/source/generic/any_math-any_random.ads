generic
package any_Math.any_Random
is
   function random_Real    (Lower : in Real := 0.0;
                            Upper : in Real := 1.0)              return Real;
   --
   -- Returns a value in Lower .. Upper.

   function random_Integer (Lower : in Integer := Integer'First;
                            Upper : in Integer := Integer'Last) return Integer;
   --
   -- Returns a value in Lower .. Upper. Raises Constraint_Error when Lower > Upper.

   function random_Boolean                                      return Boolean;

   --
   -- All three are task safe.

end any_Math.any_Random;
