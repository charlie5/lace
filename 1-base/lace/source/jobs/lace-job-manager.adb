package body lace.Job.Manager
is

   function has_Jobs (Self : in Item) return Boolean
   is
   begin
      return not Self.Jobs.is_Empty;
   end has_Jobs;



   procedure add (Self : in out Item;   the_Job : in Job_view)
   is
   begin
      Self.Jobs.append (the_Job);
   end add;



   procedure do_Jobs (Self : in out Item)
   is

      function "<" (Left, Right : in Job_view) return Boolean
      is
      begin
         return Left.Due < Right.Due;
      end "<";

      package Sorter is new job_Vectors.generic_Sorting;


      Now   : constant ada.Calendar.Time := ada.Calendar.Clock;
      Index :          Positive          := 1;

   begin
      Sorter.sort (Self.Jobs);

      while Index <= Self.Jobs.last_Index
      loop
         declare
            the_Job : constant Job_view := Self.Jobs.Element (Index);
         begin
            exit when the_Job.Due > Now;

            if the_Job.Due = Never
            then
               Self.Jobs.delete (Index);   -- The next job shifts down into this slot.
            else
               the_Job.perform;
               Index := Index + 1;
            end if;
         end;
      end loop;
   end do_Jobs;


end lace.Job.Manager;
