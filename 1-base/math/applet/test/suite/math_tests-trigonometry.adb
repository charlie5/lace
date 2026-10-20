with
     Ahven,

     cached_Trigonometry,

     ada.Numerics.generic_elementary_Functions,
     ada.Exceptions;


package body math_Tests.Trigonometry
--
-- Tests 'cached_Trigonometry' at the slot count which 'any_math.any_fast_Trigonometry' uses,
-- for both precisions the package is instantiated at and for both settings of 'prefer_Cache'.
--
-- Every instance is made inside a nested block, so that an exception raised while it elaborates
-- is reported as a failed test rather than ending the whole suite before any test has run.
--
is
   use Ahven;

   slot_Count : constant := 10_000;     -- As 'any_math.any_fast_Trigonometry' instantiates it.


   function unusable (Precision : in String;
                      E         : in ada.Exceptions.exception_Occurrence) return String
   is (  "cached_Trigonometry is unusable at " & Precision & " ~ "
       & ada.Exceptions.exception_Name    (E) & " ~ "
       & ada.Exceptions.exception_Message (E));



   ----------
   --- Checks
   --
   -- The same checks, run at whichever precision they are instantiated for.
   --

   generic
      type Real is digits <>;

   package Checks
   is
      procedure elaboration     (Precision : in String);
      procedure cos_and_sin     (Precision : in String);
      procedure large_angles    (Precision : in String);
      procedure the_Pair        (Precision : in String);
      procedure revolutions     (Precision : in String);
      procedure tangent         (Precision : in String);
      procedure arc_functions   (Precision : in String);
      procedure coarse_arc_ends (Precision : in String);
      procedure clamped_ratios  (Precision : in String);
      procedure least_slots     (Precision : in String);
      procedure library_path    (Precision : in String);
      procedure defaulted       (Precision : in String);
   end Checks;



   package body Checks
   is
      package Fn is new ada.Numerics.generic_elementary_Functions (Real);

      Pi     : constant Real := ada.Numerics.Pi;
      Pi_x_2 : constant Real := 2.0 * Pi;

      type Reals    is array (Positive range <>) of Real;
      type Naturals is array (Positive range <>) of Natural;


      function cos_Tolerance (Angle : in Real) return Real
      is (  Pi / Real (slot_Count)                  -- Half a slot: the lookup takes the nearest.
          + 4.0 * Pi_x_2 * Real'Model_Epsilon       -- The sampled angle carries its own rounding.
          + abs Angle * Real'Model_Epsilon);        -- Reducing a large angle rounds away this much.

      mid_arc_Limit : constant Real := 0.99;

      mid_arc_Tolerance : constant Real
        :=   (1.0 / Real (slot_Count - 1))                            -- Half a ratio slot,
           / Fn.SqRt (1.0 - mid_arc_Limit * mid_arc_Limit)            -- times the steepest gradient
           * 1.05;                                                    -- within the limit.

      coarse_arc_Tolerance : constant Real := Fn.SqRt (2.0 / Real (slot_Count - 1)) * 1.01;
      --
      -- Towards either end, 'arcCos (1.0 - d)' goes as 'SqRt (2.0 * d)', so half a ratio slot
      -- of error in the ratio becomes this much error in the angle.



      procedure elaboration (Precision : in String)
      --
      -- The package can be instantiated and used at all.
      --
      is
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            assert (abs (Trig.Cos (0.0) - 1.0) <= cos_Tolerance (0.0),
                    Precision & ": Cos (0.0) =" & Trig.Cos (0.0)'Image
                    & ", expected 1.0 ... failed !");
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end elaboration;



      procedure cos_and_sin (Precision : in String)
      --
      -- Cos and Sin come within half a slot of the library, across a revolution either side
      -- of zero.
      --
      is
         Steps : constant := 720;
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle : constant Real := Real (i) / Real (Steps) * Pi_x_2;
               begin
                  assert (abs (Trig.Cos (Angle) - Fn.Cos (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                          & ", expected" & Fn.Cos (Angle)'Image & " ... failed !");

                  assert (abs (Trig.Sin (Angle) - Fn.Sin (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Sin" & Angle'Image & " =" & Trig.Sin (Angle)'Image
                          & ", expected" & Fn.Sin (Angle)'Image & " ... failed !");
               end;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end cos_and_sin;



      procedure large_angles (Precision : in String)
      --
      -- An angle carrying many revolutions is still answered, and to the accuracy its own
      -- representation allows. Past that, the answer is at least a cosine.
      --
      is
         Steps  : constant := 2_000;
         Beyond : constant Reals := [1.0e4, 1.0e5];
         Far    : constant Reals := [1.0e6, 2.0e6, 1.0e9];
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle : constant Real := Real (i) / Real (Steps) * 1_000.0;
               begin
                  assert (abs (Trig.Cos (Angle) - Fn.Cos (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                          & ", expected" & Fn.Cos (Angle)'Image & " ... failed !");

                  assert (abs (Trig.Sin (Angle) - Fn.Sin (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Sin" & Angle'Image & " =" & Trig.Sin (Angle)'Image
                          & ", expected" & Fn.Sin (Angle)'Image & " ... failed !");
               end;
            end loop;

            for Angle of Beyond
            loop
               assert (abs (Trig.Cos (Angle) - Fn.Cos (Angle)) <= cos_Tolerance (Angle),
                       Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                       & ", expected" & Fn.Cos (Angle)'Image & " ... failed !");
            end loop;

            for Angle of Far
            loop
               assert (abs (Trig.Cos (Angle)) <= 1.0,
                       Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                       & ", which is not a cosine ... failed !");

               assert (abs (Trig.Sin (Angle)) <= 1.0,
                       Precision & ": Sin" & Angle'Image & " =" & Trig.Sin (Angle)'Image
                       & ", which is not a sine ... failed !");
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end large_angles;



      procedure the_Pair (Precision : in String)
      --
      -- 'get' answers the very same pair as Cos and Sin, so that an angle has one cosine
      -- however it is asked for.
      --
      is
         Steps : constant := 720;
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle   : constant Real := Real (i) / Real (Steps) * Pi_x_2;
                  the_Cos : Real;
                  the_Sin : Real;
               begin
                  Trig.get (Angle, the_Cos, the_Sin);

                  assert (the_Cos = Trig.Cos (Angle),
                          Precision & ": get" & Angle'Image & " gave a cos of" & the_Cos'Image
                          & ", but Cos gave" & Trig.Cos (Angle)'Image & " ... failed !");

                  assert (the_Sin = Trig.Sin (Angle),
                          Precision & ": get" & Angle'Image & " gave a sin of" & the_Sin'Image
                          & ", but Sin gave" & Trig.Sin (Angle)'Image & " ... failed !");
               end;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end the_Pair;



      procedure revolutions (Precision : in String)
      --
      -- Sin and Cos are periodic, so adding whole revolutions must not change the answer.
      --
      is
         Angles : constant Reals    := [0.5, 1.0, 2.0, 4.0];
         Turns  : constant Naturals := [1, 10, 100, 1_000];
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for Angle of Angles
            loop
               for R of Turns
               loop
                  declare
                     Turned : constant Real := Angle + Real (R) * Pi_x_2;
                  begin
                     assert (   abs (Trig.Cos (Turned) - Trig.Cos (Angle))
                             <= cos_Tolerance (Turned),
                             Precision & ": Cos" & Angle'Image & " after" & R'Image
                             & " revolutions =" & Trig.Cos (Turned)'Image
                             & ", expected" & Trig.Cos (Angle)'Image & " ... failed !");

                     assert (   abs (Trig.Sin (Turned) - Trig.Sin (Angle))
                             <= cos_Tolerance (Turned),
                             Precision & ": Sin" & Angle'Image & " after" & R'Image
                             & " revolutions =" & Trig.Sin (Turned)'Image
                             & ", expected" & Trig.Sin (Angle)'Image & " ... failed !");
                  end;
               end loop;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end revolutions;



      procedure tangent (Precision : in String)
      --
      -- Tan is the library's own answer, exactly. A pole falls between two slots, where the
      -- tangent changes sign and grows without bound, so no table can serve it.
      --
      is
         Steps : constant := 720;
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle : constant Real := Real (i) / Real (Steps) * Pi_x_2;
               begin
                  assert (Trig.Tan (Angle) = Fn.Tan (Angle),
                          Precision & ": Tan" & Angle'Image & " =" & Trig.Tan (Angle)'Image
                          & ", expected the library's" & Fn.Tan (Angle)'Image & " ... failed !");
               end;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end tangent;



      procedure arc_functions (Precision : in String)
      --
      -- arcCos and arcSin answer the angle of the given ratio, across all but the last hundredth
      -- at either end, where they steepen without bound and 'coarse_arc_ends' takes over.
      --
      is
         Ends : constant Reals := [1.0, 0.5, 0.0, -0.5, -1.0];
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for Ratio of Ends
            loop
               assert (abs (Trig.arcCos (Ratio) - Fn.arcCos (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                       & ", expected" & Fn.arcCos (Ratio)'Image & " ... failed !");

               assert (abs (Trig.arcSin (Ratio) - Fn.arcSin (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                       & ", expected" & Fn.arcSin (Ratio)'Image & " ... failed !");
            end loop;

            for i in -9_900 .. 9_900
            loop
               declare
                  Ratio : constant Real := Real (i) / 10_000.0;
               begin
                  assert (abs (Trig.arcCos (Ratio) - Fn.arcCos (Ratio)) <= mid_arc_Tolerance,
                          Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                          & ", expected" & Fn.arcCos (Ratio)'Image & " ... failed !");

                  assert (abs (Trig.arcSin (Ratio) - Fn.arcSin (Ratio)) <= mid_arc_Tolerance,
                          Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                          & ", expected" & Fn.arcSin (Ratio)'Image & " ... failed !");
               end;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end arc_functions;



      procedure coarse_arc_ends (Precision : in String)
      --
      -- The last hundredth at either end of the ratio range is the package's coarsest corner.
      -- It is held to the bound the sampling implies, so that it cannot quietly worsen.
      --
      is
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for i in 9_900 .. 10_000
            loop
               for Sign in 1 .. 2
               loop
                  declare
                     Ratio : constant Real := (if Sign = 1 then  Real (i) / 10_000.0
                                                           else -Real (i) / 10_000.0);
                  begin
                     assert (   abs (Trig.arcCos (Ratio) - Fn.arcCos (Ratio))
                             <= coarse_arc_Tolerance,
                             Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                             & ", expected" & Fn.arcCos (Ratio)'Image & " ... failed !");

                     assert (   abs (Trig.arcSin (Ratio) - Fn.arcSin (Ratio))
                             <= coarse_arc_Tolerance,
                             Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                             & ", expected" & Fn.arcSin (Ratio)'Image & " ... failed !");
                  end;
               end loop;
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end coarse_arc_ends;



      procedure clamped_ratios (Precision : in String)
      --
      -- A ratio beyond -1.0 .. 1.0 is clamped to that end, not refused: the usual caller is a
      -- normalised dot product, which rounding can carry a little past either end.
      --
      is
         Beyond : constant Reals := [1.000_001, 1.5, 2.0, 1.0e6];
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => True);
         begin
            for Ratio of Beyond
            loop
               assert (Trig.arcCos (Ratio) = Trig.arcCos (1.0),
                       Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                       & ", expected that of 1.0," & Trig.arcCos (1.0)'Image & " ... failed !");

               assert (Trig.arcCos (-Ratio) = Trig.arcCos (-1.0),
                       Precision & ": arcCos" & Real'Image (-Ratio) & " ="
                       & Trig.arcCos (-Ratio)'Image & ", expected that of -1.0,"
                       & Trig.arcCos (-1.0)'Image & " ... failed !");

               assert (Trig.arcSin (Ratio) = Trig.arcSin (1.0),
                       Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                       & ", expected that of 1.0," & Trig.arcSin (1.0)'Image & " ... failed !");

               assert (Trig.arcSin (-Ratio) = Trig.arcSin (-1.0),
                       Precision & ": arcSin" & Real'Image (-Ratio) & " ="
                       & Trig.arcSin (-Ratio)'Image & ", expected that of -1.0,"
                       & Trig.arcSin (-1.0)'Image & " ... failed !");
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end clamped_ratios;



      procedure least_slots (Precision : in String)
      --
      -- Two slots is the fewest the spec allows, and it still elaborates and answers.
      --
      is
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => 2,
                                                     prefer_Cache => True);
         begin
            assert (abs (Trig.Cos (0.0)) <= 1.0 and then abs (Trig.Sin (0.0)) <= 1.0,
                    Precision & ": two slots gave Cos" & Trig.Cos (0.0)'Image
                    & " and Sin" & Trig.Sin (0.0)'Image & " ... failed !");

            assert (Trig.arcCos (1.0) = Fn.arcCos (1.0),
                    Precision & ": two slots gave arcCos (1.0) =" & Trig.arcCos (1.0)'Image
                    & ", expected" & Fn.arcCos (1.0)'Image & " ... failed !");

            assert (Trig.arcCos (-1.0) = Fn.arcCos (-1.0),
                    Precision & ": two slots gave arcCos (-1.0) =" & Trig.arcCos (-1.0)'Image
                    & ", expected" & Fn.arcCos (-1.0)'Image & " ... failed !");
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end least_slots;



      procedure library_path (Precision : in String)
      --
      -- Given 'prefer_Cache' as False, Cos, Sin and 'get' are the library's own answers,
      -- exactly, while arcCos and arcSin still come from their table.
      --
      is
         Steps : constant := 360;
         Ends  : constant Reals := [1.0, 0.5, 0.0, -0.5, -1.0];
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type   => Real,
                                                     slot_Count   => slot_Count,
                                                     prefer_Cache => False);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle   : constant Real := Real (i) / Real (Steps) * Pi_x_2;
                  the_Cos : Real;
                  the_Sin : Real;
               begin
                  assert (Trig.Cos (Angle) = Fn.Cos (Angle),
                          Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                          & ", expected the library's" & Fn.Cos (Angle)'Image & " ... failed !");

                  assert (Trig.Sin (Angle) = Fn.Sin (Angle),
                          Precision & ": Sin" & Angle'Image & " =" & Trig.Sin (Angle)'Image
                          & ", expected the library's" & Fn.Sin (Angle)'Image & " ... failed !");

                  Trig.get (Angle, the_Cos, the_Sin);

                  assert (the_Cos = Fn.Cos (Angle) and then the_Sin = Fn.Sin (Angle),
                          Precision & ": get" & Angle'Image
                          & " answers a different pair from the library ... failed !");
               end;
            end loop;

            for Ratio of Ends
            loop
               assert (abs (Trig.arcCos (Ratio) - Fn.arcCos (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                       & ", expected" & Fn.arcCos (Ratio)'Image & " ... failed !");

               assert (abs (Trig.arcSin (Ratio) - Fn.arcSin (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                       & ", expected" & Fn.arcSin (Ratio)'Image & " ... failed !");
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end library_path;



      procedure defaulted (Precision : in String)
      --
      -- The form the project itself instantiates, taking 'prefer_Cache' from its default.
      -- Whichever path that selects, the answers hold to the table's bound, 'get' still agrees
      -- with Cos and Sin, and the inverse pair still comes from its table.
      --
      -- The expectation below deliberately restates the spec's rule, so that changing one
      -- without the other is caught here rather than in a caller.
      --
      is
         Steps        : constant := 720;
         expect_Cache : constant Boolean := Real'Digits > 10;
         Ends         : constant Reals   := [1.0, 0.5, 0.0, -0.5, -1.0];

         exact_Everywhere : Boolean := True;
      begin
         declare
            package Trig is new cached_Trigonometry (Float_type => Real,
                                                     slot_Count => slot_Count);
         begin
            for i in -Steps .. Steps
            loop
               declare
                  Angle   : constant Real := Real (i) / Real (Steps) * Pi_x_2;
                  the_Cos : Real;
                  the_Sin : Real;
               begin
                  assert (abs (Trig.Cos (Angle) - Fn.Cos (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Cos" & Angle'Image & " =" & Trig.Cos (Angle)'Image
                          & ", expected" & Fn.Cos (Angle)'Image & " ... failed !");

                  assert (abs (Trig.Sin (Angle) - Fn.Sin (Angle)) <= cos_Tolerance (Angle),
                          Precision & ": Sin" & Angle'Image & " =" & Trig.Sin (Angle)'Image
                          & ", expected" & Fn.Sin (Angle)'Image & " ... failed !");

                  Trig.get (Angle, the_Cos, the_Sin);

                  assert (the_Cos = Trig.Cos (Angle) and then the_Sin = Trig.Sin (Angle),
                          Precision & ": get" & Angle'Image
                          & " answers a different pair from Cos and Sin ... failed !");

                  if Trig.Cos (Angle) /= Fn.Cos (Angle) or else Trig.Sin (Angle) /= Fn.Sin (Angle)
                  then
                     exact_Everywhere := False;
                  end if;
               end;
            end loop;

            assert (exact_Everywhere = not expect_Cache,
                    Precision & ": the default chose the "
                    & (if exact_Everywhere then "library" else "table")
                    & ", where its rule implies the "
                    & (if expect_Cache then "table" else "library") & " ... failed !");

            assert (Trig.Tan (0.5) = Fn.Tan (0.5),
                    Precision & ": Tan (0.5) =" & Trig.Tan (0.5)'Image
                    & ", expected the library's" & Fn.Tan (0.5)'Image & " ... failed !");

            for Ratio of Ends
            loop
               assert (abs (Trig.arcCos (Ratio) - Fn.arcCos (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcCos" & Ratio'Image & " =" & Trig.arcCos (Ratio)'Image
                       & ", expected" & Fn.arcCos (Ratio)'Image & " ... failed !");

               assert (abs (Trig.arcSin (Ratio) - Fn.arcSin (Ratio)) <= mid_arc_Tolerance,
                       Precision & ": arcSin" & Ratio'Image & " =" & Trig.arcSin (Ratio)'Image
                       & ", expected" & Fn.arcSin (Ratio)'Image & " ... failed !");
            end loop;
         end;

      exception
         when E : ada.Numerics.Argument_Error | Constraint_Error =>
            assert (False, unusable (Precision, E));
      end defaulted;

   end Checks;



   package float_Checks is new Checks (standard.Float);
   package  long_Checks is new Checks (standard.long_Float);



   procedure elaboration_Test
   is
   begin
      float_Checks.elaboration ("Float");
      long_Checks .elaboration ("Long_Float");
   end elaboration_Test;


   procedure cos_and_sin_Test
   is
   begin
      float_Checks.cos_and_sin ("Float");
      long_Checks .cos_and_sin ("Long_Float");
   end cos_and_sin_Test;


   procedure large_angle_Test
   is
   begin
      float_Checks.large_angles ("Float");
      long_Checks .large_angles ("Long_Float");
   end large_angle_Test;


   procedure get_Test
   is
   begin
      float_Checks.the_Pair ("Float");
      long_Checks .the_Pair ("Long_Float");
   end get_Test;


   procedure revolution_Test
   is
   begin
      float_Checks.revolutions ("Float");
      long_Checks .revolutions ("Long_Float");
   end revolution_Test;


   procedure tan_Test
   is
   begin
      float_Checks.tangent ("Float");
      long_Checks .tangent ("Long_Float");
   end tan_Test;


   procedure arc_Test
   is
   begin
      float_Checks.arc_functions ("Float");
      long_Checks .arc_functions ("Long_Float");
   end arc_Test;


   procedure coarse_arc_Test
   is
   begin
      float_Checks.coarse_arc_ends ("Float");
      long_Checks .coarse_arc_ends ("Long_Float");
   end coarse_arc_Test;


   procedure clamped_ratio_Test
   is
   begin
      float_Checks.clamped_ratios ("Float");
      long_Checks .clamped_ratios ("Long_Float");
   end clamped_ratio_Test;


   procedure least_slots_Test
   is
   begin
      float_Checks.least_slots ("Float");
      long_Checks .least_slots ("Long_Float");
   end least_slots_Test;


   procedure library_path_Test
   is
   begin
      float_Checks.library_path ("Float");
      long_Checks .library_path ("Long_Float");
   end library_path_Test;



   procedure default_Test
   is
   begin
      float_Checks.defaulted ("Float");
      long_Checks .defaulted ("Long_Float");
   end default_Test;



   overriding
   procedure initialize (T : in out Test)
   is
   begin
      T.set_Name ("Trigonometry Tests");

      Framework.add_test_Routine (T, elaboration_Test  'Access, "Elaboration Test");
      Framework.add_test_Routine (T, cos_and_sin_Test  'Access, "Cos and Sin Test");
      Framework.add_test_Routine (T, large_angle_Test  'Access, "Large angle Test");
      Framework.add_test_Routine (T, get_Test          'Access, "Get Test");
      Framework.add_test_Routine (T, revolution_Test   'Access, "Revolution Test");
      Framework.add_test_Routine (T, tan_Test          'Access, "Tan Test");
      Framework.add_test_Routine (T, arc_Test          'Access, "Arc functions Test");
      Framework.add_test_Routine (T, coarse_arc_Test   'Access, "Coarse arc ends Test");
      Framework.add_test_Routine (T, clamped_ratio_Test'Access, "Clamped ratios Test");
      Framework.add_test_Routine (T, least_slots_Test  'Access, "Least slots Test");
      Framework.add_test_Routine (T, library_path_Test 'Access, "Library path Test");
      Framework.add_test_Routine (T, default_Test       'Access, "Default instantiation Test");
   end initialize;


end math_Tests.Trigonometry;
