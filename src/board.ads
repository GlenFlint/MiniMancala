package Board is 
      
   type Players is (NORTH, SOUTH);   
   type Hands is (LEFT, RIGHT);   
      
   Total_Cups             : constant := 4;
   Starting_Beans_Per_Cup : constant := 2;
   Total_Beans            : constant := Starting_Beans_Per_Cup * Total_Cups;
      
   type Beans is range 0..Total_Beans;   
   
   procedure Start_Game;

   procedure Print_Board;
   
   function Count_Beans(
                        Player:Players; 
                        Hand:Hands)
                        return Beans;
   
   function Move_Beans (
                        Player : PLayers;
                        Hand   : Hands )
                        return Boolean;
   
end Board;
