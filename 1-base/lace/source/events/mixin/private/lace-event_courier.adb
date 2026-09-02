with
     system.RPC,

     ada.Text_IO,
     ada.Exceptions,
     ada.unchecked_Deallocation;


package body lace.event_Courier
is

   -----------
   --- Courier.
   --

   task
   body Courier
   is
      Myself       : Courier_view;
      Event        : lace.Event.Containers.event_Holder;
      the_Observer : lace.Observer.view;
      subject_Name : string_Holder;
      the_Subject  : lace.Subject.view;
      the_Reports  : safe_Reports_view;
      the_Pool     : safe_Pool_view;

   begin
      loop
         begin
            select
               accept deliver (Self         : in Courier_view;
                               the_Event    : in lace.Event.item'Class;
                               To           : in lace.Observer.view;
                               from_Subject : in String;
                               Subject      : in lace.Subject.view;
                               Reports      : in safe_Reports_view;
                               Pool         : in safe_Pool_view)
               do
                  Myself       := Self;
                  the_Observer := To;
                  the_Subject  := Subject;

                  the_Reports  := Reports;
                  the_Pool     := Pool;

                  Event       .replace_Element (the_Event);
                  subject_Name.replace_Element (from_Subject);
               end deliver;
            or
               terminate;
            end select;

            declare
               observer_Name : constant String := the_Observer.Name;     -- Fails when the observer is dead, so no id is taken.

               Sequence : constant lace.Event.sequence_Id
                 := the_Subject.next_Sequence (for_observer_Name => observer_Name);
            begin
               the_Observer.receive (Event.Reference,
                                     from_Subject => subject_Name.Element,
                                     Sequence     => Sequence);

            exception
               when system.RPC.communication_Error
                  | storage_Error =>
                  the_Subject.restore_Sequence (for_observer_Name => observer_Name);     -- Sound ~ deliveries are serialised per observer,
                  raise;                                                                 -- so no later id exists for this observer.
            end;

            the_Reports.add (the_Observer);                              -- Reopen the observer's channel.
            the_Pool   .add (Myself);                                    -- Return the courier to the safe pool.

         exception
            when E : others =>
               if the_Reports /= null
               then
                  the_Reports.add (the_Observer);                        -- Reopen the observer's channel and return the courier
                  the_Pool   .add (Myself);                              -- to the safe pool before logging, which may itself fail.
               end if;

               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.put_Line ("Error detected in '" & courier_Name & "' task.");
               ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
               ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");

               begin
                  ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name & "'.");

               exception
                  when others =>
                     ada.Text_IO.put_Line ("Observer: unavailable ~ the observer is dead.");
               end;

               ada.Text_IO.put_Line ("Continuing.");
               ada.Text_IO.new_Line (2);
         end;
      end loop;

   exception
      when E : others =>
         ada.Text_IO.new_Line;
         ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
         ada.Text_IO.put_Line ("Fatal error detected in '" & courier_Name & "' task.");
         ada.Text_IO.put_Line ("Subject:  '" & subject_Name.Element & "'.");
         ada.Text_IO.put_Line ("Event:    '" & Event.Element'Image  & "'.");

         begin
            ada.Text_IO.put_Line ("Observer: '" & the_Observer.Name & "'.");

         exception
            when others =>
               ada.Text_IO.put_Line ("Observer: unavailable ~ the observer is dead.");
         end;

         ada.Text_IO.new_Line (2);
   end Courier;


   --------------
   --- Safe pool.
   --

   protected
   body safe_Pool
   is

      procedure add (new_Courier : in Courier_view)
      is
      begin
         all_Couriers.append (new_Courier);
      end add;



      procedure get (a_Courier : out Courier_view)
      is
      begin
         if all_Couriers.is_Empty
         then
            a_Courier := null;
         else
            a_Courier := all_Couriers.last_Element;
            all_Couriers.delete_Last;
         end if;
      end get;

   end safe_Pool;


   -----------------
   --- Safe reports.
   --

   protected
   body safe_Reports
   is

      procedure add (the_Observer : in lace.Observer.view)
      is
      begin
         Completed.append (the_Observer);
      end add;



      procedure fetch (the_Observers : out observer_Vector)
      is
      begin
         the_Observers := Completed;
         Completed.clear;
      end fetch;

   end safe_Reports;


   -------------
   --- Channels.
   --

   function channel_Index (Channels : in out channel_Vector;   for_Observer : in lace.Observer.view) return Positive
   is
   begin
      for i in 1 .. Natural (Channels.Length)
      loop
         if Channels (i).Observer = for_Observer
         then
            return i;
         end if;
      end loop;

      Channels.append (Channel' (Observer => for_Observer,
                                 Busy     => False,
                                 Pending  => pending_Vectors.empty_Vector));
      return Positive (Channels.Length);
   end channel_Index;



   function all_Channels_are_idle (Channels : in channel_Vector) return Boolean
   is
   begin
      for Each of Channels
      loop
         if Each.Busy or else not Each.Pending.is_Empty
         then
            return False;
         end if;
      end loop;

      return True;
   end all_Channels_are_idle;



   procedure reopen_Channels (Channels : in out channel_Vector;
                              Reports  : in out safe_Reports)
   is
      freed_Observers : observer_Vector;
   begin
      Reports.fetch (freed_Observers);

      for each_Observer of freed_Observers
      loop
         declare
            Index : constant Positive := channel_Index (Channels, each_Observer);
         begin
            Channels (Index).Busy := False;
         end;
      end loop;
   end reopen_Channels;



   procedure dispatch_Channels (Channels      : in out channel_Vector;
                                from_Subject  : in     String;
                                Subject       : in     lace.Subject.view;
                                Reports       : in     safe_Reports_view;
                                Pool          : in     safe_Pool_view;
                                courier_Count : in out Natural)
   is
      use type ada.Exceptions.Exception_Id;

      procedure free is new ada.unchecked_Deallocation (Courier,
                                                        Courier_view);
   begin
      for i in 1 .. Natural (Channels.Length)
      loop
         declare
            the_Courier : Courier_view;
         begin
            if         not Channels (i).Busy
              and then not Channels (i).Pending.is_Empty
            then
               Pool.get (the_Courier);

               if the_Courier = null
               then
                  the_Courier   := new Courier;
                  courier_Count := courier_Count + 1;
               end if;

               the_Courier.deliver (Self         => the_Courier,
                                    the_Event    => Channels (i).Pending.first_Element.Element,
                                    To           => Channels (i).Observer,
                                    from_Subject => from_Subject,
                                    Subject      => Subject,
                                    Reports      => Reports,
                                    Pool         => Pool);

               Channels (i).Pending.delete_First;
               Channels (i).Busy := True;
            end if;

         exception
            when E : others =>
               if          the_Courier /= null
                  and then ada.Exceptions.exception_Identity (E) = tasking_Error'Identity
               then
                  free (the_Courier);                       -- The dead task never engaged ~ discard it and
                  courier_Count := courier_Count - 1;       -- retry the delivery with a fresh courier.
               end if;

               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line (ada.Exceptions.exception_Information (E));
               ada.Text_IO.new_Line;
               ada.Text_IO.put_Line ("Error detected in '" & delegator_Name & "'.");
               ada.Text_IO.put_Line ("Subject '" & from_Subject & "'.");
               ada.Text_IO.put_Line ("Continuing.");
               ada.Text_IO.new_Line (2);
         end;
      end loop;
   end dispatch_Channels;



   procedure drain (Pool          : in out safe_Pool;
                    courier_Count : in out Natural)
   is
      procedure free is new ada.unchecked_Deallocation (Courier,
                                                        Courier_view);
      the_Courier : Courier_view;
   begin
      while courier_Count > 0
      loop
         Pool.get (the_Courier);

         if the_Courier = null
         then
            delay 0.001;     -- A busy courier has yet to return to the pool.
         else
            free (the_Courier);
            courier_Count := courier_Count - 1;
         end if;
      end loop;
   end drain;


end lace.event_Courier;
