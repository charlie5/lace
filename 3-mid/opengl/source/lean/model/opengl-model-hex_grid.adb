with
     openGL.Geometry.colored,
     openGL.Primitive.indexed,

     float_Math.Geometry.d2.Hexagon,

     ada.Containers.hashed_Maps,
     ada.unchecked_Deallocation;


package body openGL.Model.hex_grid
is
   --------
   -- Forge
   --

   function new_Grid (heights_Asset : in asset_Name;
                      Heights       : in height_Map_view;
                      Color         : in lucid_Color    := (palette.White,
                                                            Opaque)) return View
   is
      the_Model : constant View := new Item' (Model.item with
                                              heights_Asset => heights_Asset,
                                              Heights       => Heights,
                                              Color         => +Color);
   begin
      the_Model.set_Bounds;
      return the_Model;
   end new_Grid;



   overriding
   procedure destroy (Self : in out Item)
   is
      procedure deallocate is new ada.unchecked_Deallocation (height_Map,
                                                              height_Map_view);
   begin
      destroy    (Model.item (Self));
      deallocate (Self.Heights);
   end destroy;



   -------------
   -- Attributes
   --

   package hexagon_Geometry renames Geometry_2d.Hexagon;


   -- site_Map_of_vertex_Id
   --

   function Hash (From : in Geometry_2d.Site) return ada.Containers.Hash_type
   is
      use ada.Containers;

      type Fix is delta 0.00_1 range 0.0 .. 1000.0;

      cell_Size  : constant Fix := 0.5;
      grid_Width : constant     := 10;
   begin
      return   Hash_type (Fix (From (1)) / cell_Size)
             + Hash_type (Fix (From (2)) / cell_Size) * grid_Width;
   end Hash;



   function Equivalent (S1, S2 : Geometry_2d.Site) return Boolean
   is
      Tolerance : constant := 0.1;
   begin
      return     abs (S2 (1) - S1 (1)) < Tolerance
             and abs (S2 (2) - S1 (2)) < Tolerance;
   end Equivalent;



   type Coordinates_array is array (Index_t range <>) of hexagon_Geometry.Coordinates;

   type hex_Vertex is
      record
         shared_Hexes : Coordinates_array (1 .. 3);
         shared_Count : Index_t := 0;

         Site         : Geometry_3d.Site;
      end record;

   type hex_Vertices is array (Index_t range <>) of hex_Vertex;



   package site_Maps_of_vertex_Id is new ada.Containers.hashed_Maps (Key_type        => Geometry_2d.Site,
                                                                     Element_type    => Index_t,
                                                                     Hash            => Hash,
                                                                     equivalent_Keys => Equivalent,
                                                                     "="             => "=");

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views
   is
      pragma Unreferenced (Textures, Fonts);

      use Geometry,
          Geometry.colored,
          Geometry_2d;

      site_Map_of_vertex_Id : site_Maps_of_vertex_Id.Map;
        next_free_vertex_Id : Index_t := 0;


      function fetch_Id (S : in geometry_2d.Site) return Index_t
      is
         use site_Maps_of_vertex_Id;
         C : constant Cursor := site_Map_of_vertex_Id.Find (S);
      begin
         if has_Element (C)
         then
            return Element (C);
         else
            next_free_vertex_Id := @ + 1;
            site_Map_of_vertex_Id.insert (S, next_free_vertex_Id);

            return next_free_vertex_Id;
         end if;
      end fetch_Id;


      Heights   : height_Map_view renames Self.Heights;

      row_Count : constant Index_t := Heights'Length (1);
      col_Count : constant Index_t := Heights'Length (2);

      the_Grid  : constant hexagon_Geometry.Grid := Hexagon.to_Grid (Rows         => Positive (row_Count),
                                                                     Cols         => Positive (col_Count),
                                                                     circumRadius => 1.0);
      zigzag_Count : constant Index_t := col_Count + 1;

      first_zigzag_vertex_Count  : constant Index_t := row_Count * 2 + 1;
        mid_zigzag_vertex_Count  : constant Index_t := row_Count * 2 + 2;
       last_zigzag_vertex_Count  : constant Index_t := row_Count * 2 + 1;

      zigzags_vertex_Count       : constant Index_t :=   first_zigzag_vertex_Count
                                                       + (mid_zigzag_vertex_Count) * (zigzag_Count - 2)
                                                       + last_zigzag_vertex_Count;
      zigzag_joiner_vertex_Count : constant Index_t := col_Count * 2;


      vertex_Count  : constant Index_t :=         zigzags_vertex_Count
                                          + zigzag_joiner_vertex_Count;

      hex_Vertices  : hex_Grid.hex_Vertices (1 .. zigzags_vertex_Count);

      zigzags_indices_Count : constant long_Index_t := long_Index_t (vertex_Count);

      gl_Vertices      : aliased  Geometry.colored.Vertex_array (1 .. vertex_Count);

      hex_Count        : constant long_Index_t := long_Index_t (col_Count * row_Count * 2);

      zigzags_Indices  : aliased  Indices (1 .. zigzags_indices_Count);
      tops_Indices     : aliased  Indices (1 ..   hex_Count
                                                + long_Index_t (col_Count * 2));

      zigzags_Geometry : constant Geometry.colored.view := Geometry.colored.new_Geometry;
         tops_Geometry : constant Geometry.colored.view := Geometry.colored.new_Geometry;


      min_Site : Site := [Real'Last,  Real'Last,  Real'Last];
      max_Site : Site := [Real'First, Real'First, Real'First];

   begin

      find_shared_Hexes_per_Vertex:
      begin
         for Row in 1 .. row_Count
         loop

            for Col in 1 .. col_Count
            loop

               for Which in hexagon_Geometry.vertex_Id
               loop
                  declare
                     use hexagon_Geometry;
                     Site       : constant Geometry_2d.Site := vertex_Site (the_Grid,
                                                                            hex_Id => [Positive (Row),
                                                                                       Positive (Col)],
                                                                            Which  => Which);

                     vertex_Id  : constant Index_t    :=      fetch_Id (S => Site);
                     the_Vertex :          hex_Vertex renames hex_Vertices (vertex_Id);
                     C          : constant Index_t    :=      the_Vertex.shared_Count + 1;
                  begin
                     the_Vertex.shared_Count     := C;
                     the_Vertex.shared_Hexes (C) := [Positive (Row),
                                                     Positive (Col)];
                     the_Vertex.Site := [Site (1),
                                         0.0,
                                         Site (2)];
                  end;
               end loop;

            end loop;

         end loop;
      end find_shared_Hexes_per_Vertex;


      set_Height_for_each_Vertex:
      begin
         for Row in 1 .. row_Count
         loop

            for Col in 1 .. col_Count
            loop

               for Which in hexagon_Geometry.vertex_Id
               loop
                  declare
                     use hexagon_Geometry;
                     Site       : constant Geometry_2d.Site := vertex_Site (the_Grid,
                                                                            hex_Id => [Positive (Row),
                                                                                       Positive (Col)],
                                                                            Which  => Which);
                     Height     :          Real       :=      0.0;
                     vertex_Id  : constant Index_t    :=      fetch_Id (S => Site);
                     the_Vertex :          hex_Vertex renames hex_Vertices (vertex_Id);
                  begin
                     for Each in 1 .. the_Vertex.shared_Count
                     loop
                        Height := Height + Heights (Row, Col);
                     end loop;

                     Height          := Height / Real (the_Vertex.shared_Count);
                     the_Vertex.Site := [Site (1),
                                         Height,
                                         Site (2)];

                     min_Site := [Real'Min (min_Site (1), the_Vertex.Site (1)),
                                  Real'Min (min_Site (2), the_Vertex.Site (2)),
                                  Real'Min (min_Site (3), the_Vertex.Site (3))];

                     max_Site := [Real'Max (min_Site (1), the_Vertex.Site (1)),
                                  Real'Max (min_Site (2), the_Vertex.Site (2)),
                                  Real'Max (min_Site (3), the_Vertex.Site (3))];
                  end;
               end loop;

            end loop;

         end loop;
      end set_Height_for_each_Vertex;


      set_GL_Vertices:
      declare
         Center    : constant Site := [(max_Site (1) - min_Site (1)) / 2.0,
                                       (max_Site (2) - min_Site (2)) / 2.0,
                                       (max_Site (3) - min_Site (3)) / 2.0];

         vertex_Id :          Index_t    := 0;
         Color     : constant rgba_Color := Self.Color;
      begin
         --- Add hex vertices.
         --
         for i in hex_Vertices'Range
         loop
            vertex_Id := vertex_Id + 1;

            gl_Vertices (vertex_Id).Site  := hex_Vertices (vertex_Id).Site - Center;
            gl_Vertices (vertex_Id).Color := Color;
         end loop;

         --- Add joiner vertices.
         --
         for i in 1 .. col_Count
         loop
            declare
               use hexagon_Geometry;

               Site : Geometry_2d.Site := vertex_Site (the_Grid,
                                                       hex_Id => [Row => Positive (row_Count),
                                                                  Col => Positive (i)],
                                                       Which  => 3);
               hex_vertex_Id : Index_t := fetch_Id (Site);
            begin
               vertex_Id               := vertex_Id + 1;
               gl_Vertices (vertex_Id) := (Site  => hex_Vertices (hex_vertex_Id).Site - Center,
                                           Color => (Primary => Color.Primary,
                                                     Alpha   => 0));

               Site                    := vertex_Site (the_Grid,
                                                       hex_Id => [Row => 1,
                                                                  Col => Positive (i)],
                                                       Which  => 6);

               hex_vertex_Id           := fetch_Id (Site);
               vertex_Id               := vertex_Id + 1;
               gl_Vertices (vertex_Id) := (Site  => hex_Vertices (hex_vertex_Id).Site - Center,
                                           Color => (Primary => Color.Primary,
                                                     Alpha   => 0));
            end;
         end loop;
      end set_GL_Vertices;


      set_zigzags_GL_Indices:
      declare
         Cursor            : long_Index_t := 0;
         joiners_vertex_Id :      Index_t := zigzags_vertex_Count;


         procedure add_zigzag_Vertex (Row, Col   : in Positive;
                                      hex_Vertex : in Hexagon.vertex_Id)
         is
            use hexagon_Geometry;

            Site : constant Geometry_2d.Site := vertex_Site (the_Grid,
                                                             hex_Id => [Row, Col],
                                                             Which  => hex_Vertex);
         begin
            Cursor                   := Cursor + 1;
            zigzags_Indices (Cursor) := fetch_Id (S => Site);
         end add_zigzag_Vertex;


         procedure add_joiner_vertex_Pair
         is
         begin
            Cursor                   := Cursor + 1;
            joiners_vertex_Id        := joiners_vertex_Id + 1;
            zigzags_Indices (Cursor) := joiners_vertex_Id;

            Cursor                   := Cursor + 1;
            joiners_vertex_Id        := joiners_vertex_Id + 1;
            zigzags_Indices (Cursor) := joiners_vertex_Id;
         end add_joiner_vertex_Pair;


      begin
         --- Fist zigzag
         --
         add_zigzag_Vertex (Row => 1, Col => 1, hex_Vertex => 5);

         for Row in 1 .. Positive (row_Count)
         loop
            add_zigzag_Vertex (Row, Col => 1, hex_Vertex => 4);
            add_zigzag_Vertex (Row, Col => 1, hex_Vertex => 3);
         end loop;

         add_joiner_vertex_Pair;


         --- Middles zigzags
         --

         for zz in 2 .. Positive (zigzag_Count) - 1
         loop
            declare
               odd_Zigzag : constant Boolean := zz mod 2 = 1;
            begin
               if odd_Zigzag
               then
                  add_zigzag_Vertex (Row => 1, Col => Positive (zz),     hex_Vertex => 5);

               else -- Even zigzag.
                  add_zigzag_Vertex (Row => 1, Col => Positive (zz - 1), hex_Vertex => 6);
               end if;


               for Row in 1 .. Positive (row_Count)
               loop
                  if odd_Zigzag
                  then
                     add_zigzag_Vertex (Row, Col => zz, hex_Vertex => 4);
                     add_zigzag_Vertex (Row, Col => zz, hex_Vertex => 3);

                     if Row = Positive (row_Count)     -- Last row.
                     then
                        add_zigzag_Vertex (Row, Col => zz - 1, hex_Vertex => 2);
                     end if;

                  else -- Even zigzag.
                     add_zigzag_Vertex (Row, Col => zz, hex_Vertex => 5);
                     add_zigzag_Vertex (Row, Col => zz, hex_Vertex => 4);

                     if Row = Positive (row_Count)     -- Last row.
                     then
                        add_zigzag_Vertex (Row, Col => zz, hex_Vertex => 3);
                     end if;
                  end if;
               end loop;
            end;

            add_joiner_vertex_Pair;
         end loop;


         --- Last zigzag
         --
         add_zigzag_Vertex (Row => 1, Col => Positive (col_Count), hex_Vertex => 6);

         for Row in 1 .. Positive (row_Count)
         loop
            add_zigzag_Vertex (Row, Positive (col_Count), hex_Vertex => 1);
            add_zigzag_Vertex (Row, Positive (col_Count), hex_Vertex => 2);
         end loop;

      end set_zigzags_GL_Indices;


      zigzags_Geometry.is_Transparent (False);
      zigzags_Geometry.Vertices_are   (gl_Vertices);


      set_tops_GL_Indices:
      declare
         Cursor : long_Index_t := 0;
      begin
         for Col in 1 .. col_Count
         loop
            for Row in 1 .. row_Count
            loop
               declare
                  use hexagon_Geometry;
                  Site : Geometry_2d.Site := vertex_Site (the_Grid,
                                                          hex_Id => [Positive (Row),
                                                                     Positive (Col)],
                                                          Which  => 5);
               begin
                  Cursor                := Cursor + 1;
                  tops_Indices (Cursor) := fetch_Id (Site);

                  Site := vertex_Site (the_Grid,
                                       hex_Id => [Positive (Row),
                                                  Positive (Col)],
                                       Which  => 6);

                  Cursor                := Cursor + 1;
                  tops_Indices (Cursor) := fetch_Id (Site);

                  if Row = row_Count     -- Last row, so do bottoms.
                  then
                     Site := vertex_Site (the_Grid,
                                          hex_Id => [Positive (Row),
                                                     Positive (Col)],
                                          Which  => 3);

                     Cursor                := Cursor + 1;
                     tops_Indices (Cursor) := fetch_Id (Site);

                     Site := vertex_Site (the_Grid,
                                          hex_Id => [Positive (Row),
                                                     Positive (Col)],
                                          Which  => 2);

                     Cursor                := Cursor + 1;
                     tops_Indices (Cursor) := fetch_Id (Site);
                  end if;
               end;
            end loop;
         end loop;
      end set_tops_GL_Indices;


      tops_Geometry.is_Transparent (False);
      tops_Geometry.Vertices_are   (gl_Vertices);


      add_zigzag_Geometry:
      declare
         the_Primitive : constant Primitive.indexed.view
           := Primitive.indexed.new_Primitive (Primitive.line_Strip,
                                               zigzags_Indices);
      begin
         zigzags_Geometry.add (Primitive.view (the_Primitive));
      end add_zigzag_Geometry;


      add_tops_Geometry:
      declare
         the_Primitive : constant Primitive.indexed.view
           := Primitive.indexed.new_Primitive (Primitive.Lines,
                                               tops_Indices);
      begin
         tops_Geometry.add (Primitive.view (the_Primitive));
      end add_tops_Geometry;


      return [1 => Geometry.view (zigzags_Geometry),
              2 => Geometry.view (   tops_Geometry)];
   end to_GL_Geometries;



   -- TODO: This is an approximation based on a rectangular grid.
   --       Do a correct calculation based on the hexagon grid vertices.
   --
   overriding
   procedure set_Bounds (Self : in out Item)
   is
      Heights      : height_Map_view renames Self.Heights;

      row_Count    : constant Index_t := Heights'Length (1) - 1;
      col_Count    : constant Index_t := Heights'Length (2) - 1;

      vertex_Count : constant Index_t := Heights'Length (1) * Heights'Length (2);

      the_Sites    : aliased  Sites (1 .. vertex_Count);

      the_Bounds   : openGL.Bounds    := null_Bounds;

   begin
      set_Sites:
      declare
         vert_Id          :          Index_t  := 0;
         the_height_Range : constant Vector_2 := height_Extent (Heights.all);
         Middle           : constant Real     :=   (the_height_Range (1) + the_height_Range (2))
                                                 / 2.0;
      begin
         for Row in 1 .. row_Count + 1
         loop
            for Col in 1 .. col_Count + 1
            loop
               vert_Id             := vert_Id + 1;
               the_Sites (vert_Id) := [Real (Col)         - Real (col_Count) / 2.0 - 1.0,
                                       Heights (Row, Col) - Middle,
                                       Real (Row)         - Real (row_Count) / 2.0 - 1.0];

               the_Bounds.Box.Lower (1) := Real'Min (the_Bounds.Box.Lower (1),  the_Sites (vert_Id) (1));
               the_Bounds.Box.Lower (2) := Real'Min (the_Bounds.Box.Lower (2),  the_Sites (vert_Id) (2));
               the_Bounds.Box.Lower (3) := Real'Min (the_Bounds.Box.Lower (3),  the_Sites (vert_Id) (3));

               the_Bounds.Box.Upper (1) := Real'Max (the_Bounds.Box.Upper (1),  the_Sites (vert_Id) (1));
               the_Bounds.Box.Upper (2) := Real'Max (the_Bounds.Box.Upper (2),  the_Sites (vert_Id) (2));
               the_Bounds.Box.Upper (3) := Real'Max (the_Bounds.Box.Upper (3),  the_Sites (vert_Id) (3));

               the_Bounds.Ball := Real'Max (the_Bounds.Ball,
                                            abs (the_Sites (vert_Id)));
            end loop;
         end loop;

         the_Bounds.Ball := the_Bounds.Ball * 1.1;     -- TODO: Why the '* 1.1' ?
      end set_Sites;

      Self.Bounds := the_Bounds;
   end set_Bounds;


end openGL.Model.hex_grid;
