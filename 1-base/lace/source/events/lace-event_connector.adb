with
     lace.Event.utility,

     ada.Text_IO,
     ada.Exceptions,
     ada.unchecked_Deallocation,
     ada.Containers.Vectors;


package body lace.event_Connector
is

   ---------------
   --- Containers.
   --

   package connector_Vectors is new ada.Containers.Vectors (Positive,
                                                            Connector_view);
   subtype connector_Vector  is connector_Vectors.Vector;



   --------------------
   --- Safe connectors.
   --

   protected
   type safe_Connectors
   is
      procedure add (new_Connector : in     Connector_view);
      procedure get (  a_Connector :    out Connector_view);

      function  Length return ada.Containers.Count_type;

   private
      all_Connectors : connector_Vector;
   end safe_Connectors;

   type safe_Connectors_view is access all safe_Connectors;




   --------------
   --- Connector.
   --

   task
   type Connector
   is
      entry connect (Self           : in Connector_view;
                     the_Connection : in Connection;
                     Connectors     : in safe_Connectors_view);
   end Connector;



   task body Connector
   is
      use ada.Text_IO,
          lace.Text;

      Myself         : Connector_view;
      my_Connection  : Connection;
      connector_Pool : safe_Connectors_view;
   begin
      loop
         begin
            select
               accept connect (Self           : in Connector_view;
                               the_Connection : in Connection;
                               Connectors     : in safe_Connectors_view)
               do
                  my_Connection  := the_Connection;
                  Myself         := Self;
                  connector_Pool := Connectors;
               end connect;
            or
               terminate;
            end select;

            if my_Connection.is_Connecting
            then
               lace.Event.utility.connect (the_Observer  => my_Connection.Observer,
                                           to_Subject    => my_Connection.Subject,
                                           with_Response => my_Connection.Response,
                                           to_Event_Kind => Event.Kind (+my_Connection.Event_Kind));
            else
               lace.Event.utility.disconnect (the_Observer  => my_Connection.Observer,
                                              from_Subject  => my_Connection.Subject,
                                              for_Response  => my_Connection.Response,
                                              to_Event_Kind => Event.Kind (+my_Connection.Event_Kind),
                                              subject_Name  => my_Connection.Subject.Name);
            end if;

            connector_Pool.add (Myself);        -- Return the connector to the safe pool.

         exception
            when E : others =>
               new_Line;
               put_Line (ada.Exceptions.exception_Information (E));
               put_Line ("Error detected in 'lace.event_Connector.Connector' task.");
               new_Line;
               put_Line ("Subject:  '" &   my_Connection.Subject.Name  & "'.");
               put_Line ("Observer: '" &   my_Connection.Observer.Name & "'.");
               put_Line ("Event:    '" & (+my_Connection.Event_Kind)   & "'.");
               put_Line ("Response  '" &   my_Connection.Response.Name & "'.");
               new_Line;
               put_Line ("Continuing.");
               new_Line (2);

               connector_Pool.add (Myself);     -- Return the connector to the safe pool.
         end;
      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line (ada.Exceptions.exception_Information (E));
         put_Line ("Fatal error detected in 'lace.event_Connector.Connector' task.");
         new_Line;
         put_Line ("Subject:  '" &   my_Connection.Subject.Name  & "'.");
         put_Line ("Observer: '" &   my_Connection.Observer.Name & "'.");
         put_Line ("Event:    '" & (+my_Connection.Event_Kind)   & "'.");
         put_Line ("Response  '" &   my_Connection.Response.Name & "'.");
         new_Line (2);
   end Connector;



   -------------------------
   --- Connection delegator.
   --

   task body connection_Delegator
   is
      use ada.Text_IO;

      all_Connectors   :         connector_Vector;
      idle_Connectors  : aliased safe_Connectors;
      the_Connections  :         safe_Connections_view;
      new_Connections  :         connection_Vector;
      Done             :         Boolean          := False;


      function all_Connectors_are_idle return Boolean
      is
         use type ada.Containers.Count_type;
         --  Result : Boolean := True;
      begin
         return all_Connectors.Length = idle_Connectors.Length;
         --  for Each of all_Connectors
         --  loop
         --     if not Each'Callable
         --     then
         --        Result := False;
         --        exit;
         --     end if;
         --  end loop;
         --
         --  return Result;
      end all_Connectors_are_idle;


      procedure shutdown
      is
         procedure free is new ada.unchecked_Deallocation (Connector,
                                                           Connector_view);
         the_Connector : Connector_view;
      begin
         for Each of all_Connectors
         loop
            the_Connector := Each;
            free (the_Connector);
         end loop;
      end shutdown;


   begin
      accept start (Connections : in safe_Connections_view)
      do
         the_Connections := Connections;
      end start;


      loop
         select
            accept stop
            do
               Done := True;
            end stop;

         else
            null;
         end select;


         exit when     Done
                   and the_Connections.is_Empty;

         the_Connections.get (new_Connections);

         for each_Connection of new_Connections
         loop
            declare
               use lace.Text;
               the_Connector : Connector_view;
            begin
               idle_Connectors.get (the_Connector);

               if the_Connector = null
               then
                  the_Connector := new Connector;
                  all_Connectors.append (the_Connector);
               end if;

               the_Connector.connect (Self           => the_Connector,
                                      the_Connection => each_Connection,
                                      Connectors     => idle_Connectors'unchecked_Access);
            exception
               when E : others =>
                  new_Line;
                  put_Line (ada.Exceptions.exception_Information (E));
                  new_Line;
                  put_Line ("Error detected in 'lace.event_Connector.connector_Delegator'.");
                  new_Line;
                  put_Line ("Subject:  '" &   each_Connection.Subject.Name  & "'.");
                  put_Line ("Observer: '" &   each_Connection.Observer.Name & "'.");
                  put_Line ("Event:    '" & (+each_Connection.Event_Kind)   & "'.");
                  put_Line ("Response  '" &   each_Connection.Response.Name & "'.");
                  new_Line;
                  put_Line ("Continuing.");
                  new_Line (2);
            end;
         end loop;

         delay 0.001;     -- Keep task from churning when idle.
      end loop;


      while not all_Connectors_are_idle
      loop
         delay 0.001;
      end loop;


      shutdown;

   exception
      when E : others =>
         new_Line;
         put_Line (ada.Exceptions.exception_Information (E));
         new_Line;
         put_Line ("Fatal error detected in 'lace.event_Connector.connection_Delegator'.");
         new_Line (2);

         shutdown;
   end connection_Delegator;




   ---------------------
   --- Safe connections.
   --

   protected body safe_Connections
   is

      procedure add (new_Connection : in Connection)
      is
      begin
         all_Connections.append (new_Connection);
      end add;



      procedure get (the_Connections : out connection_Vector)
      is
      begin
         the_Connections := all_Connections;
         all_Connections.clear;
      end get;



      function is_Empty return Boolean
      is
      begin
         return all_Connections.is_Empty;
      end is_Empty;


   end safe_Connections;




   --------------------
   --- Safe connectors.
   --

   protected body safe_Connectors
   is

      procedure add (new_Connector : in Connector_view)
      is
      begin
         all_Connectors.append (new_Connector);
      end add;



      procedure get (a_Connector : out Connector_view)
      is
      begin
         if all_Connectors.is_Empty
         then
            a_Connector := null;
         else
            a_Connector := all_Connectors.last_Element;
            all_Connectors.delete_Last;
         end if;
      end get;


      function Length return ada.Containers.Count_type
      is
      begin
         return all_Connectors.Length;
      end Length;


   end safe_Connectors;




   -------------------------
   --- event_Connector item.
   --

   procedure define (Self : in out Item)
   is
   begin
      Self.Delegator.start (Connections => Self.Connections'unchecked_Access);
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
       Self.Delegator.stop;
   end destruct;



   procedure connect (Self : in out Item;   the_Observer  : in Observer.view;
                                            to_Subject    : in Subject .view;
                                            with_Response : in Response.view;
                                            to_Event_Kind : in Event.Kind)
   is
      use lace.Text;

      new_Connection : Connection := (Observer      => the_Observer,
                                      Subject       => to_Subject,
                                      Response      => with_Response,
                                      Event_Kind    => <>,
                                      subject_Name  => <>,
                                      is_Connecting => True);
   begin
      String_is (new_Connection.Event_Kind,
                 String (to_Event_Kind));

      Self.Connections.add (new_Connection);
   end connect;



   procedure disconnect (Self : in out Item;   the_Observer  : in Observer.view;
                                               from_Subject  : in Subject .view;
                                               for_Response  : in Response.view;
                                               to_Event_Kind : in Event.Kind;
                                               subject_Name  : in String)
   is
      use lace.Text;

      new_Disconnection : Connection := (Observer      => the_Observer,
                                         Subject       => from_Subject,
                                         Response      => for_Response,
                                         Event_Kind    => <>,
                                         subject_Name  => <>,
                                         is_Connecting => False);
   begin
      String_is (new_Disconnection.event_Kind,
                 String (to_Event_Kind));

      String_is (new_Disconnection.subject_Name,
                 subject_Name);

      Self.Connections.add (new_Disconnection);
   end disconnect;




   --  function is_Busy (Self : in Item) return Boolean
   --  is
   --  begin
   --     return false;
   --     --  return not (    Self.Connections.is_Empty
   --                 --  and Self.Delegator  .active_Count = 0);
   --  end is_Busy;


end lace.event_Connector;
