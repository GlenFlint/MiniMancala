with Text_IO;

package body Board is
   
   type Boards is array(Players, Hands) of Beans;
   
   Board : Boards;

   ----------------
   procedure Start_Game is
      
   begin
      
      Board := (others => (others => Starting_Beans_Per_Cup));
      
   end Start_Game;
   
   ---------------------------
   
   procedure Print_Board is
      
   begin
      
      Text_IO.Put_Line("1 - " & Beans'image(Board(NORTH, LEFT)) & Beans'image(Board(NORTH, RIGHT)));
      Text_IO.Put_Line("0 - " & Beans'image(Board(SOUTH, LEFT)) & Beans'image(Board(SOUTH, RIGHT)));                 
      
   end Print_Board;
   
   -----------------------------------
   
   function Count_Beans(
                        Player:Players; 
                        Hand:Hands)
                        return Beans is
      
   begin
      
      return Board(Player, Hand);
      
   end Count_Beans;
   
   --------------------------------------
   
   procedure Next_Cup (
                       Player : in Players;
                       Hand   : in Hands;
                       Next_Player : out Players;
                       Next_Hand   : out Hands) is
      
      type Next_Players is array (Players, Hands) of Players;
      
      Next_Player_Lookup : Next_Players := (
                                     NORTH => (
                                               LEFT => SOUTH,
                                               RIGHT =>  NORTH),
                                     SOUTH => (
                                               LEFT => SOUTH,
                                               RIGHT => NORTH ));
      
      type Next_Hands is array (Players, Hands) of Hands;
      
      Next_Hand_Lookup : Next_Hands := (
                                 NORTH => (
                                           LEFT => LEFT,
                                           RIGHT => LEFT),
                                 SOUTH => (
                                           LEFT => RIGHT,
                                           RIGHT => RIGHT ));

   begin
      
      Next_Player := Next_Player_Lookup ( Player, Hand );
      
      Next_Hand   := Next_Hand_Lookup ( Player, Hand );
      
   end Next_Cup;
   
   -----------------------------------
   
   function Move_Beans (
                        Player : Players;
                        Hand   : Hands )
                        return Boolean is
      
      Beans_Found : Boolean := false;
      
      Next_Player : Players;
      
      Next_Hand   : Hands;
      
   begin
      
--      Text_IO.Put_Line (Players'image (Player ) & "-" & Hands'image(Hand));
      
      Next_Cup ( Player, Hand, Next_Player, Next_Hand );
      
 --     Text_IO.Put_Line (Players'image (Player ) & "-" & Hands'image(Hand) & "  " & 
  --                      Players'image (Next_Player ) & "-" & Hands'image(Next_Hand));
      
      loop
         exit when (Count_Beans ( Player, Hand ) = 0 );
         
         Beans_Found := true;
         
         Board ( Player, Hand ) := Board ( Player, Hand ) - 1;
         
         Board (Next_Player, Next_Hand ) := Board (Next_Player, Next_Hand ) + 1;
         
--         Text_IO.Put_Line (Players'image (Next_Player ) & "-" & Hands'image(Next_Hand));
               
         Next_Cup ( Next_Player, Next_Hand, Next_Player, Next_Hand );
         
 --        Text_IO.Put_Line (Players'image (Next_Player ) & "-" & Hands'image(Next_Hand));
         
         if (Player = Next_Player and Hand = Next_Hand ) then  -- starting cup
            
            Next_Cup ( Next_Player, Next_Hand, Next_Player, Next_Hand );
            
         end if;
         
      end loop;
      
      return Beans_Found;
         
   end Move_Beans;
   
end Board;
