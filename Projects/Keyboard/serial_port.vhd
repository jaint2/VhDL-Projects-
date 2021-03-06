library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.util.all;






entity serial_port is 

    generic
    (
        clk_freq:   positive;                 -- clock frequency in Hz
        baud_rate:  positive;                 -- baud rate
        gate_delay: time     := 0 ns          -- gate delay
    );

    port
    (
        rst: in  std_logic   := 'X';          -- rst
        clk: in  std_logic   := 'X';          -- clock
an:   out std_logic_vector(3 downto 0) := "1111";
        wi:  in  std_logic   := 'X';          -- write in
        di:  in  byte        := byte_unknown;
     --   bi:  out std_logic   := '0';          -- busy in
--	kclk:inout std_logic    ;	
--	krx : inout  std_logic   ;		--krx in
        do:  out std_logic   := '1'           -- data out
--	krxo : out byte  := byte_unknown
    );

end serial_port;

architecture rtl of serial_port is

    type states is (st_idle, st_wait, st_start, st_transmit);
--	type krx_states is (krx_start,krx_data,krx_stop);



    constant cycles:     positive                                 := (clk_freq / baud_rate);
	constant cycles1:     positive                                := natural(0.5)*cycles;
--constant  t2 : time := (natural(1.5)*cycles) ns;
    signal   cnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_cnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   state:      states                                   := st_idle;
    signal   next_state: states                                   := st_idle;
    signal   data:  byte                                     := byte_null;
    signal   next_data:  byte                                     := byte_null;
    signal   bit:        unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');
    signal   next_bit:   unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');

    signal   krxcnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_krxcnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
 --   signal   krxstate:      krx_states  :=  krx_start      ;
 --   signal   next_krxstate: krx_states  := krx_start;             
    signal   krxdata:       std_logic_vector(8 downto 0):=(others =>'X');
    signal   next_krxdata:  std_logic_vector(8 downto 0):=(others =>'X');
    signal   krxbit:        unsigned(7 downto 0) := (others => '0');
    signal   next_krxbit:   unsigned(7  downto 0) := (others => '0');
    signal   krxi : std_logic := '0';
    signal   n_krxi : std_logic := '0';
--    signal n_krxo : byte  := byte_unknown;
  --  signal n_krxo : byte  := byte_unknown;
    signal wr : std_logic := '0';
	signal n_wr : std_logic := '0';
    signal chk:std_logic := '0';
    signal n_chk:std_logic := '0';	
begin

    process (rst, clk)
    begin
    an<="0000";
        if (rst = '1') then

            cnt   <= (others => '0') after gate_delay;
            state <= st_idle         after gate_delay;
            data  <= (others => '0') after gate_delay;
            bit   <= (others => '0') after gate_delay;

        elsif clk'event and (clk = '1') then

            cnt   <= next_cnt        after gate_delay;

            if (next_cnt = 0) or (next_state = st_wait) then

                state <= next_state  after gate_delay;
                data  <= next_data   after gate_delay;
                bit   <= next_bit    after gate_delay;

             end if;

        end if;

    end process;
    
    process (chk, cnt, state, data, bit,krxdata,wi,di)
    begin
     --   bi         <= '1'                         after gate_delay;
        do         <= '1'                         after gate_delay;
        next_state <= state                       after gate_delay;
        next_data  <= data                        after gate_delay;
        next_bit   <= bit                         after gate_delay;

        if (cnt < (cycles - 1)) then

            next_cnt <= cnt + 1                   after gate_delay;
            
        else

            next_cnt <= (others => '0')           after gate_delay;

        end if;

        case state is
        
            when st_idle =>

        --       bi <= '0'                         after gate_delay;

                if (wi='1') then
			--krxo<= (byte(unsigned(krxdata))) ;
