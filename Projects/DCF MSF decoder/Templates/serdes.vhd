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


-- type states is (X_1,X_2);
--signal i : natural:= 0;
--signal n_i : natural:= 0;
--signal  btout: unsigned(3 downto 0) := (others => '0');
--signal  n_btout: unsigned(3 downto 0) := (others => '0');
--ignal  btout1: unsigned(3 downto 0) := (others => '0');
--signal  n_btout1: unsigned(3 downto 0) := (others => '0');
--signal  ftout1: unsigned(7 downto 0) := (others => '0');
--signal  n_ftout1: unsigned(7 downto 0) := (others => '0');
signal  b : byte := byte_null ;
--signal  V0 : std_logic := '0' ;
signal  V1 : std_logic := '0' ;
signal  d_m : std_logic := '0' ;
signal  d_2m : std_logic := '0' ;
signal  d_s: std_logic := '0' ;
signal  d_2s : std_logic := '0' ;
signal  n_dout : byte := byte_null ;


--signal current_state:	states	:= X_1;
--signal next_state:	states := X_1;



begin


  IODELAY2_M : IODELAY2
  generic map (
    COUNTER_WRAPAROUND => "WRAPAROUND", -- "STAY_AT_LIMIT" or "WRAPAROUND"
    DATA_RATE => "SDR", -- "SDR" or "DDR"
    DELAY_SRC => "IDATAIN", -- "IO", "ODATAIN" or "IDATAIN"
    IDELAY_MODE => "NORMAL", -- "NORMAL" or "PCI"
    IDELAY_TYPE => "FIXED", -- "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX"
                              -- or "DIFF_PHASE_DETECTOR"
    IDELAY_VALUE => 0, -- Amount of taps for fixed input delay (0-255)
    IDELAY2_VALUE => 0, -- Delay value when IDELAY_MODE="PCI" (0-255)
    ODELAY_VALUE => 0, -- Amount of taps fixed output delay (0-255)
    SERDES_MODE => "NONE" -- "NONE", "MASTER" or "SLAVE"
-- SIM_TAPDELAY_VALUE=> 43 -- Per tap delay used for simulation in ps
   )
  port map (
    BUSY => open, -- 1-bit output: Busy output after CAL
    DATAOUT => d_m, -- 1-bit output: Delayed data output to ISERDES/input register
    DATAOUT2 => d_2m, -- 1-bit output: Delayed data output to general FPGA fabric
    DOUT => open, -- 1-bit output: Delayed data output
    TOUT => open, -- 1-bit output: Delayed 3-state output
    CAL => '0', -- 1-bit input: Initiate calibration input
    CE => '0', -- 1-bit input: Enable INC input
    CLK => clk_par, -- 1-bit input: Clock input
    IDATAIN => data_in, -- 1-bit input: Data input (connect to top-level port or I/O buffer)
    INC => '0', -- 1-bit input: Increment / decrement input
    IOCLK0 => clk_ser, -- 1-bit input: Input from the I/O clock network
    IOCLK1 => '0', -- 1-bit input: Input from the I/O clock network
    ODATAIN => '0', -- 1-bit input: Output data input from output register or OSERDES2.
    RST => '0', -- 1-bit input: reset_i to zero or 1/2 of total delay period
    T => '0' -- 1-bit input: 3-state input signal
   );


  IODELAY2_S : IODELAY2
  generic map (
    COUNTER_WRAPAROUND => "WRAPAROUND", -- "STAY_AT_LIMIT" or "WRAPAROUND"
    DATA_RATE => "SDR", -- "SDR" or "DDR"
    DELAY_SRC => "IDATAIN", -- "IO", "ODATAIN" or "IDATAIN"
    IDELAY_MODE => "NORMAL", -- "NORMAL" or "PCI"
    IDELAY_TYPE => "FIXED", -- "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX"
                              -- or "DIFF_PHASE_DETECTOR"
    IDELAY_VALUE => 10,--29, -- Amount of taps for fixed input delay (0-255) 10->0.75nS, 11->0.825nS
    IDELAY2_VALUE => 0, -- Delay value when IDELAY_MODE="PCI" (0-255)
    ODELAY_VALUE => 0, -- Amount of taps fixed output delay (0-255)
    SERDES_MODE => "NONE" -- "NONE", "MASTER" or "SLAVE"
    --SIM_TAPDELAY_VALUE => 43 -- Per tap delay used for simulation in ps
   )
  port map (
    BUSY => open, -- 1-bit output: Busy output after CAL
    DATAOUT => d_s, -- 1-bit output: Delayed data output to ISERDES/input register
    DATAOUT2 => d_2s, -- 1-bit output: Delayed data output to general FPGA fabric
    DOUT => open, -- 1-bit output: Delayed data output
    TOUT => open, -- 1-bit output: Delayed 3-state output
    CAL => '0', -- 1-bit input: Initiate calibration input
    CE => '0', -- 1-bit input: Enable INC input
    CLK => clk_par, -- 1-bit input: Clock input
    IDATAIN => data_in, -- 1-bit input: Data input (connect to top-level port or I/O buffer)
    INC => '0', -- 1-bit input: Increment / decrement input
    IOCLK0 => clk_ser, -- 1-bit input: Input from the I/O clock network
    IOCLK1 => '0', -- 1-bit input: Input from the I/O clock network
    ODATAIN => '0', -- 1-bit input: Output data input from output register or OSERDES2.
    RST => '0', -- 1-bit input: reset_i to zero or 1/2 of total delay period
    T => '0' -- 1-bit input: 3-state input signal
   );







