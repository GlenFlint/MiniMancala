with Text_IO;

package body Board is
   
   type Boards is array(Players, Hands) of Beans;
   
   Board : Boards;

   --------------------------------
   -- Start_Game                 --
   --------------------------------
   
   procedure Start_Game is
      
   begin
      
      Board := (others => (others => Starting_Beans_Per_Cup));
      
   end Start_Game;
   
   --------------------------------
   -- Print_Board                --
   --------------------------------
   
   procedure Print_Board is
      
      Trace_Board : Boolean := False;
      
   begin
      
      if (Trace_Board) then
      
         Text_IO.Put_Line("NORTH - " & Beans'image(Board(NORTH, WEST)) & Beans'image(Board(NORTH, EAST)));
         Text_IO.Put_Line("SOUTH - " & Beans'image(Board(SOUTH, WEST)) & Beans'image(Board(SOUTH, EAST))); 
      
         Text_IO.Put_Line("------------");
         
      end if;
      
      
   end Print_Board;
   
   --------------------------------
   -- Count_Beans                --
   --------------------------------
   
   function Count_Beans(
                        Player:Players; 
                        Hand:Hands)
                        return Beans is
      
   begin
      
      return Board(Player, Hand);
      
   end Count_Beans;
   
   --------------------------------
   -- Next_Cup                   --
   --------------------------------
   
   procedure Next_Cup (
                       Player : in Players;
                       Hand   : in Hands;
                       Next_Player : out Players;
                       Next_Hand   : out Hands) is
      
      type Next_Players is array (Players, Hands) of Players;
      
      Next_Player_Lookup : Next_Players := (
                                            NORTH => (
                                                      WEST => SOUTH,
                                                      EAST =>  NORTH),
                                            SOUTH => (
                                                      WEST => SOUTH,
                                                      EAST => NORTH ));
      
      type Next_Hands is array (Players, Hands) of Hands;
      
      Next_Hand_Lookup : Next_Hands := (
                                        NORTH => (
                                                  WEST => WEST,
                                                  EAST => WEST),
                                        SOUTH => (
                                                  WEST => EAST,
                                                  EAST => EAST ));

   begin
      
      Next_Player := Next_Player_Lookup ( Player, Hand );
      
      Next_Hand   := Next_Hand_Lookup ( Player, Hand );
      
   end Next_Cup;
   
   --------------------------------
   -- Move_Beans                 --
   --------------------------------
   
   function Move_Beans (
                        Player : Players;
                        Hand   : Hands )
                        return Boolean is
      
      Beans_Found : Boolean := false;
      
      Next_Player : Players;
      
      Next_Hand   : Hands;
      
   begin
      
      Next_Cup ( Player, Hand, Next_Player, Next_Hand );
      
      loop
         exit when (Count_Beans ( Player, Hand ) = 0 );
         
         Beans_Found := true;
         
         Board ( Player, Hand ) := Board ( Player, Hand ) - 1;
         
         Board (Next_Player, Next_Hand ) := Board (Next_Player, Next_Hand ) + 1;
               
         Next_Cup ( Next_Player, Next_Hand, Next_Player, Next_Hand );
         
         if (Player = Next_Player and Hand = Next_Hand ) then  -- starting cup
            
            Next_Cup ( Next_Player, Next_Hand, Next_Player, Next_Hand );
            
         end if;
         
      end loop;
      
      return Beans_Found;
         
   end Move_Beans;
   
end Board;
