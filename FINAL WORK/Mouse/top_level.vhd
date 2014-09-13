library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;
entity top_level is

    port
    (
         clk       : in    std_logic;    -- CLK
			 -- sw0 RESOLUTION
          sw 		  : in    std_logic_vector (1 downto 0); 
			 -- btnr RST
			 -- btnl refresh after resolution
          btnr, btnl       : in    std_logic; 
			 -- signal from the mouse
			 -- LED2 LEFT
			 -- LED1 MIDDLE
			 -- LED0 RIGHT
          LED       : out   std_logic_vector(2 downto 0); 
			-- signal from the pmod
          JA    : inout std_logic_vector(7 downto 4);  
		
			-- color control 
			 vgaRed  : out std_logic_vector(2 downto 0);   
			 vgaGreen: out std_logic_vector(2 downto 0); 
          vgaBlue : out std_logic_vector(2 downto 1);
			 Hsync         : out   std_logic; 
          Vsync         : out   std_logic
			 
   );

end top_level;

architecture behav of top_level is
component MouseRefComp is
   port ( CLK        : in    std_logic; 
          RESOLUTION : in    std_logic; 
          RST        : in    std_logic; 
          SWITCH     : in    std_logic; 
          LEFT       : out   std_logic; 
          MIDDLE     : out   std_logic; 
          NEW_EVENT  : out   std_logic; 
          RIGHT      : out   std_logic; 
          XPOS       : out   std_logic_vector (9 downto 0); 
          YPOS       : out   std_logic_vector (9 downto 0); 
          ZPOS       : out   std_logic_vector (3 downto 0); 
          PS2_CLK    : inout std_logic; 
          PS2_DATA   : inout std_logic);
end component;

component mouse_displayer is
port (
   clk      : in std_logic;
   
   pixel_clk: in std_logic;
   xpos     : in std_logic_vector(9 downto 0);
   ypos     : in std_logic_vector(9 downto 0);

   hcount   : in std_logic_vector(10 downto 0);
   vcount   : in std_logic_vector(10 downto 0);
   blank    : in std_logic;

   red_in   : in std_logic_vector(2 downto 0);
   green_in : in std_logic_vector(2 downto 0);
   blue_in  : in std_logic_vector(1 downto 0);

   red_out  : out std_logic_vector(2 downto 0);
   green_out: out std_logic_vector(2 downto 0);
   blue_out : out std_logic_vector(1 downto 0)
);
end component;


component VgaRefComp is
   port ( CLK_25MHz  : in    std_logic; 
          CLK_40MHz  : in    std_logic; 
          RESOLUTION : in    std_logic; 
          RST        : in    std_logic; 
          BLANK      : out   std_logic; 
          HCOUNT     : out   std_logic_vector (10 downto 0); 
          HS         : out   std_logic; 
          VCOUNT     : out   std_logic_vector (10 downto 0); 
          VS         : out   std_logic);
end component;


component dcm_all is
port(
   CLK, RST             : in    std_logic; 
   CLKSYS, CLK25, CLK40 : out   std_logic 
);
end component;


SIGNAL X, Y : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL HC, VC : STD_LOGIC_VECTOR (10 DOWNTO 0);
SIGNAL BLK, CLK25, CLK40, CLKpix, CLKSYS, NewEvent: STD_LOGIC;

begin

 -- use BUFGMUX for clock selection
  BUFGMUX_pix : BUFGMUX	port map (O=>CLKpix, I0=>CLK25, I1=>Clk40, S=>sw(0));
 

 -- revA 			 
 -- C0 : MouseRefComp PORT MAP  ( CLK =>CLKPix, RESOLUTION=>sw(0), SWITCH=>btnl, RST=>btnr, LEFT=>LED(2), MIDDLE=>LED(1), NEW_EVENT=>NewEvent, RIGHT=>LED(0),
 --									XPOS=> X, YPOS=>Y, PS2_CLK=>JA(7), PS2_DATA=>JA(5));

 --revC
 
	C0 : MouseRefComp PORT MAP  (
				CLK =>CLKPix,
				RESOLUTION=>sw(0),
				SWITCH=>btnl,
				RST=>btnr,
				LEFT=>LED(2),
				MIDDLE=>LED(1),
				NEW_EVENT=>NewEvent,
				RIGHT=>LED(0),
				XPOS=> X,
				YPOS=>Y,
				PS2_CLK=>JA(6),
				PS2_DATA=>JA(4)
	);

	C1: dcm_all PORT MAP(
				CLK=>clk,
				RST=>btnr,
				CLKSYS=>CLKSYS,
				CLK25=>CLK25,
				CLK40=>CLK40
	);   


	C2 : VgaRefComp PORT MAP  (
				CLK_25MHz=>CLK25,
				CLK_40MHz=>CLK40,
				RESOLUTION=>sw(0),
				RST=>btnr,
				BLANK=>BLK,
				HCOUNT=>HC,
				HS=>Hsync,
				VCOUNT=> VC,
				VS=>Vsync
	);
 
 -- set background to zero by setting red_in, green_in and blue_in to zero 
	C3 : mouse_displayer PORT MAP  (
				clk=>CLKSYS,
				pixel_clk=>CLKpix,
				xpos=>X,
				ypos=>Y,
				hcount=> HC,
				vcount=>VC,
				blank=>BLK, 
				red_in=>"101",
				green_in=>"100",
				blue_in=>"11",
				red_out=>vgaRed,
				green_out=>vgaGreen,
				blue_out=>vgaBlue
	);



end behav;

