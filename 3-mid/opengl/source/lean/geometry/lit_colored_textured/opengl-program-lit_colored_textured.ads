package openGL.Program.lit_colored_textured
--
--  Provides a program for lit, colored, textured GL vertices.
--
is

   type Item is new openGL.Program.item with null record;
   type View is access all Item'Class;

   overriding
   procedure set_Uniforms (Self : in Item);

end openGL.Program.lit_colored_textured;
