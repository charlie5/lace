with
     ada.Text_IO,
     ada.IO_Exceptions,
     ada.Strings.unbounded,
     ada.Strings.Maps;


package body any_Math.any_Geometry.any_d3.any_Modeller.any_Forge
is

   function to_Box_Model (half_Extents : in Vector_3 := [0.5, 0.5, 0.5]) return a_Model
   is
      Modeller : any_Modeller.item;

      X : constant Real := half_Extents (1);
      Y : constant Real := half_Extents (2);
      Z : constant Real := half_Extents (3);

      -- The eight corners; counter-clockwise when seen from outside gives outward facing triangles.
      --
      P0 : constant Site := [-X, -Y, -Z];
      P1 : constant Site := [ X, -Y, -Z];
      P2 : constant Site := [ X,  Y, -Z];
      P3 : constant Site := [-X,  Y, -Z];
      P4 : constant Site := [-X, -Y,  Z];
      P5 : constant Site := [ X, -Y,  Z];
      P6 : constant Site := [ X,  Y,  Z];
      P7 : constant Site := [-X,  Y,  Z];

      procedure add_Face (A, B, C, D : in Site)
      is
      begin
         Modeller.add_Triangle (A, B, C);
         Modeller.add_Triangle (A, C, D);
      end add_Face;

   begin
      add_Face (P4, P5, P6, P7);     -- Front  (+Z).
      add_Face (P1, P0, P3, P2);     -- Back   (-Z).
      add_Face (P5, P1, P2, P6);     -- Right  (+X).
      add_Face (P0, P4, P7, P3);     -- Left   (-X).
      add_Face (P3, P7, P6, P2);     -- Top    (+Y).
      add_Face (P0, P1, P5, P4);     -- Bottom (-Y).

      return Modeller.Model;
   end to_Box_Model;



   function to_Capsule_Model (Length : in Real := 1.0;
                              Radius : in Real := 0.5) return a_Model
   is
      use Functions;

      quality_Level : constant Positive := 4;
      sides_Count   : constant Positive := Positive (quality_Level * 4);     -- Number of sides to the cylinder (divisible by 4).

      type Edge is   -- 'Barrel' edge.
         record
            Fore : Site;
            Aft  : Site;
         end record;

      type      Edges is array (Positive range 1 .. sides_Count)   of Edge;
      type arch_Edges is array (Positive range 1 .. quality_Level) of Sites (1 .. sides_Count);

      tmp,
      ny, nz,
      start_nx,
      start_ny  : Real;
      a         : constant Real := Pi * 2.0 / Real (sides_Count);
      ca        : constant Real := Cos (a);
      sa        : constant Real := Sin (a);
      L         : constant Real := Length * 0.5;

      the_Edges : Edges;
      Modeller  : any_Modeller.item;

   begin
      -- Define cylinder body.
      --
      ny := 1.0;
      nz := 0.0;              -- Normal vector = (0, ny, nz)

      for Each in Edges'Range
      loop
         the_Edges (Each).Fore (1) :=  ny * Radius;
         the_Edges (Each).Fore (2) :=  nz * Radius;
         the_Edges (Each).Fore (3) :=  L;

         the_Edges (Each).Aft  (1) :=  ny * Radius;
         the_Edges (Each).Aft  (2) :=  nz * Radius;
         the_Edges (Each).Aft  (3) := -L;

         -- Rotate ny, nz.
         --
         tmp := ca * ny  -  sa * nz;
         nz  := sa * ny  +  ca * nz;
         ny  := tmp;
      end loop;


      for Each in Edges'Range
      loop
         if Each /= Edges'Last
         then
            Modeller.add_Triangle (the_Edges (Each)    .Fore,
                                   the_Edges (Each)    .Aft,
                                   the_Edges (Each + 1).Aft);
            Modeller.add_Triangle (the_Edges (Each + 1).Aft,
                                   the_Edges (Each + 1).Fore,
                                   the_Edges (Each)    .Fore);

         else
            Modeller.add_Triangle (the_Edges (Each)       .Fore,
                                   the_Edges (Each)       .Aft,
                                   the_Edges (edges'First).Aft);
            Modeller.add_Triangle (the_Edges (edges'First).Aft,
                                   the_Edges (edges'First).Fore,
                                   the_Edges (Each)       .Fore);
         end if;
      end loop;


      -- Define fore cylinder cap.
      --
      declare
         the_arch_Edges : arch_Edges;
      begin
         start_nx := 0.0;
         start_ny := 1.0;

         for each_Hoop in 1 .. quality_Level
         loop
            -- Get start_n2 = rotated start_n.
            --
            declare
               start_nx2 : constant Real :=  ca * start_nx  +  sa * start_ny;
               start_ny2 : constant Real := -sa * start_nx  +  ca * start_ny;
            begin
               -- Get n = start_n and n2 = start_n2.
               --
               ny := start_ny;
               nz := 0.0;

               declare
                  nx2 : constant Real := start_nx2;
                  ny2 :          Real := start_ny2;
                  nz2 :          Real := 0.0;
               begin
                  for Each in 1 .. sides_Count
                  loop
                     the_arch_Edges (each_Hoop)(Each) (1) := ny2 * Radius;
                     the_arch_Edges (each_Hoop)(Each) (2) := nz2 * Radius;
                     the_arch_Edges (each_Hoop)(Each) (3) := nx2 * Radius + L;

                     -- Rotate n, n2.
                     --
                     tmp := ca * ny  -  sa * nz;
                     nz  := sa * ny  +  ca * nz;
                     ny  := tmp;

                     tmp := ca * ny2  -  sa * nz2;
                     nz2 := sa * ny2  +  ca * nz2;
                     ny2 := tmp;
                  end loop;
               end;

               start_nx := start_nx2;
               start_ny := start_ny2;
            end;
         end loop;


         for Each in 1 .. sides_Count
         loop
            if Each /= sides_Count
            then
               Modeller.add_Triangle (the_Edges (Each)    .Fore,
                                      the_Edges (Each + 1).Fore,
                                      the_arch_Edges (1) (Each));

            else
               Modeller.add_Triangle (the_Edges (Each).Fore,
                                      the_Edges (1)   .Fore,
                                      the_arch_Edges (1) (Each));
            end if;

            if Each /= sides_Count
            then
               Modeller.add_Triangle (the_Edges (Each + 1).Fore,
                                      the_arch_Edges (1) (Each + 1),
                                      the_arch_Edges (1) (Each));

            else
               Modeller.add_Triangle (the_Edges (1).Fore,
                                      the_arch_Edges (1) (1),
                                      the_arch_Edges (1) (Each));
            end if;
         end loop;


         for each_Hoop in 1 .. quality_Level - 1
         loop
            for Each in 1 .. sides_Count
            loop
               declare
                  function next_Hoop_Vertex return Positive
                  is
                  begin
                     if Each = sides_Count then return 1;
                     else                       return Each + 1;
                     end if;
                  end next_Hoop_Vertex;
               begin
                  Modeller.add_Triangle (the_arch_Edges (each_Hoop)     (Each),
                                         the_arch_Edges (each_Hoop)     (next_Hoop_Vertex),
                                         the_arch_Edges (each_Hoop + 1) (Each));

                  if each_Hoop /= quality_Level - 1
                  then
                     Modeller.add_Triangle (the_arch_Edges (each_Hoop)     (next_Hoop_Vertex),
                                            the_arch_Edges (each_Hoop + 1) (next_Hoop_Vertex),
                                            the_arch_Edges (each_Hoop + 1) (Each));
                  end if;
               end;
            end loop;
         end loop;
      end;


      -- Define aft cylinder cap.
      --
      declare
         the_arch_Edges : arch_Edges;
      begin
         start_nx := 0.0;
         start_ny := 1.0;

         for each_Hoop in 1 .. quality_Level
         loop
            declare
               -- Get start_n2 = rotated start_n.
               --
               start_nx2 : constant Real := ca * start_nx  -  sa * start_ny;
               start_ny2 : constant Real := sa * start_nx  +  ca * start_ny;
            begin
               -- Get n = start_n and n2 = start_n2.
               --
               ny := start_ny;
               nz := 0.0;

               declare
                  nx2 : constant Real := start_nx2;
                  ny2 :          Real := start_ny2;
                  nz2 :          Real := 0.0;
               begin
                  for Each in 1 .. sides_Count
                  loop
                     the_arch_Edges (each_Hoop) (Each) (1) := ny2 * Radius;
                     the_arch_Edges (each_Hoop) (Each) (2) := nz2 * Radius;
                     the_arch_Edges (each_Hoop) (Each) (3) := nx2 * Radius - L;

                     -- Rotate n, n2
                     --
                     tmp := ca * ny  -  sa * nz;
                     nz  := sa * ny  +  ca * nz;
                     ny  := tmp;

                     tmp := ca * ny2  -  sa * nz2;
                     nz2 := sa * ny2  +  ca * nz2;
                     ny2 := tmp;
                  end loop;
               end;

               start_nx := start_nx2;
               start_ny := start_ny2;
            end;
         end loop;


         for Each in 1 .. sides_Count
         loop
            if Each /= sides_Count
            then
               Modeller.add_Triangle (the_Edges (Each).Aft,
                                      the_arch_Edges (1) (Each),
                                      the_Edges (Each + 1).Aft);

            else
               Modeller.add_Triangle (the_Edges (Each).Aft,
                                      the_arch_Edges (1) (Each),
                                      the_Edges (1).Aft);
            end if;

            if Each /= sides_Count
            then
               Modeller.add_Triangle (The_Edges (Each + 1).Aft,
                                      the_arch_Edges (1) (Each),
                                      the_arch_Edges (1) (Each + 1));

            else
               Modeller.add_Triangle (the_Edges (1).Aft,
                                      the_arch_Edges (1) (Each),
                                      the_arch_Edges (1) (1));
            end if;
         end loop;


         for each_Hoop in 1 .. quality_Level - 1
         loop
            for Each in 1 .. sides_Count
            loop
               declare
                  function next_Hoop_Vertex return Positive
                  is
                  begin
                     if Each = sides_Count then return 1;
                     else                       return Each + 1;
                     end if;
                  end next_Hoop_Vertex;
               begin
                  Modeller.add_Triangle (the_arch_Edges (each_Hoop)     (Each),
                                         the_arch_Edges (each_Hoop + 1) (Each),
                                         the_arch_Edges (each_Hoop)     (next_Hoop_Vertex));

                  if each_Hoop /= quality_Level - 1
                  then
                     Modeller.add_Triangle (the_arch_Edges (each_Hoop)     (next_hoop_Vertex),
                                            the_arch_Edges (each_Hoop + 1) (Each),
                                            the_arch_Edges (each_Hoop + 1) (next_Hoop_Vertex));
                  end if;
               end;
            end loop;
         end loop;
      end;


      return Modeller.Model;
   end to_Capsule_Model;


   --- Polar to euclidian shape models.
   --

   function to_Radians (From : in Latitude) return Radians
   is
   begin
      return Radians (From) * Pi / 180.0;
   end to_Radians;



   function to_Radians (From : in Longitude) return Radians
   is
   begin
      return Radians (From) * Pi / 180.0;
   end to_Radians;



   function polar_Model_from (model_Filename : in String) return polar_Model     -- TODO: Handle different file formats.
   is
      use
           Functions,

           ada.Text_IO,
           ada.Strings.unbounded;

      the_File : File_type;
      the_Text : unbounded_String;

   begin
      open (the_File, in_File, model_Filename);

      while not end_of_File (the_File)
      loop
         append (the_Text, get_Line (the_File) & " ");
      end loop;

      declare
         First : Positive := 1;

         use
              ada.Strings,
              ada.Strings.Maps;

         real_Set : constant Character_Set :=    to_Set (Span => (Low  => '0',
                                                                  High => '9'))
                                              or to_Set ('-' & '.');

         function more_Tokens return Boolean
         is
            Token_First : Positive;
            Token_Last  : Natural;
         begin
            find_Token (the_Text, Set   => real_Set,
                                  From  => First,
                                  Test  => Inside,
                                  First => Token_First,
                                  Last  => Token_Last);
            return Token_Last /= 0;
         end more_Tokens;


         function get_Real return Real
         is
            Last   : Natural;
            Result : Real;
         begin
            find_Token (the_Text, Set   => real_Set,
                                  From  => First,
                                  Test  => Inside,
                                  First => First,
                                  Last  => Last);
            if Last = 0
            then
               raise ada.IO_Exceptions.Data_Error with "'" & model_Filename & "' ends mid-vertex";
            end if;

            Result := Real'Value (Slice (the_Text,
                                         Low  => First,
                                         High => Last));
            First  := Last + 1;

            return Result;
         end get_Real;


         Lat       : Latitude;
         Long      : Longitude;
         Value     : Integer;
         Distance  : Real;
         Scale     : constant Real := 10.0;     -- TODO: Add a 'Scale' parameter.

         the_Model : polar_Model := [others => [others => (Id   => no_Id,
                                                           Site => [0.0, 0.0, 0.0])]];
      begin
         while more_Tokens
         loop
            Value := Integer (get_Real);
            exit when Value = 360;

            Long     := Longitude (Value);
            Lat      := Latitude  (get_Real);
            Distance := get_Real;

            the_Model (Long) (Lat).Site (1) := Scale * Distance * Cos (to_Radians (Lat)) * Sin (to_Radians (Long));
            the_Model (Long) (Lat).Site (2) := Scale * Distance * Sin (to_Radians (Lat));
            the_Model (Long) (Lat).Site (3) := Scale * Distance * Cos (to_Radians (Lat)) * Cos (to_Radians (Long));
         end loop;

         return the_Model;
      end;
   end polar_Model_from;



   function mesh_Model_from (Model : in polar_Model) return a_Model
   is
      the_raw_Model  : polar_Model := Model;
      longitude_Count : constant := 360 / 5;              -- 5 degree steps (0 .. 355).
      latitude_Count  : constant := 180 / 5 - 1;          -- 5 degree steps between the poles (-85 .. 85).
      strip_Triangles : constant := 2 + 2 * (latitude_Count - 1);

      the_mesh_Model : a_Model (site_Count => 2 + longitude_Count * latitude_Count,
                                tri_Count  =>     longitude_Count * strip_Triangles);

      the_longitude  : Longitude := 0;
      the_latitude   : Latitude;

      the_Vertex     : Positive := 1;
      the_Triangle   : Positive := 1;

      the_North_Pole : Positive;
      the_South_Pole : Positive;

      function Sum (the_Longitude : in Longitude;   Increment : in Integer) return Longitude
      is
         Result : Integer := Integer (the_Longitude) + Increment;
      begin
         if Result >= 360
         then
            Result := Result - 360;
         end if;

         return longitude (Result);
      end Sum;

   begin
      the_mesh_Model.Sites (the_Vertex) := (the_raw_model (0) (-90).Site);
      the_North_Pole                    := the_Vertex;
      the_raw_Model (0) (-90).Id        := the_Vertex;
      the_Vertex                        := the_Vertex + 1;

      the_mesh_Model.Sites (the_Vertex) := (the_raw_model (0) (90).Site);
      the_south_Pole                    := the_Vertex;
      the_raw_Model (0) (90).Id         := the_Vertex;
      the_Vertex                        := the_Vertex + 1;

      loop
         the_latitude := -90;
         loop
            if the_Latitude = -90
            then
               the_raw_Model (the_Longitude) (the_Latitude).Id := the_North_Pole;

            elsif the_Latitude = 90
            then
               the_raw_Model (the_Longitude) (the_Latitude).Id := the_South_Pole;

            else
               the_mesh_Model.Sites (the_Vertex)               := the_raw_model (the_Longitude) (the_Latitude).Site;
               the_raw_Model (the_Longitude) (the_Latitude).Id := the_Vertex;
               the_Vertex                                      := the_Vertex + 1;
            end if;

            exit when the_Latitude = 90;

            the_Latitude := the_Latitude + 5;
         end loop;

         exit when the_Longitude = 355;

         the_Longitude := the_Longitude + 5;
      end loop;


      the_Longitude := 0;
      loop
         the_mesh_Model.Triangles (the_Triangle) := [1 => the_North_Pole,
                                                     2 => the_raw_Model (Sum (the_Longitude, 5)) (-85).Id,
                                                     3 => the_raw_Model (     the_Longitude    ) (-85).Id];
         the_Triangle := the_Triangle + 1;

         the_mesh_Model.Triangles (the_Triangle) := [1 => the_South_Pole,
                                                     2 => the_raw_Model      (the_Longitude)     (85).Id,
                                                     3 => the_raw_Model (Sum (the_Longitude, 5)) (85).Id];
         the_Triangle := the_Triangle + 1;

         the_Latitude := -85;
         loop
            the_mesh_Model.Triangles (the_Triangle) := [1 => the_raw_Model (     the_Longitude)     (the_Latitude    ).Id,
                                                        2 => the_raw_Model (Sum (the_Longitude, 5)) (the_Latitude    ).Id,
                                                        3 => the_raw_Model (     the_Longitude)     (the_Latitude + 5).Id];
            the_Triangle := the_Triangle + 1;


            the_mesh_Model.Triangles (the_Triangle) := [1 => the_raw_Model (the_Longitude)          (the_Latitude + 5).Id,
                                                        2 => the_raw_Model (Sum (the_Longitude, 5)) (the_Latitude    ).Id,
                                                        3 => the_raw_Model (Sum (the_Longitude, 5)) (the_Latitude + 5).Id];
            the_Triangle := the_Triangle + 1;


            the_Latitude := the_Latitude + 5;
            exit when       the_Latitude = 85;
         end loop;

         exit when        the_Longitude = 355;
         the_Longitude := the_Longitude + 5;
      end loop;

      return the_mesh_Model;
   end mesh_Model_from;


end any_Math.any_Geometry.any_d3.any_Modeller.any_Forge;
