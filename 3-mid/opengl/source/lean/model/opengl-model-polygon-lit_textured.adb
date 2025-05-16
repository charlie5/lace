with
     openGL.Geometry.lit_textured,
     openGL.Primitive.indexed,
     openGL.Texture.Coordinates;


package body openGL.Model.polygon.lit_textured
is
   ---------
   --- Forge
   --

   function new_polygon (vertex_Sites : in Vector_2_array;
                         Face         : in Face_t) return View
   is
      Self : constant View := new Item;
   begin
      Self.vertex_Sites (1 .. vertex_Sites'Length) := vertex_Sites;
      Self.vertex_Count                            := vertex_Sites'Length;

      Self.Face := Face;

      return Self;
   end new_polygon;




   ------------------
   --- Attributes ---
   ------------------

   function Face (Self : in Item) return Face_t
   is
   begin
      return Self.Face;
   end Face;



   ------------
   -- Texturing
   --

   overriding
   procedure Fade_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                            Now   : in texture_Set.fade_Level)
   is
   begin
      Self.Face.texture_Details.Fades (which) := Now;
   end Fade_is;



   overriding
   function Fade (Self : in Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
   is
   begin
      return Self.Face.texture_Details.Fades (which);
   end Fade;



   procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in openGL.asset_Name)
   is
   begin
      Self.Face.texture_Details.Textures (Positive (which)) := Now;
   end Texture_is;




   overriding
   function texture_Count (Self : in Item) return Natural
   is
   begin
      return Self.Face.texture_Details.texture_Count;
   end texture_Count;



   overriding
   function texture_Applied (Self : in Item;   Which : in texture_Set.texture_Id) return Boolean
   is
   begin
      return Self.Face.texture_Details.texture_Applies (Which);
   end texture_Applied;



   overriding
   procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in Boolean)
   is
   begin
      Self.Face.texture_Details.texture_Applies (Which) := Now;
   end texture_Applied_is;




   overriding
   procedure animate (Self : in out Item)
   is
      use type texture_Set.Animation_view;
   begin
      if Self.Face.texture_Details.Animation = null
      then
         return;
      end if;

      texture_Set.animate (Self.Face.texture_Details.Animation.all,
                           Self.Face.texture_Details.texture_Applies);
   end animate;



   --------------------
   --- to_GL_Geometries
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views
   is
      pragma unreferenced (Fonts);

      use Geometry,
          Geometry.lit_textured,
          Texture;

      the_Sites : Vector_2_array renames Self.vertex_Sites (1 .. Self.vertex_Count);


      function new_Geometry (Vertices : in geometry.lit_textured.Vertex_array) return Geometry.lit_textured.view
      is
         use Primitive,
             texture_Set;


         function the_Indices return Indices
         is
            Result : Indices (1 .. the_Sites'Length);
         begin
            for i in Result'Range
            loop
               Result (i) := Index_t (i);
            end loop;

            return Result;
         end the_Indices;


         the_Geometry  : constant Geometry.lit_textured.view
           := Geometry.lit_textured.new_Geometry;

         the_Primitive : constant Primitive.indexed.view
           := Primitive.indexed.new_Primitive (triangle_Fan, the_Indices);

         Id : texture_Set.texture_Id;

      begin
         the_Geometry.Vertices_are (Vertices);
         the_Geometry.add          (Primitive.view (the_Primitive));

         for i in 1 .. Self.Face.texture_Details.texture_Count
         loop
            Id := texture_Id (i);

            the_Geometry.Fade_is (which => Id,
                                  now   => Self.Face.texture_Details.Fades (Id));

            the_Geometry.Texture_is     (which => Id,
                                         now   => Textures.fetch (Self.Face.texture_Details.Textures (i)));
            the_Geometry.is_Transparent (now   => the_Geometry.Texture.is_Transparent);
         end loop;

         the_Geometry.is_Transparent (True);     -- TODO: Do transparency properly.
         the_Geometry.Model_is       (Self.all'unchecked_Access);

         return the_Geometry;
      end new_Geometry;


      face_Geometry : Geometry.lit_textured.view;

   begin
      --  Geometry
      --
      declare
         use openGL.Texture.Coordinates;

         the_Vertices        :          Geometry.lit_textured.Vertex_array (1 .. the_Sites'Length + 1);
         Coords_and_Centroid : constant Coords_2D_and_Centroid := to_Coordinates (the_Sites);
      begin
         for i in the_Sites'Range
         loop
            the_Vertices (Index_t (i)) := (Site   => Vector_3 (the_Sites (i) & 0.0),
                                           Normal => Normal,
                                           Coords => (Coords_and_Centroid.Coords (Index_t (i)).S * Self.Face.texture_Details.texture_Tiling,
                                                      Coords_and_Centroid.Coords (Index_t (i)).T * Self.Face.texture_Details.texture_Tiling),
                                           Shine  => default_Shine);
         end loop;

         the_Vertices (the_Vertices'Last) := (Site   => Vector_3 (Coords_and_Centroid.Centroid & 0.0),
                                              Normal => Normal,
                                              Coords => (S => 0.5 * Self.Face.texture_Details.texture_Tiling,
                                                         T => 0.5 * Self.Face.texture_Details.texture_Tiling),
                                              Shine  => default_Shine);

         face_Geometry := new_Geometry (Vertices => the_Vertices);
      end;

      return [1 => face_Geometry.all'Access];
   end to_GL_Geometries;


end openGL.Model.polygon.lit_textured;
