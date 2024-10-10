with
     ada.Strings.Hash,
     ada.Containers.indefinite_hashed_Maps;


private
package lace.event.Containers
--
--  Common containers.
--
is
   pragma remote_Types;
   pragma suppress (container_Checks);     -- Suppress expensive tamper checks.


   ---------------------------
   -- Name map of sequence Id.
   --
   package name_Maps_of_sequence_Id is new ada.Containers.indefinite_hashed_Maps (String,
                                                                                  event.sequence_Id,
                                                                                  ada.Strings.Hash,
                                                                                  "=");
   subtype name_Map_of_sequence_Id  is name_Maps_of_sequence_Id.Map;


   ------------------------
   -- Safe sequence Id map.
   --
   protected
   type safe_sequence_Id_Map
   is
      procedure add (Name : in String);
      procedure rid (Name : in String);

      procedure get_Next (Id       :    out event.sequence_Id;
                          for_Name : in     String);
   private
      the_Map : name_Map_of_sequence_Id;
   end safe_sequence_Id_Map;


end lace.event.Containers;
