private
with
     ada.Strings.unbounded,
     ada.Containers.Vectors;


package XML
--
-- Provides simple XML reader/writer support.
--
-- Heavily based on Chip Richards Ada XML packages.
--
is

   ------------------
   --- Attribute type
   --

   type Attribute_t  is tagged private;
   type Attributes_t is array (Positive range <>) of aliased Attribute_t;

   function no_Attributes return Attributes_t;


   function Name  (Self : in Attribute_t) return String;
   function Value (Self : in Attribute_t) return String;


   ----------------
   --- Element type
   --

   type Element      is tagged limited private;
   type Element_view is access all Element;

   type Elements is array (Positive range <>) of Element_view;


   --- Forge
   --

   function  to_XML (Filename : in String) return Element_view;
   --
   -- Parses 'Filename' and returns its document element, the root of the parsed tree.
   -- Raises parse_Error, naming the file, line and column, when the file is not well-formed.

   procedure free (Self : in out Element_view);
   --
   -- Frees the element, its attributes and all of its descendants.


   --- Attributes
   --

   function  Name       (Self : in     Element) return String;
   function  Attributes (Self : in     Element) return Attributes_t;
   function  Data       (Self : in     Element) return String;
   --
   -- The character data of the element, or "" when it holds only whitespace.

   function  Attribute  (Self : in     Element;   Named : in String) return access Attribute_t'Class;
   --
   -- Returns null if the named attribute does not exist.


   --- Hierarchy
   --

   function  Parent     (Self : in     Element) return Element_view;
   --
   -- Returns null for the document element.

   function  Children   (Self : in     Element) return Elements;
   function  Children   (Self : in     Element;   Named : in String) return Elements;

   function  Child      (Self : in     Element;   Named : in String) return Element_view;
   --
   -- Returns null if the named child does not exist.

   procedure add_Child  (Self : in out Element;   the_Child : in Element_view);
   --
   -- Appends the child and makes Self its parent.


   parse_Error : exception;



private

   use ada.Strings.unbounded;


   type Attribute_t is tagged
      record
         Name  : unbounded_String;
         Value : unbounded_String;
      end record;

   type Attributes_view is access all Attributes_t;



   package element_Vectors is new ada.Containers.Vectors (Positive, Element_view);
   subtype element_Vector  is element_Vectors.Vector;


   type Element is tagged limited
      record
         Name       : unbounded_String;
         Attributes : Attributes_view;
         Data       : unbounded_String;

         Parent     : Element_view;
         Children   : element_Vector;
      end record;


end XML;
