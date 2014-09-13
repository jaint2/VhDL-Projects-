--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:16:54 08/23/2012
-- Design Name:   
-- Module Name:   C:/Users/jsackos/Desktop/Pmod_Demos/In_Progress/PmodPS2/HDL/Nexys3/VHDL/PmodPS2_Demo/PmodPS2_Source/test_PmodPS2.vhd
-- Project Name:  PmodPS2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PmodPS2
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_PmodPS2 IS
END test_PmodPS2;
 
ARCHITECTURE behavior OF test_PmodPS2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PmodPS2
    PORT(
         clk : IN  std_logic;
         sw : IN  std_logic_vector(1 downto 0);
         btnr : IN  std_logic;
         btnl : IN  std_logic;
         LED : OUT  std_logic_vector(2 downto 0);
         JA : INOUT  std_logic_vector(7 downto 4);
         vgaRed : OUT  std_logic_vector(2 downto 0);
         vgaGreen : OUT  std_logic_vector(2 downto 0);
         vgaBlue : OUT  std_logic_vector(2 downto 1);
         Hsync : OUT  std_logic;
         Vsync : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal sw : std_logic_vector(1 downto 0) := (others => '0');
   signal btnr : std_logic := '0';
   signal btnl : std_logic := '0';

	--BiDirs
   signal JA : std_logic_vector(7 downto 4);

 	--Outputs
   signal LED : std_logic_vector(2 downto 0);
   signal vgaRed : std_logic_vector(2 downto 0);
   signal vgaGreen : std_logic_vector(2 downto 0);
   signal vgaBlue : std_logic_vector(2 downto 1);
   signal Hsync : std_logic;
   signal Vsync : std_logic;

   -- Clock period definitions
   constant clk_period : time := 5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PmodPS2 PORT MAP (
          clk => clk,
          sw => sw,
          btnr => btnr,
          btnl => btnl,
          LED => LED,
          JA => JA,
          vgaRed => vgaRed,
          vgaGreen => vgaGreen,
          vgaBlue => vgaBlue,
          Hsync => Hsync,
          Vsync => Vsync
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
