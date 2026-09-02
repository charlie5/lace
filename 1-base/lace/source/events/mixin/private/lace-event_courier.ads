with
     lace.Event.Containers,
     lace.Observer,
     lace.Subject,

     ada.Containers.Vectors,
     ada.Containers.indefinite_Holders;


private
generic
   courier_Name   : in String;     -- Used in log messages, e.g. "lace.event_Emitter.Emitter".
   delegator_Name : in String;     -- Used in log messages, e.g. "lace.event_Emitter.emit_Delegator".

package lace.event_Courier
--
-- The delivery machinery shared by the event emitter and sender: a pool of
-- courier tasks, delivery completion reports and per-observer channels.
--
-- Channels serialise deliveries to a given observer, so a courier can take the
-- sequence id just before delivering and soundly reissue it when the delivery
-- fails ~ no later id can exist for that observer.
--
is
   use type lace.Observer.view;


   ---------------
   --- Containers.
   --

   package string_Holders is new ada.Containers.indefinite_Holders (Element_type => String);
   subtype string_Holder  is     string_Holders.Holder;


   package observer_Vectors is new ada.Containers.Vectors (Positive,
                                                           lace.Observer.view);
   subtype observer_Vector  is     observer_Vectors.Vector;


   package pending_Vectors is new ada.Containers.Vectors (Positive,
                                                          Event.Containers.event_Holder,
                                                          Event.Containers.event_Holders."=");
   subtype pending_Vector  is     pending_Vectors.Vector;


   -----------
   --- Courier.
   --

   type Courier;
   type Courier_view is access Courier;

   package courier_Vectors is new ada.Containers.Vectors (Positive,
                                                          Courier_view);
   subtype courier_Vector  is     courier_Vectors.Vector;


   --------------
   --- Safe pool.
   --

   protected
   type safe_Pool
   is
      procedure add (new_Courier : in     Courier_view);
      procedure get (a_Courier   :    out Courier_view);

   private
      all_Couriers : courier_Vector;
   end safe_Pool;

   type safe_Pool_view is access all safe_Pool;


   -----------------
   --- Safe reports.
   --
   -- Each courier reports its observer here when a delivery ends, successfully
   -- or not, which reopens the observer's channel for the next delivery.
   --

   protected
   type safe_Reports
   is
      procedure add   (the_Observer  : in     lace.Observer.view);
      procedure fetch (the_Observers :    out observer_Vector);

   private
      Completed : observer_Vector;
   end safe_Reports;

   type safe_Reports_view is access all safe_Reports;


   -----------
   --- Courier.
   --

   task
   type Courier
   is
      entry deliver (Self         : in Courier_view;
                     the_Event    : in lace.Event.item'Class;
                     To           : in lace.Observer.view;
                     from_Subject : in String;
                     Subject      : in lace.Subject.view;
                     Reports      : in safe_Reports_view;
                     Pool         : in safe_Pool_view);
   end Courier;


   -------------
   --- Channels.
   --

   type Channel is
      record
         Observer : lace.Observer.view;
         Busy     : Boolean := False;
         Pending  : pending_Vector;
      end record;

   package channel_Vectors is new ada.Containers.Vectors (Positive, Channel);
   subtype channel_Vector  is     channel_Vectors.Vector;


   function  channel_Index (Channels : in out channel_Vector;   for_Observer : in lace.Observer.view) return Positive;
   --
   -- The index of the observer's channel, created on first use.

   function  all_Channels_are_idle (Channels : in channel_Vector) return Boolean;

   procedure reopen_Channels (Channels : in out channel_Vector;
                              Reports  : in out safe_Reports);
   --
   -- Reopens the channels of completed deliveries.

   procedure dispatch_Channels (Channels      : in out channel_Vector;
                                from_Subject  : in     String;
                                Subject       : in     lace.Subject.view;
                                Reports       : in     safe_Reports_view;
                                Pool          : in     safe_Pool_view;
                                courier_Count : in out Natural);
   --
   -- Dispatches one pending delivery per idle channel.

   procedure drain (Pool          : in out safe_Pool;
                    courier_Count : in out Natural);
   --
   -- Awaits busy couriers and frees the pool, so no courier can touch the pool
   -- or the reports after the enclosing delegator exits.


end lace.event_Courier;
