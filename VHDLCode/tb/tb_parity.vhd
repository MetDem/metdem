library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_parity is
     generic ( M : positive := 8);
end tb_parity;
architecture Behavioral of tb_parity is
component parity is 
    generic ( M : positive := 8);
    port ( din : in std_logic_vector(M-1 downto 0);
           parity_bit : out std_logic
    );
end component;

signal din : std_logic_vector(M-1 downto 0);
signal parity_bit : std_logic;

begin
 stage : parity generic map(M=>M)
         port map (din=>din,parity_bit=>parity_bit);


process
begin

wait for 5 ns;
din <= "11110000"; -- parity 1
wait for 10 ns;
din<= "00000111"; -- parity 0 

end process;


end Behavioral;

