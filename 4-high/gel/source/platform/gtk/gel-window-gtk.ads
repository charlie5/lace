with
     gtk.glArea;

private
with
     gdk.glContext;


package gel.Window.gtk
--
-- Provides a GTK implementation of a window.
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

   function gl_Area (Self : in Item) return std_gtk.GLArea.Gtk_GLArea;



   --------------
   --- Operations
   --

   overriding
   procedure enable_GL   (Self : in     Item);
   overriding
   procedure disable_GL  (Self : in     Item);
   overriding
   procedure swap_GL     (Self : in out Item);
   overriding
   procedure freshen     (Self : in     Item);



private

   type Item is new gel.Window.item with
      record
         gl_Area    : std_gtk.glArea   .gtk_glArea;
         gl_Context :     gdk.glContext.gdk_glContext;
      end record;

end gel.Window.gtk;
