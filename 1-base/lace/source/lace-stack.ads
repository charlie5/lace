private
with
     ada.Containers.Vectors;


generic
   type Element_t is private;
   initial_Capacity : Positive;

package lace.Stack
is
   type Item is private;

   function  to_Stack return Item;


   procedure push (Self : in out Item;   E : in Element_T);
   function  pop  (Self : in out Item)   return Element_T;


   function getCount (Self : in  Item)   return Natural;



private
   package Vectors is new ada.Containers.Vectors (Positive, Element_t);
   type    Item   is new Vectors.Vector with null record;

end lace.Stack;
