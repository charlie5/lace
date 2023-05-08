with
     openGL.Geometry.lit_colored_textured,
     openGL.Primitive.indexed;


package body openGL.Model.box.lit_colored_textured_x1
is
   type Geometry_view is access all Geometry.lit_colored_textured.item'Class;


   ---------
   --- Forge
   --

   function new_Box (Size    : in Vector_3;
                     Faces   : in lit_colored_textured_x1.Faces;
                     Texture : in asset_Name) return View
   is
      Self : constant View := new Item;
   begin
      Self.Faces        := Faces;
      Self.texture_Name := Texture;
      Self.Size         := Size;

      return Self;
   end new_Box;



   --------------
   --- Attributes
   --

   overriding
   function to_GL_Geometries (Self : access Item;   Textures : access Texture.name_Map_of_texture'Class;
                                                    Fonts    : in     Font.font_id_Map_of_font) return Geometry.views
   is
      pragma unreferenced (Fonts);

      use Geometry.lit_colored_textured,
          Primitive,
          Texture;

      the_Sites    :         constant box.Sites := Self.vertex_Sites;
      the_Indices  : aliased constant Indices   := [ 1,  2,  3,   3,  4,  1,      -- Front
                                                     5,  6,  7,   7,  8,  5,      -- Rear
                                                     9, 10, 11,  11, 12,  9,      -- Upper
                                                    13, 14, 15,  15, 16, 13,      -- Lower
                                                    17, 18, 19,  19, 20, 17,      -- Left
                                                    21, 22, 23,  23, 24, 21];     -- Right

      the_Vertices : aliased constant Geometry.lit_colored_textured.Vertex_array (1 .. 6 * 4)
        := [ -- Front face.
             1 => (Site => the_Sites ( Left_Lower_Front),   Normal => front_Normal,   Color => +Self.Faces (Front).Colors (1),   Coords => (0.0, 0.0),   Shine => default_Shine),
             2 => (Site => the_Sites (Right_Lower_Front),   Normal => front_Normal,   Color => +Self.Faces (Front).Colors (2),   Coords => (1.0, 0.0),   Shine => default_Shine),
             3 => (Site => the_Sites (right_upper_front),   Normal => front_Normal,   Color => +Self.Faces (Front).Colors (3),   Coords => (1.0, 1.0),   Shine => default_Shine),
             4 => (Site => the_Sites ( Left_Upper_Front),   Normal => front_Normal,   Color => +Self.Faces (Front).Colors (4),   Coords => (0.0, 1.0),   Shine => default_Shine),

             -- Rear face.
             5 => (Site => the_Sites (Right_Lower_Rear),    Normal => rear_Normal,    Color => +Self.Faces (Rear).Colors (1),    Coords => (0.0, 0.0),   Shine => default_Shine),
             6 => (Site => the_Sites ( Left_Lower_Rear),    Normal => rear_Normal,    Color => +Self.Faces (Rear).Colors (2),    Coords => (1.0, 0.0),   Shine => default_Shine),
             7 => (Site => the_Sites ( Left_Upper_Rear),    Normal => rear_Normal,    Color => +Self.Faces (Rear).Colors (3),    Coords => (1.0, 1.0),   Shine => default_Shine),
             8 => (Site => the_Sites (Right_Upper_Rear),    Normal => rear_Normal,    Color => +Self.Faces (Rear).Colors (4),    Coords => (0.0, 1.0),   Shine => default_Shine),

            -- Upper face.
             9 => (Site => the_Sites ( Left_Upper_Front),   Normal => upper_Normal,   Color => +Self.Faces (Upper).Colors (1),   Coords => (0.0, 0.0),   Shine => default_Shine),
            10 => (Site => the_Sites (Right_Upper_Front),   Normal => upper_Normal,   Color => +Self.Faces (Upper).Colors (2),   Coords => (1.0, 0.0),   Shine => default_Shine),
            11 => (Site => the_Sites (Right_Upper_Rear),    Normal => upper_Normal,   Color => +Self.Faces (Upper).Colors (3),   Coords => (1.0, 1.0),   Shine => default_Shine),
            12 => (Site => the_Sites ( Left_Upper_Rear),    Normal => upper_Normal,   Color => +Self.Faces (Upper).Colors (4),   Coords => (0.0, 1.0),   Shine => default_Shine),

            -- Lower face.
            13 => (Site => the_Sites (Right_Lower_Front),   Normal => lower_Normal,   Color => +Self.Faces (Lower).Colors (1),   Coords => (0.0, 0.0),   Shine => default_Shine),
            14 => (Site => the_Sites ( Left_Lower_Front),   Normal => lower_Normal,   Color => +Self.Faces (Lower).Colors (2),   Coords => (1.0, 0.0),   Shine => default_Shine),
            15 => (Site => the_Sites ( Left_Lower_Rear),    Normal => lower_Normal,   Color => +Self.Faces (Lower).Colors (3),   Coords => (1.0, 1.0),   Shine => default_Shine),
            16 => (Site => the_Sites (Right_Lower_Rear),    Normal => lower_Normal,   Color => +Self.Faces (Lower).Colors (4),   Coords => (0.0, 1.0),   Shine => default_Shine),

            -- Left face.
            17 => (Site => the_Sites (Left_Lower_Rear),     Normal => left_Normal,    Color => +Self.Faces (Left).Colors (1),    Coords => (0.0, 0.0),   Shine => default_Shine),
            18 => (Site => the_Sites (Left_Lower_Front),    Normal => left_Normal,    Color => +Self.Faces (Left).Colors (2),    Coords => (1.0, 0.0),   Shine => default_Shine),
            19 => (Site => the_Sites (Left_Upper_Front),    Normal => left_Normal,    Color => +Self.Faces (Left).Colors (3),    Coords => (1.0, 1.0),   Shine => default_Shine),
            20 => (Site => the_Sites (Left_Upper_Rear),     Normal => left_Normal,    Color => +Self.Faces (Left).Colors (4),    Coords => (0.0, 1.0),   Shine => default_Shine),

            -- Right face.
            21 => (Site => the_Sites (Right_Lower_Front),   Normal => right_Normal,   Color => +Self.Faces (Right).Colors (1),   Coords => (0.0, 0.0),   Shine => default_Shine),
            22 => (Site => the_Sites (Right_Lower_Rear),    Normal => right_Normal,   Color => +Self.Faces (Right).Colors (2),   Coords => (1.0, 0.0),   Shine => default_Shine),
            23 => (Site => the_Sites (Right_Upper_Rear),    Normal => right_Normal,   Color => +Self.Faces (Right).Colors (3),   Coords => (1.0, 1.0),   Shine => default_Shine),
            24 => (Site => the_Sites (Right_Upper_Front),   Normal => right_Normal,   Color => +Self.Faces (Right).Colors (4),   Coords => (0.0, 1.0),   Shine => default_Shine)];

      the_Geometry  : constant Geometry_view  := Geometry.lit_colored_textured.new_Geometry  (texture_is_Alpha => False);
      the_Primitive : constant Primitive.view := Primitive.indexed            .new_Primitive (Triangles, the_Indices).all'Access;

   begin
      the_Geometry.Vertices_are (the_Vertices);
      the_Geometry.add          (the_Primitive);

      if Self.texture_Name /= null_Asset
      then
         the_Geometry.Texture_is     (Textures.fetch (Self.texture_Name));
         the_Geometry.is_Transparent (now => the_Geometry.Texture.is_Transparent);
      end if;


      return [1 => Geometry.view (the_Geometry)];
   end to_GL_Geometries;


end openGL.Model.box.lit_colored_textured_x1;
