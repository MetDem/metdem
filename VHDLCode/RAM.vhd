library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
   generic
      (
         WDATA : integer := 32; -- word lenght
         WADDR : integer := 10  -- addres lenght and ram height 2^10 = 1kbayt
         );
   port
      (
         i_clk		: in std_logic; -- clock signal
         i_enable		: in std_logic; -- enable signal
         i_data	: in std_logic_vector(WDATA-1 downto 0);  --32 bit 
         i_addr	: in std_logic_vector(WADDR-1 downto 0);  --32 bit
         c_wre	: in std_logic; -- write/read control 
         o_data	: out std_logic_vector(WDATA-1 downto 0)
         );

end data_mem;

architecture behavioral of data_mem is

   type ram_type is array(0 to 2**WADDR - 1) of std_logic_vector(WDATA - 1 downto 0);   

  signal ram_s : ram_type:= (others => (others =>'0'));  
begin
   process(i_clk)is
   begin
      if(rising_edge(i_clk)) then
         if(i_enable = '1') then
            if(c_wre = '1') then
               ram_s(to_integer(unsigned(i_addr))) <= i_data;
               RAM(conv_integer(addr)) <= di
            else
               o_data <= ram_s(to_integer(unsigned(i_addr)));
            end if;
         end if;
      end if;
   end process;
   
end behavioral;
