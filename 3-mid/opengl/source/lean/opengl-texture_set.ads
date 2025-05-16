with
     openGL.Program,
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



   --------
   --- Fade
   --

   type fade_Level  is delta 0.001 range 0.0 .. 1.0      -- '0.0' is no fading, '1.0' is fully faded (ie invisible).
     with Atomic;

   type fade_Levels is array (texture_Id range <>) of fade_Level;


   type texture_Apply_array is array (texture_Set.texture_Id) of Boolean;


   type fadeable_Texture is
      record
         Fade            : fade_Level                       := 0.0;
         Object          : openGL.Texture.Object            := openGL.Texture.null_Object;
         Applied         : Boolean                          := True;                           -- Whether this texture is painted on or not.
      end record;

   type fadeable_Textures is array (texture_Id range 1 .. max_Textures) of fadeable_Texture;



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
         next_frame_Time : ada.Calendar.Time :=  ada.Calendar.Clock;

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
         Fades           : fade_Levels                (texture_Id)       := [others => 0.0];
         Textures        : asset_Names (1 .. Positive (texture_Id'Last)) := [others => null_Asset];     -- The textures to be applied to the visual.
         texture_Count   : Natural                                       := 0;
         texture_Tiling  : Real                                          := 1.0;                        -- The number of times the texture should be wrapped.
         texture_Applies : texture_Apply_array                           := [1 => True, others => False];
         Animation       : Animation_view;
      end record;


   function to_Details (texture_Assets : in asset_Names;
                        Animation      : in Animation_view := null) return Details;





   --------
   --- Item
   --

   type Item is
      record
         Textures       : fadeable_Textures;
         Count          : Natural          := 0;
         is_Transparent : Boolean          := False;     -- Any of the textures contains lucid colors.
         initialised    : Boolean          := False;
      end record;

   procedure enable (the_Textures : in out Item;
                     Program      : in     openGL.Program.view);



   procedure Texture_is      (in_Set : in out Item;   Which : texture_ID;   Now : in openGL.Texture.Object);
   function  Texture         (in_Set : in     Item;   Which : texture_ID)     return openGL.Texture.Object;

   procedure Texture_is      (in_Set : in out Item;   Now : in openGL.Texture.Object);
   function  Texture         (in_Set : in     Item)     return openGL.Texture.Object;



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


end openGL.texture_Set;
