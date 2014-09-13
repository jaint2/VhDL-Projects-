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
        rst: in  std_logic   := 'X';          -- reset
        clk: in  std_logic   := 'X';          -- clock
--an:   out std_logic_vector(3 downto 0) := "1111";
    --    wi:  in  std_logic   := 'X';          -- write in
  --      di:  in  byte        := byte_unknown;
     --   bi:  out std_logic   := '0';          -- busy in
	rx : in  std_logic    :='X' ;		--rx in
        do:  out std_logic   := '1' ;          -- data out
	rxo : out byte  := byte_unknown;
	rxflg : out std_logic := '0'
    );

end serial_port;

architecture rtl of serial_port is

    type states is (st_idle, st_wait, st_start, st_transmit);
	type rx_states is (rx_start,rx_data,rx_stop,rx_wait);




    constant cycles:     positive                                 := (clk_freq / baud_rate);
	constant cycles1:     positive                                := cycles/2;
--constant  t2 : time := (natural(1.5)*cycles) ns;
    signal   cnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_cnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   state:      states                                   := st_idle;
    signal   next_state: states                                   := st_idle;
    signal   data:  byte                                     := byte_null;
    signal   next_data:  byte                                     := byte_null;
    signal   bit:        unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');
    signal   next_bit:   unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');

    signal   rxcnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_rxcnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   rxstate:      rx_states  :=  rx_start      ;
    signal   next_rxstate: rx_states  := rx_start;             
    signal   rxdata:       std_logic_vector(8 downto 0):=(others =>'X');
    signal   next_rxdata:  std_logic_vector(8 downto 0):=(others =>'X');
    signal   rxbit:        unsigned(4 downto 0) := (others => '0');
    signal   next_rxbit:   unsigned(4  downto 0) := (others => '0');
    signal   rxi : std_logic := '0';
    signal   n_rxi : std_logic := '0';
    signal n_rxo : byte  := byte_unknown;
  --  signal n_rxo : byte  := byte_unknown;
    signal wr : std_logic := '0';
	signal n_wr : std_logic := '0';
    signal chk:std_logic := '0';
    signal n_chk:std_logic := '0';	
begin

    process (rst, clk)
    begin
    
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
    
    process (chk, cnt, state, data, bit,n_rxo,rxdata)
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

                if (chk = '1') then
			--rxo<= (byte(unsigned(rxdata))) ;
--			if wr = '1' then                    
--			next_data  <=(byte(unsigned(rxdata(7 downto 1)) & '0'))              after gate_delay;
--			elsif wr = '0' then
--			next_data  <=(byte(unsigned(rxdata(7 downto 1)) & '1'))              after gate_delay;
--			end if;
			  next_data  <=(byte(unsigned(rxdata(7 downto 0))))              after gate_delay;
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

process (clk,rst)
begin
      
  if (rst = '1') then
	   rxi<='0';
		--chk<='0';
	     rxcnt   <= (others => '0') after gate_delay;
            rxstate <= rx_start        after gate_delay;
            rxdata  <= (others=>'0') after gate_delay;
            rxbit   <= (others => '0') after gate_delay;
        elsif clk'event and (clk = '1') then
               rxcnt<=next_rxcnt;
		 rxdata  <= next_rxdata   after gate_delay;
chk<=n_chk;

 if next_rxcnt = 0 then
		
		rxi<=n_rxi;
                rxstate <= next_rxstate  after gate_delay;
              
                rxbit   <= next_rxbit    after gate_delay;

		end if;
	end if;
end process;


process(rxstate,rxcnt,rxbit,rxdata,rxi,rx,clk,chk,wr)
variable ir : std_logic := '0'; 
begin
--if clk'event and (clk = '1') then
     n_rxi<=rxi;
	n_chk<=chk;

	 next_rxstate <= rxstate                    ;
      --  
        next_rxbit   <= rxbit                      ;
	if rxi ='0' then 

        if (rxcnt < (cycles - 1)) then

            next_rxcnt <= rxcnt + 1                 ;
            
        else

            next_rxcnt <= (others => '0')           ;

        end if;
	elsif rxi ='1' then
		
	if (rxcnt < (cycles1 - 1)) then
    --an    <= (others => '0');
            next_rxcnt <= rxcnt + 1                  ;
            
        else

            next_rxcnt <= (others => '0')           ;
		n_rxi<='0';
	
end if;
end if;

next_rxdata  <= rxdata                        ;
n_chk<= '0';

case rxstate is 
	when rx_start =>
		if rx = '0'  then
			next_rxcnt <= (others => '0');
			n_rxi<='1';
			next_rxstate<=rx_wait;
		end if;
	when rx_wait =>
		next_rxstate<=rx_data;
	when rx_data =>
		if rxcnt = 0 then
		next_rxdata(to_integer(rxbit))<=rx ;
		end if;
	
		if (rxbit < 9) then
			next_rxbit<= rxbit+1 ;
		else
			next_rxbit<= (others => '0');
			next_rxstate <= rx_stop;
			
		end if;

	when rx_stop =>
		
			next_rxcnt <= (others => '0');
			n_chk<='1';
			next_rxstate <= rx_start ;
end case;












end process;

rxo<= (byte(unsigned(rxdata(8 downto 1)))) ;
rxflg<=chk;

end rtl;
