with
     ada.Calendar;


package collada.Asset
--
-- Models a collada asset.
--
is
   type Contributor is
      record
         Author         : Text;
         authoring_Tool : Text;
      end record;


   type Unit is
      record
         Name  : Text  := to_Text ("meter");
         Meter : Float := 1.0;
      end record;


   type up_Direction is (X_up, Y_up, Z_up);


   unknown_Time : constant ada.Calendar.Time;
   --
   -- The creation or modification time when the document gives none, or gives one
   -- in a form other than ISO 8601.


   type Item is
      record
         Contributor : asset.Contributor;
         Created     : ada.Calendar.Time := unknown_Time;
         Modified    : ada.Calendar.Time := unknown_Time;
         Unit        : asset.Unit;
         up_Axis     : up_Direction      := Y_up;
      end record;



private

   unknown_Time : constant ada.Calendar.Time := ada.Calendar.Time_of (ada.Calendar.Year_Number'First, 1, 1);

end collada.Asset;
