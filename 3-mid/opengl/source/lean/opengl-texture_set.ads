with
     openGL.Texture,
     ada.Calendar;

private
with
     ada.Streams;


package openGL.texture_Set
--
-- Facilitates multi-texturing of geometries.
--
-- Note that Mesa currently only supports 16 texture units.
--
is

   ---------------
   --- Texture Ids
   --

   max_Textures : constant := 16;     -- 32;

   type texture_Id  is range 1 .. max_Textures;
   type texture_Ids is array (Positive range <>) of texture_Id;


   ----------
   --- Tiling
   --

   type Tiling is     -- The number of times the texture should be wrapped.
      record
         S : Real;
         T : Real;
      end record;

   type Tilings is array (texture_Id) of Tiling;


   --------
   --- Fade
   --

   type fade_Level  is delta 0.001 range 0.0 .. 1.0      -- '0.0' is no fading, '1.0' is fully faded (ie invisible).
     with Atomic;

   type fade_Levels is array (texture_Id range <>) of fade_Level;


   ---------
   --- Apply
   --

   type texture_Apply_array is array (texture_Set.texture_Id) of Boolean;


   -------------
   --- Animation
   --

   subtype frame_Id is Positive;

   type Frame is
      record
         texture_Id : texture_Set.texture_Id;
      end record;

   type Frames is array (frame_Id range <>) of Frame;

   function to_Frames (From : in texture_Ids) return Frames;



   type Animation (frame_Count : Positive) is
      record
         frame_Duration  : Duration          := 0.1;
         next_frame_Time : ada.Calendar.Time := ada.Calendar.Clock;

         Current         : frame_Id          := 1;
         Frames          : texture_Set.Frames (1 .. frame_Count);
      end record;

   type Animation_view is access all Animation;


   procedure animate (the_Animation   : in out Animation;
                      texture_Applies : in out texture_Apply_array);


   -----------
   --- Details
   --

   type Details is
      record
         texture_Count    : Natural                                           := 0;
         Fades            : fade_Levels                    (texture_Id)       := [others => 0.0];
         Textures         : asset_Names     (1 .. Positive (texture_Id'Last)) := [others => null_Asset];
         Objects          : texture.Objects (1 .. Positive (texture_Id'Last)) := [others => texture.null_Object];
         texture_Tilings  : Tilings                                           := [others => (S => 1.0,
                                                                                             T => 1.0)];
         texture_Applies  : texture_Apply_array                               := [1 => True, others => False];     -- The textures to be applied to the visual.
         Animation        : Animation_view;
      end record;


   function to_Details (texture_Assets : in asset_Names;
                        Animation      : in Animation_view := null) return Details;

   no_Details : constant Details;



private

   -----------
   --- Streams
   --

   procedure write (Stream : not null access ada.Streams.Root_Stream_type'Class;
                    Item   : in              texture_Set.Animation_view);

   procedure read  (Stream : not null access ada.Streams.Root_Stream_type'Class;
                    Item   : out             texture_Set.Animation_view);

   for Animation_view'write use write;
   for Animation_view'read  use read;


   no_Details : constant Details := (others => <>);


end openGL.texture_Set;
