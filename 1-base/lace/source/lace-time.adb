with
     gnat.formatted_String,
     ada.Strings.fixed;


package body lace.Time
is

   function to_milliSeconds (From : microSeconds) return milliSeconds
   is
      Round_Up : constant Boolean      := From rem 1_000 >= 500;
      Result   :          milliSeconds := milliSeconds (From / 1_000);
   begin
      if    Round_Up
        and Result /= 999
      then
         Result := Result + 1;
      end if;

      return Result;
   end to_milliSeconds;



   function to_microSeconds (From : milliSeconds) return microSeconds
   is
   begin
      return microSeconds (From) * 1_000;
   end to_microSeconds;



   function to_Duration (From : in lace.Time.item) return Duration
   is
   begin
      return
          Duration (From.Hours   * 60 * 60)
        + Duration (From.Minutes * 60)
        + Duration (From.Seconds)
        + Duration (From.microSeconds) / 1_000_000.0;
   end to_Duration;



   function to_Time (From : in Duration) return Time.item
   is
      Pad    : Duration := From;
      Result : Time.item;
   begin
      Result.Hours        := Hours (Float'Floor (Float (Pad / (60.0 * 60.0))));
      Pad                 := Pad - 60.0 * 60.0 * Duration (Result.Hours);

      Result.Minutes      := Minutes (Float'Floor (Float (Pad / 60.0)));
      Pad                 := Pad - 60.0 * Duration (Result.Minutes);

      Result.Seconds      := Seconds (Float'Floor (Float (Pad)));
      Pad                 := Duration'Max (Pad - Duration (Result.Seconds),
                                           0.0);

      Result.microSeconds := microSeconds (Float'Floor (Float (Pad * 1_000_000.0)));

      return Result;
   end to_Time;



   function to_Time (Hours        : in Time.Hours        := 0;
                     Minutes      : in Time.Minutes      := 0;
                     Seconds      : in Time.Seconds      := 0;
                     microSeconds : in Time.microSeconds := 0) return Time.item
   is
   begin
      return (Hours, Minutes, Seconds, microSeconds);
   end to_Time;



   function Image (Time : lace.Time.item) return String
   is
      use gnat.formatted_String;

      Format : constant formatted_String := +"%02d:%02d:%02d.%06d";
   begin
      return -(Format
               & Natural (Time.Hours)
               & Natural (Time.Minutes)
               & Natural (Time.Seconds)
               & Natural (Time.microSeconds));
   end Image;



   function Value (Image : in String) return Time.item
   is
      use ada.Strings.fixed;

      Result : Time.item;

      First  : Positive := Image'First;
      Last   : Positive := Index (Image, ":") - 1;
   begin
      Result.Hours := Hours'Value (Image (First .. Last));

      First := Last + 2;
      Last  := Index (Image, ":", From => First) - 1;

      Result.Minutes := Minutes'Value (Image (First .. Last));

      First := Last + 2;
      Last  := Index (Image, ".", From => First) - 1;

      Result.Seconds := Seconds'Value (Image (First .. Last));

      First := Last + 2;
      Last  := Image'Last;

      Result.microSeconds := microSeconds'Value (Image (First .. Last));

      return Result;
   end Value;



   function "+" (Left, Right : in Item) return Item
   is
   begin
      return to_Time (to_Duration (Left) + to_Duration (Right));
   exception
      when constraint_Error =>
         raise Overflow;
   end "+";



   function "-" (Left, Right : in Item) return Item
   is
   begin
      return to_Time (to_Duration (Left) - to_Duration (Right));
   exception
      when constraint_Error =>
         raise Underflow;
   end "-";



   function "+" (Left  : in Time.item;   Right : in Duration) return Time.item
   is
   begin
      return to_Time (to_Duration (Left) + Right);
   exception
      when constraint_Error =>
         raise Overflow;
   end "+";



   function "-" (Left  : in Time.item;   Right : in Duration) return Time.item
   is
   begin
      return to_Time (to_Duration (Left) - Right);
   exception
      when constraint_Error =>
         raise Underflow;
   end "-";



end lace.Time;
