------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with BeanGraphics;

with MicroBit.Display;
with MicroBit.Buttons;
with MicroBit.Time;

with Board;
with AI;

with Flip_A_Coin;

procedure Draw is

   type Players_AI is array (Board.Players) of AI.AI_Types;

   Player_AI : constant Players_AI :=
     (Board.NORTH => AI.BEST, Board.SOUTH => AI.RANDOM);

   type Random_Players is array (Flip_A_Coin.Coin) of Board.Players;

   Random_Player : constant Random_Players :=
     (Flip_A_Coin.HEADS => Board.NORTH, Flip_A_Coin.TAILS => Board.SOUTH);

   type Other_Players is array (Board.Players) of Board.Players;

   Other_Player : constant Other_Players :=
     (Board.NORTH => Board.SOUTH, Board.SOUTH => Board.NORTH);

   Player : Board.Players;

   Game_Continues : Boolean;

   -- Wait for a button to be pressed.

   function Get_Button_Pressed return MicroBit.Buttons.Button_Id is

      Button : MicroBit.Buttons.Button_Id := MicroBit.Buttons.Button_A;

      function Other_Button
        (Button : in MicroBit.Buttons.Button_Id) return MicroBit.Buttons
        .Button_Id
      is

         The_Other_Button : MicroBit.Buttons.Button_Id;

      begin

         case Button is

            when MicroBit.Buttons.Button_A =>

               The_Other_Button := MicroBit.Buttons.Button_B;

            when MicroBit.Buttons.Button_B =>

               The_Other_Button := MicroBit.Buttons.Button_A;

         end case;

         return The_Other_Button;

      end Other_Button;

   begin

      loop

         exit when MicroBit.Buttons."="
             (MicroBit.Buttons.State (Button), MicroBit.Buttons.PRESSED);

         Button := Other_Button (Button);

         MicroBit.Time.Delay_Ms (200);

      end loop;

      return Button;

   end Get_Button_Pressed;

   -- Wait for a button to be pressed or released.

   procedure Wait (Button : in MicroBit.Buttons.Button_Id;
      State               : in MicroBit.Buttons.Button_State)
   is

   begin

      loop

         exit when MicroBit.Buttons."="
             (MicroBit.Buttons.State (Button), State);

         MicroBit.Time.Delay_Ms (200);

      end loop;

   end Wait;

   -- Wait for a button to be pressed, then released.
   -- Convert it into the the Hand (EAST or WEST)

   function Get_Button
 return Board.Hands is

      Button : MicroBit.Buttons.Button_Id := Get_Button_Pressed;

      Hand : Board.Hands;

   begin

      Wait (Button, MicroBit.Buttons.RELEASED);

      case Button is

         when MicroBit.Buttons.Button_A =>

            Hand := Board.EAST;   -- This seems backwards, but looks better

         when MicroBit.Buttons.Button_B =>

            Hand := Board.WEST;

      end case;

      return Hand;

   end Get_Button;

   Button_Pressed : Board.Hands;

begin

   MicroBit.Display.Display ("Tiny Mancala!");

   loop

      Board.Start_Game;

      Player := Random_Player (Flip_A_Coin.Flip);

      BeanGraphics.Display;

      loop

         case Player is

            when Board.NORTH => -- MicroBit

               MicroBit.Time.Delay_Ms (2000);

               Game_Continues :=
                 AI.Turn (AI => Player_AI (Player), Player => Player);

            when Board.SOUTH =>  -- Human

               Button_Pressed := Get_Button;

               Game_Continues :=
                 AI.Turn (Cup_To_Empty => Button_Pressed, Player => Player);

         end case;

         BeanGraphics.Display;

         Player := Other_Player (Player);

         if (not Game_Continues) then

            exit;

         end if;

      end loop;

   end loop;

end Draw;
