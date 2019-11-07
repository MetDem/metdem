library ieee;
use ieee.std_logic_1164.all;

entity problem1 is 
    port(a,b : in std_logic ;
         clk, rst : in std_logic;
         moore : out std_logic);
end problem1;

architecture behaviorel of problem1 is
type state_type is (s0,s1,s2);
signal state, state_next : state_type := s0;

begin
    --state register
    process(clk)
    begin
        if rising_edge(clk) then
            if rst ='1' then
                state<=s0;
                else
                    state<=state_next;
                end if;
            end if;
        end process;
    --next state register
    
    process(state,a,b) is 
    begin
        case state is 
        when S0=>
            state_next<=s1;
        when s1 =>
            if b='1' then
                state_next<=s2;
            else 
                state_next<=s0;
            end if;
         when s2 =>
            state_next<=s0;
        end case;
    end process;

    process(state)
    begin
        case state is 
            when s0|s1=>
                 moore<='0';
             when s2 =>
                 moore<='1';
        end case;
    end process;
    end behaviorel;
