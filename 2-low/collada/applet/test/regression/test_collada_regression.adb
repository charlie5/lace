with
     collada.Document,
     collada.Asset,
     collada.Libraries,
     collada.Library.geometries,
     collada.Library.controllers,
     collada.Library.animations,
     collada.Library.visual_scenes,

     ada.Calendar.formatting,
     ada.Command_Line,
     ada.Directories,
     ada.Exceptions,
     ada.Strings.fixed,
     ada.Text_IO;


procedure test_collada_Regression
--
-- Regression tests for the defects recorded in FIXES.md.
--
is
   use collada,
       collada.Library,
       collada.Library.visual_scenes,
       ada.Text_IO,
       ada.Exceptions;

   use type ada.Calendar.Time,
            collada.Asset.up_Direction,
            collada.Library.geometries  .Geometry_array_view,
            collada.Library.controllers .Controller_array_view,
            collada.Library.animations  .Animation_array_view,
            collada.Library.geometries  .primitive_Kind,
            collada.Vector_3;

   Failures : Natural := 0;

   procedure check (Ok : in Boolean;   Label : in String)
   is
   begin
      if Ok
      then
         put_Line ("PASS: " & Label);
      else
         Failures := Failures + 1;
         put_Line ("FAIL: " & Label);
      end if;
   end check;


   Assets : constant String := ada.Directories.current_Directory & "/assets";
   Root   : constant String := ada.Directories.current_Directory & "/work";

   LF : constant Character := ASCII.LF;
   HT : constant Character := ASCII.HT;
   CR : constant Character := ASCII.CR;


   procedure write (Filename : in String;   Text : in String)
   is
      File : File_type;
   begin
      create (File, out_File, Root & "/" & Filename);
      put (File, Text);
      close (File);
   end write;


   function contains (Text, Pattern : in String) return Boolean
   is (ada.Strings.fixed.Index (Text, Pattern) /= 0);


   -- A count and checksum of every number array in a document, and a count of its texts.
   --
   type Tally is
      record
         Numbers : Natural    := 0;
         Sum     : Long_Float := 0.0;
         Texts   : Natural    := 0;
      end record;

   function tally_of (Self : in Document.item) return Tally
   is
      L      : constant Libraries.item := Self.Libraries;
      Result : Tally;

      procedure add (Sources : in Sources_view)
      is
      begin
         if Sources = null
         then
            return;
         end if;

         for Each of Sources.all
         loop
            if Each.Floats /= null
            then
               Result.Numbers := Result.Numbers + Each.Floats'Length;

               for V of Each.Floats.all
               loop
                  Result.Sum := Result.Sum + Long_Float (V);
               end loop;
            end if;

            if Each.Texts /= null
            then
               Result.Texts := Result.Texts + Each.Texts'Length;
            end if;
         end loop;
      end add;

      procedure add (Ints : in Int_array_view)
      is
      begin
         if Ints = null
         then
            return;
         end if;

         Result.Numbers := Result.Numbers + Ints'Length;

         for V of Ints.all
         loop
            Result.Sum := Result.Sum + Long_Float (V);
         end loop;
      end add;

   begin
      if L.Geometries.Contents /= null
      then
         for G of L.Geometries.Contents.all
         loop
            add (G.Mesh.Sources);

            for P of G.Mesh.Primitives.all
            loop
               for Q of P.P_List.all
               loop
                  add (Q);
               end loop;

               if P.Kind = geometries.polyList
               then
                  add (P.vCount);
               end if;
            end loop;
         end loop;
      end if;

      if L.Controllers.Contents /= null
      then
         for C of L.Controllers.Contents.all
         loop
            add (C.Skin.Sources);
            add (C.Skin.vertex_Weights.v_Count);
            add (C.Skin.vertex_Weights.V);
         end loop;
      end if;

      if L.Animations.Contents /= null
      then
         for A of L.Animations.Contents.all
         loop
            add (A.Sources);
         end loop;
      end if;

      return Result;
   end tally_of;


   function near (Actual, Expected : in Long_Float) return Boolean
   is (abs (Actual - Expected) <= 1.0e-6 * abs Expected);


   procedure expect_Error (Filename, Fragment, Label : in String)
   is
      D : Document.item;
   begin
      D := Document.to_Document (Root & "/" & Filename);
      D.destroy;
      check (False, Label);
   exception
      when E : collada.Error =>
         check (contains (exception_Message (E), Fragment), Label);
   end expect_Error;


   Identity : constant String := "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1";

