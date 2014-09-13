library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.util.all;






entity ps1  is 


    port
    (
        rst: in  std_logic   := 'X';          -- rst
        clk: in  std_logic   := 'X';          -- clock
--an:   out std_logic_vector(3 downto 0) := "1111";
        kclk:  inout  std_logic ;
        kdata:  inout  std_logic ;
     --   bi:  out std_logic   := '0';          -- busy in
	busy : out std_logic ;
        do:  out std_logic_vector(7 downto 0)    := (others =>'0') ;          -- data out
	ro : out std_logic  := '0'
    );

end ps1;

architecture rtl of ps1 is
   type states is (st_idle, st_data, st_wait ,st_stop);
    constant cycles:     positive                                 := (7000);



   signal   cnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_cnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   state:      states                                   := st_idle;
    signal   next_state: states                                   := st_idle;
    signal   data:       std_logic_vector(10 downto 0)             := (others => '0');
    signal   next_data:  std_logic_vector(10 downto 0)	          := (others => '0');
    signal   bit:        unsigned(7 downto 0) 			   := (others => '0');
    signal   next_bit:   unsigned(7 downto 0)			   := (others => '0');
    signal   wr : 	    std_logic  				   := '0';
    signal   n_wr : 	    std_logic					   := '0';
    signal   chk:	    std_logic 				   := '0';
    signal   n_chk:	    std_logic					   := '0';	
    signal   pbit : 	    std_logic  				   := '0';
    signal kclk_fifo: std_logic_vector (4 downto 0 )  := (others => '1');
    signal kdata_fifo: std_logic_vector (4 downto 0 )  := (others => '1');
begin
kclk<='Z';
kdata<='Z';


  busy <= '0' when state = st_idle else '1';
 process (rst, clk)
    begin
    
        if (rst = '1') then

      --      ro<='0';
	  --   do <= (others=> '0');
            state <= st_idle         ;
            data  <= (others => '0') ;
            bit   <= (others => '0') ;
	    kdata_fifo<=(others => '1') ;
	    kclk_fifo<=(others => '1') ;
        elsif clk'event and (clk = '1') then
--		cnt   <= next_cnt  ;

             data  <= next_data   ;
		chk<=n_chk;
			
	kclk_fifo <= kclk & kclk_fifo(4 downto 1); 
	kdata_fifo <= kdata & kdata_fifo(4 downto 1); 
		
                state <= next_state  ;

                bit   <= next_bit    ;
			
            

        end if;

    end process;
    
    process (kclk_fifo, state, data, bit,wr,kdata_fifo)
    begin
     --   bi         <= '1'                         ;
--        do         <= '1'                         ;
	        
	next_state <= state                       ;
        next_data  <= data                        ;
        next_bit   <= bit                         ;
	n_chk<='0';



    case state is
        
            when st_idle =>

             if (kclk_fifo(0) = '0') then
                  next_state <= st_data         ;
              end if;
            
            when st_data =>

		next_data(to_integer(bit))<=kdata_fifo(0) ;
                next_state <= st_wait;

                
            when st_wait =>

             if (kclk_fifo(0) = '1') then

                if (bit < 10) then
                    next_bit <= bit + 1           ;
                    next_state <= st_idle         ;
                else
                    next_state <= st_stop         ;
                end if;

              end if;
 
            when st_stop =>
                next_bit   <= (others => '0') ;
		if ((data(9) xor data(8) xor data(7) xor data(6) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1)) = '1') and
                    (data(0) = '0') and (data(10) = '1') then
                n_chk <= '1';
                end if;
		
		next_state <= st_idle;

        end case;
            
    end process;
ro<=chk;
do<=data(8 downto 1);
end rtl;
