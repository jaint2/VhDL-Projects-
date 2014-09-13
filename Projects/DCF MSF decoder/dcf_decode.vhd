library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.util.all;


entity dcf_decode is

    generic
    (
        clk_freq:   positive := 125000000; -- Hz
        gate_delay: time     := 1 ns
    );

    port
    (
        rst:    in  std_logic                    := 'X'; -- reset
        clk:    in  std_logic                    := 'X'; -- clock
        
        si:     in  std_logic                    := 'X'; -- start of second in
        mi:     in  std_logic                    := 'X'; -- start of minute in
        bi:     in  std_logic                    := 'X'; -- bit in
        year:   out bcd_digit_vector(3 downto 0) := (3 => bcd_two, 2 => bcd_zero, others => bcd_minus);
        month:  out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        day:    out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        hour:   out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        minute: out bcd_digit_vector(1 downto 0) := (others => bcd_minus);
        second: out bcd_digit_vector(1 downto 0) := (others => bcd_zero);  
        tr:     out std_logic                    := '0'  -- new bit trigger
    );

end dcf_decode;

architecture rtl of dcf_decode is

signal curr_bit : unsigned(59 downto 0) := (others => '0');
signal next_bit : unsigned(59 downto 0) := (others => '0');  
signal cntr : unsigned(7 downto 0) := (others => '0');
constant cntr1 : unsigned(7 downto 0) := (others => '0');
signal i : natural:= 0;
signal n_i : natural:= 0;
signal k : natural:= 0;
signal n_k : natural:= 0;
signal next_cntr : unsigned(7 downto 0) := (others => '0');
signal mntr : unsigned(7 downto 0) :=(others => '0');
signal n_mntr : unsigned(7 downto 0) :=(others => '0');
signal hntr : unsigned(7 downto 0) := (others => '0');
signal n_hntr : unsigned(7 downto 0) := (others => '0');
signal dntr : unsigned(7 downto 0) := (others => '0');
signal n_dntr : unsigned(7 downto 0) := (others => '0');
signal mnthr : unsigned(7 downto 0) := (others => '0');
signal n_mnthr : unsigned(7 downto 0) := (others => '0');
signal yntr : unsigned(7 downto 0) := (others => '0');
signal n_yntr : unsigned(7 downto 0) := (others => '0');
    type states is (si_det , bit_det , dout);
    signal current_state:		states 	:=si_det;
    signal next_state:			states	:= si_det;
begin

 process (rst,clk) 
begin	

if (rst = '1') then 
--second<= (others => bcd_zero);  

current_state <= si_det;
cntr <= (others => '0');
curr_bit <= (others=>'0');
mntr<="10111011";
mnthr<="10111011";
dntr<="10111011";
hntr<="10111011";
yntr<="10111011";
i<=0;
k<=0;

elsif clk'event and (clk = '1') then
current_state <= next_state  after gate_delay;
cntr <= next_cntr    after gate_delay;
curr_bit <= next_bit;
mntr<=n_mntr;
mnthr<=n_mnthr;
dntr<=n_dntr;
hntr<=n_hntr;
yntr<=n_yntr;
i<=n_i;
k<=n_k;
end if;

end process;
process (current_state , si , bi , mi , cntr,curr_bit,mntr,mnthr,dntr,hntr,i,yntr,k)
begin
tr<='0';
next_state <= current_state;
next_cntr <= cntr;
next_bit <= curr_bit;
n_mntr<=mntr;
n_mnthr<=mnthr;
n_dntr<=dntr;
n_hntr<=hntr;
n_yntr<=yntr;
n_i<=i;
n_k<=k;
second<= (others => bcd_zero);  
case current_state is

when si_det =>
if (mi='1') then
next_state <= bit_det after gate_delay;
next_cntr <= (others => '0');
n_i<=0;
if (k= 1) then
n_mntr<='0'&curr_bit(27)&curr_bit(26)&curr_bit(25)&curr_bit(24)&curr_bit(23)&curr_bit(22)&curr_bit(21);

n_hntr<='0'& '0'&curr_bit(34)&curr_bit(33)&curr_bit(32)&curr_bit(31)&curr_bit(30)&curr_bit(29);
n_dntr <= '0'&'0'& curr_bit(41)&curr_bit(40)&curr_bit(39)&curr_bit(38)&curr_bit(37)&curr_bit(36);

n_mnthr <= '0'&'0'&'0'& curr_bit(49)&curr_bit(48)&curr_bit(47)&curr_bit(46)&curr_bit(45);

n_yntr <=curr_bit(57)&curr_bit(56)&curr_bit(55)&curr_bit(54)&curr_bit(53)&curr_bit(52)&curr_bit(51)&curr_bit(50);
n_k<=0;
else 
n_mntr <= "10111011";
n_mnthr <= "10111011";
n_hntr <= "10111011";
n_dntr <= "10111011";
n_yntr <= "10111011";
end if;



elsif (si='1') then
 next_state <= bit_det after gate_delay;
end if;

 when bit_det =>
if(mi='1') then


tr<= '1';
--second<= (others => bcd_zero);  
second(0) <= bcd_digit(cntr(3 downto 0));
second(1) <= bcd_digit(cntr(7 downto 4));
next_state <= si_det;

else
tr<= '1';
next_bit(i-1)<=bi;
next_cntr <= cntr+natural(1);
n_i<= i+1;
if (cntr(3 downto 0) = 9) then
next_cntr(7 downto 4)<= cntr(7 downto 4) +natural(1);
next_cntr(3 downto 0) <= (others => '0');
end if;
second(0) <= bcd_digit(cntr(3 downto 0));
second(1) <= bcd_digit(cntr(7 downto 4));

if(i = 58) then
n_k<=1;
end if;
--next_state <= dout;
--next_cntr <= (others => '0');
--else
next_state<= si_det;
--end if;
end if;

when dout=>



next_state <= si_det;
end case;

end process;
process(mntr,mnthr,dntr,hntr,yntr)
 begin
--tr<='1';

minute(0) <= bcd_digit(mntr(3 downto 0));
minute(1) <= bcd_digit(mntr(7 downto 4));


month(0) <= bcd_digit(mnthr(3 downto 0));
month(1) <= bcd_digit(mnthr(7 downto 4));


day(0) <= bcd_digit(dntr(3 downto 0));
day(1) <= bcd_digit(dntr(7 downto 4));


hour(0) <= bcd_digit(hntr(3 downto 0));
hour(1) <= bcd_digit(hntr(7 downto 4));

year(0) <= bcd_digit(yntr(3 downto 0));
year(1) <= bcd_digit(yntr(7 downto 4));
year(2)<= "0000";
year(3)<= "0010";
--end if;

end process;
--tr<='0';
end rtl;
