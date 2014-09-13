library IEEE;

use IEEE.std_logic_1164.all;
use WORK.util.all;

entity top_level is

    port
    (
        clk:  in  std_logic;                    -- clock

        sw:   in  std_logic_vector(7 downto 0); -- switches
        an:   out std_logic_vector(3 downto 0); -- anodes   7 segment display
        ka:   out std_logic_vector(7 downto 0); -- kathodes 7 segment display
        ld:   out std_logic_vector(7 downto 0); -- leds
        rx:   in  std_logic;                    -- uart rx 
        tx:   out std_logic;                    -- uart tx
	 clk_key: inout std_logic;
	 data_key:inout std_logic 
   );

end top_level;

architecture behav of top_level is

    constant clk_freq:   positive  := 100000000; -- Hz
    constant clk_period: time      :=  1000 ms / clk_freq;
    constant debounce:   natural   := 80; -- us
    constant baud_rate:  positive  :=   57600; -- Baud
    constant bit_period: time      :=  1000 ms / baud_rate;
    constant ts_digits:  positive  := 5 + 8;
    constant signals:    positive  := 8;
    constant fifo_size:  positive  := 16;

    signal   rst:      std_logic                                  :=            '0';

    signal   wit:     std_logic                                  :=            '0';
    signal   wat:     std_logic                                  :=            '0';

    signal   sp_d:     std_logic                                  :=            '0';
	signal rx_o: byte  := byte_unknown;
	signal rx_i: byte  := byte_unknown;
begin


    serial_port_unit: entity WORK.serial_port 
    generic map
    (
        clk_freq   => clk_freq,
        baud_rate  => baud_rate
    )
    port map
    (
        rst        => rst,
        clk        => clk,
an => an,
        wi         => wat,
        di         => rx_i,
       -- bi         => sp_b,
--	kclk => clk_key,
--	 krx	     => data_key,
        do         => sp_d
--	krxo		=> open
    );


	intrp_unit : entity WORK.intrp
	port map
	(
	clk =>clk,
	rst =>rst,
	ri  =>wit,
	di  =>rx_o,
	ro  =>wat,
	do  =>rx_i
    );

	ps1_unit :entity WORK.ps1
	port map
	(
        rst   => rst,
        clk   =>clk,
        kclk  =>clk_key,
        kdata =>data_key,
        do	=>rx_o,
	 busy => open,
 	 ro	=>wit
       );






    rst   <= sw(0);

    ka    <= (others => '0');

   -- ld<= std_logic_vector((rx_o));
process( sw(7),sp_d,rx,wit,rx_i)
begin
if sw(7)='0' then
    
    tx    <= sp_d;
else
tx<= rx;
end if;
--if (wit = '1') then
ld(7 downto 0) <= std_logic_vector((rx_i(7 downto 0)));

--end if;
end process;

end behav;
