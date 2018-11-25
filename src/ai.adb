with Text_IO;
with Flip_A_Coin;

package body AI is

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
   -- Random_AI                   --
   --------------------------------

   function Random_AI(
                     Player: Board.Players)
                     return Board.Hands is

      type Random_Moves is array (Flip_A_Coin.Coin) of Board.Hands;

      Random_Move : Random_Moves := (
                                     Flip_A_Coin.HEADS=> Board.WEST,
                                     Flip_A_Coin.TAILS=> Board.EAST);
   begin

      return Random_Move(Flip_A_Coin.Flip);

   end Random_AI;

   --------------------------------
   -- Key                        --
   --------------------------------

   function Key(Player:Board.Players)
                return Board_Positions is

      --------------------------------
      -- Opponent                   --
      --------------------------------

      function Opponent(Player:Board.Players)
                        return Board.Players is

         type Opponents is array(Board.Players) of Board.Players;

         Opp : Opponents := ( Board.NORTH => Board.SOUTH,
                              Board.SOUTH => Board.NORTH);

      begin

         return Opp(Player);

      end Opponent;

      --------------------------------
      -- Key_Player                 --
      --------------------------------

      type Keys is new String(1..5);

      type Player_Keys is new String (1..2);

      function Key_Player(Player: Board.Players)
                         return Player_Keys is

         type High_Hands is array (Board.Players) of Board.Hands;

         High_Hand : High_Hands := (Board.NORTH => Board.EAST,
                                    Board.SOUTH => Board.WEST);

         --------------------------------
         -- Key_Shift                   --
         --------------------------------

         function Key_Shift(Player:Board.Players; High_Hand:Board.Hands)
                           return Player_Keys is

            High_Cup : Character := Board.Beans'image(Board.Count_Beans(Player, High_Hand))(2);
            Low_Cup  : Character := Board.Beans'image(Board.Count_Beans(Player, Other_Hand(High_Hand)))(2);

            Player_Key : Player_Keys;

         begin

            Player_Key(1) := High_Cup;

            Player_Key(2) := Low_Cup;

            return Player_Key;

         end Key_Shift;

      begin

         return Key_Shift(Player, High_Hand(Player));

      end Key_Player;

      The_Key : Keys := Keys ( 'X' & Key_Player(Player) & Key_Player(Opponent(Player) ) );

      Trace : Boolean := False;

   begin

      if (Trace) then

         Text_IO.Put_Line(Board.Players'Image(Player) & " - " & String ( The_Key ) );

      end if;

      return Board_Positions'Value( String ( The_Key ) );

   end Key;

   --------------------------------
   -- Best_AI                    --
   --------------------------------

   function Best_AI(
                   Player: Board.Players)
                   return Board.Hands is

      Cup_To_Empty : Board.Hands;

   begin

      Cup_To_Empty := Best_Move(Key(Player));

      if (Board."="(Player, Board.NORTH)) then

         Cup_To_Empty := Other_Hand ( Cup_To_Empty );  -- Switch hands on North

      end if;

      return Cup_To_Empty;

   exception

      when Constraint_Error =>

         return Random_AI(Player);

   end Best_AI;

   --------------------------------
   -- Worst_AI                   --
   --------------------------------

   function Worst_AI(
                    Player: Board.Players)
                    return Board.Hands is

   begin

      return Other_Hand(Best_AI(Player));

   end Worst_AI;

   --------------------------------
   -- Consult_AI                 --
   --------------------------------

   function Consult_AI(
                      AI : AI_Types;
                      Player: Board.Players)
                      return Board.Hands is

      type AI_Function_Types is access function(Player: Board.Players)
                                                return Board.Hands;

      type AI_Functions is array(AI_Types) of AI_Function_Types;

      AI_Function : AI_Functions := (
                                     BEST   => Best_AI'Access,
                                     WORST  => Worst_AI'Access,
                                     RANDOM => Random_AI'Access );


   begin

      return AI_Function(AI).all ( (Player) );

   end Consult_AI;

   --------------------------------
   -- Turn                       --
   --------------------------------

   function Turn(
                 AI : AI_Types;
                 Player:Board.Players)
                 return Boolean is

      Cup_To_Empty : Board.Hands := Consult_AI(AI, Player);

      Bean_Moved : Boolean := Board.Move_Beans ( Player, Cup_To_Empty )
        or else Board.Move_Beans ( Player, Other_Hand (Cup_To_Empty) );
   begin

      return Bean_Moved;

   end Turn;

end AI;
