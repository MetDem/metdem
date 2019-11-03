library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
  generic(number_bit : integer:=8); -- flip-flop stages

  port ( clk : in  std_logic;
         clear : in  std_logic;
         input : in  std_logic;
         output : out std_logic_vector(number_bit-1 downto 0));
end shift_register;

architecture rtl of shift_register is
    signal r : std_logic_vector(number_bit-1 downto 0):=x"00";
    
begin
    
    process(clk)
    begin
      if(rising_edge(clk)) then
        if (clear='1') then
          r<=x"00";
         else
         for i in 0 to number_bit-2 loop
           r(i+1)<=r(i);
          end loop;
        --  r(0)<=input;
        end if;
      end if;
      r(0)<=input;
    end process;
    
    output  <= r;
end rtl;
