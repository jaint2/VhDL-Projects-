library IEEE;
library UNISIM;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;
Library UNISIM;
use UNISIM.vcomponents.all;



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


type states is (X_1,X_2);
--signal i : natural:= 0;
--signal n_i : natural:= 0;
signal  btout: unsigned(3 downto 0) := (others => '0');
signal  n_btout: unsigned(3 downto 0) := (others => '0');
signal  btout1: unsigned(7 downto 0) := (others => '0');
signal  n_btout1: unsigned(7 downto 0) := (others => '0');
--signal  ftout1: unsigned(7 downto 0) := (others => '0');
--signal  n_ftout1: unsigned(7 downto 0) := (others => '0');
--signal  b : byte := byte_null ;
--signal  n_dout : byte := byte_null ;
signal current_state:	states	:= X_1;
signal next_state:	states := X_1;
begin
ISERDES2_inst : ISERDES2
generic map (
BITSLIP_ENABLE => FALSE, -- Enable Bitslip Functionality (TRUE/FALSE)
DATA_RATE => "SDR",-- Data-rate ("SDR" or "DDR")
DATA_WIDTH => 4,-- Parallel data width selection (2-8)
INTERFACE_TYPE => "NETWORKING", -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED"
SERDES_MODE => "NONE"-- "NONE", "MASTER" or "SLAVE"
)
port map (
CFB0 => open,-- 1-bit output: Clock feed-through route output
CFB1 => open,-- 1-bit output: Clock feed-through route output
DFB => open,-- 1-bit output: Feed-through clock output
FABRICOUT => open, -- 1-bit output: Unsynchrnonized data output
INCDEC => open, -- 1-bit output: Phase detector output
-- Q1 - Q4: 1-bit (each) output: Registered outputs to FPGA logic
Q1 =>n_btout(0),
Q2 =>n_btout(1),
Q3 =>n_btout(2),
Q4 =>n_btout(3),
SHIFTOUT => open, -- 1-bit output: Cascade output signal for master/slave I/O
VALID => open,-- 1-bit output: Output status of the phase detector
BITSLIP => '0', -- 1-bit input: Bitslip enable input
CE0 =>'1',-- 1-bit input: Clock enable input
CLK0 => clk_ser,-- 1-bit input: I/O clock network input
CLK1=>'0',-- 1-bit input: Secondary I/O clock network input
CLKDIV =>clk_2par , -- 1-bit input: FPGA logic domain clock input
D => data_in,-- 1-bit input: Input data
IOCE=>strobe,-- 1-bit input: Data strobe input
RST => '0',-- 1-bit input: Asynchronous reset input
SHIFTIN =>'0'-- 1-bit input: Cascade input signal for master/slave I/O
);

process(clk_2par)
begin 

if clk_2par'event and clk_2par= '1' then
btout<=n_btout;
btout1<=n_btout1;
current_state<=next_state;
end if;
end process;


process(current_state,clk_par)
begin
next_state<=current_state;
n_btout1<=btout1;
case current_state is 
when X_1=>
n_btout1(3 downto 0)<= btout;
--if  clk_par'event and clk_par= '1' then
next_state<=X_2;
--else
--next_state<=X_1;
--end if;

when X_2 =>
n_btout1(7 downto 4)<= btout;
next_state<=X_1;
end case;
end process;

process (clk_par)
begin
data_out<=byte(btout1);
end process;
end behav;


