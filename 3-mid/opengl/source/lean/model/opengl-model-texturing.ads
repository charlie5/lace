with
     openGL.texture_Set;


package openGL.Model.texturing
--
-- Provides texturing support for models.
--
is
   -------------
   --- Mixin ---
   -------------

   generic
      type Item is abstract new Model.item with private;

   package Mixin
   is
      type textured_Item is abstract new Item with private;


      overriding
      function  Fade               (Self : in     textured_Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level;

      overriding
      procedure Fade_is            (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in texture_Set.fade_Level);

      overriding
      function  Tiling             (Self : in     textured_Item;   Which : in texture_Set.texture_Id) return texture_Set.Tiling;

      overriding
      procedure Tiling_is          (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in texture_Set.Tiling);

      procedure Texture_is         (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in asset_Name);

      overriding
      function  texture_Count      (Self : in     textured_Item) return Natural;


      overriding
      function  texture_Applied    (Self : in     textured_Item;   Which : in texture_Set.texture_Id) return Boolean;

      overriding
      procedure texture_Applied_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in Boolean);

      overriding
      procedure animate            (Self : in out textured_Item);


      function texture_Details     (Self : in textured_Item) return openGL.texture_Set.Details;

      procedure texture_Details_is (Self : in out textured_Item;   Now : in openGL.texture_Set.Details);



   private

      type textured_Item is abstract new Item with
         record
            texture_Details : openGL.texture_Set.Details;
         end record;

   end Mixin;


end openGL.Model.texturing;
