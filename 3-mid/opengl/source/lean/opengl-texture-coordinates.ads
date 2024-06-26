package openGL.Texture.Coordinates
--
-- Provides openGL texture co-ordinates.
--
is
   ---------------
   --- 2D Textures
   --

   type Coords_2D_and_Centroid (coords_Count : Index_t) is
      record
         Coords   : Coordinates_2D (1 .. coords_Count);
         Centroid : Vector_2;
      end record;


   function to_Coordinates (the_Vertices : in Vector_2_array) return Coords_2D_and_Centroid;
   --
   -- Maps the vertices to texture coordinates.




   --- Generators
   --

   type coordinate_Generator is abstract tagged null record;

   function to_Coordinates (Self : in coordinate_Generator;   the_Vertices : access Sites) return Coordinates_2D
                            is abstract;



   type xz_Generator is new coordinate_Generator with
      record
         Normalise : texture_Transform_2D;
         Tile      : texture_Transform_2D;
      end record;

   overriding
   function to_Coordinates (Self : in xz_Generator;   the_Vertices : access Sites) return Coordinates_2D;



   type xy_Generator is new coordinate_Generator with
      record
         Normalise : texture_Transform_2D;
         Tile      : texture_Transform_2D;
      end record;

   overriding
   function to_Coordinates (Self : in xy_Generator;   the_Vertices : access Sites) return Coordinates_2D;



   type zy_Generator is new coordinate_Generator with
      record
         Normalise : texture_Transform_2D;
         Tile      : texture_Transform_2D;
      end record;

   overriding
   function to_Coordinates (Self : in zy_Generator;   the_Vertices : access Sites) return Coordinates_2D;



   type mercator_Generator is new coordinate_Generator with null record;

   overriding
   function to_Coordinates (Self : in mercator_Generator;   the_Vertices : access Sites) return Coordinates_2D;


end openGL.Texture.Coordinates;
