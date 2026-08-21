with
     physics.Rigid,
     Math;


package physics.Motor.spring
--
-- A motor which acts as a spring to bring a target solid to a desired site or attitude.
--
is
   type Item is abstract new physics.Motor.item with
      record
         Rigid : physics.Rigid.pointer;                -- Access to the Solid affected by this Motor.
      end record;



   procedure update (Self : in out Item) is abstract;



private

   procedure dummy;


end physics.Motor.spring;
