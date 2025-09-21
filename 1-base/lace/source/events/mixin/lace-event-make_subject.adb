with
     lace.Event.Logger,
     lace.Event.utility,
     system.RPC,
     ada.unchecked_Deallocation;


package body lace.event.make_Subject
is
   use type Event.Logger.view;


   procedure destroy (Self : in out Item)
   is
   begin
      if Self.Emitter /= null
      then
         Self.Emitter.destroy;
      end if;

      if Self.Sender /= null
      then
         Self.Sender.destroy;
      end if;

      Self.safe_Observers.destruct;
   end destroy;


   -------------
   -- Attributes
   --

   overriding
   function Observers (Self : in Item;   of_Kind : in Event.Kind) return subject.Observer_views
   is
   begin
      return Self.safe_Observers.fetch_Observers (of_Kind);
   end Observers;



   overriding
   function observer_Count (Self : in Item) return Natural
   is
   begin
      return Self.safe_Observers.observer_Count;
   end observer_Count;



   overriding
   function next_Sequence (Self : in out Item;   for_Observer : in Observer.view) return event.sequence_Id
   is
      Sequence : sequence_Id;
   begin
      Self.sequence_Id_Map.get_Next (Sequence,
                                     for_Observer.Name);
      return Sequence;
   end next_Sequence;



   -------------
   -- Operations
   --

   overriding
   procedure register (Self : access Item;   the_Observer : in Observer.view;
                                             of_Kind      : in Event.Kind)
   is
   begin
      Self.safe_Observers .add (the_Observer, of_Kind);
      Self.sequence_Id_Map.add (the_Observer.Name);

      if Subject.Logger /= null
      then
         Subject.Logger.log_Connection (the_Observer,
                                        Subject.view (Self),
                                        of_Kind);
      end if;
   end register;



   overriding
   procedure deregister (Self : in out Item;   the_Observer : in Observer.view;
                                               of_Kind      : in Event.Kind)
   is
   begin
      Self.safe_Observers.rid (the_Observer, of_Kind, Self.sequence_Id_Map);

      if Subject.Logger /= null
      then
         Subject.Logger.log_disconnection (the_Observer,
                                           Self'unchecked_Access,
                                           of_Kind);
      end if;
   end deregister;



   --------
   --- Emit
   --

   overriding
   procedure use_event_Emitter (Self : in out Item)
   is
   begin
      Self.Emitter := new event_Emitter.item;
      Self.Emitter.define (Self'unchecked_Access);
   end use_event_Emitter;



   overriding
   procedure emit (Self : access Item;   the_Event : in Event.item'Class)
   is
   begin
      if Self.Emitter = null
      then
         declare
            use lace.Event.utility;
            my_Observers : constant Subject.Observer_views := Self.Observers (to_Kind (the_Event'Tag));
            Sequence     :          sequence_Id;
         begin
            for i in my_Observers'Range
            loop
               begin
                  Self.sequence_Id_Map.get_Next (Sequence,
                                                 for_Name => my_Observers (i).Name);

                  my_Observers (i).receive (the_Event,
                                            from_Subject => Subject.item'Class (Self.all).Name,
                                            Sequence     => Sequence);

                  if Subject.Logger /= null
                  then
                     Subject.Logger.log_Emit (Subject.view (Self),
                                              my_Observers (i),
                                              the_Event);
                  end if;

               exception
                  when system.RPC.communication_Error
                     | storage_Error =>

                     if Subject.Logger /= null
                     then
                        Subject.Logger.log_Emit (Subject.view (Self),
                                                 my_Observers (i),
                                                 the_Event);
                     end if;
               end;
            end loop;
         end;

      else
         Self.Emitter.add (the_Event);
      end if;
   end emit;



   overriding
   function emit (Self : access Item;   the_Event : in Event.item'Class)
                  return subject.Observer_views
   is
      use lace.Event.utility;
      my_Observers  : constant Subject.Observer_views := Self.Observers (to_Kind (the_Event'Tag));
      bad_Observers :          Subject.Observer_views (my_Observers'Range);
      bad_Count     :          Natural := 0;
      s_Id          :          sequence_Id;

   begin
      for i in my_Observers'Range
      loop
         begin
            Self.sequence_Id_Map.get_Next (s_Id,
                                           for_Name => my_Observers (i).Name);

            my_Observers (i).receive (the_Event,
                                      from_Subject => Subject.view (Self).Name,
                                      Sequence     => s_Id);

            if Subject.Logger /= null
            then
               Subject.Logger.log_Emit (Subject.view (Self),
                                        my_Observers (i),
                                        the_Event);
            end if;

         exception
            when system.RPC.communication_Error
               | storage_Error =>
               bad_Count                 := bad_Count + 1;
               bad_Observers (bad_Count) := my_Observers (i);
         end;
      end loop;

      return bad_Observers (1 .. bad_Count);
   end emit;




   --------
   --- Send
   --

   overriding
   procedure use_event_Sender (Self : in out Item)
   is
   begin
      Self.Sender := new event_Sender.item;
      Self.Sender.define (Self'unchecked_Access);
   end use_event_Sender;



   overriding
   procedure send (Self : access Item;   the_Event   : in Event.item'Class;
                                         to_Observer : in Observer.view)
   is
      s_Id : sequence_Id;

   begin
      if Self.Sender = null
      then
         Self.sequence_Id_Map.get_Next (s_Id,
                                        for_Name => to_Observer.Name);
         begin
            to_Observer.receive (the_Event,
                                 from_Subject => Subject.view (Self).Name,
                                 Sequence     => s_Id);

            if Subject.Logger /= null
            then
               Subject.Logger.log_Send (Subject.view (Self),
                                        to_Observer,
                                        the_Event);
            end if;

         exception
            when system.RPC.communication_Error
               | storage_Error =>

               if Subject.Logger /= null
               then
                  Subject.Logger.log_Send (Subject.view (Self),
                                           to_Observer,
                                           the_Event);
               end if;
         end;

      else
         Self.Sender.add (the_Event,
                          for_Observer => to_Observer,
                          from_Subject => Self);
      end if;
   end send;



   -----------------
   -- Safe Observers
   --

   protected
   body safe_Observers
   is
      procedure destruct
      is
         use event_kind_Maps_of_event_observers;

         procedure deallocate is new ada.unchecked_Deallocation (event_Observer_Vector,
                                                                 event_Observer_Vector_view);

         Cursor                    : event_kind_Maps_of_event_observers.Cursor := the_Observers.First;
         the_event_Observer_Vector : event_Observer_Vector_view;
      begin
         while has_Element (Cursor)
         loop
            the_event_Observer_Vector := Element (Cursor);
            deallocate (the_event_Observer_Vector);

            next (Cursor);
         end loop;
      end destruct;



      procedure add (the_Observer : in Observer.view;
                     of_Kind      : in Event.Kind)
      is
         use event_Observer_Vectors,
             event_kind_Maps_of_event_observers;

         Cursor               : constant event_kind_Maps_of_event_observers.Cursor := the_Observers.find (of_Kind);
         the_event_Observers  :          event_Observer_Vector_view;
      begin
         if has_Element (Cursor)
         then
            the_event_Observers := Element (Cursor);
         else
            the_event_Observers := new event_Observer_Vector;
            the_Observers.insert (of_Kind,
                                  the_event_Observers);
         end if;

         the_event_Observers.append (the_Observer);
      end add;



      procedure rid (the_Observer    : in     Observer.view;
                     of_Kind         : in     Event.Kind;
                     sequence_Id_Map : in out Containers.safe_sequence_Id_Map)
      is
         the_event_Observers : event_Observer_Vector renames the_Observers.Element (of_Kind).all;
      begin
         the_event_Observers.delete (the_event_Observers.find_Index (the_Observer));

         declare
            Found : Boolean := False;
         begin
            for each_of_the_event_Observers of the_Observers
            loop
               declare
                  the_event_Observers : event_Observer_Vector renames each_of_the_event_Observers.all;
               begin
                  for each_Observer of the_event_Observers
                  loop
                     if each_Observer = the_Observer
                     then
                        Found := True;
                        exit;
                     end if;
                  end loop;
               end;
            end loop;

            if not Found
            then
               sequence_Id_Map.rid (the_Observer.Name);
            end if;

         end;
      end rid;



      function fetch_Observers (of_Kind : in Event.Kind) return subject.Observer_views
      is
      begin
         if the_Observers.Contains (of_Kind)
         then
            declare
               the_event_Observers : constant event_Observer_Vector_view := the_Observers.Element (of_Kind);
               my_Observers        :          Subject.Observer_views (1 .. Natural (the_event_Observers.Length));
            begin
               for i in my_Observers'Range
               loop
                  my_Observers (i) := the_event_Observers.Element (i);
               end loop;

               return my_Observers;
            end;
         else
            return [1 .. 0 => <>];
         end if;
      end fetch_Observers;



      function observer_Count return Natural     -- TODO: This is wrong.
      is
         use event_kind_Maps_of_event_observers;

         Cursor : event_kind_Maps_of_event_observers.Cursor := the_Observers.First;
         Count  : Natural := 0;
      begin
         while has_Element (Cursor)
         loop
            Count := Count + Natural (Element (Cursor).Length);
            next (Cursor);
         end loop;

         return Count;
      end observer_Count;

   end safe_Observers;


end lace.event.make_Subject;
