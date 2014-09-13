library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;
use WORK.util.all;
-- simulation library
library UNISIM;
use UNISIM.VComponents.all;



-- the mouse_displayer entity declaration
-- read above for behavioral description and port definitions.
entity char_disp is
port (
   clk      : in std_logic;
   pixel_clk: in std_logic;
 
   hcount   : in unsigned(10 downto 0);
   vcount   : in unsigned(10 downto 0);
   blank    : in std_logic;

   red_in   : in std_logic_vector(2 downto 0);
   green_in : in std_logic_vector(2 downto 0);
   blue_in  : in std_logic_vector(1 downto 0);

   red_out  : out std_logic_vector(2 downto 0);
   green_out: out std_logic_vector(2 downto 0);
   blue_out : out std_logic_vector(1 downto 0);

   datain   : in  unsigned(7 downto 0);
   addrout  :out  unsigned(11 downto 0);
   addrline :out unsigned(3 downto 0)
);

end char_disp;

architecture Behavioral of char_disp is
signal xw   : unsigned(11 downto 0) := (others=> '0');
signal yw   : unsigned(11 downto 0) := (others=> '0');
signal xm   : unsigned(11 downto 0)  := (others=> '0');
signal ym   : unsigned(11 downto 0)  := (others=> '0');
signal n_xw : unsigned(11 downto 0) := (others=> '0');
signal n_yw : unsigned(11 downto 0) := (others=> '0');
signal n_xm : unsigned(11 downto 0)  := (others=> '0');
signal n_ym : unsigned(11 downto 0)  := (others=> '0');
signal i    : std_logic 			  :='0';
signal n_i    : std_logic 			  :='0';
begin

process(clk)
begin
if clk'event and clk='1' then
	xw<=n_xw;
	yw<=n_yw;
	xm<=n_xm;
	ym<=n_ym;
	i<=n_i;
--	addrout<=n_yw(4 downto 0) & n_xw(6 downto 0) ;-- see128*yw
--	addrline<= n_ym(3 downto 0);
end if;
end process;
process(pixel_clk,xw,yw,xm,ym,i,clk)
begin
n_xw<=xw;
n_yw<=yw;
n_xm<=xm;
n_ym<=ym;
n_i<=i;
	addrout<=yw(4 downto 0) & xw(6 downto 0) ;-- see128*yw
	addrline<= ym(3 downto 0);
if clk'event and clk='1' then
	n_xw<=(('0' & hcount) / 8);
	n_xm<=(('0' & hcount) mod 8);	
	n_ym<=(('0' & vcount) mod 16);
	n_yw<=(('0' & vcount) / 16);	

end if;
end process;

process(pixel_clk)
begin
if pixel_clk'event and pixel_clk='1' then
if(blank = '0') then
if datain(8-to_integer(n_xm)) = '1' then
	           red_out <= (others => '1');
                  green_out <= (others => '1');
                  blue_out <= (others => '1');
else
		    red_out <=  red_in;
                  green_out <= green_in;
                  blue_out <=  blue_in;
end if;
else
	     red_out <= (others => '0');
            green_out <= (others => '0');
            blue_out <= (others => '0');
         end if;
end if;
end process;














end Behavioral;
