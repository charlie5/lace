// Include 'version.header'.
// Include 'texturing-frag.snippet'.

in  vec3       frag_Site;
in  vec4       frag_Color;
in  vec2       frag_Coords;

out vec4       final_Color;


void
main()
{
    vec4   surface_Color = mix (apply_Texturing (frag_Coords),
                                frag_Color,
                                0.5);

    vec3  Gamma = vec3 (1.0 / 2.2);
    final_Color = vec4 
    (pow
     (surface_Color.rgb,     // Final color (after gamma correction).
                             Gamma),
                        surface_Color.a);
}