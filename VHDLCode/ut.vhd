library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ut is

generic(
-- m=freq/uart rate
M: integer:= 125000000/115200
);
port(
     
     clk: in std_logic;
     o_tx: out std_logic;
     o_tx_done: out std_logic;
     i_start : in std_logic;
     i_data: in std_logic_vector(7 downto 0)
     );
  end entity;

architecture rtl of ut is
    signal cnt: unsigned(31 downto 0) := to_unsigned(M-1,32);
    signal cntrst, cntdone: std_logic:='1';
    signal dbuf : std_logic_vector(7 downto 0):= (others => '0');

begin    
   process(clk) is
   begin  
    if rising_edge(clk) then
     if cntrst= '1' then
       cnt<=to_unsigned(M-1, 32);
       cntdone<= '0';
     else
       if cnt= 0 then
       cntdone<= '1';
         cnt<= to_unsigned(M-1,32);
       else
       cntdone <= '0';
         cnt <= cnt-1;
       end if;
     end if;
    end if;
 end process;
       
   --state machine
   process(clk) is
       type state_type is (s0, s1, s2, s3, s4);
       variable state: state_type := s0;
       variable dcnt: integer :=0;
       variable par : std_logic := '0';
   begin
       if rising_edge(clk) then
            cntrst<='0';
            o_tx_done<='0';
            case state is
               when s0=>
                 o_tx<= '1';
                 cntrst <= '1';
                 
                 if i_start = '1' then
                    state:= s1;
                    dbuf<= i_data;
                    dcnt:=0;
                    par:= '0';
                    cntrst <= '0';
                 end if;
             when s1 =>
                 o_tx<= '0';
                 if cntdone = '1' then
                    state:= s2;
                 end if;
             when s2=>
                o_tx <= dbuf(0);
                  if cntdone = '1' then
                  par:= par xor dbuf(0);
                     dcnt:= dcnt+1;
                     if dcnt = 8 then
                         state:= s3;
                         dcnt:= 0;
                     else
                          dbuf <= '0' & dbuf(dbuf'left downto 1);
                     end if;
                  end if;
               when s3=>
               o_tx <= par;
               if par = '1' then
                  o_tx<= '0';
               else
                  o_tx <= '1';
               end if;
               
               if cntdone = '1' then
                   state := s4;
               end if;
               
             when s4 =>
                 o_tx<= '1';
                 if cntdone = '1' then
                    state:= s0;
                    o_tx_done <= '1';
                 end if;
             end case;
           end if;
         end process;  
                 
 end rtl;
