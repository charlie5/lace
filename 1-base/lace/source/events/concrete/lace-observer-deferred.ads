with
     lace.Event.make_Observer.deferred,
     lace.Any;

private
with
     ada.Strings.unbounded;


package lace.Observer.deferred
--
-- Provides a concrete deferred event observer.
--
is
   type Item is limited new Any.limited_item
                        and Observer   .item with private;

   type View is access all Item'Class;


   ---------
   --- Forge
   --

   package Forge
   is
      function  to_Observer (Name : in Event.observer_Name) return Item;
      function new_Observer (Name : in Event.observer_Name) return View;
   end Forge;


   --------------
   --- Attributes
   --

   overriding
   function Name (Self : in Item) return Event.observer_Name;



private

   use ada.Strings.unbounded;

   -- pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   package Observer is new Event.make_Observer (Any.limited_item);
   package Deferred is new Observer.deferred   (Observer.item);

   type Item is limited new Deferred.item with
      record
         Name : unbounded_String;
      end record;


end lace.Observer.deferred;
