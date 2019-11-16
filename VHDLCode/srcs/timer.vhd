-- INCREASE THE COUNTER every Rising-Edge-Clock 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity timer is
    generic(M : integer :=10);   -- count to 10(M) Adele :)
    Port (clk : in  std_logic;
          cout : out std_logic );
end timer;

architecture Behavioral of timer is
    type state_type is (READY,DONE);
    signal state, next_state : state_type:=READY ;    
    -- initialize count signal to all 0s
    signal count, count_next : unsigned(31 downto 0) := (others => '0');
begin

    process(clk) is
    begin
        -- Check for rising edge on the registers.
        if rising_edge(clk) then
            state <= next_state;
            count <= count_next;        
        end if;
    end process;

    process(state, count, count_next) is
        begin
        case state is
            when READY => 
            if count=M then
                next_state<=DONE;
            else 
            count_next<=count+1;
            next_state<=READY;
            cout<='0';
            end if ;
               
            when DONE =>
            count_next<= (others => '0');
            cout <='1';
            next_state<=READY;

        end case;
     end process;
    

end Behavioral;
