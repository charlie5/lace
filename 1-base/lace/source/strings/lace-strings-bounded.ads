with
     ada.Strings.Maps,
     lace.Strings.superbounded;


package lace.Strings.bounded
--
-- Based on the 'ada.Strings.bounded' package provided by FSF GCC.
--
-- Modified to be a Pure package for use with DSA.
--
is
   pragma Pure;
   pragma preelaborate;

   use ada.Strings;


   generic
      Max : Positive;
      -- Maximum length of a Bounded_String

   package Generic_Bounded_Length
   is
      Max_Length : constant Positive := Max;

      type Bounded_String is private;
      pragma preelaborable_Initialization (Bounded_String);

      Null_Bounded_String : constant Bounded_String;

      subtype Length_Range is Natural range 0 .. Max_Length;

      function Length (Source : in Bounded_String) return Length_Range;


      ------------------------------------------------------
      --- Conversion, Concatenation, and Selection Functions
      --

      function To_Bounded_String (Source : in String;
                                  Drop   : in ada.Strings.Truncation := ada.Strings.Error) return Bounded_String;

      function To_String (Source : in Bounded_String) return String;

      procedure Set_Bounded_String (Target : out Bounded_String;
                                    Source : in  String;
                                    Drop   : in  Truncation    := Error);
      pragma Ada_05 (Set_Bounded_String);

      function Append (Left  : in Bounded_String;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String;

      function Append (Left  : in Bounded_String;
                       Right : in String;
                       Drop  : in Truncation    := Error) return Bounded_String;

      function Append (Left  : in String;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String;

      function Append (Left  : in Bounded_String;
                       Right : in Character;
                       Drop  : in Truncation    := Error) return Bounded_String;

      function Append (Left  : in Character;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String;

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     Bounded_String;
                        Drop     : in     Truncation    := Error);

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     String;
                        Drop     : in     Truncation    := Error);

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     Character;
                        Drop     : in     Truncation    := Error);

      function "&" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Bounded_String;

      function "&" (Left  : in Bounded_String;
                    Right : in String) return Bounded_String;

      function "&" (Left  : in String;
                    Right : in Bounded_String) return Bounded_String;

      function "&" (Left  : in Bounded_String;
                    Right : in Character) return Bounded_String;

      function "&" (Left  : in Character;
                    Right : in Bounded_String) return Bounded_String;

      function Element (Source : in Bounded_String;
                        Index  : in Positive) return Character;

      procedure Replace_Element (Source : in out Bounded_String;
                                 Index  : in     Positive;
                                 By     : in     Character);

      function Slice (Source : in Bounded_String;
                      Low    : in Positive;
                      High   : in Natural) return String;

      function Bounded_Slice (Source : in Bounded_String;
                              Low    : in Positive;
                              High   : in Natural) return Bounded_String;
      pragma Ada_05 (Bounded_Slice);

      procedure Bounded_Slice (Source : in  Bounded_String;
                               Target : out Bounded_String;
                               Low    : in  Positive;
                               High   : in  Natural);
      pragma Ada_05 (Bounded_Slice);

      overriding
      function "=" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean;

      function "=" (Left  : in Bounded_String;
                    Right : in String) return Boolean;

      function "=" (Left  : in String;
                    Right : in Bounded_String) return Boolean;

      function "<" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean;

      function "<" (Left  : in Bounded_String;
                    Right : in String) return Boolean;

      function "<" (Left  : in String;
                    Right : in Bounded_String) return Boolean;

      function "<=" (Left  : in Bounded_String;
                     Right : in Bounded_String) return Boolean;

      function "<=" (Left  : in Bounded_String;
                     Right : in String) return Boolean;

      function "<=" (Left  : in String;
                     Right : in Bounded_String) return Boolean;

      function ">" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean;

      function ">" (Left  : in Bounded_String;
                    Right : in String) return Boolean;

      function ">" (Left  : in String;
                    Right : in Bounded_String) return Boolean;

      function ">=" (Left  : in Bounded_String;
                     Right : in Bounded_String) return Boolean;

      function ">=" (Left  : in Bounded_String;
                     Right : in String) return Boolean;

      function ">=" (Left  : in String;
                     Right : in Bounded_String) return Boolean;


      --------------------
      --- Search Functions
      --

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      Going   : in Direction              := Forward;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      Going   : in Direction                      := Forward;
                      Mapping : in Maps.Character_Mapping_Function) return Natural;

      function Index (Source : in Bounded_String;
                      Set    : in Maps.Character_Set;
                      Test   : in Membership        := Inside;
                      Going  : in Direction         := Forward) return Natural;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      From    : in Positive;
                      Going   : in Direction              := Forward;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;
      pragma Ada_05 (Index);

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      From    : in Positive;
                      Going   : in Direction                      := Forward;
                      Mapping : in Maps.Character_Mapping_Function) return Natural;
      pragma Ada_05 (Index);

      function Index (Source : in Bounded_String;
                      Set    : in Maps.Character_Set;
                      From   : in Positive;
                      Test   : in Membership        := Inside;
                      Going  : in Direction         := Forward) return Natural;
      pragma Ada_05 (Index);

      function Index_Non_Blank (Source : in Bounded_String;
                                Going  : in Direction     := Forward) return Natural;

      function Index_Non_Blank (Source : in Bounded_String;
                                From   : in Positive;
                                Going  : in Direction     := Forward) return Natural;
      pragma Ada_05 (Index_Non_Blank);

      function Count (Source  : in Bounded_String;
                      Pattern : in String;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

      function Count (Source  : in Bounded_String;
                      Pattern : in String;
                      Mapping : in Maps.Character_Mapping_Function) return Natural;

      function Count (Source : in Bounded_String;
                      Set    : in Maps.Character_Set) return Natural;

      procedure Find_Token (Source : in  Bounded_String;
                            Set    : in  Maps.Character_Set;
                            From   : in  Positive;
                            Test   : in  Membership;
                            First  : out Positive;
                            Last   : out Natural);
      pragma Ada_2012 (Find_Token);

      procedure Find_Token (Source : in  Bounded_String;
                            Set    : in  Maps.Character_Set;
                            Test   : in  Membership;
                            First  : out Positive;
                            Last   : out Natural);


      ----------------------------------
      --- String Translation Subprograms
      --

      function Translate (Source  : in Bounded_String;
                          Mapping : in Maps.Character_Mapping) return Bounded_String;

      procedure Translate (Source  : in out Bounded_String;
                           Mapping : in     Maps.Character_Mapping);

      function Translate (Source  : in Bounded_String;
                          Mapping : in Maps.Character_Mapping_Function) return Bounded_String;

      procedure Translate (Source  : in out Bounded_String;
                           Mapping : in     Maps.Character_Mapping_Function);


      -------------------------------------
      --- String Transformation Subprograms
      --

      function Replace_Slice (Source : in Bounded_String;
                              Low    : in Positive;
                              High   : in Natural;
                              By     : in String;
                              Drop   : in Truncation    := Error) return Bounded_String;

      procedure Replace_Slice (Source : in out Bounded_String;
                               Low    : in     Positive;
                               High   : in     Natural;
                               By     : in     String;
                               Drop   : in     Truncation    := Error);

      function Insert (Source   : in Bounded_String;
                       Before   : in Positive;
                       new_Item : in String;
                       Drop     : in Truncation    := Error) return Bounded_String;

      procedure Insert (Source   : in out Bounded_String;
                        Before   : in     Positive;
                        new_Item : in     String;
                        Drop     : in     Truncation    := Error);

      function Overwrite (Source   : in Bounded_String;
                          Position : in Positive;
                          new_Item : in String;
                          Drop     : in Truncation    := Error) return Bounded_String;

      procedure Overwrite (Source   : in out Bounded_String;
                           Position : in     Positive;
                           new_Item : in     String;
                           Drop     : in     Truncation    := Error);

      function Delete (Source  : in Bounded_String;
                       From    : in Positive;
                       Through : in Natural) return Bounded_String;

      procedure Delete (Source  : in out Bounded_String;
                        From    : in     Positive;
                        Through : in     Natural);


      -------------------------------
      --- String Selector Subprograms
      --

      function Trim (Source : in Bounded_String;
                     Side   : in Trim_End) return Bounded_String;

      procedure Trim (Source : in out Bounded_String;
                      Side   : in     Trim_End);

      function Trim (Source : in Bounded_String;
                     Left   : in Maps.Character_Set;
                     Right  : in Maps.Character_Set) return Bounded_String;

      procedure Trim (Source : in out Bounded_String;
                      Left   : in     Maps.Character_Set;
                      Right  : in     Maps.Character_Set);

      function Head (Source : in Bounded_String;
                     Count  : in Natural;
                     Pad    : in Character     := Space;
                     Drop   : in Truncation    := Error) return Bounded_String;

      procedure Head (Source : in out Bounded_String;
                      Count  : in     Natural;
                      Pad    : in     Character     := Space;
                      Drop   : in     Truncation    := Error);

      function Tail (Source : in Bounded_String;
                     Count  : in Natural;
                     Pad    : in Character     := Space;
                     Drop   : in Truncation    := Error) return Bounded_String;

      procedure Tail (Source : in out Bounded_String;
                      Count  : in     Natural;
                      Pad    : in     Character     := Space;
                      Drop   : in     Truncation    := Error);


      ----------------------------------
      --- String Constructor Subprograms
      --

      function "*" (Left  : in Natural;
                    Right : in Character) return Bounded_String;

      function "*" (Left  : in Natural;
                    Right : in String) return Bounded_String;

      function "*" (Left  : in Natural;
                    Right : in Bounded_String) return Bounded_String;

      function Replicate (Count : in Natural;
                          Item  : in Character;
                          Drop  : in ada.Strings.Truncation := ada.Strings.Error) return Bounded_String;

      function Replicate (Count : in Natural;
                          Item  : in String;
                          Drop  : in Truncation := Error) return Bounded_String;

      function Replicate (Count : in Natural;
                          Item  : in Bounded_String;
                          Drop  : in Truncation    := Error) return Bounded_String;

   private
      -- Most of the implementation is in the separate non generic package
      -- ada.Strings.Superbounded. Type Bounded_String is derived from type
      -- Superbounded.Super_String with the maximum length constraint. In
      -- almost all cases, the routines in Superbounded can be called with
      -- no requirement to pass the maximum length explicitly, since there
      -- is at least one Bounded_String argument from which the maximum
      -- length can be obtained. For all such routines, the implementation
      -- in this private part is simply a renaming of the corresponding
      -- routine in the superbounded package.

      -- The five exceptions are the * and Replicate routines operating on
      -- character values. For these cases, we have a routine in the body
      -- that calls the superbounded routine passing the maximum length
      -- explicitly as an extra parameter.

      type Bounded_String is new Superbounded.Super_String (Max_Length);
      -- Deriving Bounded_String from Superbounded.Super_String is the
      -- real trick, it ensures that the type Bounded_String declared in
      -- the generic instantiation is compatible with the Super_String
      -- type declared in the Superbounded package.

      function From_String (Source : in String) return Bounded_String;
      -- Private routine used only by Stream_Convert

      pragma stream_Convert (Bounded_String, From_String, To_String);
      -- Provide stream routines without dragging in ada.Streams.

      Null_Bounded_String : constant Bounded_String := (Max_Length     => Max_Length,
                                                        Current_Length => 0,
                                                        Data           => [1 .. Max_Length => ASCII.NUL]);

      pragma inline (To_Bounded_String);

      procedure Set_Bounded_String (Target : out Bounded_String;
                                    Source : in  String;
                                    Drop   : in  Truncation    := Error)
         renames Set_Super_String;

      function Length (Source : in Bounded_String) return Length_Range
         renames Super_Length;

      function To_String (Source : in Bounded_String) return String
         renames Super_To_String;

      function Append (Left  : in Bounded_String;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Append;

      function Append (Left  : in Bounded_String;
                       Right : in String;
                       Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Append;

      function Append (Left  : in String;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Append;

      function Append (Left  : in Bounded_String;
                       Right : in Character;
                       Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Append;

      function Append (Left  : in Character;
                       Right : in Bounded_String;
                       Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Append;

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     Bounded_String;
                        Drop     : in     Truncation    := Error)
         renames Super_Append;

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     String;
                        Drop     : in     Truncation    := Error)
         renames Super_Append;

      procedure Append (Source   : in out Bounded_String;
                        new_Item : in     Character;
                        Drop     : in     Truncation    := Error)
         renames Super_Append;

      function "&" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Bounded_String
         renames Concat;

      function "&" (Left  : in Bounded_String;
                    Right : in String) return Bounded_String
         renames Concat;

      function "&" (Left  : in String;
                    Right : in Bounded_String) return Bounded_String
         renames Concat;

      function "&" (Left  : in Bounded_String;
                    Right : in Character) return Bounded_String
         renames Concat;

      function "&" (Left  : in Character;
                    Right : in Bounded_String) return Bounded_String
         renames Concat;

      function Element (Source : in Bounded_String;
                        Index  : in Positive) return Character
         renames Super_Element;

      procedure Replace_Element (Source : in out Bounded_String;
                                 Index  : in     Positive;
                                 By     : in     Character)
         renames Super_Replace_Element;

      function Slice (Source : in Bounded_String;
                      Low    : in Positive;
                      High   : in Natural) return String
         renames Super_Slice;

      function Bounded_Slice (Source : in Bounded_String;
                              Low    : in Positive;
                              High   : in Natural) return Bounded_String
         renames Super_Slice;

      procedure Bounded_Slice (Source : in  Bounded_String;
                               Target : out Bounded_String;
                               Low    : in  Positive;
                               High   : in  Natural)
         renames Super_Slice;

      overriding
      function "=" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean
         renames Equal;

      function "=" (Left  : in Bounded_String;
                    Right : in String) return Boolean
         renames Equal;

      function "=" (Left  : in String;
                    Right : in Bounded_String) return Boolean
         renames Equal;

      function "<" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean
         renames Less;

      function "<" (Left  : in Bounded_String;
                    Right : in String) return Boolean
         renames Less;

      function "<" (Left  : in String;
                    Right : in Bounded_String) return Boolean
         renames Less;

      function "<=" (Left  : in Bounded_String;
                     Right : in Bounded_String) return Boolean
         renames Less_Or_Equal;

      function "<=" (Left  : in Bounded_String;
                     Right : in String) return Boolean
         renames Less_Or_Equal;

      function "<=" (Left  : in String;
                     Right : in Bounded_String) return Boolean
         renames Less_Or_Equal;

      function ">" (Left  : in Bounded_String;
                    Right : in Bounded_String) return Boolean
         renames Greater;

      function ">" (Left  : in Bounded_String;
                    Right : in String) return Boolean
         renames Greater;

      function ">" (Left  : in String;
                    Right : in Bounded_String) return Boolean
         renames Greater;

      function ">=" (Left  : in Bounded_String;
                     Right : in Bounded_String) return Boolean
         renames Greater_Or_Equal;

      function ">=" (Left  : in Bounded_String;
                     Right : in String) return Boolean
         renames Greater_Or_Equal;

      function ">=" (Left  : in String;
                     Right : in Bounded_String) return Boolean
         renames Greater_Or_Equal;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      Going   : in Direction              := Forward;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural
         renames Super_Index;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      Going   : in Direction                      := Forward;
                      Mapping : in Maps.Character_Mapping_Function) return Natural
         renames Super_Index;

      function Index (Source : in Bounded_String;
                      Set    : in Maps.Character_Set;
                      Test   : in Membership        := Inside;
                      Going  : in Direction         := Forward) return Natural
         renames Super_Index;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      From    : in Positive;
                      Going   : in Direction              := Forward;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural
         renames Super_Index;

      function Index (Source  : in Bounded_String;
                      Pattern : in String;
                      From    : in Positive;
                      Going   : in Direction                      := Forward;
                      Mapping : in Maps.Character_Mapping_Function) return Natural
      renames Super_Index;

      function Index (Source : in Bounded_String;
                      Set    : in Maps.Character_Set;
                      From   : in Positive;
                      Test   : in Membership        := Inside;
                      Going  : in Direction         := Forward) return Natural
      renames Super_Index;

      function Index_Non_Blank (Source : in Bounded_String;
                                Going  : in Direction     := Forward) return Natural
         renames Super_Index_Non_Blank;

      function Index_Non_Blank (Source : in Bounded_String;
                                From   : in Positive;
                                Going  : in Direction     := Forward) return Natural
         renames Super_Index_Non_Blank;

      function Count (Source  : in Bounded_String;
                      Pattern : in String;
                      Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural
         renames Super_Count;

      function Count (Source  : in Bounded_String;
                      Pattern : in String;
                      Mapping : in Maps.Character_Mapping_Function) return Natural
         renames Super_Count;

      function Count (Source : in Bounded_String;
                      Set    : in Maps.Character_Set) return Natural
         renames Super_Count;

      procedure Find_Token (Source : in  Bounded_String;
                            Set    : in  Maps.Character_Set;
                            From   : in  Positive;
                            Test   : in  Membership;
                            First  : out Positive;
                            Last   : out Natural)
         renames Super_Find_Token;

      procedure Find_Token (Source : in  Bounded_String;
                            Set    : in  Maps.Character_Set;
                            Test   : in  Membership;
                            First  : out Positive;
                            Last   : out Natural)
         renames Super_Find_Token;

      function Translate (Source  : in Bounded_String;
                          Mapping : in Maps.Character_Mapping) return Bounded_String
         renames Super_Translate;

      procedure Translate (Source  : in out Bounded_String;
                           Mapping : in     Maps.Character_Mapping)
         renames Super_Translate;

      function Translate (Source  : in Bounded_String;
                          Mapping : in Maps.Character_Mapping_Function) return Bounded_String
         renames Super_Translate;

      procedure Translate (Source  : in out Bounded_String;
                           Mapping : in     Maps.Character_Mapping_Function)
         renames Super_Translate;

      function Replace_Slice (Source : in Bounded_String;
                              Low    : in Positive;
                              High   : in Natural;
                              By     : in String;
                              Drop   : in Truncation    := Error) return Bounded_String
         renames Super_Replace_Slice;

      procedure Replace_Slice (Source : in out Bounded_String;
                               Low    : in     Positive;
                               High   : in     Natural;
                               By     : in     String;
                               Drop   : in     Truncation    := Error)
         renames Super_Replace_Slice;

      function Insert (Source   : in Bounded_String;
                       Before   : in Positive;
                       new_Item : in String;
                       Drop     : in Truncation    := Error) return Bounded_String
         renames Super_Insert;

      procedure Insert (Source   : in out Bounded_String;
                        Before   : in     Positive;
                        new_Item : in     String;
                        Drop     : in     Truncation    := Error)
         renames Super_Insert;

      function Overwrite (Source   : in Bounded_String;
                          Position : in Positive;
                          new_Item : in String;
                          Drop     : in Truncation    := Error) return Bounded_String
         renames Super_Overwrite;

      procedure Overwrite (Source   : in out Bounded_String;
                           Position : in     Positive;
                           new_Item : in     String;
                           Drop     : in     Truncation    := Error)
         renames Super_Overwrite;

      function Delete (Source  : in Bounded_String;
                       From    : in Positive;
                       Through : in Natural) return Bounded_String
         renames Super_Delete;

      procedure Delete (Source  : in out Bounded_String;
                        From    : in     Positive;
                        Through : in     Natural)
         renames Super_Delete;

      function Trim (Source : in Bounded_String;
                     Side   : in Trim_End) return Bounded_String
         renames Super_Trim;

      procedure Trim (Source : in out Bounded_String;
                      Side   : in     Trim_End)
         renames Super_Trim;

      function Trim (Source : in Bounded_String;
                     Left   : in Maps.Character_Set;
                     Right  : in Maps.Character_Set) return Bounded_String
         renames Super_Trim;

      procedure Trim (Source : in out Bounded_String;
                      Left   : in     Maps.Character_Set;
                      Right  : in     Maps.Character_Set)
         renames Super_Trim;

      function Head (Source : in Bounded_String;
                     Count  : in Natural;
                     Pad    : in Character     := Space;
                     Drop   : in Truncation    := Error) return Bounded_String
         renames Super_Head;

      procedure Head (Source : in out Bounded_String;
                      Count  : in     Natural;
                      Pad    : in     Character     := Space;
                      Drop   : in     Truncation    := Error)
         renames Super_Head;

      function Tail (Source : in Bounded_String;
                     Count  : in Natural;
                     Pad    : in Character     := Space;
                     Drop   : in Truncation    := Error) return Bounded_String
         renames Super_Tail;

      procedure Tail (Source : in out Bounded_String;
                      Count  : in     Natural;
                      Pad    : in     Character     := Space;
                      Drop   : in     Truncation    := Error)
         renames Super_Tail;

      function "*" (Left  : in Natural;
                    Right : in Bounded_String) return Bounded_String
         renames Times;

      function Replicate (Count : in Natural;
                          Item  : in Bounded_String;
                          Drop  : in Truncation    := Error) return Bounded_String
         renames Super_Replicate;

   end Generic_Bounded_Length;


end lace.Strings.bounded;
