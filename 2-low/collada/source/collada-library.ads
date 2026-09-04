package collada.Library
--
-- Provides a namespace and core types for the specific collada library child packages.
--
is
   type Float_array_view is access Float_array;
   type  Text_array_view is access Text_array;
   type   Int_array_view is access all Int_array;


   -----------
   --- Sources
   --

   type Source is
      record
         Id       : Text;
         array_Id : Text;

         Floats   : Float_array_view;     -- From a 'float_array'.
         Texts    :  Text_array_view;     -- From a 'Name_array' or an 'IDREF_array'.
      end record;

   type Sources      is array (Positive range <>) of Source;
   type Sources_view is access Sources;

   null_Source : constant Source;

   function Source_of (Self : in Sources_view;   Url : in String) return Source;
   --
   -- Returns the source whose id the URL ('#id') names, or null_Source.

   procedure free (Self : in out Sources_view);
   --
   -- Frees the sources' arrays as well.

   procedure free (Self : in out Int_array_view);


   ----------
   --- Inputs
   --

   type Semantic is (Unknown,
                     BINORMAL,        -- Geometric binormal (bitangent) vector.
                     COLOR,           -- Color coordinate vector. Color inputs are RGB (float3_type).
                     CONTINUITY,      -- Continuity constraint at the control vertex (CV).
                     IMAGE,           -- Raster or MIP-level input.
                     INPUT,           -- Sampler input.
                     IN_TANGENT,      -- Tangent vector for preceding control point.
                     INTERPOLATION,   -- Sampler interpolation type.
                     INV_BIND_MATRIX, -- Inverse of local-to-world matrix.
                     JOINT,           -- Skin influence identifier.
                     LINEAR_STEPS,    -- Number of piece-wise linear approximation steps to use for the spline segment that follows this CV.
                     MORPH_TARGET,    -- Morph targets for mesh morphing.
                     MORPH_WEIGHT,    -- Weights for mesh morphing.
                     NORMAL,          -- Normal vector.
                     OUTPUT,          -- Sampler output.
                     OUT_TANGENT,     -- Tangent vector for succeeding control point.
                     POSITION,        -- Geometric coordinate vector.
                     TANGENT,         -- Geometric tangent vector.
                     TEXBINORMAL,     -- Texture binormal (bitangent) vector.
                     TEXCOORD,        -- Texture coordinate vector.
                     TEXTANGENT,      -- Texture tangent vector.
                     UV,              -- Generic parameter vector.
                     VERTEX,          -- Mesh vertex.
                     WEIGHT);         -- Skin influence weighting value.

   type Input_t is
      record
         Semantic : library.Semantic := Unknown;
         Source   : Text;
         Offset   : Natural          := 0;
      end record;

   type Inputs      is array (Positive range <>) of Input_t;
   type Inputs_view is access all Inputs;

   null_Input : constant Input_t;


   function find_in   (Self : in Inputs;   the_Semantic : in library.Semantic) return Input_t;
   --
   -- Returns null_Input when no input has the semantic.

   function Offset_of (Self : in Inputs;   the_Semantic : in library.Semantic) return Natural;
   --
   -- Raises Input_not_found when no input has the semantic.

   procedure free (Self : in out Inputs_view);


   Input_not_found : exception;



private

   null_Input  : constant Input_t := (others => <>);
   null_Source : constant Source  := (others => <>);


end collada.Library;
