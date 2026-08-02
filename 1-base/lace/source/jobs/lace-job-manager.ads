with
     ada.Containers.Vectors;


package lace.Job.Manager
--
--
--
is
   type Item     is tagged private;
   type Job_view is access all Job.item'Class;


   --------------
   --- Attributes
   --

   function has_Jobs (Self : in Item) return Boolean;


   --------------
   --- Operations
   --

   procedure add     (Self : in out Item;   the_Job : in Job_view);
   procedure do_Jobs (Self : in out Item);



private

   package job_Vectors is new ada.Containers.Vectors (Positive, Job_view);
   subtype job_Vector  is     job_Vectors.Vector;


   type Item is tagged
      record
         Jobs : job_Vector;
      end record;


end lace.Job.Manager;
