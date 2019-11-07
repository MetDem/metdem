library ieee;
use ieee.std_logic_1164.all;

entity coinfsm is
    port( p5,p10,p25: in std_logic;
          clk,rst : in std_logic;
          moore, mealy : out std_logic);
end coinfsm;

architecture Behavioral of coinfsm is
    type state_type is (s0, s5, s10, s15, s20, s25);
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

    process(state,p5,p10,p25) is 
    begin
        case state is 
        when S0=>
            if p25 = '1' then
                state_next<=s25;
            elsif p10 ='1' then
                state_next<=s10;
            elsif p5 ='1' then
                state_next <=s5;
            end if;
        when s5 =>
            if p25 = '1' then
                state_next<=s25;
            elsif p10 ='1' then
                state_next<=s15;
            elsif p5 ='1' then
                state_next <=s10;
            end if;
        when s10 =>
            if p25 = '1' then
                state_next<=s25;
            elsif p10 ='1' then
                state_next<=s20;
            elsif p5 ='1' then
                state_next <=s15;
            end if;
        when s15 =>
            if p25 = '1' then
                state_next<=s25;
            elsif p10 ='1' then
                state_next<=s25;
            elsif p5 ='1' then
                state_next <=s20;
            end if;
         when s20 =>
            if p25 = '1' then
                state_next<=s25;
            elsif p10 ='1' then
                state_next<=s25;
            elsif p5 ='1' then
                state_next <=s25;
            end if;
        when s25 =>
                state_next<=s0;
        end case;
    end process;

    process(state)
    begin
        case state is 
            when s0|s5|s10|s15|s20 =>
                 moore<='0';
             when s25 =>
                 moore<='1';
        end case;
    end process;
                
                
 end Behavioral;              
                
                


