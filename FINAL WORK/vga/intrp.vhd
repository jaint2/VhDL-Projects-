library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.util.all;






entity intrp  is 


    port
    (
	clk: in  std_logic;
	rst: in  std_logic; 	
	ri : in  std_logic;
	di : in  std_logic_vector(7 downto 0);
	ro : out std_logic;
--	txo: out std_logic;
--	bi : in  std_logic; 
--	txd: out std_logic_vector(7 downto 0);
	do : out std_logic_vector(7 downto 0)
    );
end intrp;

architecture rtl of intrp is

--    type states is (st_idle, st_data1, st_intrp1,st_wait1,st_data2, st_intrp2,st_wait2,st_data3,st_intrp3);
    type states is (st_idle, st_data1, st_intrp1,st_wait1,st_data2, st_intrp2);
    signal   state:      states                                    := st_idle;
    signal   next_state: states                                    := st_idle;
    signal   data1:       std_logic_vector(7 downto 0)             := (others => '0');
    signal   next_data1:  std_logic_vector(7 downto 0)	           := (others => '0');
    signal   data2:       std_logic_vector(7 downto 0)             := (others => '0');
    signal   next_data2:  std_logic_vector(7 downto 0)	           := (others => '0');
    signal   data3:       std_logic_vector(7 downto 0)             := (others => '0');
    signal   next_data3:  std_logic_vector(7 downto 0)	           := (others => '0');
    signal   bit:        unsigned(7 downto 0) 			    := (others => '0');
    signal   next_bit:   unsigned(7 downto 0)			    := (others => '0');
    signal   datao:       std_logic_vector(7 downto 0)             := (others => '0');
    signal   next_datao:  std_logic_vector(7 downto 0)	           := (others => '0');
    signal   chk:	     std_logic				    :='0';
    signal   n_chk:	     std_logic				    :='0';
begin

process (clk,rst)
begin
	if rst ='1' then
		data1 <= (others => '0');
		data2 <= (others => '0');
		data3 <= (others => '0');
		datao <= (others => '0');
		chk<='0';
		state <= st_idle;
	elsif clk'event and clk='1' then
		data1<=next_data1;
		data2<=next_data2;
		data3<=next_data3;
		chk<=n_chk;
		state<=next_state;
		datao<=next_datao;
	end if;
end process;

process (state, data1,data2,data3,ri,di,chk,datao)
begin

	n_chk<=chk;
	next_state<=state;
	next_data1<=data1;
	next_datao<=datao;
	next_data2<=data2;
	next_data3<=data2;
case state is 
	when st_idle=>
		n_chk<='0';
		--txo<='0';
		if ri ='1' then
			next_state<=st_data1;
--		datao<=di;
--		end if;		
		--else 
--			next_state <= st_trans;
		end if;
	when st_data1 =>
		next_data1<=di;
		next_state<=st_intrp1;
	when st_intrp1 =>
		if (data1 = x"F0") or (data1=x"F0")  then
			
			next_state<=st_wait1;
--		elsif (data1 = x"58") then
--		   if bi ='0' then			
--			txo<='1';
--			txd<=x"ED";
--			next_state <= st_ledwait;
--		   end if;
		elsif data1= x"1C" then
			n_chk<='1';
