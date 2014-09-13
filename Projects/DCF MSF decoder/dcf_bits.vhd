library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity dcf_bits is

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
        si:  in  std_logic := 'X';          -- start of second in
        bo:  out std_logic := '0';          -- bit out
        tr:  out std_logic := '0'           -- new bit trigger
    );

end dcf_bits;

architecture rtl of dcf_bits is

 --constant b0: natural := (clk_freq / 1000)*20; 
	constant b1: natural := (clk_freq / 1000)*150;
	
	constant max_counter: natural := (clk_freq / 1000)*300;

 
    signal  counter: unsigned(max(1, n_bits(max_counter) - 1) downto 0) 		 := (others => '0');
    signal  next_counter: unsigned(max(1, n_bits(max_counter) - 1) downto 0) := (others => '0');
    
    type states is (si_det , cntr , prcs);
    signal current_state:		states 	:=si_det;
    signal next_state:			states	:= si_det;
	signal curr_bo : std_logic := '0';
	signal next_bo : std_logic := '0';



begin
 process (rst,clk, counter) 
begin	

if (rst = '1') then 

counter <= (others => '0') after gate_delay;
current_state <= si_det;
curr_bo <= '0';
elsif clk'event and (clk = '1') then
current_state <= next_state  after gate_delay;
counter <= next_counter    after gate_delay;
curr_bo <= next_bo;
end if;

end process;

process(current_state, counter,di,si,curr_bo)
begin	

next_state <= current_state;
next_counter <= counter;
next_bo <= curr_bo;
tr<='0';

case current_state is

when si_det =>

if (si= '1') then
next_state <= cntr    after gate_delay;

end if ;


when cntr =>
next_counter <= counter + 1   after gate_delay;
if (counter > b1 ) then
next_state <= prcs    after gate_delay;
next_counter <= (others => '0')   after gate_delay;

end if;

when prcs =>
tr <='1';
if ( di(7) ='1' ) then
next_bo <='1';

elsif ( di(7) = '0') then
next_bo <='0';
end if;

next_state <= si_det    after gate_delay;
end case;

end process;
bo<=next_bo;

end rtl;
