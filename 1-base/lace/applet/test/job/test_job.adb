with
     lace.Job.Manager,
     ada.Calendar,
     ada.Text_IO;


procedure test_Job
is
   procedure log (Message : in String := "") renames ada.Text_IO.put_Line;


   type hello_Job is new lace.Job.item with null record;

   overriding
   procedure perform (Self : in out hello_Job)
   is
      use ada.Calendar;
   begin
      lace.Job.item (Self).perform;        -- Call base class 'perform'.

      log ("Hello.");

      if Self.performed_Count = 5
      then
         Self.Due_is (lace.Job.Never);     -- Job manager will remove the job.
      else
         Self.Due_is (Self.Due + 2.0);     -- Repeat job every 2 seconds.
      end if;
   end perform;


   the_Job     : aliased hello_Job;
   the_Manager :         lace.Job.Manager.item;

begin
   log ("Begin Test");
   log;

   the_Job.Due_is  (ada.Calendar.Clock);
   the_Manager.add (the_Job'unchecked_Access);

   while the_Manager.has_Jobs
   loop
      the_Manager.do_Jobs;
   end loop;

   log;
   log ("End Test");
end test_Job;
