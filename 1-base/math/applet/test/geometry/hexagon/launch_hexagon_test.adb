with
     ada.Text_IO,
     float_Math.Geometry.d2.Hexagon;


procedure launch_Hexagon_Test
is
   use float_Math.Geometry.d2;

   procedure log (Message : in String)
                  renames ada.Text_IO.put_Line;

   Hex : constant Hexagon.item := (circumRadius => 1.0);
begin
   log ("");
   log (Hex'Image);


   log ("");
   log ("");
   for i in float_Math.Geometry.d2.Hexagon.vertex_Id
   loop
      log (Hexagon.Site (Hex, i)'Image);
   end loop;


   log ("");
   log ("");
   log ("1x1 Grid");
   declare
      the_Grid : constant hexagon.Grid := Hexagon.to_Grid (1, 1, 1.0);
   begin
      for Row in 1 .. the_Grid.Rows
      loop
         log ("");

         for Col in 1 .. the_Grid.Cols
         loop
            log ("[" & Row'Image & "][" & Col'Image & "] => " & Hexagon.hex_Center (the_Grid, [Row, Col])'Image);
         end loop;

      end loop;
   end;


   log ("");
   log ("");
   log ("2x1 Grid");
   declare
      the_Grid : constant hexagon.Grid := Hexagon.to_Grid (2, 1, 1.0);
   begin
      for Row in 1 .. the_Grid.Rows
      loop
         log ("");

         for Col in 1 .. the_Grid.Cols
         loop
            log ("[" & Row'Image & "][" & Col'Image & "] => " & Hexagon.hex_Center (the_Grid, [Row, Col])'Image);
         end loop;

      end loop;
   end;


   log ("");
   log ("");
   log ("1x2 Grid");
   declare
      the_Grid : constant hexagon.Grid := Hexagon.to_Grid (1, 2, 1.0);
   begin
      for Row in 1 .. the_Grid.Rows
      loop
         log ("");

         for Col in 1 .. the_Grid.Cols
         loop
            log ("[" & Row'Image & "][" & Col'Image & "] => " & Hexagon.hex_Center (the_Grid, [Row, Col])'Image);
         end loop;

      end loop;
   end;


   log ("");
   log ("");
   log ("2x2 Grid");
   declare
      the_Grid : constant hexagon.Grid := Hexagon.to_Grid (2, 2, 1.0);
   begin
      for Row in 1 .. the_Grid.Rows
      loop
         log ("");

         for Col in 1 .. the_Grid.Cols
         loop
            log ("[" & Row'Image & "][" & Col'Image & "] => " & Hexagon.hex_Center (the_Grid, [Row, Col])'Image);
         end loop;

      end loop;
   end;


   log ("");
   log ("");
   log ("Done.");
end launch_Hexagon_Test;
