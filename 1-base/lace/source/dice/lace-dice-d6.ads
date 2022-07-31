package lace.Dice.d6
--
-- Models 6 sided dice.
--
is
   type Item is new Dice.item with private;



   procedure Seed_is (Now : Integer);
   --
   -- If the seed is not set, a random seed will be used.



   -- Forge
   --

   function to_Dice (Rolls    : in Positive := 3;
                     Modifier : in Integer  := 0) return Dice.d6.item;



   -- Attributes
   --

   overriding
   function  side_Count (Self : in Item) return Positive;

   overriding
   function  Roll       (Self : in Item) return Natural;



   -- Stock Dice
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



private

   type Item is new Dice.item with
      record
         null;
      end record;


   d6x1_less5 : aliased constant d6.Item := (roll_count => 1,   modifier => -5);
   d6x1_less4 : aliased constant d6.Item := (roll_count => 1,   modifier => -4);
   d6x1_less3 : aliased constant d6.Item := (roll_count => 1,   modifier => -3);
   d6x1_less2 : aliased constant d6.Item := (roll_count => 1,   modifier => -2);
   d6x1_less1 : aliased constant d6.Item := (roll_count => 1,   modifier => -1);
   d6x1       : aliased constant d6.Item := (roll_count => 1,   modifier =>  0);
   d6x1_plus1 : aliased constant d6.Item := (roll_count => 1,   modifier =>  1);
   d6x1_plus2 : aliased constant d6.Item := (roll_count => 1,   modifier =>  2);

   d6x2_less1 : aliased constant d6.Item := (roll_count => 2,   modifier => -1);
   d6x2       : aliased constant d6.Item := (roll_count => 2,   modifier =>  0);
   d6x2_plus1 : aliased constant d6.Item := (roll_count => 2,   modifier =>  1);
   d6x2_plus2 : aliased constant d6.Item := (roll_count => 2,   modifier =>  2);

   d6x3_less1 : aliased constant d6.Item := (roll_count => 3,   modifier => -1);
   d6x3       : aliased constant d6.Item := (roll_count => 3,   modifier =>  0);
   d6x3_plus1 : aliased constant d6.Item := (roll_count => 3,   modifier =>  1);
   d6x3_plus2 : aliased constant d6.Item := (roll_count => 3,   modifier =>  2);

   d6x4_less1 : aliased constant d6.Item := (roll_count => 4,   modifier => -1);
   d6x4       : aliased constant d6.Item := (roll_count => 4,   modifier =>  0);
   d6x4_plus1 : aliased constant d6.Item := (roll_count => 4,   modifier =>  1);
   d6x4_plus2 : aliased constant d6.Item := (roll_count => 4,   modifier =>  2);

   d6x5_less1 : aliased constant d6.Item := (roll_count => 5,   modifier => -1);
   d6x5       : aliased constant d6.Item := (roll_count => 5,   modifier =>  0);
   d6x5_plus1 : aliased constant d6.Item := (roll_count => 5,   modifier =>  1);
   d6x5_plus2 : aliased constant d6.Item := (roll_count => 5,   modifier =>  2);

   d6x6_less1 : aliased constant d6.Item := (roll_count => 6,   modifier => -1);
   d6x6       : aliased constant d6.Item := (roll_count => 6,   modifier =>  0);
   d6x6_plus1 : aliased constant d6.Item := (roll_count => 6,   modifier =>  1);
   d6x6_plus2 : aliased constant d6.Item := (roll_count => 6,   modifier =>  2);

   d6x7_less1 : aliased constant d6.Item := (roll_count => 7,   modifier => -1);
   d6x7       : aliased constant d6.Item := (roll_count => 7,   modifier =>  0);
   d6x7_plus1 : aliased constant d6.Item := (roll_count => 7,   modifier =>  1);
   d6x7_plus2 : aliased constant d6.Item := (roll_count => 7,   modifier =>  2);

   d6x8_less1 : aliased constant d6.Item := (roll_count => 8,   modifier => -1);
   d6x8       : aliased constant d6.Item := (roll_count => 8,   modifier =>  0);
   d6x8_plus1 : aliased constant d6.Item := (roll_count => 8,   modifier =>  1);
   d6x8_plus2 : aliased constant d6.Item := (roll_count => 8,   modifier =>  2);

end lace.Dice.d6;

