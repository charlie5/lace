#version 140

uniform mat4   mvp_Transform;
uniform vec3   Scale;

in vec3        Site;
in vec2        Coords;

out vec2       frag_Coords;


void main()
{
   frag_Coords = Coords;
   gl_Position = mvp_Transform * vec4 (Site * Scale, 1.0);
}
