library IEEE;
library UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;
entity ddrserdes is
    generic
    (
        gate_delay:   time                                       := 1 ns;
        ibuf_len:     positive                                   := 2
    );
    port
    (
        clk_par:  in  std_logic                                  := 'X';      -- parallel clock in
        clk_2par: in  std_logic                                  := 'X';      -- 2 x parallel clock in
        data_in:  in  std_logic                                  := 'X';      -- serial data in
        data_out: out byte                                       := byte_null -- parallel data out
   );
end ddrserdes;
architecture behav of ddrserdes is
 type states is (X_1,X_2,X_3,X_4);
signal  btout: unsigned(3 downto 0) := (others => '0');
signal  btout1: unsigned(7 downto 0) := (others => '0');
signal  b0 : std_logic := '0' ;
signal  b1 : std_logic := '0' ;
signal  b2 : std_logic := '0' ;
signal  b3 : std_logic := '0' ;
signal current_state:	states	:= X_1;
signal next_state:	states := X_1;
begin
process(clk_2par )
begin
if clk_2par'event and (clk_2par = '1') then
current_state <= next_state;
end if;
end process;
process (current_state)
begin
case current_state is 
when X_1 =>
b0 <= data_in;
next_state <= X_2;
when X_2 =>
b1 <= data_in;
next_state <= X_3;
when X_3 =>
b2 <= data_in;
next_state <= X_4;
when X_4 =>
b3 <= data_in;
btout <= ( b3 & b2 & b1 & b0 );
btout1 <= ( btout & btout );
data_out <= byte(btout1);
next_state <= X_1;
end case;
end process;
end behav;

