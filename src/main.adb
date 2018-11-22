with Board;
with AI;
with Flip_A_Coin;

with Text_IO;

procedure Main is

   type Players_AI is array(Board.Players) of AI.AI_Types;

   Player_AI : Players_AI := (
                              Board.NORTH => AI.WORST,
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

   MAXIMUM_NUMBER_OF_TURNS : constant := 30;

   type Turns is range 0..MAXIMUM_NUMBER_OF_TURNS;

   type Turn_Counters is array(Turns) of Natural;

   type Random_Players is array (Flip_A_Coin.Coin) of Board.Players;

   Random_Player : Random_Players := (
                                      Flip_A_Coin.HEADS => Board.NORTH,
                                      Flip_A_Coin.TAILS => Board.SOUTH);

   type Other_Players is array (Board.Players) of Board.Players;

   Other_Player : Other_Players := (
                                    Board.NORTH => Board.SOUTH,
                                    Board.SOUTH => Board.NORTH);

   Turn_Counter : Turn_Counters := (others => 0);

   Player : Board.Players;

   Game_Continues : Boolean;

   Turn : Turns;

   procedure Print_Statistics is

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

   end Print_Statistics;

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

      Turn_Counter ( Turn ) := Turn_Counter ( Turn ) + 1;

      Board.Print_Board;

   end loop;  -- end all games

   Print_Statistics;

end Main;
