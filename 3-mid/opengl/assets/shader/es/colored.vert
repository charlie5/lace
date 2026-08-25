#version 300 es
//
//  GLSL ES 3.00 ~ generated from the desktop shader of the same name.
//
uniform mat4   mvp_Transform;
uniform vec3   Scale;

in vec3        Site;
in vec4        Color;

out vec3       frag_Site;
out vec4       frag_Color;


void main()
{
    // Pass some variables to the fragment shader.
    //
    frag_Site   = Site;
    frag_Color  = Color;
    
    // Apply all matrix transformations to 'Site'.
    //
    gl_Position = mvp_Transform * vec4 (Site * Scale, 1);
}