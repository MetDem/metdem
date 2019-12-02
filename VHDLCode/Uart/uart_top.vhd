library ieee;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity uart_top is
    port( 
        clk : in std_logic;

        uart_rx_i : in std_logic;   -- uart input port connect to PC tx
        uart_tx_o : out std_logic   -- uart output port connect to PC rx
);
end uart_top;

architecture rtl of uart_top is 

component uart_packer is 
port ( 
        i_clk      : in std_logic;                           
        i_packer_ready : in std_logic;
        i_packer       : in std_logic_vector(D downto 0);
        
        o_packer   : out std_logic_vector(D downto 0); 
        o_ready    : out std_logic);
end component;

signal o_packer : std_logic_vector(7 downto 0);
signal o_ready : std_logic;

component uart_unpacker is 
port ( 
        i_clk      : in std_logic;                           
        i_unpacker_ready : in std_logic;
        i_unpacker       : in std_logic_vector(D downto 0);
        
        o_unpacker   : out std_logic_vector(D downto 0); 
        o_ready    : out std_logic);
end component;

component uart_pc is 
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
    o_tx_done : out std_logic);
end component;

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

signal o_data_intermediate_vs_i_packer : std_logic_vector(7 downto 0);
signal o_data_ready_intermediate_vs_i_packer_ready : std_logic;
signal i_data_intermediate_vs_o_unpacker : std_logic_vector(7 downto 0);
signal i_start_intermediate_vs_o_unpacker_ready : std_logic;

signal o_packer_vs_i_data : std_logic_vector(7 downto 0);
signal o_ready_vs_i_start : std_logic;

signal o_tx_vs_i_rx : std_logic;

signal o_data_vs_i_unpacker : std_logic_vector(7 downto 0);
signal o_rx_ready_vs_unpacker_ready : std_logic;



begin

StagePc_comm : uart_pc port map(clk=>clk, i_rx=>uart_rx_i,
o_data_intermediate=>o_data_intermediate_vs_i_packer,
o_data_ready_intermediate=>o_data_ready_intermediate_vs_i_packer_ready,
i_data_intermediate=>i_data_intermediate_vs_o_unpacker,
i_start_intermediate=>i_start_intermediate_vs_o_unpacker_ready,
o_tx=>uart_tx_o,
o_tx_done=>open );

StagePacker : uart_packer port map(i_clk=>clk,
i_packer=>o_data_intermediate_vs_i_packer,
i_packer_ready=>o_data_ready_intermediate_vs_i_packer_ready,
o_packer=>o_packer_vs_i_data,
o_ready=>o_ready_vs_i_start);


StageTx : uart_tx port map(clk=>clk,
i_start=>o_ready_vs_i_start, 
i_data=>o_packer_vs_i_data,
o_tx=>o_tx_vs_i_rx,
o_tx_done=>open );

StageRx : uart_rx port map( clk=>clk, i_rx=>o_tx_vs_i_rx, 
o_data=>o_data_vs_i_unpacker, 
o_rx_ready=>o_rx_ready_vs_unpacker_ready);

StageUnpacker : uart_unpacker port map(i_clk=>clk,
i_unpacker_ready=> o_rx_ready_vs_unpacker_ready,
i_unpacker=> o_data_vs_i_unpacker,
o_unpacker=>i_data_intermediate_vs_o_unpacker ,
o_ready =>i_start_intermediate_vs_o_unpacker_ready);
  


end rtl;
