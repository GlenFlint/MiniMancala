with Text_IO;
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
                              x1160 => Board.EAST,
                              x1205 => Board.WEST,
                              x1304 => Board.WEST,
                              x1340 => Board.WEST,
                              x1403 => Board.WEST,
                              x1430 => Board.WEST,
                              x1502 => Board.WEST,
                              x1520 => Board.WEST,
                              x1601 => Board.WEST,
                              x1610 => Board.EAST,
                              x1700 => Board.WEST,
                              x2222 => Board.WEST,
                              x2330 => Board.WEST,
                              x2420 => Board.WEST,
                              x2510 => Board.WEST,
                              x3140 => Board.EAST,
                              x3203 => Board.WEST,
                              x3230 => Board.WEST,
                              x3320 => Board.WEST,
                              x4103 => Board.WEST,
                              x4130 => Board.EAST,
                              x4220 => Board.WEST,
                              x5120 => Board.EAST,
                              x6101 => Board.WEST,
                              x6110 => Board.EAST );

   type Other_Hands is array (Board.Hands) of Board.Hands;

   Other_Hand : Other_Hands := (Board.WEST  => Board.EAST,
                                Board.EAST => Board.WEST);

   --------------------------------
   -- randomAI                   --
   --------------------------------

   function randomAI(
                     Player: Board.Players)
                     return Board.Hands is

      type Random_Moves is array (Flip_A_Coin.Coin) of Board.Hands;

      Random_Move : Random_Moves := (
                                     Flip_A_Coin.HEADS=> Board.WEST,
                                     Flip_A_Coin.TAILS=> Board.EAST);
   begin

      return Random_Move(Flip_A_Coin.Flip);

   end randomAI;

   --------------------------------
   -- key                        --
   --------------------------------

   function key(Player:Board.Players)
                return Board_Positions is

      --------------------------------
      -- opponent                   --
      --------------------------------

      function opponent(Player:Board.Players)
                        return Board.Players is

         type Opponents is array(Board.Players) of Board.Players;

         Opp : Opponents := ( Board.NORTH => Board.SOUTH,
                              Board.SOUTH => Board.NORTH);

      begin

         return Opp(Player);

      end opponent;

      --------------------------------
      -- keyPlayer                  --
      --------------------------------

      function keyPlayer(Player: Board.Players)
                         return String is

         type High_Hands is array (Board.Players) of Board.Hands;

         High_Hand : High_Hands := (Board.NORTH => Board.EAST,
                                    Board.SOUTH => Board.WEST);

         --------------------------------
         -- keyShift                   --
         --------------------------------

         function keyShift(Player:Board.Players; High_Hand:Board.Hands)
                           return String is

            High_Cup : String := Board.Beans'image(Board.Count_Beans(Player, High_Hand));
            Low_Cup  : String := Board.Beans'image(Board.Count_Beans(Player, Other_Hand(High_Hand)));

         begin

            return High_Cup(High_Cup'Last) & Low_Cup(Low_Cup'Last);

         end keyShift;

      begin

         return keyShift(Player, High_Hand(Player));

      end keyPlayer;

      String_Key : String := "X" & keyPlayer(Player) & keyPlayer(opponent(Player));

      Trace : Boolean := False;

   begin

      if (Trace) then

         Text_IO.Put_Line(Board.Players'Image(Player) & " - " & String_Key);

      end if;

      return Board_Positions'Value(String_Key);

   end key;

   --------------------------------
   -- bestAI                     --
   --------------------------------

   function bestAI(
                   Player: Board.Players)
                   return Board.Hands is

      Cup_To_Empty : Board.Hands;

   begin

      Cup_To_Empty := Best_Move(key(Player));

      if (Board."="(Player, Board.NORTH)) then

         Cup_To_Empty := Other_Hand ( Cup_To_Empty );  -- Switch hands on North

      end if;

      return Cup_To_Empty;

   exception

      when Constraint_Error =>

         return randomAI(Player);

   end bestAI;

   --------------------------------
   -- worstAI                     --
   --------------------------------

   function worstAI(
                    Player: Board.Players)
                    return Board.Hands is

   begin

      return Other_Hand(bestAI(Player));

   end worstAI;

   --------------------------------
   -- consultAI                     --
   --------------------------------

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

   --------------------------------
   -- turn                       --
   --------------------------------

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
