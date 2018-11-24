with Text_IO;
with Ada.Strings.Fixed;     
with Ada.Numerics.Generic_Elementary_Functions;

package body Reports is
      
   type Game_Counters is array (Board.Players) of Games; 
      
   type Histogram_Of_Games_By_Turns is array(Turns) of Games;   
   
   Histogram_Of_Games_By_Turn : Histogram_Of_Games_By_Turns := (others => 0);
      
   Victory_Counter : Game_Counters := (                                          
                                                                                 Board.NORTH => 0,
                                                                                 Board.SOUTH => 0);
   
      
   Start_Counter : Game_Counters := (
                                     Board.NORTH => 0,
                                     Board.SOUTH => 0);  
      
   --------------------------------
   
   procedure Record_Start (
                           Player:Board.Players) is
      
   begin      
            
      Start_Counter(Player) := Start_Counter(Player) + 1;
      
   end Record_Start;
   
   ----------------------------------
   
   procedure Record_Turn(
                         Turn:Turns) is
      
   begin      
                     
      Histogram_Of_Games_By_Turn ( Turn ) := Histogram_Of_Games_By_Turn ( Turn ) + 1;
      
   end Record_Turn;
      
   -----------------------------------
   
   procedure Record_Win(
                        Player:Board.Players) is
      
   begin
      
      Victory_Counter(Player) := Victory_Counter(Player) + 1;
      
   end Record_Win;
      
   --------------------------------
   
      
   procedure Print is
                     
      type Turn_Index is delta 0.5 range 1.0..Float(MAXIMUM_NUMBER_OF_TURNS);   
         
      package Turn_Index_IO is new Text_IO.Fixed_IO ( Turn_Index );
   
      procedure Print_Wins is
      
         Drawn : Games := Games'Last;
      
      begin      
         
         Text_IO.Put_Line("That was quick");
      
         Text_IO.Put_Line("Player Starts Victories");
      
         for Player in Board.Players loop
         
            Text_IO.Put_Line(Board.Players'image (Player) &
                               "     " &
                               Games'Image(Start_Counter(Player)) &
                               "     " &
                               Games'Image(Victory_Counter(Player)));
         
            Drawn := Drawn - Victory_Counter(Player);
         
         end loop;
      
         Text_IO.Put_Line ( "Drawn            " & Games'Image ( Drawn ));
      
      end Print_Wins;
   
      ------------------
   
      package Turn_IO is new Text_IO.Integer_IO ( Turns );
   
      package Game_IO is new Text_IO.Integer_IO ( Games );
   
      procedure Print_Histogram is
            
         Frequency : Games;
      
      begin      
            
         for Turn in Turns loop
         
            Frequency := Histogram_Of_Games_By_Turn ( Turn );
         
            Turn_IO.put(Item => Turn,      Width => 4);
         
            Game_IO.Put(Item => Frequency, Width => 4);
         
            Text_IO.Put(" | ");
         
            if (Frequency > 0 ) then
            
               Text_IO.Put ( Ada.Strings.Fixed."*"(Integer ( Frequency ), '*' ));
            
            end if;
         
            Text_IO.New_Line;
         
         end loop;
      
      end Print_Histogram;
   
      ----------------------------------------------------
    
      procedure Print_Quartiles is
      
         type Game_Index is delta 0.5 range 1.0..Float(GAMES_TO_PLAY);
      
         function Find_Median(
                              First_Game:Game_Number;
                              Last_Game :Game_Number) 
                           return Game_Index is
                 
         begin
         
            return Game_Index(Float(First_Game + Last_Game) / 2.0);
         
         end Find_Median;     
      
         ----------------      
      
         function Find_Median(
                              Game:Game_Index) 
                           return Turn_Index is
               
            Frequency : Games;
               
            Cumulative_Games : Games := 0;
      
            Lower_Bound_Game : Games;
         
            Median_Turn : Turn_Index:= 1.0;

         begin               
      
            for Turn in Turns loop
         
               Frequency := Histogram_Of_Games_By_Turn ( Turn );
            
               if Frequency > 0 then
         
                  Lower_Bound_Game := Cumulative_Games + 1;
               
                  Cumulative_Games := Cumulative_Games + Frequency;
         
                  if Game_Index(Lower_Bound_Game) <= Game
                    and then Game_Index(Cumulative_Games) >= Game then
                
                     Median_Turn := Turn_Index( Turn );
               
                     exit;
                  
                  elsif Game < Game_Index ( Lower_Bound_Game ) then
                 
                     Median_Turn := Turn_Index ( Turn ) - 0.5;
               
                     exit;
             
                  end if; 
                            
               end if;
         
            end loop;
         
            return Median_Turn;
         
         end Find_Median;
      
         ----------
      
         type Quartiles is (MINIMUM, FIRST, MEDIAN, THIRD, MAXIMUM);
                  
         type Game_Quartiles is array (Quartiles) of Game_Index;
      
         Game_Quartile : Game_Quartiles;     
      
         Even_Number_Of_Games : Boolean := Games'Last mod 2 = 0;  
      
         First_Half_End       : Game_Number;
      
         Second_Half_Begin    : Game_Number;
            
         package Game_Index_IO is new Text_IO.Fixed_IO ( Game_Index );
      
         package Quartile_IO   is new Text_IO.Enumeration_IO ( Quartiles );
      
      begin
      
         Game_Quartile (MEDIAN) := Find_Median (Game_Number'First, Game_Number'Last);
      
         if (Even_Number_Of_Games) then
         
            Second_Half_Begin := Game_Number(Game_Quartile(MEDIAN)); -- rounds up
         
            First_Half_End    := Second_Half_Begin - 1;
         
         else
         
            First_Half_End    := Game_Number(Game_Quartile(MEDIAN)) - 1;
         
            Second_Half_Begin := First_Half_End + 2;  -- skip over the median
         
         end if;
      
         Game_Quartile (MINIMUM) := Game_Index'First;
            
         Game_Quartile (FIRST)   := Find_Median (Game_Number'First, First_Half_End);
      
         Game_Quartile (THIRD)   := Find_Median (Second_Half_Begin, Game_Number'Last);
      
         Game_Quartile (MAXIMUM) := Game_Index'Last;
      
         Text_IO.Put_Line("Quartile    Game Turn");
      
         for Quartile in Quartiles loop 
         
            Quartile_IO.Put(Quartile, Width => Quartiles'Width);
         
            Text_IO.Put(" : ");
         
            Game_Index_IO.Put(Item => Game_Quartile(Quartile), Aft => 1);
         
            Turn_Index_IO.Put(Item => Find_Median ( Game_Quartile ( Quartile ) ), Aft => 1);
                           
            Text_IO.New_Line;
         
         end loop;
                  
      end Print_Quartiles;
   
      ---------------------
   
      procedure Print_Statistics is
                                 
         MAXIMUM_TOTAL_TURNS : constant := MAXIMUM_NUMBER_OF_TURNS * GAMES_TO_PLAY;
   
         type Total_Possible_Turns is range 0..MAXIMUM_TOTAL_TURNS;
      
         type Total_Possible_Turns_Squared is range 0..MAXIMUM_TOTAL_TURNS * MAXIMUM_NUMBER_OF_TURNS;
      
         Number_Of_Games_This_Turn : Total_Possible_Turns;
      
         Total_Turns : Total_Possible_Turns := 0;

         Total_Turns_Squared : Total_Possible_Turns_Squared := 0;
      
         Frequency : Games;
      
         Mean : Turn_Index;         
       
         type Turn_Deviations is digits 12 range 1.0..Float( MAXIMUM_TOTAL_TURNS * MAXIMUM_TOTAL_TURNS );
         
         Standard_Deviation : Turn_Deviations;
         
         package Total_Possible_Turns_Squared_IO is new Text_IO.Integer_IO ( Total_Possible_Turns_Squared );
         
         package Turn_Deviation_Functions is new Ada.Numerics.Generic_Elementary_Functions ( Turn_Deviations );
         
         package Turn_Deviations_IO is new Text_IO.Float_IO ( Turn_Deviations );
      
      begin      
            
         for Turn in Turns loop
         
            Frequency := Histogram_Of_Games_By_Turn ( Turn );
         
            Number_Of_Games_This_Turn := 
              Total_Possible_Turns( Frequency ) * Total_Possible_Turns ( Turn );
         
            Total_Turns := Total_Turns + Number_Of_Games_This_Turn;
         
            Total_Turns_Squared := Total_Turns_Squared
              + Total_Possible_Turns_Squared ( Turn ) 
              * Total_Possible_Turns_Squared ( Number_Of_Games_This_Turn );
         
         end loop;
      
         Mean := Turn_Index ( Float ( Total_Turns ) / Float ( GAMES_TO_PLAY ) );
         
         Standard_Deviation := 
           Turn_Deviation_Functions.Sqrt ( ( Turn_Deviations(GAMES_TO_PLAY * Total_Turns_Squared)
                                            - Turn_Deviations ( Total_Turns * Total_Turns ) )
                                      / Turn_Deviations ( GAMES_TO_PLAY * ( GAMES_TO_PLAY - 1 ) ) );
         Text_IO.Put("Mean : ");
         Turn_Index_IO.Put ( Mean, Aft => 1);
         Text_IO.New_Line;
         
         Text_IO.Put("Standard Deviation : ");
         Turn_Deviations_IO.Put ( Standard_Deviation, Aft => 3, Exp => 0);
         Text_IO.New_Line;
         
      end Print_Statistics;
   
      --------------------------
      
   begin
              
      Print_Wins;
      
      Print_Histogram;
   
      Print_Quartiles;
      
      Print_Statistics;
      
   end Print;

end Reports;
