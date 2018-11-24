with Board;

package Reports is
   
   GAMES_TO_PLAY : constant := 100;
      
   type Games is range 0..GAMES_TO_PLAY;
   
   type Game_Number is range 1..GAMES_TO_PLAY;
      
   MAXIMUM_NUMBER_OF_TURNS : constant := 30;
   
   type Turns is range 0..MAXIMUM_NUMBER_OF_TURNS;   

   procedure Record_Start(Player:Board.Players);
                
   procedure Record_Win(Player:Board.Players);
   
   procedure Record_Turn(Turn:Turns); 
   
   procedure Print;

end Reports;
