library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ram is
generic (
        D : integer := 4; -- data bits word length
        A : integer := 3 -- address length and memory size 2**A
    );
end tb_ram;

architecture behaviorel of tb_ram is
    component ram is 
    generic (
        D : integer := 8; -- data bits word length
        A : integer := 4 -- address length and memory size 2**A
    );
    port (
        clk : in std_logic;
        we : in std_logic; 
        addr : in std_logic_vector(A-1 downto 0); 
        din : in std_logic_vector(D-1 downto 0); 
        dout : out std_logic_vector(D-1 downto 0) 
    );
    end component;
    
    constant CLK_PERIOD : time := 5 ns;

    signal clk,we : std_logic:='0';
    signal addr : std_logic_vector(A-1 downto 0);
    signal din,dout : std_logic_vector(D-1 downto 0);
    
begin
    stage : ram generic map(D=>D,A=>A)
    port map (clk=>clk,we=>we,addr=>addr,din=>din,dout=>dout);

    process
    begin
    clk<= not clk;
    wait for CLK_PERIOD;
    end process;

    process
    begin
    wait for 10 ns;
            
          
            addr <= "000"; -- send A 1010 
            wait for 10 ns;
            
            we<='1';
            addr<= "000";
            din <=x"B";            
            wait for 20 ns;
            
            we<='0';
            din <=x"0"; 
            addr <= "000"; -- ?
            
            wait;
    end process;

end behaviorel;
