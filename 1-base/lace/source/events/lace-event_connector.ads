with
     lace.Event,
     lace.Response,
     lace.Observer,
     lace.Subject;


private
with
     lace.Text,
     ada.Containers.indefinite_Vectors;


package lace.event_Connector
is

   type Item is tagged limited private;


   procedure define     (Self : in out Item);
   procedure destruct   (Self : in out Item);

   procedure connect    (Self : in out Item;   the_Observer  : in Observer.view;
                                               to_Subject    : in Subject .view;
                                               with_Response : in Response.view;
                                               to_Event_Kind : in Event.Kind);

   procedure disconnect (Self : in out Item;   the_Observer  : in Observer.view;
                                               from_Subject  : in Subject .view;
                                               for_Response  : in Response.view;
                                               to_Event_Kind : in Event.Kind;
                                               subject_Name  : in String);


private

   --------------
   --- Connector.
   --

   type Connector;
   type Connector_view is access Connector;



   ---------------
   --- Connection.
   --

   type Connection is
      record
         Observer      : lace.Observer.view;
         Subject       : lace.Subject .view;
         Response      : lace.Response.view;
         Event_Kind    : lace.Text.item_256;
         subject_Name  : lace.Text.item_256;
         is_Connecting : Boolean;
      end record;



   ---------------
   --- Containers.
   --

   package connection_Vectors is new ada.Containers.indefinite_Vectors (Positive,
                                                                        Connection);
   subtype connection_Vector  is connection_Vectors.Vector;



   ---------------------
   --- Safe connections.
   --

   protected
   type safe_Connections
   is
      procedure add (new_Connection  : in     Connection);
      procedure get (the_Connections :    out connection_Vector);

      function is_Empty return Boolean;

   private
      all_Connections : connection_Vector;
   end safe_Connections;

   type safe_Connections_view is access all safe_Connections;



   -------------------------
   --- Connection delegator.
   --

   task
   type connection_Delegator
   is
      entry start (Connections : in safe_Connections_view);
      entry stop;
   end connection_Delegator;



   ---------
   --- Item.
   --

   type Item is tagged limited
      record
         Connections : aliased safe_Connections;
         Delegator   :         connection_Delegator;
      end record;


end lace.event_Connector;
