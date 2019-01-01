with Board;

package AI is

   type AI_Types is (
                     BEST, 
                     WORST,
                     RANDOM );
   
   function Turn(
                 AI : in AI_Types;
                 Player : in Board.Players)
                 return Boolean;
   
   function Turn(
                 Cup_To_Empty : in Board.Hands;
                 Player : in Board.Players)
                 return Boolean;

end AI;
