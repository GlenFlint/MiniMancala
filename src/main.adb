with Board;
with AI;
with Flip_A_Coin;
with Reports;

with Text_IO;

procedure Main is

   type Players_AI is array(Board.Players) of AI.AI_Types;

   Player_AI : Players_AI := (
                              Board.NORTH => AI.BEST,
                              Board.SOUTH => AI.RANDOM );

   type Random_Players is array (Flip_A_Coin.Coin) of Board.Players;

   Random_Player : Random_Players := (
                                      Flip_A_Coin.HEADS => Board.NORTH,
                                      Flip_A_Coin.TAILS => Board.SOUTH);

   type Other_Players is array (Board.Players) of Board.Players;

   Other_Player : Other_Players := (
                                    Board.NORTH => Board.SOUTH,
                                    Board.SOUTH => Board.NORTH);

   Player : Board.Players;

   Game_Continues : Boolean;

   Turn : Reports.Turns;

begin

   Text_IO.Put_Line("Let the games begin");

   for Game in Reports.Game_Number loop

      Board.Start_Game;

      Player := Random_Player ( Flip_A_Coin.Flip );

      Reports.Record_Start ( Player );

      Turn   := 0;

      loop

         Board.Print_Board;

         Game_Continues := AI.turn(
                                   AI => Player_AI(Player),
                                   Player => Player);

         Player := Other_Player ( Player );

         if (not Game_Continues) then

            Reports.Record_Win(Player);

            exit;

         elsif (Reports."<"(Turn, Reports.Turns'Last)) then

              Turn := Reports."+"(Turn, 1);

         else

            exit;  -- end in a draw

         end if;

      end loop;   -- end game

      Reports.Record_Turn(Turn);

      Board.Print_Board;

   end loop;  -- end all games

   Reports.Print;

end Main;
