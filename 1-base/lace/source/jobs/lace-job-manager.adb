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


      Now    : constant ada.Calendar.Time  := ada.Calendar.Clock;
      Cursor :          job_Vectors.Cursor := Self.Jobs.to_Cursor (1);

      use job_Vectors;

   begin
      Sorter.sort (Self.Jobs);

      while has_Element (Cursor)
      loop
         declare
            the_Job : Job_view renames Element (Cursor);
         begin
            exit when the_Job.Due > Now;

            if the_Job.Due = Never
            then
               Self.Jobs.delete (Cursor);
            else
               the_Job.perform;
            end if;
         end;
      end loop;
   end do_Jobs;


end lace.Job.Manager;
