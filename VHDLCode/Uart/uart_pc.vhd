library ieee;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity uart_pc is
    generic  ( M : integer  );

    port(
        clk : in std_logic;
        -- input from Rx Side
        i_rx : in std_logic;
        -- outputs from Rx Side
        o_data_intermediate : out std_logic_vector(7 downto 0);
        o_data_ready_intermediate : out std_logic;

        --input from Tx Side
        i_data_intermediate : in std_logic_vector(7 downto 0);
        i_start_intermediate : in std_logic;
        -- outputs from Tx Side
        o_tx : out std_logic;
        o_tx_done : out std_logic
    );
end uart_pc;

architecture rtl of uart_pc is

component uart_tx is 
    port(   
     clk: in std_logic;
     o_tx: out std_logic;
     o_tx_done: out std_logic;
     i_start : in std_logic;
     i_data: in std_logic_vector(7 downto 0));
    end component;
    
component uart_rx is 
port(
    clk : in std_logic;
    i_rx : in std_logic;
    o_data : out std_logic_vector(7 downto 0);
    o_rx_ready : out std_logic);      
end component; 


begin

    StageTx : uart_tx port map( clk=>clk, i_start=>i_start_intermediate, 
    i_data=>i_data_intermediate, o_tx=>o_tx, o_tx_done=>o_tx_done );
                    
    StageRx :  uart_rx port map( clk=>clk, o_data=>o_data_intermediate, 
    o_rx_ready=>o_data_ready_intermediate, i_rx=>i_rx );


end rtl;
