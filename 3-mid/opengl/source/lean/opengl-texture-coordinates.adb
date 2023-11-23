package body openGL.Texture.Coordinates
is

   function to_Coordinates (the_Vertices : in Vector_2_array) return Coords_2D_and_Centroid
   is
      Centroid : Vector_2 := [0.0, 0.0];
      Min      : Vector_2 := [Real'Last,  Real'Last];
      Max      : Vector_2 := [Real'First, Real'First];
      Coords   : Vector_2;

      Result   : Coords_2D_and_Centroid (coords_Count => the_Vertices'Length);
   begin
      --- Calculate the centroid and min/max of x and y.
      --
      for i in the_Vertices'Range
      loop
         Centroid := Centroid + the_Vertices (i);

         Min (1) := Real'Min (Min (1),  the_Vertices (i) (1));
         Min (2) := Real'Min (Min (2),  the_Vertices (i) (2));

         Max (1) := Real'Max (Max (1),  the_Vertices (i) (1));
         Max (2) := Real'Max (Max (2),  the_Vertices (i) (2));
      end loop;


      Centroid := Centroid / Real (the_Vertices'Length);


      declare
         half_Width  : constant Real := (Max (1) - Min (1))  /  2.0;
         half_Height : constant Real := (Max (2) - Min (2))  /  2.0;
      begin
         for i in the_Vertices'Range
         loop
            Coords := the_Vertices (i) - Centroid;      -- The centroid is now the origin.

            Coords (1) := Coords (1) / half_Width;
            Coords (2) := Coords (2) / half_Height;     -- The coords are now in range -1.0 .. 1.0.

            Coords (1) := (Coords (1) + 1.0)  /  2.0;
            Coords (2) := (Coords (2) + 1.0)  /  2.0;     -- The coords are now in range 0.0 .. 1.0.

            Result.Coords (Index_t (i)) := (Coords (1),
                                            Coords (2));
         end loop;
      end;


      Result.Centroid := Centroid;
      return Result;
   end to_Coordinates;




   overriding
   function to_Coordinates (Self : in xz_Generator;   the_Vertices : access Sites) return Coordinates_2D
   is
      the_Coords : Coordinates_2D (1 .. the_Vertices'Length);
   begin
      for Each in the_Coords'Range
      loop
         declare
            the_Vertex : Site renames the_Vertices (Each);
            S, T       : Real;
         begin
            -- Normalise.
            --
            S := (  the_Vertex (1)
                  + Self.Normalise.S.Offset) * Self.Normalise.S.Scale;
            T := 1.0 -   (  the_Vertex (3)
                          + Self.Normalise.T.Offset)
                       * Self.Normalise.T.Scale;
            -- Tile.
            --
            S :=   (S + Self.Tile.S.Offset)
                 * Self.Tile.S.Scale;
            T :=   (T + Self.Tile.T.Offset)
                 * Self.Tile.T.Scale;

            the_Coords (Each).S := S;
            the_Coords (Each).T := T;
         end;
      end loop;

      return the_Coords;
   end to_Coordinates;




   overriding
   function to_Coordinates (Self : in xy_Generator;   the_Vertices : access Sites) return Coordinates_2D
   is
      the_Coords : Coordinates_2D (1 .. the_Vertices'Length);
   begin
      for Each in the_Coords'Range
      loop
         declare
            the_Vertex : Site renames the_Vertices (Index_t (Each));
            S, T       : Real;
         begin
            -- Normalise.
            --
            S :=   (the_Vertex (1) + Self.Normalise.S.Offset)
                 * Self.Normalise.S.Scale;
            T := 1.0 -   (  the_Vertex (2)
                          + Self.Normalise.T.Offset)
                       * Self.Normalise.T.Scale;
            -- Tile.
            --
            S :=   (S + Self.Tile.S.Offset)
                 * Self.Tile.S.Scale;
            T :=   (T + Self.Tile.T.Offset)
                 * Self.Tile.T.Scale;

            the_Coords (Each).S := S;
            the_Coords (Each).T := T;
         end;
      end loop;

      return the_Coords;
   end to_Coordinates;




   overriding
   function to_Coordinates (Self : in zy_Generator;   the_Vertices : access Sites) return Coordinates_2D
   is
      the_Coords : Coordinates_2D (1 .. the_Vertices'Length);
   begin
      for Each in the_Coords'Range
      loop
         declare
            the_Vertex : Site renames the_Vertices (Index_t (Each));
            S, T       : Real;
         begin
            -- Normalise.
            --
            S :=   (the_Vertex (3) + Self.Normalise.S.Offset)
                                   * Self.Normalise.S.Scale;
            T := 1.0 -   (  the_Vertex (2)
                          + Self.Normalise.T.Offset)
                       * Self.Normalise.T.Scale;
            -- Tile.
            --
            S :=   (S + Self.Tile.S.Offset)
                 * Self.Tile.S.Scale;
            T :=   (T + Self.Tile.T.Offset)
                 * Self.Tile.T.Scale;

            the_Coords (Each).S := S;
            the_Coords (Each).T := T;
         end;
      end loop;

      return the_Coords;
   end to_Coordinates;



   --  TODO: - Below does not cater for 'right edge' case where 's' should be
   --          1.0 rather than 0.0
   --
   --       - Would be possible given a known set of vertices
   --         ie - First vertex is North Pole,
   --            - Last  vertex is South Pole,
   --            - Middle vertices are a set of latitude rings.
   --              - Each rings first vertex site should map s => 0.0
   --              - Each rings last  vertex is a duplicate of the first and
   --                will be mapped to s => 1.0
   --
   overriding
   function to_Coordinates (Self : in mercator_Generator;   the_Vertices : access Sites) return Coordinates_2D
   is
      pragma Unreferenced (Self);
      the_Coords : Coordinates_2D (1 .. the_Vertices'Length);
   begin
      for Each in the_Coords'Range
      loop
         declare
            use real_Functions;

            the_Vertex : Site renames the_Vertices (Index_t (Each));

            x : Real renames the_Vertex (1);
            y : Real renames the_Vertex (2);
            z : Real renames the_Vertex (3);

            Degrees_90  : constant      := Pi / 2.0;
            Degrees_180 : constant      := Pi;
            Radius      : constant Real := SqRt (x * x  +  y * y  +  z * z);

            Latitude    : constant Real := arcSin (y / Radius);
            Longitude   :          Real;
         begin
            if         z = 0.0
              and then x = 0.0
            then
               the_Coords (Each).S := 0.5;
            else
               Longitude           := arcTan (-z, x);
               the_Coords (Each).S := (Longitude / Degrees_180 + 1.0) / 2.0;
            end if;

            the_Coords (Each).T := (Latitude / Degrees_90 + 1.0) / 2.0;
         end;
      end loop;

      return the_Coords;
   end to_Coordinates;


end openGL.Texture.Coordinates;
