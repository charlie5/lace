with
     openGL.Primitive.indexed,
     openGL.Geometry.colored;


package body openGL.Model.box.colored
is
   type Geometry_view  is access all openGL.Geometry.colored.item'class;

   ---------
   --- Forge
   --

   function new_Box (Size : in math.Vector_3;
                     Faces : in colored.Faces) return View
   is
      Self : constant View := new Item;
   begin
      Self.Faces := Faces;
      Self.Size  := Size;

      return Self;
   end new_Box;



   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Maps_of_font.Map) return openGL.Geometry.views
   is
      pragma Unreferenced (Textures, Fonts);

      use openGL.Geometry;

      the_Sites    :         constant box.Sites := Self.vertex_Sites;
      the_Indices  : aliased constant Indices   := (1, 2, 3, 4);


      function new_Face (Vertices : access openGL.geometry.colored.Vertex_array) return Geometry_view
      is
         use openGL.Geometry.colored,
             openGL.Primitive;

         the_Geometry  : constant Geometry_view          := openGL.Geometry.colored.new_Geometry.all'Access;
         the_Primitive : constant Primitive.indexed.view := Primitive.indexed.new_Primitive (triangle_Fan,
                                                                                             the_Indices).all'Access;
      begin
         the_Geometry.Vertices_are   (Vertices.all);
         the_Geometry.add            (openGL.Primitive.view (the_Primitive));

         the_Geometry.is_Transparent (now => False);

         return the_Geometry;
      end new_Face;


      front_Face : Geometry_view;
      rear_Face  : Geometry_view;
      upper_Face : Geometry_view;
      lower_Face : Geometry_view;
      left_Face  : Geometry_view;
      right_Face : Geometry_view;

   begin
      --  Front
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (left_lower_front),   color => self.Faces (Front).Colors (1)),
               2 => (site => the_Sites (right_lower_front),  color => self.Faces (Front).Colors (2)),
               3 => (site => the_Sites (right_upper_front),  color => self.Faces (Front).Colors (3)),
               4 => (site => the_Sites (left_upper_front),   color => self.Faces (Front).Colors (4)));
      begin
         front_Face := new_Face (vertices => the_Vertices'Access);
      end;

      --  Rear
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (Right_Lower_Rear),   color => self.Faces (Rear).Colors (1)),
               2 => (site => the_Sites (Left_Lower_Rear),    color => self.Faces (Rear).Colors (2)),
               3 => (site => the_Sites (Left_Upper_Rear),    color => self.Faces (Rear).Colors (3)),
               4 => (site => the_Sites (Right_Upper_Rear),   color => self.Faces (Rear).Colors (4)));
      begin
         rear_Face := new_Face (vertices => the_Vertices'Access);
      end;

      --  Upper
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (Left_Upper_Front),   color => self.Faces (Upper).Colors (1)),
               2 => (site => the_Sites (Right_Upper_Front),  color => self.Faces (Upper).Colors (2)),
               3 => (site => the_Sites (Right_Upper_Rear),   color => self.Faces (Upper).Colors (3)),
               4 => (site => the_Sites (Left_Upper_Rear),    color => self.Faces (Upper).Colors (4)));
      begin
         upper_Face := new_Face (vertices => the_Vertices'Access);
      end;

      --  Lower
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (Right_Lower_Front),   color => self.Faces (Lower).Colors (1)),
               2 => (site => the_Sites (Left_Lower_Front),    color => self.Faces (Lower).Colors (2)),
               3 => (site => the_Sites (Left_Lower_Rear),     color => self.Faces (Lower).Colors (3)),
               4 => (site => the_Sites (Right_Lower_Rear),    color => self.Faces (Lower).Colors (4)));
      begin
         lower_Face := new_Face (vertices => the_Vertices'Access);
      end;

      --  Left
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (Left_Lower_Rear),   color => self.Faces (Left).Colors (1)),
               2 => (site => the_Sites (Left_Lower_Front),  color => self.Faces (Left).Colors (2)),
               3 => (site => the_Sites (Left_Upper_Front),  color => self.Faces (Left).Colors (3)),
               4 => (site => the_Sites (Left_Upper_Rear),   color => self.Faces (Left).Colors (4)));
      begin
         left_Face := new_Face (vertices => the_Vertices'Access);
      end;

      --  Right
      --
      declare
         the_Vertices : aliased openGL.Geometry.colored.Vertex_array
           := (1 => (site => the_Sites (Right_Lower_Front),   color => self.Faces (Right).Colors (1)),
               2 => (site => the_Sites (Right_Lower_Rear),    color => self.Faces (Right).Colors (2)),
               3 => (site => the_Sites (Right_Upper_Rear),    color => self.Faces (Right).Colors (3)),
               4 => (site => the_Sites (Right_Upper_Front),   color => self.Faces (Right).Colors (4)));
      begin
         right_Face := new_Face (vertices => the_Vertices'Access);
      end;


      return (openGL.Geometry.view (front_Face),
              openGL.Geometry.view (rear_Face),
              openGL.Geometry.view (upper_Face),
              openGL.Geometry.view (lower_Face),
              openGL.Geometry.view (left_Face),
              openGL.Geometry.view (right_Face));
   end to_GL_Geometries;


end openGL.Model.box.colored;