ISERDES2_inst : ISERDES2
generic map (
BITSLIP_ENABLE => FALSE, -- Enable Bitslip Functionality (TRUE/FALSE)
DATA_RATE => "SDR",-- Data-rate ("SDR" or "DDR")
DATA_WIDTH => 4,-- Parallel data width selection (2-8)
INTERFACE_TYPE => "NETWORKING_PIPELINED", -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED"
SERDES_MODE => "MASTER"-- "NONE", "MASTER" or "SLAVE"
)
port map (
CFB0 => open,-- 1-bit output: Clock feed-through route output
CFB1 => open,-- 1-bit output: Clock feed-through route output
DFB => open,-- 1-bit output: Feed-through clock output
FABRICOUT => open, -- 1-bit output: Unsynchrnonized data output
INCDEC => open, -- 1-bit output: Phase detector output
-- Q1 - Q4: 1-bit (each) output: Registered outputs to FPGA logic
Q1 =>data_out(4),
Q2 =>data_out(5),
Q3 =>data_out(6),
Q4 =>data_out(7),
SHIFTOUT => open, -- 1-bit output: Cascade output signal for master/slave I/O
VALID => open,-- 1-bit output: Output status of the phase detector
BITSLIP => '0', -- 1-bit input: Bitslip enable input
CE0 =>'1',-- 1-bit input: Clock enable input
CLK0 => clk_ser,-- 1-bit input: I/O clock network input
CLK1=>'0',-- 1-bit input: Secondary I/O clock network input
CLKDIV =>clk_par , -- 1-bit input: FPGA logic domain clock input
D => d_m,-- 1-bit input: Input data
IOCE=>strobe,-- 1-bit input: Data strobe input
RST => '0',-- 1-bit input: Asynchronous reset input
SHIFTIN =>'0'-- 1-bit input: Cascade input signal for master/slave I/O
);




ISERDES2_instslave : ISERDES2
generic map (
BITSLIP_ENABLE => FALSE, -- Enable Bitslip Functionality (TRUE/FALSE)
DATA_RATE => "SDR",-- Data-rate ("SDR" or "DDR")
DATA_WIDTH => 4,-- Parallel data width selection (2-8)
INTERFACE_TYPE => "NETWORKING_PIPELINED", -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED"
SERDES_MODE => "SLAVE"-- "NONE", "MASTER" or "SLAVE"
)
port map (
CFB0 => open,-- 1-bit output: Clock feed-through route output
CFB1 => open,-- 1-bit output: Clock feed-through route output
DFB => open,-- 1-bit output: Feed-through clock output
FABRICOUT => open, -- 1-bit output: Unsynchrnonized data output
INCDEC => open, -- 1-bit output: Phase detector output
-- Q1 - Q4: 1-bit (each) output: Registered outputs to FPGA logic
Q1 =>data_out(0),
Q2 =>data_out(1),
Q3 =>data_out(2),
Q4 =>data_out(3),
SHIFTOUT => open, -- 1-bit output: Cascade output signal for master/slave I/O
VALID => open,-- 1-bit output: Output status of the phase detector
BITSLIP => '0', -- 1-bit input: Bitslip enable input
CE0 =>'1',-- 1-bit input: Clock enable input
CLK0 => clk_ser,-- 1-bit input: I/O clock network input
CLK1=>'0',-- 1-bit input: Secondary I/O clock network input
CLKDIV =>clk_par , -- 1-bit input: FPGA logic domain clock input
D => d_m,-- 1-bit input: Input data
IOCE=>strobe,-- 1-bit input: Data strobe input
RST => '0',-- 1-bit input: Asynchronous reset input
SHIFTIN =>'0'-- 1-bit input: Cascade input signal for master/slave I/O
);



end behav;


