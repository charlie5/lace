with
     ada.unchecked_Deallocation,
     ada.Tags;


package body openGL.Model
is
   ---------
   --- Forge
   --

   procedure define (Self : out Item) is null;


   procedure deallocate is new ada.unchecked_Deallocation (Geometry.views,
                                                           access_Geometry_views);


   procedure destroy (Self : in out Item)
   is
   begin
      if Self.opaque_Geometries /= null
      then
         for i in Self.opaque_Geometries'Range
         loop
            Geometry.free (Self.opaque_Geometries (i));
         end loop;

         deallocate (Self.opaque_Geometries);
      end if;

      if Self.lucid_Geometries /= null
      then
         for i in Self.lucid_Geometries'Range
         loop
            Geometry.free (Self.lucid_Geometries (i));
         end loop;

         deallocate (Self.lucid_Geometries);
      end if;
   end destroy;



   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Model.item'Class,
                                                              Model.view);
   begin
      Self.destroy;
      deallocate (Self);
   end free;



   --------------
   --- Attributes
   --

   function Id (Self : in Item'Class) return Model_Id
   is
   begin
      return Self.Id;
   end Id;


   procedure Id_is (Self : in out Item'Class;   Now : in Model_Id)
   is
   begin
      Self.Id := Now;
   end Id_is;



   procedure set_Bounds (Self : in out Item)
   is
   begin
      Self.Bounds := null_Bounds;

      if Self.opaque_Geometries /= null
      then
         for Each of Self.opaque_Geometries.all
         loop
            Self.Bounds.Box  :=    Self.Bounds.Box
                                or Each.Bounds.Box;

            Self.Bounds.Ball := Real'Max (Self.Bounds.Ball,
                                          Each.Bounds.Ball);
         end loop;
      end if;

      if Self.lucid_Geometries /= null
      then
         for Each of Self.lucid_Geometries.all
         loop
            Self.Bounds.Box  :=    Self.Bounds.Box
                                or Each.Bounds.Box;

            Self.Bounds.Ball := Real'Max (Self.Bounds.Ball,
                                          Each.Bounds.Ball);
         end loop;
      end if;
   end set_Bounds;



   procedure create_GL_Geometries (Self : in out Item'Class;   Textures : access openGL.Texture.name_Map_of_texture'Class;
                                                               Fonts    : in     Font.font_id_Map_of_font)
   is
      all_Geometries : constant Geometry.views := Self.to_GL_Geometries (Textures, Fonts);

      opaque_Faces   : Geometry.views (1 .. all_Geometries'Length);
      opaque_Count   : Index_t := 0;

      lucid_Faces    : Geometry.views (1 .. all_Geometries'Length);
      lucid_Count    : Index_t := 0;

   begin
      Self.Bounds := null_Bounds;

      -- Separate lucid and opaque geometries.
      --
      for i in all_Geometries'Range
      loop
         if all_Geometries (i).is_Transparent
         then
            lucid_Count               := lucid_Count + 1;
            lucid_Faces (lucid_Count) := all_Geometries (i);
         else
            opaque_Count                := opaque_Count + 1;
            opaque_Faces (opaque_Count) := all_Geometries (i);
         end if;

         Self.Bounds.Box :=    Self.Bounds.Box
                            or all_Geometries (i).Bounds.Box;

         Self.Bounds.Ball:= Real'Max (Self.Bounds.Ball,
                                      all_Geometries (i).Bounds.Ball);
      end loop;


      -- Free any existing geometries.
      --
      if Self.opaque_Geometries /= null
      then
         for i in Self.opaque_Geometries'Range
         loop
            Geometry.free (Self.opaque_Geometries (i));
         end loop;

         deallocate (Self.opaque_Geometries);
      end if;

      if Self.lucid_Geometries /= null
      then
         for i in Self.lucid_Geometries'Range
         loop
            Geometry.free (Self.lucid_Geometries (i));
         end loop;

         deallocate (Self.lucid_Geometries);
      end if;

      -- Create new gemometries.
      --
      Self.opaque_Geometries := new Geometry.views' (opaque_Faces (1 .. opaque_Count));
      Self. lucid_Geometries := new Geometry.views' ( lucid_Faces (1 ..  lucid_Count));
      Self.needs_Rebuild     := False;
   end create_GL_Geometries;



   function is_Modified (Self : in Item) return Boolean
   is
      pragma unreferenced (Self);
   begin
      return False;
   end is_Modified;


   function Bounds (Self : in Item) return openGL.Bounds
   is
   begin
      return Self.Bounds;
   end Bounds;


   function opaque_Geometries (Self : in Item) return access_Geometry_views
   is
   begin
      return Self.opaque_Geometries;
   end opaque_Geometries;


   function lucid_Geometries (Self : in Item) return access_Geometry_views
   is
   begin
      return Self.lucid_Geometries;
   end lucid_Geometries;


   function needs_Rebuild (Self : in Item) return Boolean
   is
   begin
      return Boolean (Self.needs_Rebuild);
   end needs_Rebuild;


   procedure needs_Rebuild (Self : in out Item)
   is
   begin
      Self.needs_Rebuild := True;
   end needs_Rebuild;




   ------------
   -- Texturing
   --

   use ada.Tags;


   function texture_Object (Self : in     Item;   Which : in texture_Set.texture_Id) return openGL.texture.Object
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
      return openGL.Texture.null_Object;
   end texture_Object;



   procedure texture_Object_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                      Now   : in openGL.texture.Object)
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
   end texture_Object_is;



   procedure Fade_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                            Now   : in texture_Set.fade_Level)
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
   end Fade_is;



   function Fade (Self : in Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
      return 0.0;
   end Fade;



   procedure Tiling_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                              Now   : in texture_Set.Tiling)
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
   end Tiling_is;



   function Tiling (Self : in Item;   Which : in texture_Set.texture_Id) return texture_Set.Tiling
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
      return (S => 0.0,
              T => 0.0);
   end Tiling;



   function texture_Count (Self : in Item) return Natural
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
      return 0;
   end texture_Count;



   function texture_Applied (Self : in Item;   Which : in texture_Set.texture_Id) return Boolean
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
      return False;
   end texture_Applied;



   procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in Boolean)
   is
   begin
      raise program_Error with External_Tag (Model.item'Class (Self)'Tag) & " Model does not support texturing.";
   end texture_applied_is;


end openGL.Model;
