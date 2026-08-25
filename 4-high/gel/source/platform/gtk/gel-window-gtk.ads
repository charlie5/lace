with
     gtk.Widget;

private
with
     gtk.Drawing_Area;


package gel.Window.gtk
--
-- Provides a GTK implementation of a window.
--
-- The world view is a plain drawing widget whose native X window the renderer
-- Engine drives directly with EGL, so GDK never composites GL content itself.
--
is
   type Item is new gel.Window.item with private;
   type View is access all Item'Class;


   ---------
   --- Forge
   --

   procedure define  (Self : access Item;   Title  : in String;
                                            Width  : in Natural;
                                            Height : in Natural);
   overriding
   procedure destroy (Self : in out Item);


   package Forge
   is
      function new_Window (Title  : in String;
                           Width  : in Natural;
                           Height : in Natural) return Window.gtk.view;
   end Forge;


   --------------
   --- Attributes
   --

   package std_gtk renames standard.GTK;

   function gl_Area (Self : in Item) return std_gtk.Widget.gtk_Widget;
   --
   -- The widget displaying the rendered world, for packing into a GTK layout.


   --------------
   --- Operations
   --

   overriding
   procedure enable_GL   (Self : in     Item);
   overriding
   function  GL_is_ready (Self : in     Item) return Boolean;
   overriding
   procedure disable_GL  (Self : in     Item);
   overriding
   procedure swap_GL     (Self : in out Item);
   overriding
   procedure freshen     (Self : in     Item);



private

   type engine_GL_State;
   type engine_GL_State_view is access all engine_GL_State;
   --
   -- Holds the Engine's EGL display, context and window surface. Completed in the body.

   type Item is new gel.Window.item with
      record
         gl_Area   : std_gtk.Drawing_Area.gtk_Drawing_Area;
         engine_GL :         engine_GL_State_view;
      end record;


end gel.Window.gtk;
