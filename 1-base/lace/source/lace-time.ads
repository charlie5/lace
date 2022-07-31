package lace.Time
--
-- Time of day.
--
is
   type Hours        is range 0 ..      23;
   type Minutes      is range 0 ..      59;
   type Seconds      is range 0 ..      59;
   type milliSeconds is range 0 ..     999;
   type microSeconds is range 0 .. 999_999;


   function to_milliSeconds (From : microSeconds) return milliSeconds;
   function to_microSeconds (From : milliSeconds) return microSeconds;


   type Item is
      record
         Hours        : Time.Hours;
         Minutes      : Time.Minutes;
         Seconds      : Time.Seconds;
         microSeconds : Time.microSeconds;
      end record;

   zero_Time : constant Time.item;


   function to_Duration (From  : in Time.item)         return Duration;
   function to_Time     (From  : in standard.Duration) return Time.item;

   function to_Time     (Hours        : in Time.Hours        := 0;
                         Minutes      : in Time.Minutes      := 0;
                         Seconds      : in Time.Seconds      := 0;
                         microSeconds : in Time.microSeconds := 0) return Time.item;

   function Image (Time  : in Item)   return String;     -- Format: HH:MM:SS.mmmmmm
   function Value (Image : in String) return Time.item;


   Overflow  : exception;
   Underflow : exception;

   function "+" (Left, Right : in Time.item) return Time.item;
   function "-" (Left, Right : in Time.item) return Time.item;

   function "+" (Left  : in Time.item;   Right : in Duration) return Time.item;
   function "-" (Left  : in Time.item;   Right : in Duration) return Time.item;



private
   zero_Time : constant Time.item := (Hours        => 0,
                                      Minutes      => 0,
                                      Seconds      => 0,
                                      microSeconds => 0);

end lace.Time;
