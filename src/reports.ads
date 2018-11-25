with Board;

package Reports is

   procedure Record_Start(Player:Board.Players);
   
   function Record_Next_Turn
     return Boolean;
                
   procedure Record_Win(Player:Board.Players);
   
   function End_Of_Game
     return Boolean; 
   
   procedure Print;

end Reports;
