with
     openGL.Geometry.lit_textured,
     openGL.Primitive.indexed,
     openGL.Texture.Coordinates;

with ada.Text_IO;   use ada.Text_IO;


package body openGL.Model.circle.lit_textured
is
   ---------
   --- Forge
   --

   function new_circle (Radius          : in Real;
                        texture_Details : in texture_Set.item;
                        Sides           : in Positive           := 24) return View
   is
      Self : constant View := new Item;
   begin
      Self.Radius := Radius;
      Self.texture_Details_is (texture_Details);
      Self.Sides  := Sides;

      return Self;
   end new_circle;



   ------------------
   --- Attributes ---
   ------------------


   ---------------------
   --- openGL Geometries
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views
   is
      pragma unreferenced (Fonts);

      use Geometry,
          Geometry.lit_textured,
          Texture;


      function to_Indices return Indices
      is
         Result : Indices (1 .. long_Index_t (Self.Sides) + 2);
      begin
         for i in 1 .. Index_t (Self.Sides) + 1
         loop
            Result (long_Index_t (i)) := i; -- Index_t (Self.Sides) + 1 - i;
         end loop;

         Result (Result'Last) := 2;

         return Result;
      end to_Indices;


      the_Indices : aliased constant Indices        := to_Indices;
      the_Sites   :         constant Vector_2_array := vertex_Sites (Self.Radius,
                                                                     Self.Sides);


      function new_Geometry (Vertices : in geometry.lit_textured.Vertex_array) return Geometry.lit_textured.view
      is
         use Primitive,
             texture_Set;

         the_Geometry  : constant Geometry.lit_textured.view
           := Geometry.lit_textured.new_Geometry;

         the_Primitive : constant Primitive.indexed.view
           := Primitive.indexed.new_Primitive (triangle_Fan, the_Indices);

         Id : texture_Set.texture_Id;
      begin
         the_Geometry.Model_is     (Self.all'unchecked_Access);
         the_Geometry.Vertices_are (Vertices);
         the_Geometry.add          (Primitive.view (the_Primitive));

         for i in 1 .. Self.texture_Details.Count
         loop
            put_Line ("KKK" & Self.texture_Details'Image);


            Id := texture_Id (i);

            --  the_Geometry.Fade_is (which => Id,
            --                        now   => Self.texture_Details.Fades (Id));

            the_Geometry.Texture_is     (Which => Id,
                                         Now   => Textures.fetch (Self.texture_Details.Details (i).Texture));
            the_Geometry.is_Transparent (Now   => the_Geometry.Texture.is_Transparent);
         end loop;

         the_Geometry.is_Transparent (True);     -- TODO: Do transparency properly.

         return the_Geometry;
      end new_Geometry;


      face_Geometry : Geometry.lit_textured.view;

   begin
      -- Geometry.
      --
      declare
         use Texture.Coordinates;

         the_Coords   : constant Texture.Coordinates.Coords_2D_and_Centroid := to_Coordinates (the_Sites);
         the_Vertices :          Geometry.lit_textured.Vertex_array (1 .. Index_t (Self.Sides + 1));
      begin
         -- Center.
         --
         the_Vertices (1) := (Site   => [0.0, 0.0, 0.0],
                              Normal => Normal,
                              Coords => (0.50, 0.50),
                              Shine  => default_Shine);
         -- Circumference.
         --
         for i in 2 .. the_Vertices'Last
         loop
            the_Vertices (i) := (Site   => Vector_3 (the_Sites (Positive (i - 1)) & 0.0),
                                 Normal => Normal,
                                 Coords => the_Coords.Coords (i - 1),
                                 Shine  => default_Shine);
         end loop;

         face_Geometry := new_Geometry (Vertices => the_Vertices);
      end;

      return [1 => face_Geometry.all'Access];
   end to_GL_Geometries;


end openGL.Model.circle.lit_textured;
