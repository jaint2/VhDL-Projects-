library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;

entity serial_port is

    generic
    (
        clk_freq:   positive := 125000000;  -- Hz
        gate_delay: time     := 0.1 ns;
        baud_rate:  positive := 57600
    );

    port
    (
        rst: in  std_logic := 'X';          -- reset
        clk: in  std_logic := 'X';          -- clock

        wr:  in  std_logic := 'X';          -- write
        di:  in  byte      := byte_unknown; -- data in
        bsy: out std_logic := '0';          -- busy
        tx:  out std_logic := '1'           -- serial out
   );

end serial_port;

architecture rtl of serial_port is

    type states is (st_idle, st_wait, st_start, st_transmit);

    constant cycles:     positive                                 := (clk_freq / baud_rate);

    signal   cnt:        unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   next_cnt:   unsigned(n_bits(cycles) - 1 downto 0)    := (others => '0');
    signal   state:      states                                   := st_idle;
    signal   next_state: states                                   := st_idle;
    signal   data:       byte                                     := byte_null;
    signal   next_data:  byte                                     := byte_null;
    signal   bit:        unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');
    signal   next_bit:   unsigned(n_bits(byte'high) - 1 downto 0) := (others => '0');

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
    
    process (wr, di, cnt, state, data, bit)
    begin
        bsy         <= '1'                         after gate_delay;
        tx         <= '1'                         after gate_delay;
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

                bsy <= '0'                         after gate_delay;

                if (wr = '1') then

                    next_data  <= di              after gate_delay;
                    next_state <= st_wait         after gate_delay;

                end if;

            when st_wait =>
            
                next_state <= st_start            after gate_delay;

            when st_start =>
            
                tx         <= '0'                 after gate_delay;
                next_state <= st_transmit         after gate_delay;

            when st_transmit =>

                tx <= data(to_integer(bit))       after gate_delay;

                if (bit < byte'high) then

                    next_bit <= bit + 1           after gate_delay;

                else

                    next_state <= st_idle         after gate_delay;
                    next_bit   <= (others => '0') after gate_delay;

                end if;
                
            when others =>

               next_state <= st_idle              after gate_delay;
               next_bit   <= (others => '0')      after gate_delay;

        end case;
            
    end process;

end rtl;
