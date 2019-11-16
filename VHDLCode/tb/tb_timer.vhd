library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_timer is
end tb_timer;

architecture Behavioral of tb_timer is
component timer is 
 Port (clk : in  std_logic;
       cout : out std_logic );
end component;
    signal clk, cout : std_logic := '0';
    signal clk_period : time := 10 ns;
begin

stage : timer port map (
clk=>clk, cout=>cout);

clk_process : process
    begin
        for i in 0 to 100 loop
            clk <= not clk;
            wait for clk_period/2;
        end loop;
        wait;
    end process;
        
    -- stimulus

end Behavioral;
