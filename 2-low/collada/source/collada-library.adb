with
     ada.unchecked_Deallocation;


package body collada.Library
is

   -----------
   --- Sources
   --

   function Source_of (Self : in Sources_view;   Url : in String) return Source
   is
      use ada.Strings.unbounded;

      First : constant Positive := (if Url'Length > 0 and then Url (Url'First) = '#' then Url'First + 1
                                                                                     else Url'First);
      Id    : String renames Url (First .. Url'Last);
   begin
      if Self /= null
      then
         for Each of Self.all
         loop
            if Each.Id = Id
            then
               return Each;
            end if;
         end loop;
      end if;

      return null_Source;
   end Source_of;



   procedure free (Self : in out Sources_view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Float_array, Float_array_view);
      procedure deallocate is new ada.unchecked_Deallocation (Text_array,  Text_array_view);
      procedure deallocate is new ada.unchecked_Deallocation (Sources,     Sources_view);
   begin
      if Self = null
      then
         return;
      end if;

      for Each of Self.all
      loop
         deallocate (Each.Floats);
         deallocate (Each.Texts);
      end loop;

      deallocate (Self);
   end free;



   procedure free (Self : in out Int_array_view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Int_array, Int_array_view);
   begin
      deallocate (Self);
   end free;


   ----------
   --- Inputs
   --

   function find_in (Self : in Inputs;   the_Semantic : in library.Semantic) return Input_t
   is
   begin
      for Each of Self
      loop
         if Each.Semantic = the_Semantic
         then
            return Each;
         end if;
      end loop;

      return null_Input;
   end find_in;



   function Offset_of (Self : in Inputs;   the_Semantic : in library.Semantic) return Natural
   is
      the_Input : constant Input_t := find_in (Self, the_Semantic);
   begin
      if the_Input = null_Input
      then
         raise Input_not_found with "No input with semantic " & the_Semantic'Image;
      end if;

      return the_Input.Offset;
   end Offset_of;



   procedure free (Self : in out Inputs_view)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Inputs, Inputs_view);
   begin
      deallocate (Self);
   end free;


end collada.Library;
