// Include 'version.header'.
// Include 'texturing-frag.snippet'.
// Include 'lighting-frag.snippet'



in  vec3       frag_Site;
in  vec3       frag_Normal;
in  vec2       frag_Coords;

uniform mat4   model_Transform;
uniform mat3   inverse_model_Rotation;
uniform vec3   camera_Site;

out vec4       final_Color;



void
main()
{
    vec3   surface_Site      = vec3 (  model_Transform
                                     * vec4 (frag_Site, 1));
    vec4   surface_Color     = apply_Texturing (frag_Coords);
    vec3   Surface_to_Camera = normalize (camera_Site - surface_Site);
    vec3   Normal            = normalize (  frag_Normal
                                          * inverse_model_Rotation);
  
    // Combine color from all the lights.
    //
    vec3   linear_Color = vec3 (0);
    
    for (int i = 0;   i < light_Count;   ++i)
    {
        linear_Color += apply_Light (Lights [i],
                                     surface_Color.rgb,
                                     Normal,
                                     surface_Site,
                                     Surface_to_Camera);
    }

    
    // Final color (after gamma correction).
    //
    vec3   Gamma = vec3 (1.0 / 2.2);
    
    final_Color = vec4 (pow (linear_Color,     
                             Gamma),
                        surface_Color.a);
 
                        
    // Prevent light saturation.
    //
//    final_Color = min (final_Color,
//                       surface_Color);
}