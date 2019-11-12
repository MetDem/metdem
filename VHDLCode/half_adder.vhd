library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder is
     Port (  x,y : in std_logic;
             s,co : out std_logic
         );
end half_adder;

architecture Behavioral of half_adder is
begin
co<= x and y;
s<=x xor y;

end Behavioral;
