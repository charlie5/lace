with
     posix.Permissions,
     ada.Streams;


package lace.Environ
--
-- Models an operating system environment.
--
is
   use posix.Permissions;

   subtype Data is ada.Streams.stream_Element_array;

   Error : exception;


   ---------
   --- Forge
   --

   function to_octal_Mode (Permissions : in permission_Set) return String;


end lace.Environ;