--			if wr = '1' then                    
--			next_data  <=(byte(unsigned(krxdata(7 downto 1)) & '0'))              after gate_delay;
--			elsif wr = '0' then
--			next_data  <=(byte(unsigned(krxdata(7 downto 1)) & '1'))              after gate_delay;
--			end if;
			  next_data  <=(byte(unsigned(di)))              after gate_delay;
                  next_state <= st_wait         after gate_delay;

                end if;

            when st_wait =>
            
                next_state <= st_start            after gate_delay;

             when st_start =>
            
                do         <= '0'                 after gate_delay;
                next_state <= st_transmit         after gate_delay;

            when st_transmit =>

                do <= data(to_integer(bit))       after gate_delay;

                if (bit < byte'high) then

                    next_bit <= bit + 1           after gate_delay;

                else
			--do<='1';
                    next_state <= st_idle         after gate_delay;
                    next_bit   <= (others => '0') after gate_delay;

                end if;
                
            when others =>

               next_state <= st_idle              after gate_delay;
               next_bit   <= (others => '0')      after gate_delay;

        end case;
            
    end process;
 
--process (clk,rst)
--begin
      
--  if (rst = '1') then
	   
--krxi<='0';
		--chk<='0';
	--     krxcnt   <= (others => '0') after gate_delay;
--            krxstate <= krx_start        after gate_delay;
--            krxdata  <= (others=>'0') after gate_delay;
--            krxbit   <= (others => '0') after gate_delay;
-- 
--
--	       elsif clk'event and (clk = '1') then
--   --            krxcnt<=next_krxcnt;
----
--		 krxdata  <= next_krxdata   after gate_delay;
--	chk<=n_chk;
----	wr<=n_wr;
--		if n_wr='0' then
--			kclk<='Z';
--			krx<='Z';
--			
--		end if;	
-- if kclk'event and kclk = '0' then
--		
--		krxi<=n_krxi;
--               
-- krxstate <= next_krxstate  after gate_delay;
--             
--                krxbit   <= next_krxbit    after gate_delay;
--
--		end if;
--	end if;
--end process;

------
--process(krxstate,krxcnt,krxbit,krxdata,krxi,krx,clk,chk,wr)
----variable ir : std_logic := '0'; 
----begin
----if clk'event and (clk = '1') then
--     n_krxi<=krxi;
--	n_chk<=chk;
--	n_wr<=wr;
--	 next_krxstate <= krxstate                    ;
--      --  
--        next_krxbit   <= krxbit                      ;
----	
--
--next_krxdata  <= krxdata                        ;

----
--case krxstate is 
--	when krx_start =>
--
--		if krx = '0'  then
--				n_wr<='1';
			--next_krxcnt <= (others => '0');
----			--n_krxi<='1';
----an<="1111";
--
------	an(2) <=krx;
--			n_chk<= '0';
----			--krxo<= "00011101";
	--		next_krxstate<=krx_data;
--		end if;
----	when krx_wait =>
----		next_krxstate<=krx_data;
----	when krx_data =>
--
--		--an(0)<='0';
--		--next_krxdata<="001100110";
--		next_krxdata(to_integer(krxbit))<=krx ;
--		--	an(2) <=krx;
--
	
--	
--		if (krxbit < 9) then
--			next_krxbit<= krxbit+1 ;
--		else
--			next_krxbit<= (others => '0');
--			next_krxstate <= krx_stop;
			
--		end if;

--	when krx_stop =>
	--	if krxcnt = 10 then
	--	if krx = '1' then
		 --an<="0000";
--			--an(3) <='0';
--			n_chk<='1';--
--			n_wr <='0';
--			next_krxstate <= krx_start ;
--			--krxo<= krxdata;
			--n_krxo<=not(byte(unsigned(krxdata)));
	--	elsif krx = '0' then
	--	
	--		next_krxstate <= krx_start;
	--	end if;
	--	end if;
--end case;




--end if;








--end process;

--krxo<= not(byte(unsigned(krxdata(7 downto 0)))) ;



end rtl;
