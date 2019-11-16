library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serilazer is 
generic (
    D : integer := 8 ; -- data bits
    M : integer := 10 -- cycle bits 
);
port (
    clk, rst : in std_logic;
    i_start : in std_logic; -- start transmission
    i_data : in std_logic_vector(D-1 downto 0); -- send this data
    o_tx : out std_logic; -- transmission out
    o_tx_done : out std_logic -- transmission done
);
end serilazer;

architecture behaviorel of serilazer is
    component timer is 
    generic(M : integer :=10);   -- count to 10(M) Adele :)
    Port (clk : in  std_logic;
          cout : out std_logic );
    end component;

    type state_type is (READY,START,DATA,DONE);
    signal state, state_next : state_type:=READY ;
    signal count, count_next: unsigned(3 downto 0):="0000";
   -- signal c, c_n : integer range 0 to 15 : 0;
    signal i_timer : std_logic:='0';
   
begin

stage1 : timer generic map(M=>M)
               port map (clk,cout=>i_timer);
--    o_tx<='0';
--    o_tx_done<='0';
    process(clk) is
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    state <= ready;
                elsif i_timer ='1' then
                    state <= state_next;
                    count <= count_next;      
                  --  c <= c_n;
                end if;
            end if;
        end process;

    process(state, i_start, i_data,count,count_next,i_timer) is
    begin
        --    state_next <= state;
        case state is
            when READY => 
                count_next <= "0000";
             --   c_n <= c;
                o_tx_done <= '0';
                o_tx <= '0';
                if i_start = '1' then
                    state_next <= START;
 --                   o_tx <= '0';
 --                   o_tx_done <= '0';
                else
                    state_next <= READY;
                end if;
            when START =>  
                if count < 3 then
                    o_tx <= '1';
 --                 o_tx_done <= '0';
                    count_next <= count + 1;
                    state_next <= START;
                else
                    count_next <="0000";
                    state_next <= DATA;
                end if;
            when DATA =>
                if count < 7 then
                 --   o_tx <='0';
                    o_tx <= i_data(to_integer(count));
                    o_tx_done <= '0';
                    count_next <= count + 1;
                    state_next <= DATA;
                else
                    o_tx <= i_data(to_integer(count));
                    count_next <= "0000";
                    state_next <= DONE;
                end if;
            when DONE =>
                if count < 3 then
                    o_tx <= '0';
                    state_next <= DONE;
                    count_next <= count + 1;
                else
                    state_next <= READY;
                    o_tx_done <= '0';
                end if;
        end case;
    end process;
  
end behaviorel;
