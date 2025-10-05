with
     openGL.Geometry.lit_textured,
     openGL.Primitive.indexed;


package body openGL.Model.hexagon.lit_textured
is
   ---------
   --- Forge
   --

   function new_Hexagon (Radius          : in Real;
                         texture_Details : in texture_Set.item) return View
   is
      Self : constant View := new Item;
   begin
      Self.Radius := Radius;
      Self.texture_Details_is (texture_Details);

      return Self;
   end new_Hexagon;




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

      the_Sites   :         constant hexagon.Sites := vertex_Sites (Self.Radius);
      the_Indices : aliased constant Indices       := [1, 2, 3, 4, 5, 6, 7, 2];


      function new_Face (Vertices : in geometry.lit_textured.Vertex_array) return Geometry.lit_textured.view
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
            Id := texture_Id (i);

            --  the_Geometry.Fade_is (Which => Id,
            --                        Now   => Self.texture_Details.Fades (Id));

            the_Geometry.Texture_is     (Which => Id,
                                         Now   => Textures.fetch (Self.texture_Details.Details (i).Texture));
            the_Geometry.is_Transparent (Now   => the_Geometry.Texture.is_Transparent);
         end loop;

         the_Geometry.is_Transparent (True);     -- TODO: Do transparency properly.

         return the_Geometry;
      end new_Face;


      upper_Face : Geometry.lit_textured.view;

   begin
      --  Upper Face
      --
      declare
         the_Vertices : constant Geometry.lit_textured.Vertex_array
           := [1 => (Site => [0.0, 0.0, 0.0],  Normal => Normal,  Coords => (0.50, 0.50),  Shine => default_Shine),     -- Center.

               2 => (Site =>   the_Sites (1),  Normal => Normal,  Coords => (1.00, 0.50),  Shine => default_Shine),     -- Mid    right.
               3 => (Site =>   the_Sites (2),  Normal => Normal,  Coords => (0.75, 1.00),  Shine => default_Shine),     -- Bottom right.
               4 => (Site =>   the_Sites (3),  Normal => Normal,  Coords => (0.25, 1.00),  Shine => default_Shine),     -- Bottom left.
               5 => (Site =>   the_Sites (4),  Normal => Normal,  Coords => (0.00, 0.50),  Shine => default_Shine),     -- Mid    left.
               6 => (Site =>   the_Sites (5),  Normal => Normal,  Coords => (0.25, 0.00),  Shine => default_Shine),     -- Top    left.
               7 => (Site =>   the_Sites (6),  Normal => Normal,  Coords => (0.75, 0.00),  Shine => default_Shine)];    -- Top    right.
      begin
         upper_Face := new_Face (Vertices => the_Vertices);
      end;

      return [1 => upper_Face.all'Access];
   end to_GL_Geometries;


end openGL.Model.hexagon.lit_textured;
