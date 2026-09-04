with
     collada.Library.geometries,
     collada.Library.controllers,
     collada.Library.animations,
     collada.Library.visual_scenes,

     XML,

     ada.Calendar.formatting,
     ada.Calendar.time_Zones,
     ada.Containers.Vectors,
     ada.Strings.fixed,
     ada.Characters.latin_1;


package body collada.Document
is
   use ada.Strings.unbounded;
   use type xml.Element_view;


   -------------
   --- Utilities
   --

   function "+" (From : in String) return unbounded_String
     renames to_unbounded_String;



   function Value (Attribute : access xml.Attribute_t'Class;   Default : in String) return String
   is (if Attribute = null then Default
                           else Attribute.Value);



   function Id_of (From : in xml.Element) return String
   is (Value (From.Attribute ("id"), ""));



   function required_Attribute (From : in xml.Element;   Named : in String) return String
   is
      the_Attribute : constant access xml.Attribute_t'Class := From.Attribute (Named);
   begin
      if the_Attribute = null
      then
         raise Error with "'" & From.Name & "' element '" & Id_of (From) & "' has no '" & Named & "' attribute";
      end if;

      return the_Attribute.Value;
   end required_Attribute;



   function required_Child (From : in xml.Element;   Named : in String) return xml.Element_view
   is
      the_Child : constant xml.Element_view := From.Child (Named);
   begin
      if the_Child = null
      then
         raise Error with "'" & From.Name & "' element '" & Id_of (From) & "' has no '" & Named & "' child";
      end if;

      return the_Child;
   end required_Child;



   function to_Time (From : in String) return ada.Calendar.Time
   --
   -- Accepts ISO 8601 'YYYY-MM-DDThh:mm:ss', with optional fractional seconds and
   -- an optional 'Z' or '+hh:mm' zone. Anything else yields collada.Asset.unknown_Time.
   --
   is
      use ada.Calendar.formatting,
          ada.Calendar.time_Zones;

      Image : String      := ada.Strings.fixed.Trim (From, ada.Strings.Both);
      Zone  : Time_Offset := 0;
      Last  : Natural;                -- Of the seconds.
      i     : Natural;
   begin
      if Image'Length < 19
      then
         return collada.Asset.unknown_Time;
      end if;

      if Image (Image'First + 10) = 'T'
      then
         Image (Image'First + 10) := ' ';
      end if;

      Last := Image'First + 18;
      i    := Last + 1;

      if i <= Image'Last and then Image (i) = '.'                                       -- Skip any fraction.
      then
         i := i + 1;

         while i <= Image'Last and then Image (i) in '0' .. '9'
         loop
            i := i + 1;
         end loop;
      end if;

      if i <= Image'Last
      then
         if Image (i) = 'Z' and then i = Image'Last
         then
            Zone := 0;

         elsif Image (i) in '+' | '-' and then i + 5 = Image'Last and then Image (i + 3) = ':'
         then
            Zone := Time_Offset (  Integer'Value (Image (i + 1 .. i + 2)) * 60
                                 + Integer'Value (Image (i + 4 .. i + 5)));
            if Image (i) = '-'
            then
               Zone := -Zone;
            end if;

         else
            return collada.Asset.unknown_Time;
         end if;
      end if;

      return Value (Image (Image'First .. Last), Zone);

   exception
      when Constraint_Error =>
         return collada.Asset.unknown_Time;
   end to_Time;



   function is_Whitespace (C : in Character) return Boolean
   is (C in ' ' | ada.Characters.latin_1.HT
              | ada.Characters.latin_1.LF
              | ada.Characters.latin_1.CR);


   generic
      type Element is private;
      type Index   is range <>;
      type Elements is array (Index range <>) of Element;

      with function Value (Image : in String) return Element;

   function to_Array (From : in String) return Elements;
   --
   -- Splits 'From' at runs of XML whitespace (space, tab, line feed and carriage
   -- return) and converts each token with 'Value'.

   function to_Array (From : in String) return Elements
   is
      Count : Natural := 0;
      i     : Natural := From'First;

      procedure skip_Whitespace
      is
      begin
         while i <= From'Last and then is_Whitespace (From (i))
         loop
            i := i + 1;
         end loop;
      end skip_Whitespace;

      procedure skip_Token
      is
      begin
         while i <= From'Last and then not is_Whitespace (From (i))
         loop
            i := i + 1;
         end loop;
      end skip_Token;

   begin
      -- Count the tokens.
      --
      loop
         skip_Whitespace;
         exit when i > From'Last;

         Count := Count + 1;
         skip_Token;
      end loop;

      -- Convert them.
      --
      declare
         Result : Elements (Index (1) .. Index (Count));
         First  : Positive;
      begin
         i := From'First;

         for Each of Result
         loop
            skip_Whitespace;
            First := i;
            skip_Token;

            Each := Value (From (First .. i - 1));
         end loop;

         return Result;
      end;
   end to_Array;



   function to_Integer (Image : in String) return Integer   is (Integer  'Value (Image));
   function to_Real    (Image : in String) return math.Real is (math.Real'Value (Image));

   function to_int_Array   is new to_Array (Integer,   math.Index, int_array,   to_Integer);
   function to_float_Array is new to_Array (math.Real, math.Index, float_array, to_Real);
   function to_Text_array  is new to_Array (Text,      Positive,   Text_array,  to_Text);



   function to_Matrix (From : in String) return Matrix_4x4
   is
      the_Floats : constant math.Vector_16 := math.Vector_16 (to_float_Array (From));
   begin
      return math.to_Matrix_4x4 (the_Floats);
   end to_Matrix;



   function to_Semantic (Image : in String) return collada.Library.Semantic
   is
   begin
      return collada.Library.Semantic'Value (Image);
   exception
      when Constraint_Error =>
         return collada.Library.Unknown;
   end to_Semantic;



   function to_Source (From : in xml.Element) return collada.Library.Source
   is
      the_Floats : constant xml.Element_view := From.Child ("float_array");
      the_Names  : constant xml.Element_view := From.Child ("Name_array");
      the_IDREFs : constant xml.Element_view := From.Child ("IDREF_array");

      the_Array  : constant xml.Element_view := (if    the_Floats /= null then the_Floats
                                                 elsif the_Names  /= null then the_Names
                                                 else                          the_IDREFs);
      the_Source : Library.Source;


      procedure check_Count (Values : in Natural)
      is
         Count : constant String := Value (the_Array.Attribute ("count"), "");
      begin
         if Count /= "" and then Natural'Value (Count) /= Values
         then
            raise Error with   "Source '" & Id_of (From) & "': '" & the_Array.Name & "' has count "
                             & Count & " but holds" & Values'Image & " values";
         end if;
      end check_Count;

   begin
      the_Source.Id := +required_Attribute (From, "id");

      if the_Array = null
      then
         for Kind of Text_array' [+"int_array", +"bool_array", +"SIDREF_array"]
         loop
            if From.Child (to_String (Kind)) /= null
            then
               raise Error with "Source '" & Id_of (From) & "' holds a " & to_String (Kind) & ", which is not supported";
            end if;
         end loop;

         return the_Source;
      end if;

      the_Source.array_Id := +Value (the_Array.Attribute ("id"), "");

      if the_Array = the_Floats
      then
         the_Source.Floats := new float_array' (to_float_Array (the_Array.Data));
         check_Count (the_Source.Floats'Length);
      else
         the_Source.Texts  := new Text_array' (to_Text_array (the_Array.Data));
         check_Count (the_Source.Texts'Length);
      end if;

      return the_Source;
   end to_Source;



   function to_Input (From : in xml.Element) return collada.Library.Input_t
   is
      use collada.Library;

      the_Input : Input_t;
   begin
      the_Input.Semantic := to_Semantic (required_Attribute (From, "semantic"));
      the_Input.Source   :=            +required_Attribute (From, "source");
      the_Input.Offset   := Natural'Value (Value (From.Attribute ("offset"), "0"));

      return the_Input;
   end to_Input;



   function to_Inputs (From : in xml.Element) return collada.Library.Inputs_view
   is
      use collada.Library;

      the_xml_Inputs : constant xml.Elements := From.Children ("input");
      the_Inputs     : constant Inputs_view  := new Inputs (the_xml_Inputs'Range);
   begin
      for i in the_xml_Inputs'Range
      loop
         the_Inputs (i) := to_Input (the_xml_Inputs (i).all);
      end loop;

      return the_Inputs;
   end to_Inputs;



   function to_Vertices (From : in xml.Element) return collada.Library.geometries.Vertices
   is
      use collada.Library.geometries;

      the_Vertices : Vertices;
   begin
      the_Vertices.Id     := +required_Attribute (From, "id");
      the_Vertices.Inputs :=  to_Inputs (From);

      return the_Vertices;
   end to_Vertices;



   function to_Polylist (From : in xml.Element) return collada.Library.geometries.Primitive
   is
      use collada.Library.geometries;

      the_Polylist : Primitive (polyList);
   begin
      the_Polylist.Count    := Natural'Value (required_Attribute (From, "count"));
      the_Polylist.Material := +Value (From.Attribute ("material"), "");
      the_Polylist.Inputs   :=  to_Inputs (From);
      the_Polylist.vCount   :=  new int_array'      (to_int_Array (required_Child (From, "vcount").Data));
      the_Polylist.P_List   :=  new int_array_List' (1 => new int_array' (to_int_Array (required_Child (From, "p").Data)));

      return the_Polylist;
   end to_Polylist;



   function to_Primitive (From : in xml.Element;   Kind : in collada.Library.geometries.primitive_Kind)
                          return collada.Library.geometries.Primitive
   --
   -- For the primitives which hold one or more 'p' lists: polygons and triangles.
   --
   is
      use collada.Library.geometries;

      the_xml_Ps    : constant xml.Elements := From.Children ("p");
      the_Primitive : Primitive (Kind);
   begin
      the_Primitive.Count    := Natural'Value (required_Attribute (From, "count"));
      the_Primitive.Material := +Value (From.Attribute ("material"), "");
      the_Primitive.Inputs   :=  to_Inputs (From);
      the_Primitive.P_List   :=  new int_array_List (1 .. the_xml_Ps'Length);

      for i in the_Primitive.P_List'Range
      loop
         the_Primitive.P_List (i) := new int_array' (to_int_Array (the_xml_Ps (i).Data));
      end loop;

      return the_Primitive;
   end to_Primitive;



   function to_Joints (From : in xml.Element) return collada.Library.controllers.Joints
   is
      use collada.Library.controllers;

      the_Joints : Joints;
   begin
      the_Joints.Inputs := to_Inputs (From);
      return the_Joints;
   end to_Joints;



   function to_vertex_Weights (From : in xml.Element) return collada.Library.controllers.vertex_Weights
   is
      use collada.Library.controllers;

      the_Weights : vertex_Weights;
   begin
      the_Weights.Count   := Natural'Value (required_Attribute (From, "count"));
      the_Weights.Inputs  := to_Inputs (From);
      the_Weights.v_Count := new int_array' (to_int_Array (required_Child (From, "vcount").Data));
      the_Weights.V       := new int_array' (to_int_Array (required_Child (From, "v")     .Data));

      return the_Weights;
   end to_vertex_Weights;



   function to_Sampler (From : in xml.Element) return collada.Library.animations.Sampler
   is
      use collada.Library.animations;

      the_Sampler : Sampler;
   begin
      the_Sampler.Id     := +required_Attribute (From, "id");
      the_Sampler.Inputs :=  to_Inputs (From);

      return the_Sampler;
   end to_Sampler;



   function to_Channel (From : in xml.Element) return collada.Library.animations.Channel
   is
      use collada.Library.animations;

      the_Channel : Channel;
   begin
      the_Channel.Source := +required_Attribute (From, "source");
      the_Channel.Target := +required_Attribute (From, "target");

      return the_Channel;
   end to_Channel;



   function to_Sources (From : in xml.Element) return collada.Library.Sources_view
   is
      the_xml_Sources : constant xml.Elements          := From.Children ("source");
      the_Sources     : constant Library.Sources_view := new Library.Sources (the_xml_Sources'Range);
   begin
      for i in the_xml_Sources'Range
      loop
         the_Sources (i) := to_Source (the_xml_Sources (i).all);
      end loop;

      return the_Sources;
   end to_Sources;



   function stripped_Url (Url : in String) return Text
   --
   -- Returns the id a '#id' URL names.
   --
   is
   begin
      if Url'Length > 0 and then Url (Url'First) = '#'
      then
         return +Url (Url'First + 1 .. Url'Last);
      end if;

      return +Url;
   end stripped_Url;


   ----------------
   --- Construction
   --

   function to_Document (Filename : in String) return Item
   is
      use XML;

      the_xml_Tree     :          xml.Element_view := xml.to_XML (Filename);
      the_collada_Tree : constant xml.Element_view := the_xml_Tree;

      the_Document     : Document.item;

   begin
      if the_collada_Tree.Name /= "COLLADA"
      then
         xml.free (the_xml_Tree);
         raise Error with Filename & ": document element is '" & the_collada_Tree.Name & "', not 'COLLADA'";
      end if;


      parse_the_asset_Element:
      declare
         the_Asset : constant xml.Element_view := the_collada_Tree.Child ("asset");
      begin
         if the_Asset /= null
         then
            declare
               the_Contributor       : constant xml.Element_view := the_Asset.Child ("contributor");
               the_creation_Date     : constant xml.Element_view := the_Asset.Child ("created");
               the_modification_Date : constant xml.Element_view := the_Asset.Child ("modified");
               the_Unit              : constant xml.Element_view := the_Asset.Child ("unit");
               the_up_Axis           : constant xml.Element_view := the_Asset.Child ("up_axis");
            begin
               if the_Contributor /= null
               then
                  declare
                     the_Author         : constant xml.Element_view := the_Contributor.Child ("author");
                     the_authoring_Tool : constant xml.Element_view := the_Contributor.Child ("authoring_tool");
                  begin
                     if the_Author /= null
                     then
                        the_Document.Asset.Contributor.Author := +the_Author.Data;
                     end if;

                     if the_authoring_Tool /= null
                     then
                        the_Document.Asset.Contributor.authoring_Tool := +the_authoring_Tool.Data;
                     end if;
                  end;
               end if;

               if the_creation_Date /= null
               then
                  the_Document.Asset.Created := to_Time (the_creation_Date.Data);
               end if;

               if the_modification_Date /= null
               then
                  the_Document.Asset.Modified := to_Time (the_modification_Date.Data);
               end if;

               if the_Unit /= null
               then
                  the_Document.Asset.Unit.Name  :=             +Value (the_Unit.Attribute ("name"),  "meter");
                  the_Document.Asset.Unit.Meter := Float'Value (Value (the_Unit.Attribute ("meter"), "1.0"));
               end if;

               if the_up_Axis /= null
               then
                  the_Document.Asset.up_Axis := collada.asset.up_Direction'Value (the_up_Axis.Data);
               end if;
            end;
         end if;
      end parse_the_asset_Element;


      ---------------------------------
      --- Parse the 'library' elements.
      --

      parse_the_geometries_Library:
      declare
         the_Library : constant xml.Element_view := the_collada_Tree.Child ("library_geometries");
      begin
         if the_Library /= null
         then
            declare
               use collada.Library.geometries;

               the_Geometries : constant xml.Elements := the_Library.Children ("geometry");
            begin
               the_Document.Libraries.Geometries.Contents := new Geometry_array (the_Geometries'Range);

               for Each in the_Geometries'Range
               loop
                  declare
                     the_xml_Geometry : xml.Element_view renames the_Geometries (Each);
                     the_Geometry     : Geometry         renames the_Document.Libraries.Geometries.Contents (Each);

                     the_xml_Mesh     : constant xml.Element_view := the_xml_Geometry.Child ("mesh");
                  begin
                     the_Geometry.Id   := +required_Attribute (the_xml_Geometry.all, "id");
                     the_Geometry.Name := +Value (the_xml_Geometry.Attribute ("name"), "");

                     if the_xml_Mesh = null
                     then
                        raise Error with   "Geometry '" & Id_of (the_xml_Geometry.all)
                                         & "' has no mesh (convex_mesh, spline and brep are not supported)";
                     end if;

                     the_Geometry.Mesh.Sources  := to_Sources  (the_xml_Mesh.all);
                     the_Geometry.Mesh.Vertices := to_Vertices (required_Child (the_xml_Mesh.all, "vertices").all);

                     parse_Primitives:
                     declare
                        the_xml_Polylists : constant xml.Elements := the_xml_Mesh.Children ("polylist");
                        the_xml_Polygons  : constant xml.Elements := the_xml_Mesh.Children ("polygons");
                        the_xml_Triangles : constant xml.Elements := the_xml_Mesh.Children ("triangles");

                        Count : Natural := 0;
                     begin
                        the_Geometry.Mesh.Primitives := new Primitives (1 ..   the_xml_Polylists'Length
                                                                             + the_xml_Polygons 'Length
                                                                             + the_xml_Triangles'Length);
                        for i in the_xml_Polylists'Range
                        loop
                           Count                                := Count + 1;
                           the_Geometry.Mesh.Primitives (Count) := to_Polylist (the_xml_Polylists (i).all);
                        end loop;

                        for i in the_xml_Polygons'Range
                        loop
                           Count                                := Count + 1;
                           the_Geometry.Mesh.Primitives (Count) := to_Primitive (the_xml_Polygons (i).all, Polygons);
                        end loop;

                        for i in the_xml_Triangles'Range
                        loop
                           Count                                := Count + 1;
                           the_Geometry.Mesh.Primitives (Count) := to_Primitive (the_xml_Triangles (i).all, Triangles);
                        end loop;
                     end parse_Primitives;
                  end;
               end loop;
            end;
         end if;
      end parse_the_geometries_Library;


      parse_the_controllers_Library:
      declare
         the_Library : constant xml.Element_view := the_collada_Tree.Child ("library_controllers");
      begin
         if the_Library /= null
         then
            declare
               use collada.Library.controllers;

               the_Controllers : constant xml.Elements := the_Library.Children ("controller");
            begin
               the_Document.Libraries.Controllers.Contents := new Controller_array (the_Controllers'Range);

               for Each in the_Controllers'Range
               loop
                  declare
                     the_xml_Controller : xml.Element_view renames the_Controllers (Each);
                     the_Controller     : Controller       renames the_Document.Libraries.Controllers.Contents (Each);

                     the_xml_Skin       : constant xml.Element_view := the_xml_Controller.Child ("skin");
                  begin
                     the_Controller.Id   := +required_Attribute (the_xml_Controller.all, "id");
                     the_Controller.Name := +Value (the_xml_Controller.Attribute ("name"), "");

                     if the_xml_Skin = null
                     then
                        raise Error with   "Controller '" & Id_of (the_xml_Controller.all)
                                         & "' has no skin (morph controllers are not supported)";
                     end if;

                     the_Controller.Skin.main_Source       := +required_Attribute (the_xml_Skin.all, "source");
                     the_Controller.Skin.bind_shape_Matrix :=  to_float_Array (required_Child (the_xml_Skin.all, "bind_shape_matrix").Data);
                     the_Controller.Skin.Sources           :=  to_Sources        (the_xml_Skin.all);
                     the_Controller.Skin.Joints            :=  to_Joints         (required_Child (the_xml_Skin.all, "joints")        .all);
                     the_Controller.Skin.vertex_Weights    :=  to_vertex_Weights (required_Child (the_xml_Skin.all, "vertex_weights").all);
                  end;
               end loop;
            end;
         end if;
      end parse_the_controllers_Library;


      parse_the_visual_scenes_Library:
      declare
         the_Library : constant xml.Element_view := the_collada_Tree.Child ("library_visual_scenes");
      begin
         if the_Library /= null
         then
            declare
               use collada.Library.visual_scenes;

               the_visual_Scenes : constant xml.Elements := the_Library.Children ("visual_scene");


               function to_Node (the_XML : in xml.Element_view;
                                 Parent  : in Node_view) return Node_view
               is
                  use collada.Math;

                  the_Node : constant Node_view := new Node;


                  function Sid_of (the_Child : in xml.Element_view) return Text
                  is (+Value (the_Child.Attribute ("sid"), ""));

               begin
                  the_Node.Id_is   (+Value (the_XML.Attribute ("id"),   ""));
                  the_Node.Sid_is  (+Value (the_XML.Attribute ("sid"),  ""));
                  the_Node.Name_is (+Value (the_XML.Attribute ("name"), ""));
                  the_Node.Parent_is (Parent);

                  for the_Child of the_XML.Children
                  loop
                     declare
                        Name : constant String := the_Child.Name;
                     begin
                        if Name = "translate"
                        then
                           the_Node.add (Transform' (Kind   => Translate,
                                                     Sid    => Sid_of (the_Child),
                                                     Vector => Vector_3 (to_float_Array (the_Child.Data))));
                        elsif Name = "rotate"
                        then
                           declare
                              the_Data : constant Vector_4 := Vector_4 (to_float_Array (the_Child.Data));
                           begin
                              the_Node.add (Transform' (Kind  => Rotate,
                                                        Sid   => Sid_of (the_Child),
                                                        Axis  => Vector_3 (the_Data (1 .. 3)),
                                                        Angle => to_Radians (Degrees (the_Data (4)))));
                           end;
                        elsif Name = "scale"
                        then
                           the_Node.add (Transform' (Kind  => Scale,
                                                     Sid   => Sid_of (the_Child),
                                                     Scale => Vector_3 (to_float_Array (the_Child.Data))));
                        elsif Name = "matrix"
                        then
                           the_Node.add (Transform' (Kind   => full_Transform,
                                                     Sid    => Sid_of (the_Child),
                                                     Matrix => to_Matrix (the_Child.Data)));     -- Column vectors.
                        elsif Name = "node"
                        then
                           the_Node.add (the_Child => to_Node (the_Child, Parent => the_Node));   -- Recurse.

                        elsif Name = "instance_geometry"
                        then
                           the_Node.Instance_is (stripped_Url (required_Attribute (the_Child.all, "url")));

                        elsif Name = "instance_controller"
                        then
                           the_Node.Instance_is (stripped_Url (required_Attribute (the_Child.all, "url")));

                           declare
                              the_Skeleton : constant xml.Element_view := the_Child.Child ("skeleton");
                           begin
                              if the_Skeleton /= null
                              then
                                 the_Node.Skeleton_is (stripped_Url (the_Skeleton.Data));

                                 if the_Document.Libraries.visual_Scenes.skeletal_Root = ""
                                 then
                                    the_Document.Libraries.visual_Scenes.skeletal_Root := the_Node.Skeleton;
                                 end if;
                              end if;
                           end;

                        elsif Name in "asset" | "extra" | "instance_camera" | "instance_light"
                        then
                           null;                                                                  -- Nothing we model.

                        else
                           raise Error with   "Node '" & Id_of (the_XML.all) & "' has a '" & Name
                                            & "' element, which is not supported";               -- lookat, skew, instance_node.
                        end if;
                     end;
                  end loop;

                  return the_Node;
               end to_Node;

            begin
               the_Document.Libraries.visual_Scenes.Contents := new visual_Scene_array (the_visual_Scenes'Range);

               for Each in the_visual_Scenes'Range
               loop
                  declare
                     the_visual_Scene  : visual_Scene     renames the_Document.Libraries.visual_Scenes.Contents (Each);
                     the_xml_Scene     : xml.Element_view renames the_visual_Scenes (Each);

                     the_xml_Roots     : constant xml.Elements := the_xml_Scene.Children ("node");
                  begin
                     the_visual_Scene.Id   := +required_Attribute (the_xml_Scene.all, "id");
                     the_visual_Scene.Name := +Value (the_xml_Scene.Attribute ("name"), "");

                     the_visual_Scene.root_Nodes := new Nodes (the_xml_Roots'Range);

                     for i in the_xml_Roots'Range
                     loop
                        the_visual_Scene.root_Nodes (i) := to_Node (the_xml_Roots (i), Parent => null);
                     end loop;
                  end;
               end loop;
            end;
         end if;
      end parse_the_visual_scenes_Library;


      parse_the_animations_Library:
      declare
         the_Library : constant xml.Element_view := the_collada_Tree.Child ("library_animations");
      begin
         if the_Library /= null
         then
            declare
               use collada.Library.animations;

               package element_Vectors is new ada.Containers.Vectors (Positive, xml.Element_view);

               the_xml_Animations : element_Vectors.Vector;


               procedure gather (From : in xml.Element_view)
               --
               -- Gathers the animations which have a sampler, however deeply exporters nest them.
               --
               is
               begin
                  for the_Child of From.Children ("animation")
                  loop
                     if the_Child.Child ("sampler") /= null
                     then
                        the_xml_Animations.append (the_Child);
                     end if;

                     gather (the_Child);     -- Recurse.
                  end loop;
               end gather;

            begin
               gather (the_Library);

               the_Document.Libraries.Animations.Contents := new Animation_array (1 .. Natural (the_xml_Animations.Length));

               for Each in the_Document.Libraries.Animations.Contents'Range
               loop
                  declare
                     the_Animation     : Animation                 renames the_Document.Libraries.Animations.Contents (Each);
                     the_xml_Animation : constant xml.Element_view :=      the_xml_Animations (Each);
                  begin
                     the_Animation.Id      := +required_Attribute (the_xml_Animation.all, "id");
                     the_Animation.Name    := +Value (the_xml_Animation.Attribute ("name"), "");
                     the_Animation.Sampler :=  to_Sampler (required_Child (the_xml_Animation.all, "sampler").all);
                     the_Animation.Channel :=  to_Channel (required_Child (the_xml_Animation.all, "channel").all);
                     the_Animation.Sources :=  to_Sources (the_xml_Animation.all);
                  end;
               end loop;
            end;
         end if;
      end parse_the_animations_Library;


      parse_the_scene_Element:
      declare
         the_Scene : constant xml.Element_view := the_collada_Tree.Child ("scene");
      begin
         if the_Scene /= null
         then
            declare
               the_Instance : constant xml.Element_view := the_Scene.Child ("instance_visual_scene");
            begin
               if the_Instance /= null
               then
                  the_Document.Scene := stripped_Url (required_Attribute (the_Instance.all, "url"));
               end if;
            end;
         end if;
      end parse_the_scene_Element;


      xml.free (the_xml_Tree);
      return the_Document;

   exception
      when others =>
         xml.free (the_xml_Tree);
         the_Document.destroy;
         raise;
   end to_Document;



   procedure destroy (Self : in out Item)
   is
   begin
      collada.Library.geometries   .destroy (Self.Libraries.Geometries);
      collada.Library.controllers  .destroy (Self.Libraries.Controllers);
      collada.Library.visual_scenes.destroy (Self.Libraries.visual_Scenes);
      collada.Library.animations   .destroy (Self.Libraries.Animations);
   end destroy;


   --------------
   --- Attributes
   --

   function Asset (Self : in Item) return collada.Asset.item
   is
   begin
      return Self.Asset;
   end Asset;



   function Libraries (Self : in Item) return collada.Libraries.item
   is
   begin
      return Self.Libraries;
   end Libraries;



   function Scene (Self : in Item) return Text
   is
   begin
      return Self.Scene;
   end Scene;


end collada.Document;
