package body openGL.Light
is

   package body Forge
   is
      function to_Light (Id                  : in Id_t         := null_Id;
                         Kind                : in Kind_t       := Direct;
                         is_On               : in Boolean      := True;
                         Site                : in openGL.Site  := [0.0, 0.0, 1.0];
                         Strength            : in Intensity    :=  1.0;
                         Color               : in openGL.Color := (1.0, 1.0, 1.0);
                         Attenuation         : in Real         :=  0.0;
                         ambient_Coefficient : in Real         :=  0.0;
                         cone_Angle          : in Degrees      := 90.0;
                         cone_Direction      : in Vector_3     := [0.0, 0.0, -1.0]) return Item
      is
      begin
         return (Id                  => Id,
                 Kind                => Kind,
                 On                  => is_On,
                 Site                => Site,
                 Color               => Color,
                 Strength            => Strength,
                 Attenuation         => Attenuation,
                 ambient_Coefficient => ambient_Coefficient,
                 cone_Angle          => cone_Angle,
                 cone_Direction      => cone_Direction);
      end to_Light;

   end Forge;




   function Id (Self : in Item) return light.Id_t
   is
   begin
      return Self.Id;
   end Id;


   procedure Id_is (Self : in out Item;   Now : in light.Id_t)
   is
   begin
      Self.Id := Now;
   end Id_is;


   function Kind (Self : in Item) return light.Kind_t
   is
   begin
      return Self.Kind;
   end Kind;


   procedure Kind_is (Self : in out Item;   Now : in light.Kind_t)
   is
   begin
      Self.Kind := Now;
   end Kind_is;


   function is_On (Self : in Item) return Boolean
   is
   begin
      return Self.On;
   end is_On;


   procedure is_On (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.On := Now;
   end is_On;



   function Site (Self : in Item) return openGL.Site
   is
   begin
      return Self.Site;
   end Site;


   procedure Site_is (Self : in out Item;   Now : in openGL.Site)
   is
   begin
      Self.Site := Now;
   end Site_is;



   function Strength (Self : in Item)     return Intensity
   is
   begin
      return Self.Strength;
   end Strength;


   procedure Strength_is (Self : in out Item;   Now : in Intensity)
   is
   begin
      Self.Strength := Now;
   end Strength_is;



   function Color (Self : in Item) return openGL.Color
   is
   begin
      return Self.Color;
   end Color;


   function Attenuation (Self : in Item) return Real
   is
   begin
      return Self.Attenuation;
   end Attenuation;


   function ambient_Coefficient (Self : in Item) return Real
   is
   begin
      return Self.ambient_Coefficient;
   end ambient_Coefficient;


   function cone_Angle (Self : in Item) return Degrees
   is
   begin
      return Self.cone_Angle;
   end cone_Angle;


   function cone_Direction (Self : in Item) return Vector_3
   is
   begin
      return Self.cone_Direction;
   end cone_Direction;



   procedure Color_is (Self : in out Item;   Now : in openGL.Color)
   is
   begin
      Self.Color := Now;
   end Color_is;


   procedure Attenuation_is (Self : in out Item;   Now : in Real)
   is
   begin
      Self.Attenuation := Now;
   end Attenuation_is;


   procedure ambient_Coefficient_is (Self : in out Item;   Now : in Real)
   is
   begin
      Self.ambient_Coefficient := Now;
   end ambient_Coefficient_is;



   procedure cone_Angle_is (Self : in out Item;   Now : in Degrees)
   is
   begin
      Self.cone_Angle := Now;
   end cone_Angle_is;


   procedure cone_Direction_is (Self : in out Item;   Now : in Vector_3)
   is
   begin
      Self.cone_Direction := Now;
   end cone_Direction_is;


end openGL.Light;
