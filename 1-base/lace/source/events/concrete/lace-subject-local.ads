with
     lace.Event.make_Subject,
     lace.Any;

private
with
     ada.Strings.unbounded;


package lace.Subject.local
--
-- Provides a concrete local event Subject.
--
is
   type Item is limited new Any.limited_item
                        and Subject    .item with private;

   type View is access all Item'Class;


   ---------
   --- Forge
   --

   package Forge
   is
      function  to_Subject (Name : in Event.subject_Name) return Item;
      function new_Subject (Name : in Event.subject_Name) return View;
   end Forge;


   --------------
   --- Operations
   --

   procedure destroy (Self : in out Item);


   --------------
   --- Attributes
   --

   overriding
   function Name (Self : in Item) return Event.subject_Name;



private

   use ada.Strings.unbounded;

   -- pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   package Subject is new Event.make_Subject (Any.limited_item);

   type Item is limited new Subject.item with
      record
         Name : unbounded_String;
      end record;


end lace.Subject.local;
