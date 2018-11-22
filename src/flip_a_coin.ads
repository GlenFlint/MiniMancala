package Flip_A_Coin is

   type Coin is (HEADS, TAILS);

   procedure Reset;

   function Flip
     return Coin;

end Flip_A_Coin;
