generic
   type Item is private;
   type View is access all Item;

   pool_Size : Positive := 5_000;

package lace.heap_based_Pool
is

   function  new_Item     return View;
   procedure free (Self : in out View);

end lace.heap_based_Pool;
