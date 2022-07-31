package collada.Library.geometries
--
-- Models a collada 'geometries' library, which is a collection of geometries.
--
is
   type Inputs_view         is access library.Inputs;

   type Int_array_view      is access Int_array;
   type Int_array_List      is array (Positive range <>) of Int_array_view;
   type Int_array_List_view is access int_array_List;



   ------------
   --- Vertices
   --

   type Vertices is
      record
         Id     : Text;
         Inputs : Inputs_view;
      end record;


   --------------
   --- Primitives
   --

   type primitive_Kind is (Unknown,
                           Lines,     line_Strips,
                           Polygons,  polyList,
                           Triangles, triFans,   triStrips);

   type Primitive (Kind : primitive_Kind := Unknown) is
      record
         Count    : Natural;
         Material : Text;

         Inputs   : Inputs_view;
         P_List   : int_array_List_view;

         case Kind is
            when polyList =>
               vCount : Int_array_view;

            when others =>
               null;
         end case;
      end record;

   type Primitives      is array (Positive range <>) of Primitive;
   type Primitives_view is access Primitives;

   function vertex_Offset_of (Self : in Primitive) return math.Index;
   function normal_Offset_of (Self : in Primitive) return math.Index;
   function  coord_Offset_of (Self : in Primitive) return math.Index;

   no_coord_Offset : exception;


   --------
   --- Mesh
   --

   type Mesh is
      record
         Sources    : library.Sources_view;
         Vertices   : geometries.Vertices;
         Primitives : geometries.Primitives_view;
      end record;

   function Source_of    (Self          : in Mesh;
                          source_Name   : in String)    return Source;

   function Positions_of (Self          : in Mesh)      return access float_Array;

   function Normals_of   (Self          : in Mesh;
                          for_Primitive : in Primitive) return access float_Array;

   function Coords_of    (Self          : in Mesh;
                          for_Primitive : in Primitive) return access float_Array;

   ------------
   --- Geometry
   --

   type Geometry is
      record
         Name : Text;
         Id   : Text;
         Mesh : geometries.Mesh;
      end record;

   type Geometry_array      is array (Positive range <>) of Geometry;
   type Geometry_array_view is access Geometry_array;


   ----------------
   --- Library Item
   --

   type Item is
      record
         Contents : Geometry_array_view;
      end record;


end collada.Library.geometries;
