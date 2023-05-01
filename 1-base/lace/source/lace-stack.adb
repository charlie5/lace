package body lace.Stack
is
   use ada.Containers;


   function to_Stack return Item
   is
      Self : Item;
   begin
      Self.reserve_Capacity (Count_type (initial_Capacity));
      return Self;
   end to_Stack;




   procedure push (Self : in out Item;   E : in Element_T)
   is
      pragma assert (Check   => Self.Capacity >= Count_type (initial_Capacity),
                     Message => "Stack has not been initialised.");
   begin
      Self.append (E);
   end push;



   function pop (Self : in out Item) return Element_T
   is
      Top : constant Element_t := Self.last_Element;
   begin
      Self.delete_Last;
      return Top;
   end pop;




   function getCount (Self : in  Item) return Natural
   is
   begin
      return Natural (Self.Length);
   end getCount;


end lace.Stack;