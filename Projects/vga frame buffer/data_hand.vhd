library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

use WORK.util.all;


entity data_hand is
   port(
      clk: in std_logic;
      rst: in std_logic;
      wrflg: in std_logic;
      wradd: out std_logic_vector(11 downto 0)
  --    wdatai: in   std_logic_vector(7 downto 0);
  --    wdatao: out   std_logic_vector(7 downto 0)
   );
end data_hand;


architecture arch of data_hand is
signal addr : unsigned(11 downto 0) := "001000000000";
signal n_addr : unsigned(11 downto 0) := "001000000000";

begin
process(rst,clk)
begin
	if rst = '1' then
		addr<="001000000000";
		--wdatao<= x"20";
	elsif clk'event and clk='1' then
		addr<=n_addr;
	end if;
end process;

process(clk)
begin
n_addr<=addr;
 if wrflg ='1' then
	if (addr(6 downto 0) = 79) then
		if (addr (11 downto 7) = 28) then
		n_addr<=("001000000000");
		else
		n_addr<=((addr(11 downto 7) +1)&'0'&'0'&'0'&'0'&'0'&'0'&'0'); 
		end if;
	else
	n_addr<= (addr)+1;
	end if;
end if;
end process;
--wdatao<=wdatai;
wradd<=std_logic_vector(addr);
end arch;
