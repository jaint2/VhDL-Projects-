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
signal i : natural:= 0;
signal n_i : natural:= 0;
signal  btout: unsigned(3 downto 0) := (others => '0');
signal  n_btout: unsigned(3 downto 0) := (others => '0');
signal  btout1: unsigned(3 downto 0) := (others => '0');
signal  n_btout1: unsigned(3 downto 0) := (others => '0');
signal  ftout1: unsigned(7 downto 0) := (others => '0');
signal  n_ftout1: unsigned(7 downto 0) := (others => '0');
signal  b0 : std_logic := '0' ;
signal  V0 : std_logic := '0' ;
signal  V1 : std_logic := '0' ;
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




ISERDES2_inst : ISERDES2
generic map (
BITSLIP_ENABLE => FALSE, -- Enable Bitslip Functionality (TRUE/FALSE)
DATA_RATE => "DDR",-- Data-rate ("SDR" or "DDR")
DATA_WIDTH => 8,-- Parallel data width selection (2-8)
INTERFACE_TYPE => "NETWORKING", -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED"
SERDES_MODE => "MASTER"-- "NONE", "MASTER" or "SLAVE"
)
port map (
--CFB0 => CFB0,-- 1-bit output: Clock feed-through route output
--CFB1 => CFB1,-- 1-bit output: Clock feed-through route output
--DFB => DFB,-- 1-bit output: Feed-through clock output
--FABRICOUT => FABRICOUT, -- 1-bit output: Unsynchrnonized data output
--INCDEC => INCDEC, -- 1-bit output: Phase detector output
-- Q1 - Q4: 1-bit (each) output: Registered outputs to FPGA logic
Q1 =>b0,
Q2 =>b1,
Q3 =>b2,
Q4 =>b3,
SHIFTOUT => V1, -- 1-bit output: Cascade output signal for master/slave I/O
--VALID => VALID,-- 1-bit output: Output status of the phase detector
--BITSLIP => BITSLIP, -- 1-bit input: Bitslip enable input
CE0 =>'1',-- 1-bit input: Clock enable input
CLK0 => clk_ser,-- 1-bit input: I/O clock network input
CLK1=>clk_ser,-- 1-bit input: Secondary I/O clock network input
CLKDIV =>clk_par , -- 1-bit input: FPGA logic domain clock input
D => data_in,-- 1-bit input: Input data
IOCE=>strobe,-- 1-bit input: Data strobe input
--RST => RST,-- 1-bit input: Asynchronous reset input
SHIFTIN =>V0-- 1-bit input: Cascade input signal for master/slave I/O
);



ISERDES2_instslave : ISERDES2
generic map (
BITSLIP_ENABLE => FALSE, -- Enable Bitslip Functionality (TRUE/FALSE)
DATA_RATE => "DDR",-- Data-rate ("SDR" or "DDR")
DATA_WIDTH => 8,-- Parallel data width selection (2-8)
INTERFACE_TYPE => "NETWORKING", -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED"
SERDES_MODE => "SLAVE"-- "NONE", "MASTER" or "SLAVE"
)
port map (
--CFB0 => CFB0,-- 1-bit output: Clock feed-through route output
--CFB1 => CFB1,-- 1-bit output: Clock feed-through route output
--DFB => DFB,-- 1-bit output: Feed-through clock output
--FABRICOUT => FABRICOUT, -- 1-bit output: Unsynchrnonized data output
--INCDEC => INCDEC, -- 1-bit output: Phase detector output
-- Q1 - Q4: 1-bit (each) output: Registered outputs to FPGA logic
Q1 =>n_b0,
Q2 =>n_b1,
Q3 =>n_b2,
Q4 =>n_b3,
SHIFTOUT => V0, -- 1-bit output: Cascade output signal for master/slave I/O
--VALID => VALID,-- 1-bit output: Output status of the phase detector
--BITSLIP => BITSLIP, -- 1-bit input: Bitslip enable input
CE0 =>'1',-- 1-bit input: Clock enable input
CLK0 => clk_ser,-- 1-bit input: I/O clock network input
CLK1=>clk_ser,-- 1-bit input: Secondary I/O clock network input
CLKDIV =>clk_par , -- 1-bit input: FPGA logic domain clock input
D => data_in,-- 1-bit input: Input data
IOCE=>strobe,-- 1-bit input: Data strobe input
--RST => RST,-- 1-bit input: Asynchronous reset input
SHIFTIN =>V1-- 1-bit input: Cascade input signal for master/slave I/O
);


process(clk_par)
begin
if clk_par'event and (clk_par = '1') then
data_out(7 downto 0)<=(b3&b2&b1&b0&n_b3&n_b2&n_b1&n_b0);


end if;
end process;
end behav;


