with Board;

package AI is

   type AI_Types is (
                     BEST, 
                     WORST,
                     RANDOM );
   
   function Turn(
                 AI : AI_Types;
                 Player:Board.Players)
                 return Boolean;

end AI;
