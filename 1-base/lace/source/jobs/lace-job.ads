with
     ada.Calendar;


package lace.Job
--
--
--
is
   type Item is abstract tagged private;

   procedure perform (Self : in out Item);


   procedure Due_is (Self : in out Item;   Now : in ada.Calendar.Time);
   function  Due    (Self : in     Item)    return  ada.Calendar.Time;

   function  performed_Count (Self : in Item) return Natural;



   Never : constant ada.Calendar.Time;



private

   type Item is abstract tagged
      record
         Due             : ada.Calendar.Time;
         performed_Count : Natural          := 0;
      end record;



   use ada.Calendar;

   Never : constant ada.Calendar.Time := ada.Calendar.Time_of (year_Number 'First,
                                                               month_Number'First,
                                                               day_Number  'First);

end lace.Job;
