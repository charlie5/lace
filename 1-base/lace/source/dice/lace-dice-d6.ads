package lace.Dice.d6
--
-- Models 6 sided dice.
--
is
   type Item is new Dice.item with private;


   ---------
   --- Forge
   --

   function to_Dice (Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.d6.item;


   --------------
   --- Attributes
   --

   overriding
   function side_Count (Self : in Item) return Positive;

   overriding
   function Roll       (Self : in Item) return Natural;


   --------------
   --- Operations
   --

   procedure Seed_is (Now : in Integer);
   --
   -- If the seed is not set, a random seed will be used.


   --------------
   --- Stock Dice
   --

   d6x1_less5 : aliased constant d6.Item;
   d6x1_less4 : aliased constant d6.Item;
   d6x1_less3 : aliased constant d6.Item;
   d6x1_less2 : aliased constant d6.Item;
   d6x1_less1 : aliased constant d6.Item;
   d6x1       : aliased constant d6.Item;
   d6x1_plus1 : aliased constant d6.Item;
   d6x1_plus2 : aliased constant d6.Item;

   d6x2_less1 : aliased constant d6.Item;
   d6x2       : aliased constant d6.Item;
   d6x2_plus1 : aliased constant d6.Item;
   d6x2_plus2 : aliased constant d6.Item;

   d6x3_less1 : aliased constant d6.Item;
   d6x3       : aliased constant d6.Item;
   d6x3_plus1 : aliased constant d6.Item;
   d6x3_plus2 : aliased constant d6.Item;

   d6x4_less1 : aliased constant d6.Item;
   d6x4       : aliased constant d6.Item;
   d6x4_plus1 : aliased constant d6.Item;
   d6x4_plus2 : aliased constant d6.Item;

   d6x5_less1 : aliased constant d6.Item;
   d6x5       : aliased constant d6.Item;
   d6x5_plus1 : aliased constant d6.Item;
   d6x5_plus2 : aliased constant d6.Item;

   d6x6_less1 : aliased constant d6.Item;
   d6x6       : aliased constant d6.Item;
   d6x6_plus1 : aliased constant d6.Item;
   d6x6_plus2 : aliased constant d6.Item;

   d6x7_less1 : aliased constant d6.Item;
   d6x7       : aliased constant d6.Item;
   d6x7_plus1 : aliased constant d6.Item;
   d6x7_plus2 : aliased constant d6.Item;

   d6x8_less1 : aliased constant d6.Item;
   d6x8       : aliased constant d6.Item;
   d6x8_plus1 : aliased constant d6.Item;
   d6x8_plus2 : aliased constant d6.Item;

   d6x9_less1 : aliased constant d6.Item;
   d6x9       : aliased constant d6.Item;
   d6x9_plus1 : aliased constant d6.Item;
   d6x9_plus2 : aliased constant d6.Item;

   d6x10_less1 : aliased constant d6.Item;
   d6x10       : aliased constant d6.Item;
   d6x10_plus1 : aliased constant d6.Item;
   d6x10_plus2 : aliased constant d6.Item;

   d6x11_less1 : aliased constant d6.Item;
   d6x11       : aliased constant d6.Item;
   d6x11_plus1 : aliased constant d6.Item;
   d6x11_plus2 : aliased constant d6.Item;

   d6x12_less1 : aliased constant d6.Item;
   d6x12       : aliased constant d6.Item;
   d6x12_plus1 : aliased constant d6.Item;
   d6x12_plus2 : aliased constant d6.Item;



private

   type Item is new Dice.item with
      record
         null;
      end record;


   d6x1_less5 : aliased constant d6.Item := (roll_Count => 1,   Modifier => -5);
   d6x1_less4 : aliased constant d6.Item := (roll_Count => 1,   Modifier => -4);
   d6x1_less3 : aliased constant d6.Item := (roll_Count => 1,   Modifier => -3);
   d6x1_less2 : aliased constant d6.Item := (roll_Count => 1,   Modifier => -2);
   d6x1_less1 : aliased constant d6.Item := (roll_Count => 1,   Modifier => -1);
   d6x1       : aliased constant d6.Item := (roll_Count => 1,   Modifier =>  0);
   d6x1_plus1 : aliased constant d6.Item := (roll_Count => 1,   Modifier =>  1);
   d6x1_plus2 : aliased constant d6.Item := (roll_Count => 1,   Modifier =>  2);

   d6x2_less1 : aliased constant d6.Item := (roll_Count => 2,   Modifier => -1);
   d6x2       : aliased constant d6.Item := (roll_Count => 2,   Modifier =>  0);
   d6x2_plus1 : aliased constant d6.Item := (roll_Count => 2,   Modifier =>  1);
   d6x2_plus2 : aliased constant d6.Item := (roll_Count => 2,   Modifier =>  2);

   d6x3_less1 : aliased constant d6.Item := (roll_Count => 3,   Modifier => -1);
   d6x3       : aliased constant d6.Item := (roll_Count => 3,   Modifier =>  0);
   d6x3_plus1 : aliased constant d6.Item := (roll_Count => 3,   Modifier =>  1);
   d6x3_plus2 : aliased constant d6.Item := (roll_Count => 3,   Modifier =>  2);

   d6x4_less1 : aliased constant d6.Item := (roll_Count => 4,   Modifier => -1);
   d6x4       : aliased constant d6.Item := (roll_Count => 4,   Modifier =>  0);
   d6x4_plus1 : aliased constant d6.Item := (roll_Count => 4,   Modifier =>  1);
   d6x4_plus2 : aliased constant d6.Item := (roll_Count => 4,   Modifier =>  2);

   d6x5_less1 : aliased constant d6.Item := (roll_Count => 5,   Modifier => -1);
   d6x5       : aliased constant d6.Item := (roll_Count => 5,   Modifier =>  0);
   d6x5_plus1 : aliased constant d6.Item := (roll_Count => 5,   Modifier =>  1);
   d6x5_plus2 : aliased constant d6.Item := (roll_Count => 5,   Modifier =>  2);

   d6x6_less1 : aliased constant d6.Item := (roll_Count => 6,   Modifier => -1);
   d6x6       : aliased constant d6.Item := (roll_Count => 6,   Modifier =>  0);
   d6x6_plus1 : aliased constant d6.Item := (roll_Count => 6,   Modifier =>  1);
   d6x6_plus2 : aliased constant d6.Item := (roll_Count => 6,   Modifier =>  2);

   d6x7_less1 : aliased constant d6.Item := (roll_Count => 7,   Modifier => -1);
   d6x7       : aliased constant d6.Item := (roll_Count => 7,   Modifier =>  0);
   d6x7_plus1 : aliased constant d6.Item := (roll_Count => 7,   Modifier =>  1);
   d6x7_plus2 : aliased constant d6.Item := (roll_Count => 7,   Modifier =>  2);

   d6x8_less1 : aliased constant d6.Item := (roll_Count => 8,   Modifier => -1);
   d6x8       : aliased constant d6.Item := (roll_Count => 8,   Modifier =>  0);
   d6x8_plus1 : aliased constant d6.Item := (roll_Count => 8,   Modifier =>  1);
   d6x8_plus2 : aliased constant d6.Item := (roll_Count => 8,   Modifier =>  2);

   d6x9_less1 : aliased constant d6.Item := (roll_Count => 9,   Modifier => -1);
   d6x9       : aliased constant d6.Item := (roll_Count => 9,   Modifier =>  0);
   d6x9_plus1 : aliased constant d6.Item := (roll_Count => 9,   Modifier =>  1);
   d6x9_plus2 : aliased constant d6.Item := (roll_Count => 9,   Modifier =>  2);

   d6x10_less1 : aliased constant d6.Item := (roll_Count => 10,   Modifier => -1);
   d6x10       : aliased constant d6.Item := (roll_Count => 10,   Modifier =>  0);
   d6x10_plus1 : aliased constant d6.Item := (roll_Count => 10,   Modifier =>  1);
   d6x10_plus2 : aliased constant d6.Item := (roll_Count => 10,   Modifier =>  2);

   d6x11_less1 : aliased constant d6.Item := (roll_Count => 11,   Modifier => -1);
   d6x11       : aliased constant d6.Item := (roll_Count => 11,   Modifier =>  0);
   d6x11_plus1 : aliased constant d6.Item := (roll_Count => 11,   Modifier =>  1);
   d6x11_plus2 : aliased constant d6.Item := (roll_Count => 11,   Modifier =>  2);

   d6x12_less1 : aliased constant d6.Item := (roll_Count => 12,   Modifier => -1);
   d6x12       : aliased constant d6.Item := (roll_Count => 12,   Modifier =>  0);
   d6x12_plus1 : aliased constant d6.Item := (roll_Count => 12,   Modifier =>  1);
   d6x12_plus2 : aliased constant d6.Item := (roll_Count => 12,   Modifier =>  2);


end lace.Dice.d6;
