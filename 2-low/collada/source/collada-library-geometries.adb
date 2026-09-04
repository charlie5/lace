with
     ada.unchecked_Deallocation;


package body collada.Library.geometries
is

   -------------
   --- Primitive
   --

   function vertex_Offset_of (Self : in Primitive) return math.Index
   is
   begin
      return math.Index (Offset_of (Self.Inputs.all, Vertex));
   end vertex_Offset_of;



   function normal_Offset_of (Self : in Primitive) return math.Index
   is
   begin
      return math.Index (Offset_of (Self.Inputs.all, Normal));
   end normal_Offset_of;



   function coord_Offset_of (Self : in Primitive) return math.Index
   is
   begin
      return math.Index (Offset_of (Self.Inputs.all, TexCoord));
   end coord_Offset_of;


   --------
   --- Mesh
   --

   function Source_of (Self        : in Mesh;
                       source_Name : in String) return Source
   is
   begin
      return Source_of (Self.Sources, source_Name);
   end Source_of;



   function Positions_of (Self : in Mesh) return access float_array
   is
      the_Input : constant Input_t := find_in (Self.Vertices.Inputs.all, Position);
   begin
      if the_Input = null_Input
      then
         return null;
      end if;

      return Source_of (Self, to_String (the_Input.Source)).Floats;
   end Positions_of;



   function Normals_of (Self          : in Mesh;
                        for_Primitive : in Primitive) return access float_array
   is
      the_Input : constant Input_t := find_in (for_Primitive.Inputs.all, Normal);
   begin
      if the_Input = null_Input
      then
         return null;
      end if;

      return Source_of (Self, to_String (the_Input.Source)).Floats;
   end Normals_of;



   function Coords_of (Self          : in Mesh;
                       for_Primitive : in Primitive) return access float_array
   is
      the_Input : constant Input_t := find_in (for_Primitive.Inputs.all, TexCoord);
   begin
      if the_Input = null_Input
      then
         return null;
      end if;

      return Source_of (Self, to_String (the_Input.Source)).Floats;
   end Coords_of;


   ----------------
   --- Library Item
   --

   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Geometry_array,  Geometry_array_view);
      procedure deallocate is new ada.unchecked_Deallocation (Primitives,      Primitives_view);
      procedure deallocate is new ada.unchecked_Deallocation (Int_array_List,  Int_array_List_view);
   begin
      if Self.Contents = null
      then
         return;
      end if;

      for Each of Self.Contents.all
      loop
         free (Each.Mesh.Sources);
         free (Each.Mesh.Vertices.Inputs);

         if Each.Mesh.Primitives /= null
         then
            for the_Primitive of Each.Mesh.Primitives.all
            loop
               free (the_Primitive.Inputs);

               if the_Primitive.P_List /= null
               then
                  for the_List of the_Primitive.P_List.all
                  loop
                     free (the_List);
                  end loop;

                  deallocate (the_Primitive.P_List);
               end if;

               if the_Primitive.Kind = polyList
               then
                  free (the_Primitive.vCount);
               end if;
            end loop;

            deallocate (Each.Mesh.Primitives);
         end if;
      end loop;

      deallocate (Self.Contents);
   end destroy;


end collada.Library.geometries;
