package body lace.event.Containers
is
   ------------------------
   -- Safe sequence Id map.
   --

   protected
   body safe_sequence_Id_Map
   is
      procedure add (Name : in String)
      is
      begin
         if not the_Map.Contains (Name)
         then
            the_Map.insert (Name,
                            new_Item => 0);
         end if;
      end add;


      procedure rid (Name : in String)
      is
      begin
         the_Map.delete (Name);
      end rid;


      procedure get_Next (Id       :    out event.sequence_Id;
                          for_Name : in     String)
      is
         next_Id : name_Maps_of_sequence_Id.Reference_type renames the_Map (for_Name);
      begin
         Id      := next_Id;
         next_Id := next_Id + 1;
      end get_Next;

   end safe_sequence_Id_Map;


end lace.event.Containers;
