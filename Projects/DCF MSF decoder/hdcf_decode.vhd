library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity dcf_decode is

    generic
    (
        clk_freq:   positive := 125000000; -- Hz
        gate_delay: time     := 1 ns
    );

    port
    (
        rst:    in  std_logic                    := 'X'; -- reset
        clk:    in  std_logic                    := 'X'; -- clock
        
        si:     in  std_logic                    := 'X'; -- start of second in
        mi:     in  std_logic                    := 'X'; -- start of minute in
        bi:     in  std_logic                    := 'X'; -- bit in
        year:   out bcd_digit_vector(3 downto 0) := (3 => bcd_two, 2 => bcd_zero, others => bcd_minus);
        month:  out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        day:    out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        hour:   out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        minute: out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        second: out bcd_digit_vector(1 downto 0) := (others => bcd_zero);  
        tr:     out std_logic                    := '0'  -- new bit trigger
    );

end dcf_decode;

architecture rtl of dcf_decode is

signal curr_bit : std_logic_vector(59 downto 0) := (others => '0');
signal next_bit : std_logic_vector(59 downto 0) := (others => '0');  
signal cntr : integer := 0;
signal next_cntr : integer:= 0;
    type states is (si_det , bit_det , dout);
    signal current_state:		states 	:=si_det;
    signal next_state:			states	:= si_det;
begin

 process (rst,clk) 
begin	

if (rst = '1') then 


current_state <= si_det;
cntr <= 0;
curr_bit <= (others=>'0');
elsif clk'event and (clk = '1') then
current_state <= next_state  after gate_delay;
cntr <= next_cntr    after gate_delay;
curr_bit <= next_bit;
end if;

end process;
process (current_state , si , bi , mi , cntr)
begin
next_state <= current_state;
next_cntr <= cntr;
next_bit <= curr_bit;

case current_state is

when si_det =>
if (si='1') then
next_state <= bit_det after gate_delay;
end if;

 when bit_det =>
if(mi='1') then
next_cntr <= 0;
next_state <= si_det;
else
next_bit(cntr)<=bi;
next_cntr <= cntr+1;
if (cntr = 58) then
next_state <= dout;
else
next_state<= si_det;
end if;
end if;

when dout=>
next_state => si_det;
end case;

end process;
process(tr)
begin
if(tr ='1') then
so <= next_cntr;
end if;
end process;
end rtl;
