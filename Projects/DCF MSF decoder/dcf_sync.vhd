library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity dcf_sync is

    generic
    (
        clk_freq:   positive := 125000000; -- Hz
        gate_delay: time     := 1 ns
    );

    port
    (
        rst: in  std_logic := 'X';          -- reset
        clk: in  std_logic := 'X';          -- clock
        di:  in  byte      := byte_unknown; -- data in
        so:  out std_logic := '0';          -- start of second
        mo:  out std_logic := '0'           -- start of minute
    );

end dcf_sync;

architecture rtl of dcf_sync is

	constant b0: natural := (clk_freq / 1000)*1020; 
	constant b1: natural := (clk_freq / 1000)*1050;
	constant tolerance: natural := (clk_freq / 1000)*980;
	constant max_counter: natural := (clk_freq / 1000)*2500;
	constant nocnt: time := 1000000000 ns; 
	signal ri : std_logic := '0';
	signal cur_fi : std_logic := '0';	
	signal nxt_fi : std_logic := '0';	
	signal counter: unsigned(max(1, n_bits(max_counter) - 1) downto 0) := (others => '0');
	signal next_counter: unsigned(max(1, n_bits(max_counter) - 1) downto 0) := (others => '0');
    
	type states is (neutral, rising);
	signal current_state:	states := neutral;
	signal next_state:	states := neutral;
    
--	signal valid_bits: integer	:= 0;
    

    


begin


process (rst,clk) 
begin	

if (rst = '1') then 
ri<= '0';
counter <= (others => '0') after gate_delay;
current_state <= neutral;

elsif clk'event and (clk = '1') then
current_state <= next_state  after gate_delay;
counter <= next_counter    after gate_delay;
cur_fi <= nxt_fi;
if (di(7)= '0') and (di(0) = '1') then
	ri<='1' ;-- after gate_delay;
	--fi<=0  after gate_delay;
elsif (di(7)= '0') and (di(0) = '0') then
	ri<='0'  ;--after gate_delay;

elsif (di(7)='1') and (di(0) = '0')  then
	--fi<=1  after gate_delay;
	ri<='0' ;-- after gate_delay;
elsif (di(7)='1') and (di(0) = '1')  then
	--fi<=1  after gate_delay;
	ri<='1'  ;--after gate_delay;

end if;

end if;

end process;

process(current_state, counter,ri,cur_fi)
begin	



mo <= '0' after gate_delay;
so <= '0' after gate_delay;

next_counter <= counter + 1   after gate_delay;
next_state <= current_state;
nxt_fi<=cur_fi;
case current_state is

when neutral =>

if (ri = '1') and (counter > tolerance) and (counter < b0)  then
if (cur_fi = '1') then
mo <= '1'  after gate_delay;
so <= '1'   after gate_delay;
nxt_fi<='0' after gate_delay;
else
so <= '1'  after gate_delay;
end if;
--valid_bits <=valid_bits + 1    after gate_delay;
next_counter <= (others => '0')   after gate_delay;
next_state <= rising   after gate_delay;
			

elsif (counter > b1)  then

next_counter <= (others => '0')   after gate_delay;
--mo <= '1'  after gate_delay;
so <= '1'   after gate_delay;
--valid_bits <= 0    after gate_delay;
nxt_fi<='1' after gate_delay;

next_counter <= (others => '0')   after gate_delay;

next_state <= rising   after gate_delay;



 end if;

when rising =>

next_state <= neutral    after gate_delay;



end case;

end process;



end rtl;


