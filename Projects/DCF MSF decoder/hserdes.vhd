library IEEE;
library UNISIM;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity serdes is

    generic
    (
        gate_delay:   time      := 1 ns
    );

    port
    (
        clk_ser:  in  std_logic := 'X';      -- serial clock in
        clk_par:  in  std_logic := 'X';      -- parallel clock in
        clk_2par: in  std_logic := 'X';      -- 2 x parallel clock in
        strobe:   in  std_logic := 'X';      -- strobe
        data_in:  in  std_logic := 'X';      -- serial data in
        data_out: out byte      := byte_null -- parallel data out
   );

end serdes;

architecture behav of serdes is

  type states is (X_1,X_2,X_3);
signal  btout: unsigned(3 downto 0) := (others => '0');
signal  n_btout: unsigned(3 downto 0) := (others => '0');
signal  btout1: unsigned(3 downto 0) := (others => '0');
signal  n_btout1: unsigned(3 downto 0) := (others => '0');
signal  b0 : std_logic := '0' ;
signal  b1 : std_logic := '0' ;
signal  n_b0 : std_logic := '0' ;
signal  n_b1 : std_logic := '0' ;
signal  n_dout : byte := byte_null ;
signal  b2 : std_logic := '0' ;
signal  b3 : std_logic := '0' ;
signal  n_b2 : std_logic := '0' ;
signal  n_b3 : std_logic := '0' ;

signal current_state:	states	:= X_1;
signal next_state:	states := X_1;
begin
process(clk_ser )
begin
if clk_ser'event and (clk_ser = '1') then
current_state <= next_state;
b0<=n_b0;
b1<=n_b1;
b2<=n_b2;
b3<=n_b3;
btout<= btout1;
--data_out<=byte_null;
end if;
end process;
process (current_state, clk_par,b0,b1,btout,data_in)
begin
next_state <= current_state;
n_b0<=b0;
n_b1<=b1;
n_b2<=b2;
n_b3<=b3;
btout1<= btout;
--data_out<= byte_null;
--n_dout<=data_out;
case current_state is 
when X_1 =>
if clk_par'event and clk_par ='1' then
--btout <= ( b3 & b2 & b1 & b0 );
--tout1 <= ( btout & btout );
data_out <= byte(btout);
end if;
n_b0 <= data_in;
next_state <= X_2;
when X_2 =>
n_b1 <= data_in;
next_state <= X_3;
when X_3 =>

btout1 <= ( b1 & b1 & b1 & b1 &b0&b0&b0&b0 );

--data_out <= byte(btout1);
next_state <= X_1;


end case;
end process;
end behav;