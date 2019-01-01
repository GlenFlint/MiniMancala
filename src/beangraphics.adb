with Board;

with MicroBit.Display;
with HAL;  use HAL;

package body BeanGraphics is

     -- This values are all oriented to the southwest corner.
      
      type Glyph is array (MicroBit.Display.Coord) of HAL.UInt5;
      Beans : constant array (Board.Beans) of Glyph :=
     ((2#00000#, -- 0
       2#00000#,
       2#00000#,
       2#00000#,
       2#00000#),
      
      (2#00000#, -- 1
       2#00000#,
       2#00000#,
       2#00000#,
       2#10000#),
      
      (2#00000#, -- 2
       2#00000#,
       2#00000#,
       2#00000#,
       2#11000#),
      
      (2#00000#, -- 3
       2#00000#,
       2#00000#,
       2#10000#,
       2#11000#),
            
      (2#00000#, -- 4
       2#00000#,
       2#00000#,
       2#11000#,
       2#11000#),
            
      (2#00000#, -- 5
       2#00000#,
       2#01000#,
       2#11000#,
       2#11000#),
            
      (2#00000#, -- 6
       2#00000#,
       2#11000#,
       2#11000#,
       2#11000#),
      
      (2#00000#, -- 7
       2#00000#,
       2#11000#,
       2#11000#,
       2#11100#),
      
      (2#00000#, -- 8
       2#00000#,
       2#11000#,
       2#11100#,
       2#11100#));
      
      --  Reverse the bits east west
      
      function Mirror(G : in Glyph)
                      return Glyph is
         
         M: Glyph;         
         
      begin
                  
         for C in G'Range loop
            
            case G(C) is
               when 2#00000# => M(C) := 2#00000#;
               when 2#10000# => M(C) := 2#00001#;
               when 2#01000# => M(C) := 2#00010#;
               when 2#11000# => M(C) := 2#00011#;
               when 2#11100# => M(C) := 2#00111#;
               when others =>   M(C) := 2#11111#; -- something went wrong
            end case;     
            
         end loop;
         
         return M;
         
      end Mirror;
            
      --  Flip the bits north and south
      
      function Flip(G: in Glyph)
                      return Glyph is
         
         F : Glyph;         
         
      begin
                  
         for C in G'Range loop
 
            F(C) := G(G'Last - C);
            
         end loop;
         
         return F;
         
      end Flip;
      
      -- Merge two Glyphs together
      
      function "+"(A, B : in Glyph)
                     return Glyph is
         
         U : Glyph;
         
      begin
                           
         for C in A'Range loop
 
            U(C) := A(C) OR B(C);
            
         end loop;
         
         return U;
         
   end "+";
   
   -------------------
   -- Print a Glyph --
   -------------------

   procedure Print (
            G     : in Glyph)
   is
      
      row : HAL.UInt5;
      column : HAL.UInt5;
  
   begin
             
      MicroBit.Display.Clear;     
      
      for X in MicroBit.Display.Coord loop
         column := 2 ** X;
         for Y in MicroBit.Display.Coord loop
            row := G(Y);
            if (row and column) /= 0 then
               MicroBit.Display.Set(X, Y);
            end if;
         end loop;
      end loop;
   end Print;
   
   -- Display current state of the board
   
   procedure Display is
      
      NW : Glyph := Flip(Beans(Board.Count_Beans(Board.NORTH, Board.WEST)));
      NE : Glyph := Mirror(Flip(Beans(Board.Count_Beans(Board.NORTH, Board.EAST))));
      SW : Glyph := Beans(Board.Count_Beans(Board.SOUTH, Board.WEST));
      SE : Glyph := Mirror(Beans(Board.Count_Beans(Board.SOUTH, Board.EAST)));
      
      B  : Glyph := NW + NE + SW + SE;
            
   begin
      
      Print(B);  
      
   end Display;   
   
   -- Display the blank board
   
   procedure Clear 
   
   is
      
   begin
      
      Print(Beans(0));
      
   end Clear;

end BeanGraphics;
