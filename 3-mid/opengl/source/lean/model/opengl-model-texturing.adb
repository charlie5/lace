with
     GL.lean,
     GL.Binding,
     ada.Strings.fixed;


package body openGL.Model.texturing
is
   use GL;


   -------------
   --- Mixin ---
   -------------

   package body Mixin
   is
      overriding
      procedure Fade_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                        Now   : in texture_Set.fade_Level)
      is
      begin
         Self.texture_Details.Fades (which) := Now;
      end Fade_is;



      overriding
      function Fade (Self : in textured_Item;   Which : in texture_Set.texture_Id) return texture_Set.fade_Level
      is
      begin
         return Self.texture_Details.Fades (which);
      end Fade;



      procedure Texture_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                           Now   : in openGL.asset_Name)
      is
      begin
         Self.texture_Details.Textures (Positive (which)) := Now;
      end Texture_is;




      overriding
      function texture_Count (Self : in textured_Item) return Natural
      is
      begin
         return Self.texture_Details.texture_Count;
      end texture_Count;



      overriding
      function texture_Applied (Self : in textured_Item;   Which : in texture_Set.texture_Id) return Boolean
      is
      begin
         return Self.texture_Details.texture_Applies (Which);
      end texture_Applied;



      overriding
      procedure texture_Applied_is (Self : in out textured_Item;   Which : in texture_Set.texture_Id;
                                                                   Now   : in Boolean)
      is
      begin
         Self.texture_Details.texture_Applies (Which) := Now;
      end texture_Applied_is;




      overriding
      procedure animate (Self : in out textured_Item)
      is
         use type texture_Set.Animation_view;
      begin
         if Self.texture_Details.Animation = null
         then
            return;
         end if;

         texture_Set.animate (Self.texture_Details.Animation.all,
                              Self.texture_Details.texture_Applies);
      end animate;



      function texture_Details (Self : in textured_Item) return openGL.texture_Set.Details
      is
      begin
         return Self.texture_Details;
      end texture_Details;


      procedure texture_Details_is (Self : in out textured_Item;   Now : in openGL.texture_Set.Details)
      is
      begin
         Self.texture_Details := Now;
      end texture_Details_is;


   end Mixin;



end openGL.Model.texturing;
