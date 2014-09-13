library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use WORK.util.all;

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

          LED       : out   std_logic_vector(2 downto 0); 
			-- color control 
 	  vgaRed  : out std_logic_vector(2 downto 0);   
 	  vgaGreen: out std_logic_vector(2 downto 0); 
          vgaBlue : out std_logic_vector(2 downto 1);

	  Hsync         : out   std_logic; 
          Vsync         : out   std_logic;

          rx:   in  std_logic;                    -- uart rx 
          tx:   out std_logic                   -- uart tx
   );

end top_level;

architecture behav of top_level is

component font_map is 
port(
      clk: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end component;


component char_map is 
port(
      clk: in std_logic;
      char_read_addr : in std_logic_vector(11 downto 0);
      char_write_addr: in std_logic_vector(11 downto 0);
      char_we : in std_logic;
      char_write_value : in std_logic_vector(7 downto 0);
      char_read_value : out std_logic_vector(7 downto 0)
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
   
    constant clk_freq:   positive  := 100000000; -- Hz
    constant clk_period: time      :=  1000 ms / clk_freq;
    constant debounce:   natural   := 80; -- us
    constant baud_rate:  positive  :=   57600; -- Baud
    constant bit_period: time      :=  1000 ms / baud_rate;
    constant ts_digits:  positive  := 5 + 8;
    constant signals:    positive  := 8;
    constant fifo_size:  positive  := 16;



SIGNAL HC, VC : STD_LOGIC_VECTOR (10 DOWNTO 0);
SIGNAL BLK, CLK25, CLK40, CLKpix, CLKSYS, NewEvent: STD_LOGIC;
signal din :  unsigned (7 downto 0) ;
signal din1 : unsigned (7 downto 0) ;
signal dout:  unsigned (11 downto 0);
signal dline: unsigned (3 downto 0) ;
signal flg  : std_logic;
signal data : std_logic_vector(7 downto 0);
signal wadrs : std_logic_vector(11 downto 0);
begin

 -- use BUFGMUX for clock selection
  BUFGMUX_pix : BUFGMUX	port map (O=>CLKpix, I0=>CLK25, I1=>Clk40, S=>sw(0));
 


 


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
 

	char_disp_unit: entity WORK.char_disp 
		 PORT MAP (
			
			   clk      => CLKSYS,
			   pixel_clk=> CLKpix,
 	
			   hcount(10 downto 0)   => unsigned(HC(10 downto 0)),
			   vcount   =>  unsigned(VC),
       	          blank    =>  BLK,
	
			   red_in   => "000",
			   green_in => "001",
			   blue_in  => "11",
			   red_out  =>  vgaRed,
			   green_out=>  vgaGreen,
			   blue_out =>  vgaBlue,
	
			   datain   => din,
			   addrout  => dout,
			   addrline => dline
); 
	char_map_unit : entity WORK.char_map
		PORT MAP (
				clk		   =>CLKSYS,
			       char_read_addr   =>std_logic_vector(dout),
 			       char_write_addr  =>wadrs,
			       char_we 	   =>flg or sw(1),
				rst => sw(1) OR btnr,	
 			       char_write_value =>data,
			       char_read_value  =>(din1)
   			  );
   
	data_hand_unit : entity WORK.data_hand
		PORT MAP (
				clk   =>clk,
	                        rst   =>btnr or btnl,
      				wrflg => flg or sw(1),
      				wradd => wadrs
      	--			wdatai=> (others=>'0'),
	--			wdatao=> open
   			  );



 serial_port_unit: entity WORK.serial_port 
    generic map
    (
        clk_freq   => clk_freq,
        baud_rate  => baud_rate
    )
    port map
    (
        rst        => btnr,
        clk        => clk,


	 rx	     => rx,
        do         => open,
	rxo		=> data,
	rxflg => flg
    );


	font_map_unit : entity WORK.font_map
		PORT MAP (
				clk =>CLKSYS,
			       addr=>(din1(6 downto 0)) & dline,
			       data=>din
   );



tx<=rx;

LED(2 downto 0) <= data(2 downto 0);

end behav;

