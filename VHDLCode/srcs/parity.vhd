-- 8-bit parity generator
--   t = 0 for even parity
--   t = 1 for  odd parity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parity is
    generic ( M : positive := 8);
    port ( din : in std_logic_vector(M-1 downto 0);
           parity_bit : out std_logic
    );
end parity;
architecture behaviorel of parity is
    
begin
    process(din)
	variable test : integer := 0;
	variable aux : integer := 0;
		begin 
		for i in 0 to M-1 loop 
            if (din(i) = '1') then
                test := test + 1;
            end if ;
		end loop ;
		
		aux := test mod 2;
            if ( aux = 0 ) then 
                parity_bit <= '1';
            else 
                parity_bit <= '0';
            end if;
	end process;


end behaviorel;
