package collada.Library.animations
--
-- Models a collada 'animations' library, which is a collection of animations.
--
is

   -----------
   --- Sampler
   --

   type Sampler is
      record
         Id     : Text;
         Inputs : Inputs_view;
      end record;


   -----------
   --- Channel
   --

   type Channel is
      record
         Source : Text;
         Target : Text;
      end record;


   -------------
   --- Animation
   --

   type Animation is
      record
         Id      : Text;
         Name    : Text;

         Sources : library.Sources_view;
         Sampler : animations.Sampler;
         Channel : animations.Channel;
      end record;

   type Animation_array      is array (Positive range <>) of Animation;
   type Animation_array_view is access Animation_array;

   function Inputs_of         (Self : in Animation) return access float_array;
   function Outputs_of        (Self : in Animation) return access float_array;
   function Interpolations_of (Self : in Animation) return access float_array;
   --
   -- Return null when the animation has no such data.


   ----------------
   --- Library Item
   --

   type Item is
      record
         Contents : Animation_array_view;
      end record;

   procedure destroy (Self : in out Item);


end collada.Library.animations;
