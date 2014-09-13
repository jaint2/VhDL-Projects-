library IEEE;
library UNISIM;

use UNISIM.vcomponents.all;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity pll is

    -- PLL VCO frequency range is 400 to 1080 MHz
    -- Maximum frequency for BUFG is 400 MHz

    generic
    (
        clk_freq:     positive                 := 100000000;  -- Hz
        gate_delay:   time                     := 1 ns;
        clk_mult:     positive                 := 1; -- Range 1 to  64
        clk_div:      positive                 := 1; -- Range 1 to  52
        clk_div0:     positive                 := 1; -- Range 1 to 128
        clk_div1:     positive                 := 1; -- Range 1 to 128
        clk_div2:     positive                 := 1; -- Range 1 to 128
        clk_div3:     positive                 := 1; -- Range 1 to 128
        clk_div4:     positive                 := 1; -- Range 1 to 128
        clk_div5:     positive                 := 1  -- Range 1 to 128
    );

    port
    (
        clkin:    in  std_logic                := 'X';  -- clock in
        --pragma synthesis_off
        end_flag: in  std_logic                := 'X';  -- stop clocks
        --pragma synthesis_on
        clk0:     out std_logic                := '0';  -- clock 0 out
        clk1:     out std_logic                := '0';  -- clock 1 out
        clk2:     out std_logic                := '0';  -- clock 2 out
        clk3:     out std_logic                := '0';  -- clock 3 out
        clk4:     out std_logic                := '0';  -- clock 4 out
        clk5:     out std_logic                := '0';  -- clock 5 out
        strobe:   out std_logic                := '0'   -- strobe
   );

end pll;

architecture behav of pll is


signal bfclk : std_logic := '0';
--signal bfclkio : std_logic := '0'; 
signal bplclko  : std_logic := '0'; 
signal bplclki  : std_logic := '0'; 
signal plbsclko  : std_logic := '0'; 
signal plbsclk1  : std_logic := '0'; 
signal plbsclk2  : std_logic := '0';
signal plbsclko1  : std_logic := '0'; 
signal plbsclko2  : std_logic := '0';
signal locbo  : std_logic := '0'; 
signal clo  : std_logic := '0'; 
signal cl1  : std_logic := '0'; 
begin





PLL_BASE_inst : PLL_BASE
generic map (
BANDWIDTH => "OPTIMIZED",-- "HIGH", "LOW" or "OPTIMIZED"
CLKFBOUT_MULT => clk_mult,-- Multiply value for all CLKOUT clock outputs (1-64)
CLKFBOUT_PHASE => 0.0,-- Phase offset in degrees of the clock feedback output-- (0.0-360.0).
--CLKIN_PERIOD => "0",-- Input clock period in ns to ps resolution (i.e. 33.333 is 30-- MHz).
-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
CLKOUT0_DIVIDE => clk_div0,
CLKOUT1_DIVIDE => clk_div1,
CLKOUT2_DIVIDE => clk_div2,
CLKOUT3_DIVIDE => clk_div3,
CLKOUT4_DIVIDE => clk_div4,
CLKOUT5_DIVIDE => clk_div5,--  Duty cycle for CLKOUT# clockoutput (0.01-0.99).
CLKOUT0_DUTY_CYCLE => 0.5,
CLKOUT1_DUTY_CYCLE => 0.5,
CLKOUT2_DUTY_CYCLE => 0.5,
CLKOUT3_DUTY_CYCLE => 0.5,
CLKOUT4_DUTY_CYCLE => 0.5,
CLKOUT5_DUTY_CYCLE => 0.5,-- Output phase relationship for CLKOUT# clock output (-360.0-360.0).
CLKOUT0_PHASE => 0.0,
CLKOUT1_PHASE => 0.0,
CLKOUT2_PHASE => 0.0,
CLKOUT3_PHASE => 0.0,
CLKOUT4_PHASE => 0.0,
CLKOUT5_PHASE => 0.0,
CLK_FEEDBACK => "CLKFBOUT",-- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
COMPENSATION => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
DIVCLK_DIVIDE => clk_div,-- Division value for all output clocks (1-52)
--REF_JITTER => 0.0,-- Reference Clock Jitter in UI (0.000-0.999).
RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
)
port map (
CLKFBOUT => bplclko, -- 1-bit output: PLL_BASE feedback output
-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
CLKOUT0 => plbsclko,
CLKOUT1 => plbsclk1,
CLKOUT2 => plbsclk2,
CLKOUT3 => clk3,
CLKOUT4 => clk4,
CLKOUT5 => clk5,
LOCKED => locbo, -- 1-bit output: PLL_BASE lock status outpu
CLKFBIN => bplclko, -- 1-bit input: Feedback clock input
CLKIN => clkin, -- 1-bit input: Clock input
RST => '0'-- 1-bit input: Reset input
);

BUFG_inst1 : BUFG
port map (
O => plbsclko1, -- 1-bit output: Clock buffer output
I => plbsclk1 -- 1-bit input: Clock buffer input
);

BUFG_inst2 : BUFG
port map (
O => plbsclko2, -- 1-bit output: Clock buffer output
I => plbsclk2-- 1-bit input: Clock buffer input
);

BUFPLL_inst : BUFPLL
generic map (
DIVIDE => 1,-- DIVCLK divider (1-8)
ENABLE_SYNC => TRUE -- Enable synchrnonization between PLL and GCLK (TRUE/FALSE)
)
port map (
IOCLK => clo,-- 1-bit output: Output I/O clock
LOCK => open,-- 1-bit output: Synchronized LOCK output
SERDESSTROBE => strobe, -- 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
GCLK => plbsclko2,-- 1-bit input: BUFG clock input
LOCKED => locbo,-- 1-bit input: LOCKED input from PLL
PLLIN => plbsclko-- 1-bit input: Clock input from PLL
);
clk0<=clo;
clk1<=plbsclko1;
clk2<=plbsclko2;
end behav;
