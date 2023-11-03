// Include 'version.header'.
// Include 'texturing.frag'.

in  vec2   frag_Coords;
out vec4   final_Color;


void main()
{
   final_Color = apply_Texturing (frag_Coords);
}