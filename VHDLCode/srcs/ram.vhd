library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic (
        D : integer := 4; -- data bits word length
        A : integer := 3 -- address length and memory size 2**A
    );
    port (
        clk : in std_logic;
        we : in std_logic; 
        addr : in std_logic_vector(A-1 downto 0); 
        din : in std_logic_vector(D-1 downto 0); 
        dout : out std_logic_vector(D-1 downto 0) 
    );
    end ram;
architecture behaviorel of ram is
type ram_type is array(0 to 2**A-1) of std_logic_vector(D-1 downto 0);
signal RAM : ram_type:=(
    x"A", x"4", x"C", x"E",
    x"1", x"3", x"9", x"D"
);
--signal RAM : ram_type := (others => (others => '0' ));
--         3210
--         ----
--   000 | xxxx
--   001 | xxxx
--   010 | xxxx
--   ... |  ..
--   ... |  ..
--   110 | xxxx
--   111 | xxxx
begin

    process(clk) is
    begin
        if rising_edge(clk) then
            dout <= RAM(to_integer(unsigned(addr))); -- read enable MODE

            if we = '1' then
                RAM(to_integer(unsigned(addr))) <= din; -- write enable MODE
                 --dout <= din; -- optional, write first
            end if;
        end if;
    end process;

end behaviorel;
