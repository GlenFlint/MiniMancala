with Flip_A_Coin;

package body ai is

   type Board_Positions is (
                            x1160,
                            x1205,
                            x1304,
                            x1340,
                            x1403,
                            x1430,
                            x1502,
                            x1520,
                            x1601,
                            x1610,
                            x1700,
                            x2222,
                            x2330,
                            x2420,
                            x2510,
                            x3140,
                            x3203,
                            x3230,
                            x3320,
                            x4103,
                            x4130,
                            x4220,
                            x5120,
                            x6101,
                            x6110);

   type Best_Moves is array (Board_Positions) of Board.Hands;

   Best_Move : Best_Moves := (
                           x1160 => Board.RIGHT,
                           x1205 => Board.LEFT,
                           x1304 => Board.LEFT,
                           x1340 => Board.LEFT,
                           x1403 => Board.LEFT,
                           x1430 => Board.LEFT,
                           x1502 => Board.LEFT,
                           x1520 => Board.LEFT,
                           x1601 => Board.LEFT,
                           x1610 => Board.RIGHT,
                           x1700 => Board.LEFT,
                           x2222 => Board.LEFT,
                           x2330 => Board.LEFT,
                           x2420 => Board.LEFT,
                           x2510 => Board.LEFT,
                           x3140 => Board.RIGHT,
                           x3203 => Board.LEFT,
                           x3230 => Board.LEFT,
                           x3320 => Board.LEFT,
                           x4103 => Board.LEFT,
                           x4130 => Board.RIGHT,
                           x4220 => Board.LEFT,
                           x5120 => Board.RIGHT,
                           x6101 => Board.LEFT,
                           x6110 => Board.RIGHT );

   type Other_Hands is array (Board.Hands) of Board.Hands;

   Other_Hand : Other_Hands := (Board.LEFT  => Board.RIGHT,
                                Board.RIGHT => Board.LEFT);

   ----------------------------------

   function randomAI(
                     Player: Board.Players)
                     return Board.Hands is

      type Random_Moves is array (Flip_A_Coin.Coin) of Board.Hands;

      Random_Move : Random_Moves := (
                                     Flip_A_Coin.HEADS=> Board.LEFT,
                                     Flip_A_Coin.TAILS=> Board.RIGHT);
   begin

      return Random_Move(Flip_A_Coin.Flip);

   end randomAI;

   -----------------------------------
   function keyShift(Player:Board.Players; High_Hand:Board.Hands)
                     return String is

      High_Cup : String := Board.Beans'image(Board.Count_Beans(Player, High_Hand));
      Low_Cup  : String := Board.Beans'image(Board.Count_Beans(Player, Other_Hand(High_Hand)));

   begin

      return High_Cup(High_Cup'Last) & Low_Cup(Low_Cup'Last);

   end keyShift;

   -----------------------------------

   function keyPlayer(Player: Board.Players)
                      return String is

      type High_Hands is array (Board.Players) of Board.Hands;

      High_Hand : High_Hands := (Board.NORTH => Board.LEFT,
                                 Board.SOUTH => Board.RIGHT);
   begin

      return keyShift(Player, High_Hand(Player));

   end keyPlayer;

   ----------------------------------

   function opponent(Player:Board.Players)
                     return Board.Players is

      type Opponents is array(Board.Players) of Board.Players;

      Opp : Opponents := ( Board.NORTH => Board.SOUTH,
                           Board.SOUTH => Board.NORTH);

   begin

      return Opp(Player);

   end opponent;

   -----------------------------------

   function key(Player:Board.Players)
                return Board_Positions is

      String_Key : String := keyPlayer(Player) & keyPlayer(opponent(Player));

   begin

      return Board_Positions'Value("X" & String_Key);

   end key;

   -----------------------------------------

   function bestAI(
                   Player: Board.Players)
                   return Board.Hands is

   begin

      return Best_Move(key(Player));

   exception

      when Constraint_Error =>

         return randomAI(Player);

   end bestAI;

   --------------------------------------------------

   function worstAI(
                   Player: Board.Players)
                   return Board.Hands is

   begin

      return Other_Hand(bestAI(Player));

   end worstAI;

   -----------------------------------------------------

   function consultAI(
               AI : AI_Types;
               Player: Board.Players)
               return Board.Hands is

      type AI_Function_Types is access function(Player: Board.Players)
                                                return Board.Hands;

      type AI_Functions is array(AI_Types) of AI_Function_Types;

      AI_Function : AI_Functions := (
                                     BEST   => bestAI'Access,
                                     WORST  => worstAI'Access,
                                     RANDOM => randomAI'Access );


   begin

      return AI_Function(AI).all ( (Player) );

   end consultAI;

   -------------------------------------------

   function turn(
                 AI : AI_Types;
                 Player:Board.Players)
                 return Boolean is

      Cup_To_Empty : Board.Hands := consultAI(AI, Player);

      Bean_Moved : Boolean := Board.Move_Beans ( Player, Cup_To_Empty )
        or else Board.Move_Beans ( Player, Other_Hand (Cup_To_Empty) );
   begin

      return Bean_Moved;

   end turn;

end ai;
