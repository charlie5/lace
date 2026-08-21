with
     ada.Streams.Stream_IO;


package openGL.Images
--
-- Provides ability to create and manipulate images.
--
is
   function fetch_Image (Stream  : in ada.Streams.Stream_IO.Stream_access;
                         try_TGA : in Boolean) return openGL.Image;


end openGL.Images;
