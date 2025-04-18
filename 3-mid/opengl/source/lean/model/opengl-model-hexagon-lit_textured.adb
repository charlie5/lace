with
     openGL.Geometry.lit_textured,
     openGL.Primitive.indexed;


package body openGL.Model.hexagon.lit_textured
is
   ---------
   --- Forge
   --

   function new_Hexagon (Radius : in Real;
                         Face   : in lit_textured.Face) return View
   is
      Self : constant View := new Item;
   begin
      Self.Radius := Radius;
      Self.Face   := Face;

      return Self;
   end new_Hexagon;




   ------------------
   --- Attributes ---
   ------------------


   ------------
   -- Texturing
   --

   overriding
   procedure Fade_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                            Now   : in texture_Set.fade_Level)
   is
   begin
      Self.Face.Fades (Which) := Now;
   end Fade_is;



   overriding
   function Fade (Self : in Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
   is
   begin
      return Self.Face.Fades (Which);
   end Fade;



   procedure Texture_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                               Now   : in openGL.asset_Name)
   is
   begin
      Self.Face.Textures (Positive (Which)) := Now;
   end Texture_is;




   overriding
   function texture_Count (Self : in Item) return Natural
   is
   begin
      return Self.Face.texture_Count;
   end texture_Count;




   overriding
   function texture_Applied (Self : in Item;   Which : in texture_Set.texture_Id) return Boolean
   is
   begin
      return Self.Face.texture_Applies (Which);
   end texture_Applied;



   overriding
   procedure texture_Applied_is (Self : in out Item;   Which : in texture_Set.texture_Id;
                                                       Now   : in Boolean)
   is
   begin
      Self.Face.texture_Applies (Which) := Now;
   end texture_Applied_is;



   overriding
   procedure animate (Self : in out Item)
   is
      use type texture_Set.Animation_view;
   begin
      if Self.Face.Animation = null
      then
         return;
      end if;

      texture_Set.animate (Self.Face.Animation.all,
                           Self.Face.texture_Applies);
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

      the_Sites   :         constant hexagon.Sites := vertex_Sites (Self.Radius);
      the_Indices : aliased constant Indices       := (1, 2, 3, 4, 5, 6, 7, 2);


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
         the_Geometry.Vertices_are (Vertices);
         the_Geometry.add          (Primitive.view (the_Primitive));

         for i in 1 .. Self.Face.texture_Count
         loop
            Id := texture_Id (i);

            the_Geometry.Fade_is (which => Id,
                                  now   => Self.Face.Fades (Id));

            the_Geometry.Texture_is     (which => Id,
                                         now   => Textures.fetch (Self.Face.Textures (i)));
            the_Geometry.is_Transparent (now   => the_Geometry.Texture.is_Transparent);
         end loop;

         the_Geometry.is_Transparent (True);     -- TODO: Do transparency properly.
         the_Geometry.Model_is       (Self.all'unchecked_Access);

         return the_Geometry;
      end new_Face;


      upper_Face : Geometry.lit_textured.view;

   begin
      --  Upper Face
      --
      declare
         the_Vertices : constant Geometry.lit_textured.Vertex_array
           := (1 => (Site => (0.0, 0.0, 0.0),  Normal => Normal,  Coords => (0.50, 0.50),  Shine => default_Shine),     -- Center.

               2 => (Site =>   the_Sites (1),  Normal => Normal,  Coords => (1.00, 0.50),  Shine => default_Shine),     -- Mid    right.
               3 => (Site =>   the_Sites (2),  Normal => Normal,  Coords => (0.75, 1.00),  Shine => default_Shine),     -- Bottom right.
               4 => (Site =>   the_Sites (3),  Normal => Normal,  Coords => (0.25, 1.00),  Shine => default_Shine),     -- Bottom left.
               5 => (Site =>   the_Sites (4),  Normal => Normal,  Coords => (0.00, 0.50),  Shine => default_Shine),     -- Mid    left.
               6 => (Site =>   the_Sites (5),  Normal => Normal,  Coords => (0.25, 0.00),  Shine => default_Shine),     -- Top    left.
               7 => (Site =>   the_Sites (6),  Normal => Normal,  Coords => (0.75, 0.00),  Shine => default_Shine));    -- Top    right.
      begin
         upper_Face := new_Face (Vertices => the_Vertices);
      end;

      return (1 => upper_Face.all'Access);
   end to_GL_Geometries;


end openGL.Model.hexagon.lit_textured;
