with Math;


package physics.Motor.spring.angular
--
-- A spring which operates in 3 degrees of rotational motion to keep a Solid in a desired attitude.
--
is
   use type math.Real;

   type Item is new physics.Motor.spring.item with
      record
         desiredForward : math.Vector_3 := (0.0, 0.0, -1.0);   -- The Motor's desired forward direction, part of the desired orientation.
         desiredUp      : math.Vector_3 := (0.0, 1.0,  0.0);   -- The Motor's desired up      direction.
         desiredRight   : math.Vector_3 := (1.0, 0.0,  0.0);   -- The Motor's desired right   direction.

         angularKd      : math.Real := 0.000_1;    -- The damping constant for angular mode.
         angularKs      : math.Real := 1.0;        -- The spring  constant for angular mode.
      end record;


   procedure update (Self : in out Item);


end physics.Motor.spring.angular;
