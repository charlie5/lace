#version 140

uniform   mat4   mvp_Transform;
uniform   vec3   Scale;

in  vec3   Site;
in  vec4   Color;
in  vec2   Coords;

out vec4   frag_Color;
out vec2   frag_Coords;


void main()
{
   gl_Position = mvp_Transform * vec4 (Site * Scale, 1.0);
   frag_Color  = Color;
   frag_Coords = Coords;
}
