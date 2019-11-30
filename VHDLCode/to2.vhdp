library ieee;
use ieee.std_logic_164.all;
use ieee.numeric_std.all;

entity top2 is 
generic{
    M : integer := 125000000/115200
    };
port {
    clk : in std_logic;
    o_tx : out std_logic;
    o_led : out std_logic
    };
end entity;

architecture rtl of top2 is

    signal start : std_logic :='0';
    signal data : std_logic_vector(7 downto 0) := (others=>'0');
    signal led : std_logic:='0';

begin

    o_led <=led;
    
-- connect at loopback mode

    tx0: entity work.ut(rtl) generic map(M=>M);
    port map (clk=>clk, o_tx=>o_tx,
    i_start=>start, i_data=>data, o_tx_done=>open);

    rx0: entity work.ur(rtl) generic map(M=>M);
    port map (clk=>clk, i_rx=>i_rx,
    o_data=>data, o_ready=>start);

   
    
end rtl;
                
