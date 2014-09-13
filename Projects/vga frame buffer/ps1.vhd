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
   type states is (st_idle, st_data, st_parity,st_stop);
    constant cycles:     positive                                 := (7000);



   signal   cnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_cnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   state:      states                                   := st_idle;
    signal   next_state: states                                   := st_idle;
    signal   data:       std_logic_vector(7 downto 0)             := (others => '0');
    signal   next_data:  std_logic_vector(7 downto 0)	          := (others => '0');
    signal   bit:        unsigned(7 downto 0) 			   := (others => '0');
    signal   next_bit:   unsigned(7 downto 0)			   := (others => '0');
    signal   wr : 	    std_logic  				   := '0';
    signal   n_wr : 	    std_logic					   := '0';
    signal   chk:	    std_logic 				   := '0';
    signal   n_chk:	    std_logic					   := '0';	
    signal   pbit : 	    std_logic  				   := '0';
begin
kclk<='Z';
kdata<='Z';


  busy <= '0' when state = st_idle else '1';
 process (rst, clk,kclk,cnt)
    begin
    
        if (rst = '1') then

      --      ro<='0';
	  --   do <= (others=> '0');
            state <= st_idle         ;
            data  <= (others => '0') ;
            bit   <= (others => '0') ;

        elsif clk'event and (clk = '1') then
--		cnt   <= next_cnt  ;
		wr<=n_wr;
             data  <= next_data   ;
		chk<=n_chk;
			
--				if next_cnt =0 then
--					state<= st_idle;
--				end if;
--
		if next_cnt = 0 then
		state <= st_idle;
		end if;

            if kclk'event and kclk='0' then
			
                state <= next_state  ;
              cnt<=(others => '0') ;
                bit   <= next_bit    ;
			
		else 
			cnt   <= next_cnt  ;
             
		end if;

        end if;

    end process;
    
    process (chk,kclk, state, data, bit,wr,kdata)
    begin
     --   bi         <= '1'                         ;
--        do         <= '1'                         ;
	        
	next_state <= state                       ;
        next_data  <= data                        ;
        next_bit   <= bit                         ;
	n_chk<=chk;
	n_wr<=wr;
     

--   if (cnt < (cycles - 1)) then

--            next_cnt <= cnt + 1                   ;
--            
--        else
--	--	n_wr<='1';		
--		--next_state <=st_idle;
--            next_cnt <= (others => '0')           ;
--
--        end if;

    

    case state is
        
            when st_idle =>

        --       bi <= '0'                         ;
		n_chk<='0';
                  next_state <= st_data         ;
		--next_data<=(others => '0');	
            
            when st_data =>
		
		if bit = 0 and kclk ='0' and not (kclk'event) then
			next_data(0)<=kdata ;
			
		if (kdata = '0') then
			n_wr<='1';
		else
			n_wr <='0';
		end if;
		elsif (bit > 0) then
		if kclk ='0' and not (kclk'event) then
		next_data(to_integer(bit))<=kdata ;
		end if;
		end if;

                if (bit < 8) then

                    next_bit <= bit + 1           ;

                else
			--do<='1';
                    next_state <= st_parity         ;
                    next_bit   <= (others => '0') ;

                end if;
                
            when st_parity =>
		if wr = '1' then                    
			next_data  <=std_logic_vector(byte(unsigned(data(7 downto 1)) & '0'))              ;
		
			if kclk='0' and  not(kclk'event) then
				n_chk<=kdata xor '0' xor data(1) xor data(2) xor  data(3) xor  data(4) xor  data(5) xor  data(6) xor  data(7) ;
			end if;

		elsif wr = '0' then
			next_data  <=std_logic_vector(byte(unsigned(data(7 downto 1)) & '1'))              ;
			if kclk='0' and  not(kclk'event) then
				n_chk<=kdata xor '1' xor data(1) xor data(2) xor  data(3) xor  data(4) xor  data(5) xor  data(6) xor  data(7) ;
			end if;
		end if;

               next_state <= st_idle             ;

		when st_stop =>
		
		next_state <= st_idle;

        end case;
            
    end process;
ro<=chk;
do<=data;

process (cnt)
begin
   if (cnt < (cycles - 1)) then

            next_cnt <= cnt + 1                   ;
            
        else
		
		--next_state <=st_idle;
            next_cnt <= (others => '0')           ;

        end if;
end process;




end rtl;
