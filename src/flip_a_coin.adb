with Ada.Numerics.Discrete_Random;

package body Flip_A_Coin is
   
   package Random_Coin is new Ada.Numerics.Discrete_Random(Coin);
   
   G: Random_Coin.Generator;
   
procedure Reset is
   
begin
   
      Random_Coin.Reset(G);
      
end Reset;
   
function Flip
   return Coin is
      
begin
      
   return Random_Coin.Random(G);
      
   end Flip;
   
begin
   
   Reset;
   
end Flip_A_Coin;
