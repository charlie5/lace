with
     ada.unchecked_Deallocation;


package body collada.Library.animations
is

   -------------
   --- Animation
   --

   function find_Inputs_of (Self : in Animation;   for_Semantic : in Semantic) return access float_array
   is
      the_Input : constant Input_t := find_in (Self.Sampler.Inputs.all, for_Semantic);
   begin
      if the_Input = null_Input
      then
         return null;
      end if;

      return Source_of (Self.Sources, to_String (the_Input.Source)).Floats;
   end find_Inputs_of;



   function Inputs_of (Self : in Animation) return access float_array
   is
   begin
      return find_Inputs_of (Self, for_Semantic => Input);
   end Inputs_of;



   function Outputs_of (Self : in Animation) return access float_array
   is
   begin
      return find_Inputs_of (Self, for_Semantic => Output);
   end Outputs_of;



   function Interpolations_of (Self : in Animation) return access float_array
   is
   begin
      return find_Inputs_of (Self, for_Semantic => Interpolation);
   end Interpolations_of;


   ----------------
   --- Library Item
   --

   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Animation_array, Animation_array_view);
   begin
      if Self.Contents = null
      then
         return;
      end if;

      for Each of Self.Contents.all
      loop
         free (Each.Sources);
         free (Each.Sampler.Inputs);
      end loop;

      deallocate (Self.Contents);
   end destroy;


end collada.Library.animations;
