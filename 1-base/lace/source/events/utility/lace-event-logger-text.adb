with
     lace.Event.utility,
     system.RPC,
     ada.unchecked_Conversion;


package body lace.Event.Logger.text
is
   use
        lace.Event.utility,
        ada.Text_IO;


   --------------------------------------------------------------------------------
   --- The log file and the ignored set are shared by every task, so all access is
   --- serialised by a lock. The lock is held across the file writes themselves and
   --- released before returning ~ the writes happen outside any protected action,
   --- since Text_IO may block.
   --

   type File_view is access all ada.Text_IO.File_type;


   protected Gate
   is
      entry     seize;
      procedure release;

   private
      Seized : Boolean := False;
   end Gate;


   protected
   body Gate
   is
      entry seize
        when not Seized
      is
      begin
         Seized := True;
      end seize;



      procedure release
      is
      begin
         Seized := False;
      end release;
   end Gate;



   procedure guarded_put_Line (File        : in File_view;
                               Message     : in String;
                               blank_First : in Boolean := False)
   is
   begin
      Gate.seize;

      if blank_First
      then
         new_Line (File.all);
      end if;

      put_Line (File.all, Message);
      Gate.release;

   exception
      when others =>
         Gate.release;
         raise;
   end guarded_put_Line;



   function is_Ignored (Self : in Item;   Kind : in Event.Kind) return Boolean
   is
   begin
      Gate.seize;

      declare
         Result : constant Boolean := Self.Ignored.contains (Kind);
      begin
         Gate.release;
         return Result;
      end;

   exception
      when others =>
         Gate.release;
         raise;
   end is_Ignored;


   ---------
   --- Forge
   --

   function to_Logger (Name : in String) return Item
   is
   begin
      return Self : Item
      do
         create (Self.File, out_File, Name & ".log");
      end return;
   end to_Logger;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      Gate.seize;

      if is_Open (Self.File)     -- Tolerate a repeated destruct.
      then
         close (Self.File);
      end if;

      Gate.release;

   exception
      when others =>
         Gate.release;
         raise;
   end destruct;


   --------------
   --- Operations
   --

   overriding
   procedure log_Connection (Self : in out Item;   From     : in Observer.view;
                                                   To       : in Subject .view;
                                                   for_Kind : in Event.Kind)
   is
   begin
      guarded_put_Line (Self.File'unchecked_Access,
                          "new Connection => "
                        & From.Name
                        & " observes "
                        & To.Name
                        & " for event kind "
                        & Name_of (for_Kind)
                        & ".");
   end log_Connection;



   overriding
   procedure log_Disconnection (Self : in out Item;   From     : in Observer.view;
                                                      To       : in Subject .view;
                                                      for_Kind : in Event.Kind)
   is

      function from_Name return String
      is
         function to_Integer is new ada.unchecked_Conversion (Observer.view,
                                                              long_Integer);
      begin
         return From.Name;

      exception
         when system.RPC.communication_Error
            | storage_Error =>
            return "dead Observer (" & to_Integer (From)'Image & ")";
      end from_Name;

   begin
      guarded_put_Line (Self.File'unchecked_Access,
                          "Disconnection => "
                        & from_Name
                        & " no longer observes "
                        & To.Name
                        & " for event kind "
                        & Name_of (for_Kind)
                        & ".");
   end log_Disconnection;



   function to_Integer is new ada.unchecked_Conversion (lace.Observer.view,
                                                        long_Integer);


   overriding
   procedure log_Emit (Self : in out Item;   From      : in Subject .view;
                                             To        : in Observer.view;
                                             the_Event : in Event.item'Class)
   is

      function to_Name return String
      is
      begin
         return To.Name;

      exception
            when system.RPC.communication_Error
               | storage_Error =>
            return "dead Observer (" & to_Integer (To)'Image & ")";
      end to_Name;

   begin
      if is_Ignored (Self, to_Kind (the_Event'Tag))
      then
         return;
      end if;

      guarded_put_Line (Self.File'unchecked_Access,
                          "Emit     => "
                        & From.Name
                        & "  emits       "
                        & Name_of (Kind_of (the_Event))
                        & " to "
                        & to_Name
                        & ".",
                        blank_First => True);
   end log_Emit;



   overriding
   procedure log_Send (Self : in out Item;   From      : in Subject .view;
                                             To        : in Observer.view;
                                             the_Event : in Event.item'Class)
   is

      function to_Name return String
      is
      begin
         return To.Name;

      exception
         when system.RPC.communication_Error
            | storage_Error =>
            return "dead Observer (" & to_Integer (To)'Image & ")";
      end to_Name;

   begin
      if is_Ignored (Self, to_Kind (the_Event'Tag))
      then
         return;
      end if;

      guarded_put_Line (Self.File'unchecked_Access,
                          "Send     => "
                        & From.Name
                        & "  sends       "
                        & Name_of (Kind_of (the_Event))
                        & " to "
                        & to_Name
                        & ".",
                        blank_First => True);
   end log_Send;



   overriding
   procedure log_new_Response (Self : in out Item;   the_Response : in Response.view;
                                                     of_Observer  : in Observer.item'Class;
                                                     to_Kind      : in Event.Kind;
                                                     from_Subject : in subject_Name)
   is
   begin
      guarded_put_Line (Self.File'unchecked_Access,
                          "new Response   => "
                        & of_Observer.Name
                        & " responds to " & Name_of (to_Kind)
                        & " from "        & from_Subject
                        & " with "        & the_Response.Name);
   end log_new_Response;



   overriding
   procedure log_rid_Response (Self : in out Item;   the_Response : in Response.view;
                                                     of_Observer  : in Observer.item'Class;
                                                     to_Kind      : in Event.Kind;
                                                     from_Subject : in subject_Name)
   is
   begin
      guarded_put_Line (Self.File'unchecked_Access,
                          "rid Response => "
                        & of_Observer.Name
                        & " no longer responds to "
                        & Name_of (to_Kind)
                        & " from "
                        & from_Subject
                        & " with "
                        & the_Response.Name
                        & ".");
   end log_rid_Response;



   overriding
   procedure log_Response (Self : in out Item;   the_Response : in Response.view;
                                                 of_Observer  : in Observer.view;
                                                 to_Event     : in Event.item'Class;
                                                 from_Subject : in subject_Name)
   is
   begin
      if is_Ignored (Self, to_Kind (to_Event'Tag))
      then
         return;
      end if;

      guarded_put_Line (Self.File'unchecked_Access,
                          "Response => "
                        & of_Observer.Name
                        & " responds to "
                        & Name_of (to_Kind (to_Event'Tag))
                        & " from "
                        & from_Subject
                        & " with "
                        & the_Response.Name
                        & ".");
   end log_Response;



   overriding
   procedure log (Self : in out Item;   Message : in String)
   is
   begin
      guarded_put_Line (Self.File'unchecked_Access, Message);
   end log;



   overriding
   procedure ignore (Self : in out Item;   Kind : in Event.Kind)
   is
   begin
      Gate.seize;
      Self.Ignored.include (Kind);     -- 'include', so a repeated ignore is harmless.
      Gate.release;

   exception
      when others =>
         Gate.release;
         raise;
   end ignore;


end lace.Event.Logger.text;
