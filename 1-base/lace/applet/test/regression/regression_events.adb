package body regression_Events
is

   overriding
   procedure respond (Self : in out counting_Response;   to_Event : in lace.Event.item'Class)
   is
   begin
      Self.Count := Self.Count + 1;

      if tick_Event (to_Event).Id /= Self.Count
      then
         Self.in_Order := False;
      end if;
   end respond;

end regression_Events;
