with Board;

package ai is

   type AI_Types is (
                     BEST, 
                     WORST,
                     RANDOM );
   
   function turn(
                 AI : AI_Types;
                 Player:Board.Players)
                 return Boolean;

end ai;
