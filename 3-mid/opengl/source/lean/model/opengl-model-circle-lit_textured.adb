with
     openGL.Geometry.lit_textured,
     openGL.Primitive.indexed,
     openGL.Texture.Coordinates;


package body openGL.Model.circle.lit_textured
is
   ---------
   --- Forge
   --

   function new_circle (Radius : in Real;
                        Face   : in lit_textured.Face_t;
                        Sides  : in Positive         := 24) return View
   is
      Self : constant View := new Item;
   begin
      Self.Radius := Radius;
      Self.Face   := Face;
      Self.Sides  := Sides;

      return Self;
   end new_circle;



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
