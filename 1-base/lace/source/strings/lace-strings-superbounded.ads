with
     ada.Strings.Maps;


package lace.Strings.superbounded
--
-- Based on the 'ada.Strings.superbounded' package provided by FSF GCC.
--
-- Modified to be a Pure package for use with DSA.
--
is
   pragma Pure;
   pragma preelaborate;

   use ada.Strings;


   -- Type Bounded_String in ada.Strings.Bounded.Generic_Bounded_Length is
   -- derived from Super_String, with the constraint of the maximum length.

   type Super_String (Max_Length : Positive) is
      record
         Current_Length : Natural                 := 0;
         Data           : String (1 .. Max_Length);
         -- A previous version had a default initial value for Data, which is
         -- no longer necessary, because we now special-case this type in the
         -- compiler, so "=" composes properly for descendants of this type.
         -- Leaving it out is more efficient.
      end record;

   -- The subprograms defined for Super_String are similar to those
   -- defined for Bounded_String, except that they have different names, so
   -- that they can be renamed in ada.Strings.Bounded.Generic_Bounded_Length.

   function Super_Length (Source : in Super_String) return Natural;


   ------------------------------------------------------
   --- Conversion, Concatenation, and Selection Functions
   --

   function To_Super_String (Source     : in String;
                             Max_Length : in Natural;
                             Drop       : in Truncation := Error) return Super_String;
   -- Note the additional parameter Max_Length, which specifies the maximum
   -- length setting of the resulting Super_String value.

   -- The following procedures have declarations (and semantics) that are
   -- exactly analogous to those declared in ada.Strings.Bounded.

   function Super_To_String (Source : in Super_String) return String;

   procedure Set_Super_String (Target : out Super_String;
                               Source : in  String;
                               Drop   : in  Truncation := Error);

   function Super_Append (Left  : in Super_String;
                          Right : in Super_String;
                          Drop  : in Truncation := Error) return Super_String;

   function Super_Append (Left  : in Super_String;
                          Right : in String;
                          Drop  : in Truncation := Error) return Super_String;

   function Super_Append (Left  : in String;
                          Right : in Super_String;
                          Drop  : in Truncation := Error) return Super_String;

   function Super_Append (Left  : in Super_String;
                          Right : in Character;
                          Drop  : in Truncation := Error) return Super_String;

   function Super_Append (Left  : in Character;
                          Right : in Super_String;
                          Drop  : in Truncation := Error) return Super_String;

   procedure Super_Append (Source   : in out Super_String;
                           New_Item : in     Super_String;
                           Drop     : in     Truncation := Error);

   procedure Super_Append (Source   : in out Super_String;
                           New_Item : in     String;
                           Drop     : in     Truncation := Error);

   procedure Super_Append (Source   : in out Super_String;
                           New_Item : in     Character;
                           Drop     : in     Truncation := Error);

   function Concat (Left  : in Super_String;
                    Right : in Super_String) return Super_String;

   function Concat (Left  : in Super_String;
                    Right : in String) return Super_String;

   function Concat (Left  : in String;
                    Right : in Super_String) return Super_String;

   function Concat (Left  : in Super_String;
                    Right : in Character) return Super_String;

   function Concat (Left  : in Character;
                    Right : in Super_String) return Super_String;

   function Super_Element (Source : in Super_String;
                           Index  : in Positive) return Character;

   procedure Super_Replace_Element (Source : in out Super_String;
                                    Index  : in     Positive;
                                    By     : in     Character);

   function Super_Slice (Source : in Super_String;
                         Low    : in Positive;
                         High   : in Natural) return String;

   function Super_Slice (Source : in Super_String;
                         Low    : in Positive;
                         High   : in Natural) return Super_String;

   procedure Super_Slice (Source : in  Super_String;
                          Target : out Super_String;
                          Low    : in  Positive;
                          High   : in  Natural);

   overriding
   function "=" (Left  : in Super_String;
                 Right : in Super_String) return Boolean;

   function Equal (Left  : in Super_String;
                   Right : in Super_String) return Boolean renames "=";

   function Equal (Left  : in Super_String;
                   Right : in String) return Boolean;

   function Equal (Left  : in String;
                   Right : in Super_String) return Boolean;

   function Less (Left  : in Super_String;
                  Right : in Super_String) return Boolean;

   function Less (Left  : in Super_String;
                  Right : in String) return Boolean;

   function Less (Left  : in String;
                  Right : in Super_String) return Boolean;

   function Less_Or_Equal (Left  : in Super_String;
                           Right : in Super_String) return Boolean;

   function Less_Or_Equal (Left  : in Super_String;
                           Right : in String) return Boolean;

   function Less_Or_Equal (Left  : in String;
                           Right : in Super_String) return Boolean;

   function Greater (Left  : in Super_String;
                     Right : in Super_String) return Boolean;

   function Greater (Left  : in Super_String;
                     Right : in String) return Boolean;

   function Greater (Left  : in String;
                     Right : in Super_String) return Boolean;

   function Greater_Or_Equal (Left  : in Super_String;
                              Right : in Super_String) return Boolean;

   function Greater_Or_Equal (Left  : in Super_String;
                              Right : in String) return Boolean;

   function Greater_Or_Equal (Left  : in String;
                              Right : in Super_String) return Boolean;


   --------------------
   --- Search Functions
   --

   function Super_Index (Source  : in Super_String;
                         Pattern : in String;
                         Going   : in Direction              := Forward;
                         Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Super_Index (Source  : in Super_String;
                         Pattern : in String;
                         Going   : in Direction := Forward;
                         Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Super_Index (Source : in Super_String;
                         Set    : in Maps.Character_Set;
                         Test   : in Membership := Inside;
                         Going  : in Direction  := Forward) return Natural;

   function Super_Index (Source  : in Super_String;
                         Pattern : in String;
                         From    : in Positive;
                         Going   : in Direction              := Forward;
                         Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Super_Index (Source  : in Super_String;
                         Pattern : in String;
                         From    : in Positive;
                         Going   : in Direction := Forward;
                         Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Super_Index (Source : in Super_String;
                         Set    : in Maps.Character_Set;
                         From   : in Positive;
                         Test   : in Membership := Inside;
                         Going  : in Direction  := Forward) return Natural;

   function Super_Index_Non_Blank (Source : in Super_String;
                                   Going  : in Direction := Forward) return Natural;

   function Super_Index_Non_Blank (Source : in Super_String;
                                   From   : in Positive;
                                   Going  : in Direction := Forward) return Natural;

   function Super_Count (Source  : in Super_String;
                         Pattern : in String;
                         Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Super_Count (Source  : in Super_String;
                         Pattern : in String;
                         Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Super_Count (Source : in Super_String;
                         Set    : in Maps.Character_Set) return Natural;

   procedure Super_Find_Token (Source : in  Super_String;
                               Set    : in  Maps.Character_Set;
                               From   : in  Positive;
                               Test   : in  Membership;
                               First  : out Positive;
                               Last   : out Natural);

   procedure Super_Find_Token (Source : in  Super_String;
                               Set    : in  Maps.Character_Set;
                               Test   : in  Membership;
                               First  : out Positive;
                               Last   : out Natural);


   ----------------------------------
   --- String Translation Subprograms
   --

   function Super_Translate (Source  : in Super_String;
                             Mapping : in Maps.Character_Mapping) return Super_String;

   procedure Super_Translate (Source  : in out Super_String;
                              Mapping : in     Maps.Character_Mapping);

   function Super_Translate (Source  : in Super_String;
                             Mapping : in Maps.Character_Mapping_Function) return Super_String;

   procedure Super_Translate (Source  : in out Super_String;
                              Mapping : in     Maps.Character_Mapping_Function);


   -------------------------------------
   --- String Transformation Subprograms
   --

   function Super_Replace_Slice (Source : in Super_String;
                                 Low    : in Positive;
                                 High   : in Natural;
                                 By     : in String;
                                 Drop   : in Truncation := Error) return Super_String;

   procedure Super_Replace_Slice (Source : in out Super_String;
                                  Low    : in     Positive;
                                  High   : in     Natural;
                                  By     : in     String;
                                  Drop   : in     Truncation := Error);

   function Super_Insert (Source   : in Super_String;
                          Before   : in Positive;
                          New_Item : in String;
                          Drop     : in Truncation := Error) return Super_String;

   procedure Super_Insert (Source   : in out Super_String;
                           Before   : in     Positive;
                           New_Item : in     String;
                           Drop     : in     Truncation := Error);

   function Super_Overwrite (Source   : in Super_String;
                             Position : in Positive;
                             New_Item : in String;
                             Drop     : in Truncation := Error) return Super_String;

   procedure Super_Overwrite (Source   : in out Super_String;
                              Position : in     Positive;
                              New_Item : in     String;
                              Drop     : in     Truncation := Error);

   function Super_Delete (Source  : in Super_String;
                          From    : in Positive;
                          Through : in Natural) return Super_String;

   procedure Super_Delete (Source  : in out Super_String;
                           From    : in     Positive;
                           Through : in     Natural);


   -------------------------------
   --- String Selector Subprograms
   --

   function Super_Trim (Source : in Super_String;
                        Side   : in Trim_End) return Super_String;

   procedure Super_Trim (Source : in out Super_String;
                         Side   : in     Trim_End);

   function Super_Trim (Source : in Super_String;
                        Left   : in Maps.Character_Set;
                        Right  : in Maps.Character_Set) return Super_String;

   procedure Super_Trim (Source : in out Super_String;
                         Left   : in     Maps.Character_Set;
                         Right  : in     Maps.Character_Set);

   function Super_Head (Source : in Super_String;
                        Count  : in Natural;
                        Pad    : in Character  := Space;
                        Drop   : in Truncation := Error) return Super_String;

   procedure Super_Head (Source : in out Super_String;
                         Count  : in     Natural;
                         Pad    : in     Character  := Space;
                         Drop   : in     Truncation := Error);

   function Super_Tail (Source : in Super_String;
                        Count  : in Natural;
                        Pad    : in Character  := Space;
                        Drop   : in Truncation := Error) return Super_String;

   procedure Super_Tail (Source : in out Super_String;
                         Count  : in     Natural;
                         Pad    : in     Character  := Space;
                         Drop   : in     Truncation := Error);


   ----------------------------------
   --- String Constructor Subprograms
   --

   -- Note: in some of the following routines, there is an extra parameter
   -- Max_Length which specifies the value of the maximum length for the
   -- resulting Super_String value.

   function Times (Left       : in Natural;
                   Right      : in Character;
                   Max_Length : in Positive) return Super_String;
   -- Note the additional parameter Max_Length

   function Times (Left       : in Natural;
                   Right      : in String;
                   Max_Length : in Positive) return Super_String;
   -- Note the additional parameter Max_Length

   function Times (Left  : in Natural;
                   Right : in Super_String) return Super_String;

   function Super_Replicate (Count      : in Natural;
                             Item       : in Character;
                             Drop       : in Truncation := Error;
                             Max_Length : in Positive) return Super_String;
   -- Note the additional parameter Max_Length

   function Super_Replicate (Count      : in Natural;
                             Item       : in String;
                             Drop       : in Truncation := Error;
                             Max_Length : in Positive) return Super_String;
   -- Note the additional parameter Max_Length

   function Super_Replicate (Count : in Natural;
                             Item  : in Super_String;
                             Drop  : in Truncation := Error) return Super_String;



private
      -- pragma inline declarations

      pragma inline ("=");
      pragma inline (Less);
      pragma inline (Less_Or_Equal);
      pragma inline (Greater);
      pragma inline (Greater_Or_Equal);
      pragma inline (Concat);
      pragma inline (Super_Count);
      pragma inline (Super_Element);
      pragma inline (Super_Find_Token);
      pragma inline (Super_Index);
      pragma inline (Super_Index_Non_Blank);
      pragma inline (Super_Length);
      pragma inline (Super_Replace_Element);
      pragma inline (Super_Slice);
      pragma inline (Super_To_String);


end lace.Strings.superbounded;
