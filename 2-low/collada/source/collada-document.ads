with
     collada.Asset,
     collada.Libraries;


package collada.Document
--
-- Models a collada document.
--
is
   type Item is tagged private;

   function  to_Document (Filename : in String) return Item;
   --
   -- Raises collada.Error when the document lacks something the parser needs, and
   -- xml.parse_Error when the file is not well-formed.

   procedure destroy (Self : in out Item);
   --
   -- Frees everything the document holds. A copy of a document shares its
   -- contents, so destroy only one of them.


   function Asset     (Self : in Item) return collada.Asset    .item;
   function Libraries (Self : in Item) return collada.Libraries.item;

   function Scene     (Self : in Item) return Text;
   --
   -- The id of the visual scene the document instantiates, or empty.



private

   type Item is tagged
      record
         Asset     : collada.Asset    .item;
         Libraries : collada.Libraries.item;
         Scene     : Text;
      end record;


end collada.Document;
