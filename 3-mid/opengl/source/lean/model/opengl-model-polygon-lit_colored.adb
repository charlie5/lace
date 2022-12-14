with
     openGL.Geometry.lit_colored,
     openGL.Primitive.indexed;


package body openGL.Model.polygon.lit_colored
is

   function new_Polygon (Vertices : in Vector_2_array;
                         Color    : in lucid_Color) return View
   is
      Self : constant View := new Item;
   begin
      Self.Color := Color;

      Self.Vertices (Vertices'Range) := Vertices;
      Self.vertex_Count              := Vertices'Length;

      Self.define  (scale => (1.0, 1.0, 1.0));
      return Self;
   end new_Polygon;



   type Geometry_view is access all openGL.Geometry.lit_colored.item'class;


   --  nb: - An extra vertex is required at the end of each latitude ring
   --      - This last vertex has the same site as the rings initial vertex.
   --      - The  last    vertex has 's' texture coord of 1.0, whereas
   --        the  initial vertex has 's' texture coord of 0.0
   --
   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Maps_of_font.Map) return openGL.Geometry.views
   is
      pragma Unreferenced (Textures, Fonts);

      use openGL.Geometry,
          openGL.Geometry.lit_colored;

      vertex_Count  : constant      Index_t :=      Index_t (Self.vertex_Count);
      indices_Count : constant long_Index_t := long_Index_t (Self.vertex_Count);

      the_Vertices  : aliased  Geometry.lit_colored.Vertex_array := (1 .. vertex_Count  => <>);
      the_Indices   : aliased  Indices                           := (1 .. indices_Count => <>);

      the_Geometry  : constant Geometry_view := Geometry_view (Geometry.lit_colored.new_Geometry);

   begin
      set_Vertices :
      begin
         for Each in 1 .. vertex_Count
         loop
            the_Vertices (Each).Site   := math.Vector_3 (Self.Vertices (Integer (Each)) & 0.0);
            the_Vertices (Each).Normal := (0.0, 0.0, 1.0);
            the_Vertices (Each).Color  := Self.Color;
         end loop;
      end set_Vertices;


      --- Set Indices.
      --
      for Each in the_Indices'Range
      loop
         the_Indices (Each) := openGL.Index_t (Each);
      end loop;

      the_Geometry.is_Transparent (False);
      the_Geometry.Vertices_are   (the_Vertices);

      declare
         the_Primitive : constant openGL.Primitive.indexed.view
           := openGL.Primitive.indexed.new_Primitive (primitive.triangle_Fan,
                                                      the_Indices);
      begin
         the_Geometry.add (openGL.Primitive.view (the_Primitive));
      end;

      return (1 => openGL.Geometry.view (the_Geometry));
   end to_GL_Geometries;


end openGL.Model.polygon.lit_colored;
