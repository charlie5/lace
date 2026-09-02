with
     shell.Commands.unsafe,
     gnat.OS_Lib,

     ada.Strings.fixed,
     ada.Strings.Maps,
     ada.Characters.latin_1,
     ada.Exceptions;


package body lace.Environ.OS_Commands
is
   use ada.Exceptions;


   function Path_to (Command : in String) return Paths.File
   is
      use Paths;
   begin
      return to_File (run_OS ("which " & escaped (Command)));
   end Path_to;



   function Executable_on_Path (Executable : in Paths.File) return Boolean
   is
      use
           Paths,
           gnat.OS_Lib;

      File_Path :          String_access := locate_Exec_on_Path (+Executable);
      Found     : constant Boolean       := File_Path /= null;

   begin
      free (File_Path);
      return Found;
   end Executable_on_Path;



   function escaped (Argument : in String) return String
   is
      Result : String (1 .. 2 * Argument'Length);
      Last   : Natural := 0;
   begin
      for Each of Argument
      loop
         if Each in ' ' | '"' | '\' | '|'
         then
            Last          := Last + 1;
            Result (Last) := '\';
         end if;

         Last          := Last + 1;
         Result (Last) := Each;
      end loop;

      return Result (1 .. Last);
   end escaped;



   procedure run_OS (command_Line : in String;
                     Input        : in String := "")
   is
      use Shell;
   begin
      Commands.unsafe.run (command_Line, +Input);

   exception
      when E : Commands.command_Error =>
         raise Error with Exception_Message (E);
   end run_OS;



   function run_OS (command_Line : in String;
                    Input        : in String := "") return Data
   is
      use
           Shell,
           shell.Commands,
           shell.Commands.unsafe;

      the_Command : unsafe.Command := Forge.to_Command (command_Line);

   begin
      return Output_of (run (the_Command, +Input));

   exception
      when E : command_Error =>
         raise Error with Exception_Message (E);
   end run_OS;



   function run_OS (command_Line : in String;
                    Input        : in String  := "";
                    add_Errors   : in Boolean := True) return String
   is
      use
           Shell,
           shell.Commands,
           shell.Commands.unsafe;

      function trim_LF (Source : in String) return String
      is
         use
              ada.Strings.fixed,
              ada.Strings.Maps,
              ada.Characters;

         LF_Set : constant Character_Set := to_Set (latin_1.LF);
      begin
         return trim (Source, LF_Set, LF_Set);
      end trim_LF;


      Results : constant Command_Results := run (command_Line, +Input);
      Output  : constant String          := +Output_of (Results);

   begin
      if add_Errors
      then
         return trim_LF (Output & (+Errors_of (Results)));
      else
         return trim_LF (Output);
      end if;

   exception
      when E : command_Error =>
         raise Error with Exception_Message (E);
   end run_OS;


end lace.Environ.OS_Commands;
