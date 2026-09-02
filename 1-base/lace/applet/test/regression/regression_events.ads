with
     lace.Event,
     lace.Response;


package regression_Events
--
-- Event and response types for 'test_Regression'. Events sent through the
-- (potentially remote) subject interface must be transportable, so their
-- types must live in a remote types unit rather than inside the test.
--
is
   pragma remote_Types;


   type tick_Event is new lace.Event.item with
      record
         Id : Positive;
      end record;


   type counting_Response is new lace.Response.item with
      record
         Count    : Natural := 0;
         in_Order : Boolean := True;
      end record;

   overriding
   procedure respond (Self : in out counting_Response;   to_Event : in lace.Event.item'Class);


end regression_Events;
