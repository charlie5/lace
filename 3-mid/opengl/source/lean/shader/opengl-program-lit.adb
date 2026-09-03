with
     openGL.Conversions,
     ada.Strings.fixed,
     ada.unchecked_Deallocation;


package body openGL.Program.lit
is

   overriding
   procedure destroy (Self : in out Item)
   is
      procedure free is new ada.unchecked_Deallocation (lit_uniform_Cache, lit_uniform_Cache_view);
   begin
      openGL.Program.item (Self).destroy;
      free (Self.lit_Cache);
   end destroy;



   overriding
   procedure Lights_are (Self : in out Item;   Now : in Light.items)
   is
   begin
      if Now'Length > Self.Lights'Length
      then
         raise openGL.Error with   "Too many lights:" & Integer'Image (Now'Length)
                                 & " (the maximum is" & Integer'Image (Self.Lights'Length) & ").";
      end if;

      Self.light_Count              := Now'Length;
      Self.Lights (1 .. Now'Length) := Now;
   end Lights_are;



   overriding
   procedure camera_Site_is (Self : in out Item;   Now : in Vector_3)
   is
   begin
      Self.camera_Site := Now;
   end camera_Site_is;



   overriding
   procedure model_Matrix_is (Self : in out Item;   Now : in Matrix_4x4)
   is
   begin
      Self.model_Transform := Now;
   end model_Matrix_is;



   overriding
   procedure set_Uniforms (Self : in Item)
   is
      use
           openGL.Conversions,
           linear_Algebra_3d;

      Cache : lit_uniform_Cache renames Self.lit_Cache.all;
   begin
      if not Cache.Filled
      then
         Cache.model_Transform        := Self.uniform_Variable ("model_Transform");
         Cache.inverse_model_Rotation := Self.uniform_Variable ("inverse_model_Rotation");
         Cache.camera_Site            := Self.uniform_Variable ("camera_Site");
         Cache.light_Count            := Self.uniform_Variable ("light_Count");
         Cache.specular_Color         := Self.uniform_Variable ("specular_Color");
         Cache.Filled                 := True;
      end if;

      while Cache.lights_Filled < Self.light_Count
      loop
         declare
            i : constant Positive := Cache.lights_Filled + 1;

            function light_Name return String
            is
               use
                    ada.Strings,
                    ada.Strings.fixed;
            begin
               return "Lights[" & Trim (Integer'Image (i - 1), Left) & "]";
            end light_Name;

         begin
            Cache.Lights (i) := (Site                => Self.uniform_Variable (light_Name & ".Site"),
                                 Strength            => Self.uniform_Variable (light_Name & ".Strength"),
                                 Color               => Self.uniform_Variable (light_Name & ".Color"),
                                 Attenuation         => Self.uniform_Variable (light_Name & ".Attenuation"),
                                 ambient_Coefficient => Self.uniform_Variable (light_Name & ".ambient_Coefficient"),
                                 cone_Angle          => Self.uniform_Variable (light_Name & ".cone_Angle"),
                                 cone_Direction      => Self.uniform_Variable (light_Name & ".cone_Direction"));
            Cache.lights_Filled := i;
         end;
      end loop;

      openGL.Program.item (Self).set_Uniforms;

      Cache.camera_Site           .Value_is (Self.camera_Site);
      Cache.model_Transform       .Value_is (Self.model_Transform);
      Cache.inverse_model_Rotation.Value_is (Inverse (get_Rotation (Self.model_Transform)));

      -- Lights.
      --
      Cache.light_Count   .Value_is (Self.light_Count);
      Cache.specular_Color.Value_is (to_Vector_3 (Self.specular_Color));

      for i in 1 .. Self.light_Count
      loop
         declare
            use Light;

            Light    : openGL.Light.item renames Self.Lights (i);
            Uniforms : light_uniform_Set renames Cache.Lights (i);
         begin
            case Light.Kind
            is
            when Diffuse =>   Uniforms.Site.Value_is (Vector_4 (Light.Site & 1.0));
            when Direct  =>   Uniforms.Site.Value_is (Vector_4 (Light.Site & 0.0));    -- '0.0' tells shader that this light is 'direct'.
            end case;

            Uniforms.Color              .Value_is (to_Vector_3 (Light.Color));
            Uniforms.Strength           .Value_is (Real        (Light.Strength));
            Uniforms.Attenuation        .Value_is (             Light.Attenuation);
            Uniforms.ambient_Coefficient.Value_is (             Light.ambient_Coefficient);
            Uniforms.cone_Angle         .Value_is (Real        (Light.cone_Angle));
            Uniforms.cone_Direction     .Value_is (             Light.cone_Direction);
         end;
      end loop;
   end set_Uniforms;



   procedure specular_Color_is (Self : in out Item;   Now : in Color)
   is
   begin
      Self.specular_Color := Now;
   end specular_Color_is;


end openGL.Program.lit;
