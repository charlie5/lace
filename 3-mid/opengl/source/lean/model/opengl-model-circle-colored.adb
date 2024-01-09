with
     openGL.Geometry.colored,
     openGL.Primitive.indexed;


package body openGL.Model.circle.colored
is
   ---------
   --- Forge
   --

   function new_circle (Radius : in Real;
                        Color  : in openGL.lucid_Color := (Primary => openGL.Palette.White,
                                                           Opacity => Opaque);
                        Sides  : in Positive           := 24) return View
   is
      Self : constant View := new Item;
   begin
      Self.Radius := Radius;
      Self.Color  := Color;
      Self.Sides  := Sides;

      return Self;
   end new_circle;



   ---------------------
   --- openGL Geometries
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views
   is
      pragma unreferenced (Fonts);

      use Geometry,
          Geometry.colored;


      function to_Indices return Indices
      is
         Result : Indices (1 .. long_Index_t (Self.Sides));
      begin
         for i in 1 .. long_Index_t (Self.Sides)
         loop
            Result (i) := Index_t (i);
         end loop;

         return Result;
      end to_Indices;


      the_Indices : aliased constant Indices        := to_Indices;
      the_Sites   :         constant Vector_2_array := vertex_Sites (Self.Radius,
                                                                     Self.Sides);


      function new_Face (Vertices : in geometry.colored.Vertex_array) return Geometry.colored.view
      is
         use Primitive;

         the_Geometry  : constant Geometry .colored.view := Geometry.colored.new_Geometry;
         the_Primitive : constant Primitive.indexed.view := Primitive.indexed.new_Primitive (line_Loop, the_Indices);

      begin
         the_Geometry.Vertices_are (Vertices);
         the_Geometry.add          (Primitive.view (the_Primitive));

         the_Geometry.is_Transparent (True);     -- TODO: Do transparency properly.
         the_Geometry.Model_is       (Self.all'unchecked_Access);

         return the_Geometry;
      end new_Face;


      upper_Face : Geometry.colored.view;

   begin
      --  Upper Face
      --
      declare
         the_Vertices : Geometry.colored.Vertex_array (1 .. Index_t (Self.Sides));
      begin
         for i in the_Vertices'Range
         loop
            the_Vertices (i) := (Site  =>  Vector_3 (the_Sites (Positive (i)) & 0.0),
                                 Color => +Self.Color);
         end loop;

         upper_Face := new_Face (Vertices => the_Vertices);
      end;

      return [1 => upper_Face.all'Access];
   end to_GL_Geometries;


end openGL.Model.circle.colored;
