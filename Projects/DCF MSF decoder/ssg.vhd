library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity ssg is

    generic
    (
        clk_freq:   positive := 125000000;  -- H
        gate_delay: time     := 0.1 ns
    );

    port
    (
        clk: in  std_logic                    :=            'X';           -- clock
        wr:  in  std_logic                    :=            'X';           -- write
        di:  in  byte_vector(3 downto 0)      := (others => byte_unknown); -- data in
        an:  out std_logic_vector(3 downto 0) := (others => '1');          -- anodes   7 segment display
        ka:  out std_logic_vector(7 downto 0) := (others => '1')           -- kathodes 7 segment display
   );

end ssg;

architecture behav of ssg is
constant nwclk: natural := (clk_freq / 400);
constant d3:std_logic_vector(3 downto 0) := "0111";
constant d2:std_logic_vector(3 downto 0) := "1011";
constant d1:std_logic_vector(3 downto 0) := "1101";
constant d0:std_logic_vector(3 downto 0) := "1110";
    type states is (i , ii , iii,iv);
    signal current_state:		states 	:=i;
    signal next_state:			states	:= i;
 signal  counter: unsigned(max(1, n_bits(nwclk) - 1) downto 0) 		 := (others => '0');
    signal  next_counter: unsigned(max(1, n_bits(nwclk) - 1) downto 0) := (others => '0');
    

begin
 process (clk) 
begin	


if clk'event and (clk = '1') then

if (wr = '0') then
if (counter = 0 ) then
current_state <= next_state  after gate_delay;

end if ;
counter <= next_counter;
end if;
end if;
end process;
process ( counter)
begin
next_counter <= counter +1 ;
if (counter = nwclk ) then
next_counter  <= (others => '0');
end if;
end process;

process(current_state, di)
begin
case current_state is 

when i =>
an <= d3  after gate_delay;
ka <= di(0)  after gate_delay;
next_state <= ii    after gate_delay;

when ii =>
an <=d2  after gate_delay;
ka <= di(1) after gate_delay;
next_state <= iii    after gate_delay;

when iii =>
an <=d1  after gate_delay;
ka <= di(2) after gate_delay;
next_state <= iv    after gate_delay;

when iv =>
an <=d0  after gate_delay;
ka <=di(3)  after gate_delay;
next_state <= i    after gate_delay;
end case;
end process;
end behav;
