library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity edge_detector is

    generic
    (
        gate_delay: time     := 1 ns
    );

    port
    (
        rst: in  std_logic := 'X';          -- reset
        clk: in  std_logic := 'X';          -- clock
        
        di:  in  byte      := byte_unknown; -- data in
        do:  out byte      := byte_null;    -- data out
        ed:  out std_logic := '0'           -- edge detected
    );

end edge_detector;

architecture rtl of edge_detector is

signal ri : std_logic := '0';
signal fi : std_logic := '0';
signal cur_d :std_logic := '0';
signal nxt_d :std_logic := '0';
begin

--ed<='0';
process(clk,rst,di)
begin 
if rst='1' then
nxt_d<='0';

--do<=byte_null;
end if;
nxt_d<='0';
--if (clk'event and (clk='1' or clk='0')) then
if (di(7)= '0') and (di(0) = '1') then
	nxt_d<='1';

elsif (di(7)= '0') and (di(0) = '0') then
	nxt_d<='0';

elsif (di(7)='1') and (di(0) = '0')  then
	nxt_d<='1';
elsif (di(7)='1') and (di(0) = '1')  then
	nxt_d<='0';
end if;
--else
--nxt_d<='0';
--end if;
end process;
cur_d<=nxt_d;
process (clk ,di,cur_d)
begin
--if clk'event then
ed<= cur_d;
do<=di;
--end if;
end process;
end rtl;
