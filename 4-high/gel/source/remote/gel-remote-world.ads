with
     physics.remote.Model,
     openGL .remote_Model,

     lace.Observer,
     lace.Subject,
     lace.Event,
     lace.Text,

     ada.unchecked_Conversion,
     ada.Containers.indefinite_hashed_Maps,
     ada.Containers.indefinite_Vectors,
     ada.Streams;

package gel.remote.World
--
--  Provides a remote (DSA friendly) interface of a GEL world.
--
--  Supports world mirroring, in which a mirror world mimics the objects and dynamics of a master world.
--
is
   pragma remote_Types;
   --  pragma suppress (Container_Checks);     -- Suppress expensive tamper checks.

   type Item is  limited interface
             and lace.Subject .item
             and lace.Observer.item;

   type View is access all Item'Class with Asynchronous;



   -----------
   --  Mirrors
   --

   --  Registration
   --

   procedure   register (Self : access Item;   the_Mirror         : in World.view;
                                               Mirror_as_observer : in lace.Observer.view)   is abstract;
   procedure deregister (Self : access Item;   the_Mirror         : in World.view;
                                               Mirror_as_observer : in lace.Observer.view)   is abstract;



   ----------
   --  Models
   --

   --  Graphics
   --

   use type openGL.remote_Model.item;
   package  model_Vectors is new ada.Containers.indefinite_Vectors (Positive, openGL.remote_Model.item'Class);

   function Hash is new ada.unchecked_Conversion (gel.graphics_model_Id, ada.containers.Hash_type);
   use type gel.graphics_model_Id;

   package  id_Maps_of_graphics_model is new ada.Containers.indefinite_Hashed_Maps (gel.graphics_model_Id,
                                                                                    openGL.remote_Model.item'Class,
                                                                                    Hash,
                                                                                    "=");
   subtype  id_Map_of_graphics_model is id_Maps_of_graphics_model.Map;

   function graphics_Models (Self : in Item) return id_Map_of_graphics_model is abstract;


   type new_graphics_model_Event is new lace.Event.item with
      record
         Model : access openGL.remote_Model.item'Class;
      end record;


   procedure write (Stream : not null access ada.Streams.Root_Stream_type'Class;   the_Event : in     new_graphics_model_Event);
   procedure read  (Stream : not null access ada.Streams.Root_Stream_type'Class;   the_Event :    out new_graphics_model_Event);

   for new_graphics_model_Event'write use write;
   for new_graphics_model_Event'read  use read;


   --  Physics
   --

   use physics.remote.Model;
   package  physics_model_Vectors is new ada.containers.indefinite_Vectors (Positive, physics.remote.Model.item'Class);

   use type physics.model_Id;
   function Hash is new ada.unchecked_Conversion (physics.model_Id, ada.containers.Hash_type);

   package  id_Maps_of_physics_model is new ada.containers.indefinite_Hashed_Maps (physics.model_Id,
                                                                                   physics.remote.Model.item'Class,
                                                                                   Hash,
                                                                                   "=");
   subtype  id_Map_of_physics_model is id_Maps_of_physics_model.Map;

   function physics_Models (Self : in Item) return id_Map_of_physics_model is abstract;


   type new_physics_model_Event is new lace.Event.item with
      record
         Model : access physics.remote.Model.item'Class;
      end record;

   procedure Write (Stream : not null access ada.Streams.Root_Stream_type'Class;   the_Event : in  new_physics_model_Event);
   procedure Read  (Stream : not null access ada.Streams.Root_Stream_type'Class;   the_Event : out new_physics_model_Event);

   for new_physics_model_Event'write use write;
   for new_physics_model_Event'read  use read;


   -----------
   --- Sprites
   --

   type sprite_model_Pair is
      record
         sprite_Id         : gel   .sprite_Id;
         sprite_Name       : lace.Text.item_64;
         graphics_model_Id : openGL .model_Id;
         physics_model_Id  : physics.model_Id;

         Mass              : math.Real;
         Transform         : math.Matrix_4x4;
         is_Visible        : Boolean;
      end record;

   type sprite_model_Pairs is array (math.Index range <>) of sprite_model_Pair;

   function Sprites (Self : in out Item) return sprite_model_Pairs is abstract;


   -------------------------
   --- Id Motion Updates
   --

   --  Coarse types to help minimise network use - (TODO: Currently disabled til better quaternion 'coarsen' is ready.)
   --
   type coarse_Real is new math.Real;   -- Not coarse atm (see above 'TODO')

   type coarse_Vector_3 is array (1 .. 3) of coarse_Real;

   function refined (Self : in coarse_Vector_3) return   math.Vector_3;
   function coarsen (Self : in   math.Vector_3) return coarse_Vector_3;


   type coarse_Real2 is new math.Real;   -- Not coarse atm.


   type coarse_Quaternion is array (1 .. 4) of coarse_Real2;

   function refined (Self : in coarse_Quaternion) return   math.Quaternion;
   function coarsen (Self : in   math.Quaternion) return coarse_Quaternion;


   type motion_Update is
      record
         Id   : gel.sprite_Id;
         Site : coarse_Vector_3;
         Spin : coarse_Quaternion;
      end record
   with Pack;


   type motion_Updates is array (Positive range <>) of motion_Update
     with Pack;

   procedure motion_Updates_write (Stream : access ada.Streams.Root_Stream_type'Class;   Item : in  motion_Updates);
   procedure motion_Updates_read  (Stream : access ada.Streams.Root_Stream_type'Class;   Item : out motion_Updates);

   for motion_Updates'write use motion_Updates_write;
   for motion_Updates'read  use motion_Updates_read;


   type sequence_Id is range 0 .. 2**32 - 1;

   procedure motion_Updates_are (Self : in Item;   seq_Id : in sequence_Id;
                                                   Now    : in motion_Updates) is abstract;




   ------------------------------
   --- Id add and rid events.
   --

   type sprite_added_Event is new lace.Event.item with
      record
         Sprite : gel.sprite_Id;
      end record;


   type sprite_ridded_Event is new lace.Event.item with
      record
         Id   : gel.sprite_Id;
         Name : lace.Text.item_128;
      end record;



   --------------
   --  Test/Debug
   --

   procedure kick_Sprite (Self : in out Item;   sprite_Id : in gel.Sprite_Id) is abstract;

end gel.remote.World;
