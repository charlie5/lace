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



   function get_Count (Self : in Item) return Natural
   is
   begin
      return Natural (Self.Length);
   end get_Count;



   procedure push (Self : in out Item;   the_Item : in Element_t)
   is
      pragma assert (Check   => Self.Capacity >= Count_type (initial_Capacity),
                     Message => "Stack has not been initialised.");
   begin
      Self.append (the_Item);
   end push;



   function pop (Self : in out Item) return Element_t
   is
      Top : constant Element_t := Self.last_Element;
   begin
      Self.delete_Last;
      return Top;
   end pop;


end lace.Stack;
