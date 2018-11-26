with Board;

with STM32.Board;       use STM32.Board;
with HAL.Bitmap;        use HAL.Bitmap;

with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Real_Arrays;
with Ada.Real_Time;

package body draw_board is

   procedure Draw_Cups is
         
      Buffer : HAL.Bitmap.Any_Bitmap_Buffer renames Display.Hidden_Buffer (1);
      
      procedure Clear is
      
      begin      
               
         Buffer.Set_Source (Black);
         Buffer.Fill;
      
      end Clear;
                     
      ----------------------
      
      EAST_OFFSET    : constant HAL.Bitmap.Point := (120, 0);
      
      SOUTH_OFFSET    : constant HAL.Bitmap.Point := (0, 140);      
            
      NORTH_WEST_CUP : constant HAL.Bitmap.Point := (10, 40);
      
      NORTH_EAST_CUP : constant HAL.Bitmap.Point := NORTH_WEST_CUP + EAST_OFFSET;
      
      SOUTH_WEST_CUP : constant HAL.Bitmap.Point := NORTH_WEST_CUP + SOUTH_OFFSET;
      
      SOUTH_EAST_CUP : constant HAL.Bitmap.Point := SOUTH_WEST_CUP + EAST_OFFSET;
                  
      type Cup_Corners is array (Board.Players, Board.Hands ) of HAL.Bitmap.Point;
            
      Cup_Corner     : constant Cup_Corners  := (
                                                 Board.NORTH => (
                                                                 Board.WEST => NORTH_WEST_CUP,
                                                                 Board.EAST => NORTH_EAST_CUP ),
                                                 Board.SOUTH => (
                                                                 Board.WEST => SOUTH_WEST_CUP,
                                                                 Board.EAST => SOUTH_EAST_CUP ) );

      procedure Draw_Beans (
                            Player : Board.Players;
                            Hand : Board.Hands ) is
         
         CUP_CENTER : constant HAL.Bitmap.Point := (50, 50) + Cup_Corner (Player, Hand);
         
         BEAN_RADIUS : constant := 15;
         
         Bean_Center : HAL.Bitmap.Point := CUP_CENTER;
         
         type Angles is new Float range 0.0 .. 2.0 * Ada.Numerics.Pi;
         
         DELTA_THETA : constant Angles := Angles(2.0 * Ada.Numerics.Pi / Float(Board.Total_Beans - 1) );
         
         Theta : Angles := Angles'First;         
         
         REMAINING_BEANS_RADIUS : constant := 32.0;
         
         Bean_Offset : Ada.Numerics.Real_Arrays.Real_Vector(1..2);
         
      begin
         
         for Bean in 1..Board.Count_Beans ( Player, Hand ) loop
         
            Buffer.Set_Source (HAL.Bitmap.Yellow);
            Buffer.Fill_Circle (Bean_Center, BEAN_RADIUS);

            Buffer.Set_Source (HAL.Bitmap.Blue);
            Buffer.Draw_Circle (Bean_Center, BEAN_RADIUS);
            
            Bean_Offset := (1 => Ada.Numerics.Elementary_Functions.cos(Float(Theta)),
                            2 => Ada.Numerics.Elementary_Functions.sin(Float(Theta)));
            
            Bean_Offset := Ada.Numerics.Real_Arrays."*"(REMAINING_BEANS_RADIUS, Bean_Offset);
            
            Bean_Center := (
                            X => CUP_CENTER.X + Integer( Bean_Offset ( 1 ) ),
                            Y => CUP_CENTER.Y + Integer( Bean_Offset ( 2 ) ) );
            
            Theta := Theta + DELTA_THETA;
            
         end loop;        
         
      end Draw_Beans;
      
      -----------------------------------
      
      procedure Draw_Cup (
                          Player : Board.Players;
                          Hand : Board.Hands ) is
      
         CUP_WIDTH  : constant := 100;
      
         CUP_HEIGHT : constant := 100;
      
         CUP_RADIUS : constant := 20;
      
         CUP : constant HAL.Bitmap.Rect := (
                                            Position => Cup_Corner(Player, Hand),
                                            Width    => CUP_WIDTH,
                                            Height   => CUP_HEIGHT ); 
      
      begin

         Buffer.Set_Source (Green);
         Buffer.Fill_Rounded_Rect (CUP, CUP_RADIUS);

         Buffer.Set_Source (HAL.Bitmap.Red);
         Buffer.Draw_Rounded_Rect (CUP, CUP_RADIUS, Thickness => 4);
      
      end Draw_Cup;      
         
      Period     : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (2000);  -- arbitrary
      
      Next_Start : Ada.Real_Time.Time;
      
   begin
      
      Clear;
                                   
      for Player in Board.Players loop
         
         for Hand in Board.Hands loop
                                   
            Draw_Cup ( Player, Hand );
            
            Draw_Beans ( Player, Hand );
                        
         end loop;
                                   
      end loop;      
               
      Display.Update_Layer (1, Copy_Back => False);
         
      Next_Start := Ada.Real_Time.Clock;
         
      Next_Start := Ada.Real_Time."+"(Next_Start, Period);
         
      delay until Next_Start;
            
   end Draw_Cups;     

end draw_board;
