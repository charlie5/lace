private
with
     ada.Containers.Vectors;


generic
   type Element_t is private;
   initial_Capacity : Positive;

package lace.Stack
is
   type Item is private;


   ---------
   --- Forge
   --

   function to_Stack return Item;


   --------------
   --- Attributes
   --

   function get_Count (Self : in Item) return Natural;


   --------------
   --- Operations
   --

   procedure push (Self : in out Item;   the_Item : in Element_t);
   function  pop  (Self : in out Item)          return Element_t;



private

   package Vectors is new ada.Containers.Vectors (Positive, Element_t);
   type    Item    is new Vectors.Vector with null record;


end lace.Stack;
