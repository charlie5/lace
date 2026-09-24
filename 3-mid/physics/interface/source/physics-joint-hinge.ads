package physics.Joint.hinge
--
-- An interface to a hinge joint.
--
is
   type Item is  limited interface
             and Joint.item;

   type View is access all Item'Class;



   procedure Limits_are  (Self : in out Item;   Low, High        : in Real;
                                                Softness         : in Real := 0.9;
                                                biasFactor       : in Real := 0.3;
                                                relaxationFactor : in Real := 1.0)   is abstract;

   function  lower_Limit (Self : in     Item)   return Real                          is abstract;
   function  upper_Limit (Self : in     Item)   return Real                          is abstract;

   function  limit_Enabled (Self : in Item) return Boolean                           is abstract;

   function  reference_Angle (Self : in     Item) return Radians                     is abstract;
   function  Angle           (Self : in     Item) return Real                        is abstract;

   function  local_Anchor_on_A (Self : in Item) return Vector_3                      is abstract;
   function  local_Anchor_on_B (Self : in Item) return Vector_3                      is abstract;


   ---------
   --- Motor
   --

   function motor_Enabled    (Self : in Item) return Boolean is abstract;
   function motor_Speed      (Self : in Item) return Real    is abstract;
   function max_motor_Torque (Self : in Item) return Real    is abstract;

   procedure Motor_is (Self       : in out Item;   Enabled    : in Boolean;
                                                   Speed      : in Real;
                                                   max_Torque : in Real) is null;
   --
   -- Drives the hinge at the speed, with up to the torque, or lets it swing free.
   -- An engine without a hinge motor ignores it.


end physics.Joint.hinge;
