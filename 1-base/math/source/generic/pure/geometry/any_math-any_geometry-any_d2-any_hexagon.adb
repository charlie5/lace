package body any_Math.any_Geometry.any_d2.any_Hexagon
is

   -------------
   --- vertex_Id
   --

   function prior_Vertex (to_Vertex : in vertex_Id) return vertex_Id
   is
   begin
      if To_Vertex = 1
      then   return 6;
      else   return to_Vertex - 1;
      end if;
   end prior_Vertex;



   function next_Vertex (to_Vertex : in vertex_Id) return vertex_Id
   is
   begin
      if to_Vertex = 6
      then   return 1;
      else   return to_Vertex + 1;
      end if;
   end next_Vertex;



   -----------
   --- Hexagon
   --

   function to_Hexagon (circumRadius : in Real) return Item
   is
   begin
      return (circumRadius => circumRadius);
   end to_Hexagon;



   function circumRadius (Self : in Item) return Real
   is
   begin
      return Self.circumRadius;
   end circumRadius;



   function Area (Self : in Item) return Real
   is
   begin
      return 3.0 * R (Self) * inRadius (Self);
   end Area;



   function Perimeter (Self : in Item) return Real
   is
   begin
      return 6.0 * side_Length (Self);
   end Perimeter;



   function Angle (Self      : in Item      with Unreferenced;
                   at_Vertex : in vertex_Id with Unreferenced) return Radians
   is
   begin
      return to_Radians (120.0);
   end Angle;



   function minimal_Diameter (Self : in Item) return Real
   is
   begin
      return 2.0 * inRadius (Self);
   end minimal_Diameter;



   function maximal_Diameter (Self : in Item) return Real
   is
   begin
      return 2.0 * Self.circumRadius;
   end maximal_Diameter;



   function inRadius (Self : in Item) return Real
   is
      use Functions;
   begin
      return cos (to_Radians (30.0)) * R (Self);
   end inRadius;



   function side_Length (Self : in Item) return Real
   is
   begin
      return Self.circumRadius;
   end side_Length;



   function Site (Self : in Item;   of_Vertex : in vertex_Id) return any_d2.Site
   is
      use Functions;

      Angle : constant Radians := to_Radians (60.0 * Degrees (of_Vertex - 1));
   begin
      return any_d2.Site' (1 => Self.circumRadius * cos (Angle),
                           2 => Self.circumRadius * sin (Angle));
   end Site;



   function horizontal_Distance (Self : in Item) return Real
   is
   begin
      return Width (Self) * 3.0 / 4.0;
   end horizontal_Distance;



   function vertical_Distance (Self : in Item) return Real
   is
   begin
      return Height (Self);
   end vertical_Distance;



   --------
   --- Grid
   --

   function to_Grid (Rows, Cols   : in Positive;
                     circumRadius : in Real) return Grid
   is
      Hex              : constant Item := (circumRadius => circumRadius);
      inRadius         : constant Real := any_Hexagon.inRadius         (Hex);
      maximal_Diameter : constant Real := any_Hexagon.maximal_Diameter (Hex);
      minimal_Diameter : constant Real := any_Hexagon.minimal_Diameter (Hex);

      Result : Grid (Rows, Cols);

   begin
      Result.circumRadius := circumRadius;

      for Row in 1 .. Rows
      loop

         for Col in 1 .. Cols
         loop
            Result.Centers (Row, Col) := [circumRadius + Real (Col - 1) * (maximal_Diameter - 0.5 * circumRadius),
                                          inRadius     + Real (Row - 1) * minimal_Diameter];

            if Col mod 2 = 0   -- Even column.
            then
               Result.Centers (Row, Col) (2) := @ + inRadius;
            end if;
         end loop;

      end loop;

      return Result;
   end to_Grid;



   function hex_Center (Grid : in any_Hexagon.Grid;   Coords : in Coordinates) return any_d2.Site
   is
   begin
      return Grid.Centers (Coords.Row, Coords.Col);
   end hex_Center;



   function vertex_Site (Self : in Grid;   hex_Id : in any_Hexagon.Coordinates;
                                           Which  : in any_Hexagon.vertex_Id) return any_d2.Site
   is
      Hex : constant Item := (circumRadius => Self.circumRadius);
   begin
      return   hex_Center (Self, hex_Id)
             + Site (Hex, of_Vertex => Which);
   end vertex_Site;


end any_Math.any_Geometry.any_d2.any_Hexagon;
