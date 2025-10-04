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

   max_Textures : constant := 16;     -- 32;


   type detail_Count is range 0 .. max_Textures;


   --  type Item (Count : detail_Count := 1) is private;
   --
   --  null_Set : constant Item;




   ---------------
   --- Texture Ids
   --

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



   type Detail is
      record
         Object         : texture.Object;
         Texture        : asset_Name;
         Fade           : fade_Level;
         texture_Tiling : Tiling;
         texture_Apply  : Boolean;   -- If the textures is to be applied to the visual.
      end record;

   type Detail_array is array (detail_Count range <>) of Detail;



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



   ---------
   --- Forge
   --

   function to_Details (texture_Assets : in asset_Names;
                        Animation      : in Animation_view := null) return Details;

   no_Details : constant Details;


   --  function to_Set (texture_Assets : in asset_Names;
   --                   Animation      : in Animation_view := null) return Item;


   --------------
   --- Attributes
   --

   --  function  get_Details   (Self : in     Item)     return Detail_array;
   --  procedure Details_are   (Self : in out Item;   Now : in Detail_array);
   --
   --  function  get_Animation (Self : in     Item)     return Animation_view;
   --  procedure Animation_is  (Self : in out Item;   Now : in Animation_view);



private

   --  type Item (Count : detail_Count := 1) is
   --     record
   --        Details    : Detail_array (1 .. Count);
   --        Animation  : Animation_view;
   --     end record;



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
   --  null_Set   : constant Item    := (Count  => 0,
   --                                    others => <>);

end openGL.texture_Set;
