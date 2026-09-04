with
     ada.unchecked_Deallocation;


package body collada.Library.controllers
is

   ------------------
   --- vertex weights
   --

   function joint_Offset_of (Self : in vertex_Weights) return math.Index
   is
   begin
      return math.Index (Offset_of (Self.Inputs.all, Joint));
   end joint_Offset_of;



   function weight_Offset_of (Self : in vertex_Weights) return math.Index
   is
   begin
      return math.Index (Offset_of (Self.Inputs.all, Weight));
   end weight_Offset_of;


   --------
   --- Skin
   --

   function Weights_of (Self : in Skin) return access float_array
   is
      the_Input : constant Input_t := find_in (Self.vertex_weights.Inputs.all, Weight);
   begin
      if the_Input = null_Input
      then
         return null;
      end if;

      return Source_of (Self.Sources, to_String (the_Input.Source)).Floats;
   end Weights_of;



   function bind_shape_Matrix_of (Self : in Skin) return Matrix_4x4
   is
   begin
      return get_Matrix (Self.bind_shape_Matrix, 1);
   end bind_shape_Matrix_of;



   function bind_Poses_of (Self : in Skin) return Matrix_4x4_array
   is
      the_Input : constant Input_t := find_in (Self.Joints.Inputs.all, inv_bind_Matrix);
   begin
      if the_Input = null_Input
      then
         return [];
      end if;

      declare
         Raw : constant Float_array_view := Source_of (Self.Sources, to_String (the_Input.Source)).Floats;
      begin
         if Raw = null
         then
            return [];
         end if;

         return the_Poses : Matrix_4x4_array (1 .. matrix_Count (Raw.all))
         do
            for i in the_Poses'Range
            loop
               the_Poses (i) := get_Matrix (Raw.all, i);
            end loop;
         end return;
      end;
   end bind_Poses_of;



   function joint_Names_of (Self : in Skin) return Text_array
   is
      the_Input  : constant Input_t := find_in (Self.Joints.Inputs.all, Joint);
      the_Source : constant Source  := Source_of (Self.Sources, to_String (the_Input.Source));
   begin
      if the_Input = null_Input
      then
         raise Input_not_found with "Skin has no joint input";
      end if;

      if the_Source.Texts = null
      then
         raise Error with "Skin joint source '" & to_String (the_Input.Source) & "' has no name array";
      end if;

      return the_Source.Texts.all;
   end joint_Names_of;


   ----------------
   --- Library Item
   --

   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Controller_array, Controller_array_view);
   begin
      if Self.Contents = null
      then
         return;
      end if;

      for Each of Self.Contents.all
      loop
         free (Each.Skin.Sources);
         free (Each.Skin.Joints.Inputs);
         free (Each.Skin.vertex_weights.Inputs);
         free (Each.Skin.vertex_weights.v_Count);
         free (Each.Skin.vertex_weights.v);
      end loop;

      deallocate (Self.Contents);
   end destroy;


end collada.Library.controllers;
