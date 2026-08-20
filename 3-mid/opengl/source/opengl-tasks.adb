with
     openGL.Errors;


package body openGL.Tasks
is
   use openGL.Errors;


   procedure check
   is
   begin
      if Debugging
      then
         declare
            use
                 Ada,
                 ada.task_Identification;

            calling_Task : constant Task_Id := task_Identification.current_Task;

            -- TODO: Use the assert instead of the exception for performance.
            -- pragma assert (Renderer_Task = calling_Task,
            --                   "Calling task '"      & task_Identification.Image (current_Task)  & "'"
            --                 & " /= Renderer task '" & task_Identification.Image (Renderer_Task) & "'");
         begin
            if Renderer_Task /= calling_Task
            then
               raise Error with   "Calling task '"      & task_Identification.Image (current_Task)  & "'"
                                & " /= Renderer task '" & task_Identification.Image (Renderer_Task) & "'";
            end if;
         end;
      end if;
   end check;



   function check return Boolean
   is
   begin
      if Debugging
      then
         check;
      end if;

      return True;
   end check;


end openGL.Tasks;