begin
   if ada.Directories.Exists (Root)
   then
      ada.Directories.delete_Tree (Root);
   end if;

   ada.Directories.create_Path (Root);

   put_Line ("Begin Test");
   new_Line;


   --- A Blender box: several scene roots, instanced geometry, cameras and lights (M2, M6, L10).
   --
   declare
      D : Document.item := Document.to_Document (Assets & "/box.dae");
      L : constant Libraries.item := D.Libraries;
      S : constant visual_Scene   := L.visual_Scenes.Contents (1);
      T : constant Tally          := tally_of (D);
   begin
      check (L.Geometries.Contents'Length = 1,                            "box: one geometry");
      check (S.root_Nodes'Length = 3,                                     "box: every top-level scene node is parsed");
      check (to_String (S.root_Nodes (1).Id) = "Cube"
             and then to_String (S.root_Nodes (3).Id) = "Camera",          "box: scene roots keep document order");
      check (to_String (S.root_Nodes (1).Instance) = "Cube-mesh",          "box: a node records the geometry it instances");
      check (to_String (D.Scene) = "Scene",                                "box: the instantiated scene");
      check (T.Numbers = 96 and then near (T.Sum, 167.999_998_718_5),      "box: array checksum");
      check (D.Asset.Created = ada.Calendar.formatting.Value ("2010-11-28 13:09:56"),
                                                                           "box: ISO 8601 creation time");
      D.destroy;
      check (True,                                                         "box: destroy");
   end;


   --- A Blender rig with a nested animation, a skin and weights (M4, checksums).
   --
   declare
      use collada.Library.controllers;

      D : Document.item := Document.to_Document (Assets & "/box_1_bone-animated.dae");
      L : constant Libraries.item := D.Libraries;
      T : constant Tally          := tally_of (D);
   begin
      check (L.Animations.Contents'Length = 1,                            "rig: the nested animation is gathered");
      check (L.Animations.Contents (1).Sampler.Inputs /= null
             and then animations.Inputs_of  (L.Animations.Contents (1)) /= null
             and then animations.Outputs_of (L.Animations.Contents (1)) /= null,
                                                                           "rig: the animation has inputs and outputs");
      check (L.Controllers.Contents'Length = 1,                           "rig: one controller");

      declare
         Skin  : collada.Library.controllers.Skin renames L.Controllers.Contents (1).Skin;
         Names : constant Text_array := joint_Names_of (Skin);
      begin
         check (Names'Length >= 1,                                          "rig: joint names");
         check (bind_Poses_of (Skin)'Length = Names'Length,                 "rig: one bind pose per joint");
         check (Weights_of (Skin) /= null,                                  "rig: weights");
      end;

      check (T.Numbers = 4400 and then near (T.Sum, 1898.479_352_083_52) and then T.Texts = 251,
                                                                           "rig: array checksum");
      D.destroy;
      check (True,                                                         "rig: destroy");
   end;


   --- A document exercising the parser's edge cases (H1, M4, M5, M7, M9, L8, L10).
   --
   write ("features.dae",
            "<?xml version=""1.0""?>" & LF
          & "<COLLADA>" & LF
          & " <asset>" & LF
          & "  <created>2011-04-14T22:53:18.123Z</created>" & LF
          & "  <modified>Sun, 16 Oct 2011 15:24:24 +0000</modified>" & LF
          & "  <unit name=""cm""/>" & LF
          & "  <up_axis>Z_UP</up_axis>" & LF
          & " </asset>" & LF
          & " <library_geometries>" & LF
          & "  <geometry id=""g""><mesh>" & LF
          & "   <source id=""pos""><float_array id=""pa"" count=""6"">1.0" & LF & "2.0" & HT & "3.0" & CR & LF & "4.0 5.0" & LF & "6.0</float_array></source>" & LF
          & "   <vertices id=""v""><input semantic=""POSITION"" source=""#pos""/></vertices>" & LF
          & "   <triangles count=""1""><input semantic=""VERTEX"" source=""#v"" offset=""0""/><p>0 1" & LF & "2</p></triangles>" & LF
          & "  </mesh></geometry>" & LF
          & " </library_geometries>" & LF
          & " <library_controllers>" & LF
          & "  <controller id=""c""><skin source=""#g"">" & LF
          & "   <bind_shape_matrix>" & Identity & "</bind_shape_matrix>" & LF
          & "   <source id=""names""><IDREF_array id=""na"" count=""2"">Root" & LF & "Tip</IDREF_array></source>" & LF
          & "   <source id=""ibm""><float_array id=""ia"" count=""32"">" & Identity & " " & Identity & "</float_array></source>" & LF
          & "   <source id=""w""><float_array id=""wa"" count=""2"">1.0 0.5</float_array></source>" & LF
          & "   <joints><input semantic=""JOINT"" source=""#names""/><input semantic=""INV_BIND_MATRIX"" source=""#ibm""/></joints>" & LF
          & "   <vertex_weights count=""1""><input semantic=""JOINT"" source=""#names"" offset=""0""/><input semantic=""WEIGHT"" source=""#w"" offset=""1""/>" & LF
          & "    <vcount>2</vcount><v>0 0 1 1</v></vertex_weights>" & LF
          & "  </skin></controller>" & LF
          & " </library_controllers>" & LF
          & " <library_visual_scenes>" & LF
          & "  <visual_scene id=""s"">" & LF
          & "   <node id=""n1""><translate>1 2 3</translate><rotate sid=""rotationZ"">0 0 1 90</rotate><extra/><node id=""n2"" name=""n2""/></node>" & LF
          & "   <node id=""n3""><instance_controller url=""#c""><skeleton>#n1</skeleton></instance_controller></node>" & LF
          & "  </visual_scene>" & LF
          & " </library_visual_scenes>" & LF
          & " <library_animations>" & LF
          & "  <animation id=""container"">" & LF
          & "   <animation id=""a1""><source id=""a1i""><float_array id=""a1ia"" count=""2"">0 1</float_array></source>" & LF
          & "    <sampler id=""a1s""><input semantic=""INPUT"" source=""#a1i""/></sampler><channel source=""#a1s"" target=""n1/rotationZ.ANGLE""/></animation>" & LF
          & "   <animation id=""a2""><source id=""a2i""><float_array id=""a2ia"" count=""2"">0 2</float_array></source>" & LF
          & "    <sampler id=""a2s""><input semantic=""INPUT"" source=""#a2i""/></sampler><channel source=""#a2s"" target=""n2/rotationZ.ANGLE""/></animation>" & LF
          & "  </animation>" & LF
          & " </library_animations>" & LF
          & " <scene><instance_visual_scene url=""#s""/></scene>" & LF
          & "</COLLADA>" & LF);

   declare
      use collada.Library.geometries,
          collada.Library.controllers;

      D : Document.item := Document.to_Document (Root & "/features.dae");
      L : constant Libraries.item := D.Libraries;

      Positions : constant access Float_array := Positions_of (L.Geometries.Contents (1).Mesh);
      Skin      : collada.Library.controllers.Skin renames L.Controllers.Contents (1).Skin;
      Names     : constant Text_array   := joint_Names_of (Skin);
      S         : constant visual_Scene := L.visual_Scenes.Contents (1);
      N1        : constant Node_view    := S.root_Nodes (1);
      N3        : constant Node_view    := S.root_Nodes (2);
      M         : constant Matrix_4x4   := N1.local_Transform;
   begin
      check (Positions /= null and then Positions'Length = 6
             and then Positions (1) = 1.0 and then Positions (2) = 2.0 and then Positions (3) = 3.0
             and then Positions (4) = 4.0 and then Positions (5) = 5.0 and then Positions (6) = 6.0,
                                                                           "features: numbers split at line feeds, tabs and CR LF");
      check (L.Geometries.Contents (1).Mesh.Primitives (1).P_List (1)'Length = 3,
                                                                           "features: an index list split at a line feed");
      check (D.Asset.Created  = ada.Calendar.formatting.Value ("2011-04-14 22:53:18"),
                                                                           "features: a date with a fraction and a Z zone");
      check (D.Asset.Modified = collada.Asset.unknown_Time,                 "features: a date in another form is unknown_Time");
      check (to_String (D.Asset.Unit.Name) = "cm" and then D.Asset.Unit.Meter = 1.0,
                                                                           "features: a unit without 'meter' takes the default");
      check (D.Asset.up_Axis = collada.Asset.Z_up,                          "features: up axis");
      check (Names'Length = 2 and then to_String (Names (1)) = "Root" and then to_String (Names (2)) = "Tip",
                                                                           "features: joint names from an IDREF_array");
      check (bind_Poses_of (Skin)'Length = 2,                               "features: bind poses");
      check (joint_Offset_of (Skin.vertex_Weights) = 0 and then weight_Offset_of (Skin.vertex_Weights) = 1,
                                                                           "features: input offsets");
      check (S.root_Nodes'Length = 2,                                       "features: scene roots");
      check (N1.Translation = [1.0, 2.0, 3.0],                              "features: a translate without a sid");
      check (abs (N1.Rotate_Z (4) - Math.to_Radians (90.0)) < 1.0e-6,      "features: a rotation angle in radians");
      check (abs (M (1, 4) - 1.0) < 1.0e-6 and then abs (M (2, 1) - 1.0) < 1.0e-6 and then abs (M (1, 1)) < 1.0e-6,
                                                                           "features: transforms compose as column-vector matrices");
      check (N1.Child ("n2") /= null and then N1.Child ("n2").Parent = N1,  "features: child nodes and their parent");
      check (N1.Child ("nowhere") = null,                                   "features: a missing descendant is null");
      check (to_String (N3.Instance) = "c" and then to_String (N3.Skeleton) = "n1",
                                                                           "features: an instanced controller and its skeleton");
      check (to_String (L.visual_Scenes.skeletal_Root) = "n1",              "features: the library's skeletal root");
      check (L.Animations.Contents'Length = 2
             and then to_String (L.Animations.Contents (2).Id) = "a2",      "features: every nested animation is gathered");
      check (to_String (D.Scene) = "s",                                     "features: the instantiated scene");

      D.destroy;
      check (True,                                                          "features: destroy");
   end;


   --- Documents the parser must refuse (M6, M9, L8).
   --
   write ("not_collada.dae", "<doc/>" & LF);
   write ("bad_count.dae",   "<COLLADA><library_geometries><geometry id=""g""><mesh>"
                           & "<source id=""p""><float_array id=""pa"" count=""5"">1 2 3 4 5 6</float_array></source>"
                           & "<vertices id=""v""><input semantic=""POSITION"" source=""#p""/></vertices>"
                           & "</mesh></geometry></library_geometries></COLLADA>" & LF);
   write ("no_mesh.dae",     "<COLLADA><library_geometries><geometry id=""g""><spline/></geometry></library_geometries></COLLADA>" & LF);
   write ("lookat.dae",      "<COLLADA><library_visual_scenes><visual_scene id=""s""><node id=""n""><lookat>0 0 0 0 0 1 0 1 0</lookat></node>"
                           & "</visual_scene></library_visual_scenes></COLLADA>" & LF);
   write ("no_id.dae",       "<COLLADA><library_geometries><geometry><mesh><vertices id=""v""/></mesh></geometry></library_geometries></COLLADA>" & LF);
   write ("int_array.dae",   "<COLLADA><library_geometries><geometry id=""g""><mesh>"
                           & "<source id=""p""><int_array id=""pa"" count=""1"">1</int_array></source>"
                           & "<vertices id=""v""><input semantic=""POSITION"" source=""#p""/></vertices>"
                           & "</mesh></geometry></library_geometries></COLLADA>" & LF);

   expect_Error ("not_collada.dae", "not 'COLLADA'",       "refuse: a document whose root is not COLLADA");
   expect_Error ("bad_count.dae",   "count",               "refuse: an array whose count disagrees with its values");
   expect_Error ("no_mesh.dae",     "no mesh",             "refuse: a geometry without a mesh");
   expect_Error ("lookat.dae",      "lookat",              "refuse: a lookat transform");
   expect_Error ("no_id.dae",       "no 'id' attribute",   "refuse: a geometry without an id");
   expect_Error ("int_array.dae",   "int_array",           "refuse: an int_array source");


   ada.Directories.delete_Tree (Root);

   new_Line;

   if Failures = 0
   then
      put_Line ("Success");
   else
      put_Line ("Failures:" & Failures'Image);
      ada.Command_Line.set_Exit_Status (1);
   end if;

   put_Line ("End Test");
end test_collada_Regression;
