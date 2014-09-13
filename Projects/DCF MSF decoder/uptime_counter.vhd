library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uptime_counter is

    generic
    (
        gate_delay: time                                := 1 ns;
        width:      positive                            := 64
    );

    port
    (
        rst: in  std_logic                              := 'X';             -- reset
        clk: in  std_logic                              := 'X';             -- clock
        
        cnt: out std_logic_vector((width - 1) downto 0) := (others => '0')  -- clock cycle counter out
    );

end uptime_counter;

architecture rtl of uptime_counter is

signal ctr: unsigned((width - 1) downto 0) := (others => '0');
signal n_ctr: unsigned((width - 1) downto 0) := (others => '0');
begin
ctr<=n_ctr;
process(rst,clk,ctr)
begin
if (rst='1') then
--cnt <= (others => '0');
--ctr <= (others => '0');
n_ctr <= (others => '0');
elsif clk'event and clk='1' then
--if (ctr=64) then
--n_ctr <= (others => '0');
--else
n_ctr<=ctr+1; 
end if;
--end if;
end process;
process(ctr)
begin
cnt<=std_logic_vector(ctr((width - 1) downto 0));
end process;
end rtl;
