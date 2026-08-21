with
     ada.Strings.Maps;


private package lace.Strings.search
--
-- Based on the 'ada.Strings.search' package provided by FSF GCC.
--
-- Modified to be a Pure package for use with DSA.
--
is
   pragma preelaborate;
   pragma Pure;

   use ada.Strings;


   function Index (Source  : in String;
                   Pattern : in String;
                   Going   : in Direction              := Forward;
                   Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Index (Source  : in String;
                   Pattern : in String;
                   Going   : in Direction                      := Forward;
                   Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Index (Source : in String;
                   Set    : in Maps.Character_Set;
                   Test   : in Membership        := Inside;
                   Going  : in Direction         := Forward) return Natural;

   function Index (Source  : in String;
                   Pattern : in String;
                   From    : in Positive;
                   Going   : in Direction              := Forward;
                   Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Index (Source  : in String;
                   Pattern : in String;
                   From    : in Positive;
                   Going   : in Direction                      := Forward;
                   Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Index (Source : in String;
                   Set    : in Maps.Character_Set;
                   From   : in Positive;
                   Test   : in Membership        := Inside;
                   Going  : in Direction         := Forward) return Natural;

   function Index_Non_Blank (Source : in String;
                             Going  : in Direction := Forward) return Natural;

   function Index_Non_Blank (Source : in String;
                             From   : in Positive;
                             Going  : in Direction := Forward) return Natural;

   function Count (Source  : in String;
                   Pattern : in String;
                   Mapping : in Maps.Character_Mapping := Maps.Identity) return Natural;

   function Count (Source  : in String;
                   Pattern : in String;
                   Mapping : in Maps.Character_Mapping_Function) return Natural;

   function Count (Source : in String;
                   Set    : in Maps.Character_Set) return Natural;

   procedure Find_Token (Source : in  String;
                         Set    : in  Maps.Character_Set;
                         From   : in  Positive;
                         Test   : in  Membership;
                         First  : out Positive;
                         Last   : out Natural);

   procedure Find_Token (Source : in  String;
                         Set    : in  Maps.Character_Set;
                         Test   : in  Membership;
                         First  : out Positive;
                         Last   : out Natural);


end lace.Strings.search;
