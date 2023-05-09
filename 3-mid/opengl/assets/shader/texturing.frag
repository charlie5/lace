uniform int         texture_Count;
uniform sampler2D   Textures [32];
uniform float       Fade     [32];

vec4
apply_Texturing (vec2   Coords)
{
    vec4   Color = vec4 (0);

    for (int i = 0;   i < texture_Count;   ++i)
    {
        Color.rgb +=   texture (Textures [i], Coords).rgb
                     * texture (Textures [i], Coords).a
                     * (1.0 - Fade [i]);
                                      
//        Color.a    += texture (Textures [i],  Coords).a * (1.0 - Fade[1]);

        Color.a    = max (Color.a,
                          texture (Textures [i],Coords).a * (1.0 - Fade[i]));


//        Color.a    = max (Color.a,
//                            texture (Textures [i],Coords).a);
    }
    
    return Color;
}