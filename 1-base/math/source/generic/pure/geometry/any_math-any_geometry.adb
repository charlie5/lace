package body any_Math.any_Geometry
is

   function Image (Self : in Triangle)  return String
   is
   begin
      return   "("
             & Vertex_Id'Image (Self (1)) & ","
             & Vertex_Id'Image (Self (2)) & ","
             & Vertex_Id'Image (Self (3)) & ")";
   end Image;



   function Image (Self : in Triangles) return String
   is
      Ellipsis : constant String := " ...";
      Result   :          String (1 .. 1024);
      Last     :          standard.Natural := 0;
   begin
      for Each in Self'Range
      loop
         declare
            Id_Image : constant String := Image (Self (Each));
         begin
            if Last + Id_Image'Length > Result'Last - Ellipsis'Length
            then
               Result (Last + 1 .. Last + Ellipsis'Length) := Ellipsis;    -- Out of room, so truncate.
               Last                                        := Last + Ellipsis'Length;
               exit;
            end if;

            Result (Last + 1 .. Last + Id_Image'Length) := Id_Image;
            Last                                        := Last + Id_Image'Length;
         end;
      end loop;

      return Result (1 .. Last);
   end Image;



   function Image (Self : in Model) return String
   is
   begin
      if Self.Triangles = null
      then
         return "(no triangles)";
      end if;

      return Self.Triangles.Image;
   end Image;



   function Image (Self : in Model_Triangles) return String
   is
   begin
      return   "Triangle_Count =>" & standard.Positive'Image (Self.Triangle_Count)
             & Image (Self.Triangles);
   end Image;


end any_Math.any_Geometry;