--			txo<='1';
--			txd<=x"ED";
			next_datao<=x"61";
			next_state <= st_idle;
		elsif data1= x"1B" then
			n_chk<='1';
			next_datao<=x"73";
			next_state<=st_idle;
		elsif data1= x"23" then
			n_chk<='1';
			next_datao<=x"64";
			next_state<=st_idle;
		elsif data1= x"2B" then
			n_chk<='1';
			next_datao<=x"66";
			next_state<=st_idle;
		elsif data1= x"34" then
			n_chk<='1';
			next_datao<=x"67";
			next_state<=st_idle;
		elsif data1= x"33" then
			n_chk<='1';
			next_datao<=x"68";
			next_state<=st_idle;
		elsif data1= x"3B" then
			n_chk<='1';
			next_datao<=x"6A";
			next_state<=st_idle;
		elsif data1= x"42" then
			n_chk<='1';
			next_datao<=x"6B";
			next_state<=st_idle;
		elsif data1= x"4B" then
			n_chk<='1';
			next_datao<=x"6C";
			next_state<=st_idle;
		elsif data1= x"4C" then
			n_chk<='1';
			next_datao<=x"3B";
			next_state<=st_idle;
		elsif data1= x"52" then
			n_chk<='1';
			next_datao<=x"27";
			next_state<=st_idle;
		elsif data1= x"5A" then
			n_chk<='1';
			next_datao<=x"0C";
			next_state<=st_idle;
		elsif data1= x"0D" then
			n_chk<='1';
			next_datao<=x"0B";
			next_state<=st_idle;
		elsif data1= x"15" then
			n_chk<='1';
			next_datao<=x"71";
			next_state<=st_idle;
		elsif data1= x"1D" then
			n_chk<='1';
			next_datao<=x"77";
			next_state<=st_idle;
		elsif data1= x"24" then
			n_chk<='1';
			next_datao<=x"65";
			next_state<=st_idle;
		elsif data1= x"2D" then
			n_chk<='1';
			next_datao<=x"72";
			next_state<=st_idle;
		elsif data1= x"2C" then
			n_chk<='1';
			next_datao<=x"74";
			next_state<=st_idle;
		elsif data1= x"35" then
			n_chk<='1';
			next_datao<=x"79";
			next_state<=st_idle;
		elsif data1= x"3C" then
			n_chk<='1';
			next_datao<=x"75";
			next_state<=st_idle;
		elsif data1= x"43" then
			n_chk<='1';
			next_datao<=x"69";
			next_state<=st_idle;
		elsif data1= x"44" then
			n_chk<='1';
			next_datao<=x"6F";
			next_state<=st_idle;
		elsif data1= x"4D" then
			n_chk<='1';
			next_datao<=x"70";
			next_state<=st_idle;
		elsif data1= x"54" then
			n_chk<='1';
			next_datao<=x"5B";
			next_state<=st_idle;
		elsif data1= x"5B" then
			n_chk<='1';
			next_datao<=x"5D";
			next_state<=st_idle;
		elsif data1= x"0E" then
			n_chk<='1';
			next_datao<=x"73";
			next_state<=st_idle;
		elsif data1= x"16" then
			n_chk<='1';
			next_datao<=x"31";
			next_state<=st_idle;
		elsif data1= x"1E" then
			n_chk<='1';
			next_datao<=x"32";
			next_state<=st_idle;
		elsif data1= x"26" then
			n_chk<='1';
			next_datao<=x"33";
			next_state<=st_idle;
		elsif data1= x"25" then
			n_chk<='1';
			next_datao<=x"34";
			next_state<=st_idle;
		elsif data1= x"2E" then
			n_chk<='1';
			next_datao<=x"35";
			next_state<=st_idle;
		elsif data1= x"36" then
			n_chk<='1';
			next_datao<=x"36";
			next_state<=st_idle;
		elsif data1= x"3E" then
			n_chk<='1';
			next_datao<=x"38";
			next_state<=st_idle;
		elsif data1= x"3D" then
			n_chk<='1';
			next_datao<=x"37";
			next_state<=st_idle;
		elsif data1= x"46" then
			n_chk<='1';
			next_datao<=x"39";
			next_state<=st_idle;
		elsif data1= x"45" then
			n_chk<='1';
			next_datao<=x"30";
			next_state<=st_idle;
		elsif data1= x"4E" then
			n_chk<='1';
			next_datao<=x"2D";
			next_state<=st_idle;
		elsif data1= x"55" then
			n_chk<='1';
			next_datao<=x"3D";
			next_state<=st_idle;
		elsif data1= x"66" then
			n_chk<='1';
			next_datao<=x"08";
			next_state<=st_idle;
		elsif data1= x"1A" then
			n_chk<='1';
			next_datao<=x"7A";
			next_state<=st_idle;
		elsif data1= x"22" then
			n_chk<='1';
			next_datao<=x"78";
			next_state<=st_idle;
		elsif data1= x"21" then
			n_chk<='1';
			next_datao<=x"63";
			next_state<=st_idle;
		elsif data1= x"2A" then
			n_chk<='1';
			next_datao<=x"76";
			next_state<=st_idle;
		elsif data1= x"32" then
			n_chk<='1';
			next_datao<=x"62";
			next_state<=st_idle;
		elsif data1= x"31" then
			n_chk<='1';
			next_datao<=x"6E";
			next_state<=st_idle;
		elsif data1= x"3A" then
			n_chk<='1';
			next_datao<=x"6D";
			next_state<=st_idle;
		elsif data1= x"41" then
			n_chk<='1';
			next_datao<=x"2C";
			next_state<=st_idle;
		elsif data1= x"49" then
			n_chk<='1';
			next_datao<=x"2E";
			next_state<=st_idle;
		elsif data1= x"4A" then
			n_chk<='1';
			next_datao<=x"2F";
			next_state<=st_idle;
		elsif data1= x"29" then
			n_chk<='1';
			next_datao<=x"20";
			next_state<=st_idle;

		else
			n_chk<='1';
			next_datao<=((data1));
			next_state<=st_idle;
		end if;
	when st_wait1 =>
		if ri='1' then
			next_state <= st_data2;
		end if;
	when st_data2 =>
		next_data2<=di;
		next_state<=st_intrp2;
	when st_intrp2 =>
			next_state<=st_idle;
--	when st_ledwait =>
--		txo<='0';
--		if ri = '1' then
--			
--				next_state<=st_ledlit;
--			
--		
--		end if;
--	when st_ledlit =>
--				
--		txo<='1';
--		txd<=x"02";
--		next_state<=st_idle;				
--	when st_trans =>
--		txo<='1';
--		txd<=x"EE";
--		if ri = '1'	then
--		next_state<=st_idle;
--		end if;
end case;


ro<=chk;
do<=datao;




end process;

end rtl;
