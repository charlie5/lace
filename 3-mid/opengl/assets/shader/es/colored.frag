#version 300 es
//
//  GLSL ES 3.00 ~ generated from the desktop shader of the same name.
//
//  Fragment shaders must declare default precisions, which desktop GLSL supplies implicitly.
//
precision highp float;
precision highp int;
precision highp sampler2D;
in  vec4   frag_Color;
out vec4   final_Color;


void
main()
{
    final_Color = frag_Color;
}