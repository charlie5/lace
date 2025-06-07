package body lace.Job
is

   procedure Due_is (Self : in out Item;   Now : in ada.Calendar.Time)
   is
   begin
      Self.Due := Now;
   end Due_is;



   function Due (Self : in Item) return ada.Calendar.Time
   is
   begin
      return Self.Due;
   end Due;



   function  performed_Count (Self : in Item) return Natural
   is
   begin
      return Self.performed_Count;
   end performed_Count;



   procedure perform (Self : in out Item)
   is
   begin
      Self.performed_Count := Self.performed_Count + 1;
   end perform;


end lace.Job;
