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
signal cur_data : byte := byte_unknown ;
signal nxt_data : byte := byte_unknown ;
begin
cur_data <= nxt_data;
process(rst , clk,di)
begin 
ed <='0';
if (rst ='1') then
do<= byte_null;
ed<='0';
elsif (clk'event and clk='1') then
if (di(7)= '0') and (di(0) = '1') then
	ed<='1';

elsif (di(7)= '0') and (di(0) = '0') then
	ed<='0';

elsif (di(7)='1') and (di(0) = '0')  then
	ed<='1';
elsif (di(7)='1') and (di(0) = '1')  then
	ed<='0';
end if;
end if;
end process;

end rtl;
