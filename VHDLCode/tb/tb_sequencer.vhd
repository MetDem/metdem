library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_seqvol3 is
    generic (
    D : integer := 8 -- data bits
);
end tb_seqvol3;

architecture Behavioral of tb_seqvol3 is
component sequencerasil 
    port (
    clk, rst : in std_logic;
    i_start : in std_logic; -- start transmission
    i_data : in std_logic_vector(D-1 downto 0); -- send this data
    o_tx : out std_logic; -- transmission out
    o_tx_done : out std_logic -- transmission done
);
end component;
    signal clk,rst  : std_logic := '0';
    signal i_start : std_logic := '0';
    signal i_data : std_logic_vector(D-1 downto 0) ;
    signal o_tx,o_tx_done : std_logic; 
    
    constant wait_time: time:=10ns;

begin
    h0: sequencerasil port map (
    clk=>clk,rst=>rst,i_start=>i_start,i_data=>i_data,o_tx=>o_tx,o_tx_done=>o_tx_done
    );
    
    process
    begin
    
     wait for wait_time/2;
     clk<= not clk;
    
    end process;
    
    process
    begin
    
    wait for wait_time;
    rst<='1';
    wait for wait_time;
    rst<='0';
    wait for wait_time;
    i_start<='1';
    --i_data<="10101011";
    i_data<="10101010";
    
    wait;
    
    end process;
end Behavioral;
