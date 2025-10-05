package body openGL.Model.texturing
is

   -------------
   --- Mixin ---
   -------------

   package body Mixin
   is
      use openGL.texture_Set;


      overriding
      procedure texture_Object_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                  Now   : in openGL.texture.Object)
      is
      begin
         Self.texture_Set.Details (detail_Count (Which)).Object := Now;
      end texture_Object_is;



      overriding
      function texture_Object (Self : in textured_Item;   Which : in texture_Set.texture_Id) return openGL.texture.Object
      is
      begin
         return Self.texture_Set.Details (detail_Count (Which)).Object;
      end texture_Object;




      overriding
      procedure Fade_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                        Now   : in texture_Set.fade_Level)
      is
      begin
         Self.texture_Set.Details (detail_Count (Which)).Fade := Now;
      end Fade_is;



      overriding
      function Fade (Self : in textured_Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
      is
      begin
         return Self.texture_Set.Details (detail_Count (Which)).Fade;
      end Fade;



      overriding
      procedure Tiling_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                          Now   : in texture_Set.Tiling)
      is
      begin
         Self.texture_Set.Details (detail_Count (Which)).texture_Tiling := Now;
      end Tiling_is;



      overriding
      function Tiling (Self : in textured_Item;   Which : in texture_Set.texture_Id) return texture_Set.Tiling
      is
      begin
         return Self.texture_Set.Details (detail_Count (Which)).texture_Tiling;
      end Tiling;




      procedure Texture_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                           Now   : in openGL.asset_Name)
      is
      begin
         Self.texture_Set.Details (detail_Count (Which)).Texture := Now;
      end Texture_is;




      overriding
      function texture_Count (Self : in textured_Item) return Natural
      is
      begin
         return Natural (Self.texture_Set.Count);
      end texture_Count;



      overriding
      function texture_Applied (Self : in textured_Item;   Which : in texture_Set.texture_Id) return Boolean
      is
      begin
         return Self.texture_Set.Details (detail_Count (Which)).texture_Apply;
      end texture_Applied;



      overriding
      procedure texture_Applied_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in Boolean)
      is
      begin
         Self.texture_Set.Details (detail_Count (Which)).texture_Apply := Now;
      end texture_Applied_is;




      overriding
      procedure animate (Self : in out textured_Item)
      is
         --  use type texture_Set.Animation_view;
      begin
         if Self.texture_Details.Animation = null
         then
            return;
         end if;

         --  texture_Set.animate (Self.texture_Set.Animation.all,
         --                       Self.texture_Set.texture_Applies);

         texture_Set.animate (Self.texture_Set);
      end animate;



      function texture_Details (Self : in textured_Item) return openGL.texture_Set.item
      is
      begin
         return Self.texture_Set;
      end texture_Details;


      procedure texture_Details_is (Self : in out textured_Item;   Now : in openGL.texture_Set.item)
      is
      begin
         Self.texture_Set := Now;
      end texture_Details_is;


   end Mixin;



end openGL.Model.texturing;
