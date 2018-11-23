with Board;
with AI;
with Flip_A_Coin;
with Ada.Strings.Fixed;

with Text_IO;

procedure Main is

   type Players_AI is array(Board.Players) of AI.AI_Types;

   Player_AI : Players_AI := (
                              Board.NORTH => AI.RANDOM,
                              Board.SOUTH => AI.RANDOM );


   GAMES_TO_PLAY : constant := 100;

   type Games is range 0..GAMES_TO_PLAY;

   type Game_Number is range 1..GAMES_TO_PLAY;

   type Game_Counters is array (Board.Players) of Games;

   Victory_Counter : Game_Counters := (
                                          Board.NORTH => 0,
                                          Board.SOUTH => 0);


   Start_Counter : Game_Counters := (
                                          Board.NORTH => 0,
                                          Board.SOUTH => 0);

   type Random_Players is array (Flip_A_Coin.Coin) of Board.Players;

   Random_Player : Random_Players := (
                                      Flip_A_Coin.HEADS => Board.NORTH,
                                      Flip_A_Coin.TAILS => Board.SOUTH);

   type Other_Players is array (Board.Players) of Board.Players;

   Other_Player : Other_Players := (
                                    Board.NORTH => Board.SOUTH,
                                    Board.SOUTH => Board.NORTH);

   MAXIMUM_NUMBER_OF_TURNS : constant := 30;

   type Turns is range 0..MAXIMUM_NUMBER_OF_TURNS;

   type Histogram_Of_Games_By_Turns is array(Turns) of Games;

   Histogram_Of_Games_By_Turn : Histogram_Of_Games_By_Turns := (others => 0);

   Player : Board.Players;

   Game_Continues : Boolean;

   Turn : Turns;

   --------------------------------

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

   procedure Print_Statistics is

      MAXIMUM_TOTAL_TURNS : constant := MAXIMUM_NUMBER_OF_TURNS * GAMES_TO_PLAY;

      type Total_Possible_Turns is range 0..MAXIMUM_TOTAL_TURNS;

      type Total_Possible_Turns_Squared is range 0..MAXIMUM_TOTAL_TURNS ** 2;

      Total_Turns : Total_Possible_Turns := 0;

      Index : Total_Possible_Turns := 0;

      Next_Index : Total_Possible_Turns;

      Total_Turns_Squared : Total_Possible_Turns_Squared := 0;

      Frequency : Games;

      Min : Turns := 0;

      Max : Turns;

      type Quartiles is digits 4 range 0.0..Float(MAXIMUM_NUMBER_OF_TURNS);

      Median : Games := Games'Last / 2;

      Whole_Remainder : Games := Games'Last mod 2;

      Half_Remainder  : Games := Median mod 2;

      First_Quartile  : Games := Median / 2;

      Third_Quartile  : Games := Median + First_Quartile + Whole_Remainder;

   begin

      for Turn in Turns loop

         Frequency := Histogram_Of_Games_By_Turn ( Turn );

         if (Frequency > 0) then

            if (Min = 0) then

               Min := Turn;

            end if;

            Max := Turn;

         end if;

         Turn_IO.put(Item => Turn,      Width => 4);

         Game_IO.Put(Item => Frequency, Width => 4);

         Text_IO.Put(" | ");

         if (Frequency > 0 ) then

            Text_IO.Put ( Ada.Strings.Fixed."*"(Integer ( Frequency ), '*' ));

         end if;

         Text_IO.New_Line;

      end loop;

   end Print_Statistics;

   ------------------------------------


begin

   Text_IO.Put_Line("Let the games begin");

   for Game in Game_Number loop

      Board.Start_Game;

      Player := Random_Player ( Flip_A_Coin.Flip );

      Start_Counter(Player) := Start_Counter(Player) + 1;
      Turn   := 0;

      loop

         Board.Print_Board;

         Game_Continues := AI.turn(
                                   AI => Player_AI(Player),
                                   Player => Player);

         Player := Other_Player ( Player );

         if (not Game_Continues) then

            Victory_Counter(Player) := Victory_Counter(Player) + 1;

            exit;

         elsif (Turn < Turns'Last) then

              Turn := Turn + 1;

         else

            exit;  -- end in a draw

         end if;

      end loop;   -- end game

      Histogram_Of_Games_By_Turn ( Turn ) := Histogram_Of_Games_By_Turn ( Turn ) + 1;

      Board.Print_Board;

   end loop;  -- end all games

   Print_Wins;

   Print_Statistics;

end Main;
