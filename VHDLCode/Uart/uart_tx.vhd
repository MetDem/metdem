library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity uart_tx is

port(   
     clk: in std_logic;
     o_tx: out std_logic;
     o_tx_done: out std_logic;
     i_start : in std_logic;
     i_data: in std_logic_vector(7 downto 0)
     );
  end entity;

architecture rtl of uart_tx is
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
       type state_type is (idle, startbit, send_data, parity, stopbit);
       variable state: state_type := idle;
       variable dcnt: integer :=0;
       variable par : std_logic := '1'; -- for even parity we calculated xor methodlogy
   begin
       if rising_edge(clk) then
            cntrst<='0';
            o_tx_done<='0';

            case state is
               when idle=>
                 o_tx<= '1';
                 cntrst <= '1';
                 
                 if i_start = '1' then
                    state:= startbit;
                    dbuf<= i_data;
                    dcnt:=0;
                    par:= '0';
                    cntrst <= '0';
                 end if;

             when startbit =>
                 o_tx<= '0';
                 if cntdone = '1' then
                    state:= send_data;
                 end if;

             when send_data=>
                o_tx <= dbuf(0);
                  if cntdone = '1' then
                  par:= par xor dbuf(0);
                     dcnt:= dcnt+1;
                     if dcnt = 8 then
                         state:= parity;
                         dcnt:= 0;
                     else
                          dbuf <= '0' & dbuf(dbuf'left downto 1);
                     end if;
                  end if;

               when parity=>
               o_tx <= par;
               if par = '1' then
                  o_tx<= '1';   -- even parity
               else
                  o_tx <= '0';
               end if;
               
               if cntdone = '1' then
                   state := stopbit;
               end if;
               
             when stopbit =>
                 o_tx<= '1';
                 if cntdone = '1' then
                    state:= idle;
                    o_tx_done <= '1';
                 end if;
             end case;
           end if;
         end process;  
                 
 end rtl;
