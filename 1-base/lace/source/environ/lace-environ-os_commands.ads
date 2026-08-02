with
     lace.Environ.Paths;


package lace.Environ.OS_Commands
--
-- Allows running of operating system commands.
--
is

   --------------
   --- Attributes
   --

   function Path_to            (Command    : in String)      return Paths.Folder;

   function Executable_on_Path (Executable : in Paths.File)  return Boolean;
   --
   -- Returns True if the Executable exists on the environment PATH variable.


   --------------
   --- Operations
   --

   procedure run_OS (command_Line : in String;
                     Input        : in String := "");
   --
   -- Discards any output. The 'Error' exception is raised if the command fails.

   function  run_OS (command_Line : in String;
                     Input        : in String := "") return Data;
   --
   -- Returns any output. The 'Error' exception is raised if the command fails.

   function  run_OS (command_Line : in String;
                     Input        : in String  := "";
                     add_Errors   : in Boolean := True) return String;
   --
   -- Returns any output. Error output is appended if add_Errors is true.


end lace.Environ.OS_Commands;
