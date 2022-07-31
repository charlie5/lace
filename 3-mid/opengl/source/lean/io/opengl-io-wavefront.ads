package openGL.IO.wavefront
--
--  Provides a function to convert a Wavefront model file (*.obj) to an openGL IO model.
--
is
   ---------
   --  Group
   --

   type group_Kind is (object_Name,     group_Name,
                       smoothing_Group, merging_Group);

   type Group (Kind : group_Kind := group_Name) is
      record
         case Kind
         is
         when object_Name     => object_Name     : Text;
         when group_Name      => group_Name      : Text;
         when smoothing_Group => smooth_group_Id : Natural;
         when merging_Group   => null;
         end case;
      end record;

   function Image (Self : in Group) return String;


   --------
   --  Face
   --

   type face_Kind is (a_Group, a_Facet);

   type Face (Kind : face_Kind := a_Facet) is
      record
         case Kind
         is
         when a_Group => Group : wavefront.Group;
         when a_Facet => Facet : openGL.IO.Face;
         end case;
   end record;

   type Faces is array (long_Index_t range <>) of Face;

   function Image    (Self       : in wavefront.Face) return String;
   function to_Model (model_File : in String)         return IO.Model;


   type Sites_view          is access openGL.Sites;
   type Coordinates_2D_view is access openGL.Coordinates_2D;
   type Normals_view        is access openGL.Normals;

   type Model is
      record
         material_Library : Text;
         material_Name    : Text;
         object_Name      : Text;
         group_Name       : Text;

         Sites   : Sites_view;
         Coords  : Coordinates_2D_view;
         Normals : Normals_view;
         Faces   : access wavefront.Faces;
      end record;

   function  to_Model (model_Path : in String) return wavefront.Model;

   procedure write    (the_Model  : in wavefront.Model;
                       to_File    : in String);


   -----------
   --  Utility
   --

   function to_Vector_3   (Self : in String) return Vector_3;
   function to_Coordinate (Self : in String) return Coordinate_2D;
   function to_Text       (Self : in String) return Text;


end openGL.IO.wavefront;
