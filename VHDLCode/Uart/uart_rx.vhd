library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity uart_rx is
port(
    clk : in std_logic;
    i_rx : in std_logic;
    o_data : out std_logic_vector(7 downto 0);
    o_rx_ready : out std_logic
);
end entity;

architecture rtl of uart_rx is

    signal  cnt : unsigned(31 downto 0) := to_unsigned(M/2-1,32);
    signal cntrst, cntdone :std_logic:= '1';
    signal dbuf : std_logic_vector( 7 downto 0):=(others=>'0');

begin

    process(clk) is
        begin 
        if rising_edge(clk) then
            if cntrst ='1' then
                cnt<=to_unsigned(M/2-1,32);
                cntdone<='0';
            else 
                if cnt=0 then
                    cntdone<='1';
                    cnt<=to_unsigned(M/2-1,32);
                else
                    cntdone <='0';
                    cnt<=cnt-1;
                end if;
            end if;
        end if;
    end process;

    process(clk) is
        type state_type is (idle, startbit, recdata, parity, stopbit);
        variable state : state_type := idle;
        variable par : std_logic :='0';
        variable dcnt : integer :=0;
        variable tcnt : integer :=0;
    begin

        if rising_edge(clk) then
            cntrst <= '0';
            o_rx_ready <= '0';

            case state is 
            --idle state
                when idle=>
                    cntrst<='1';
                    if i_rx = '0' then
                        cntrst<='0';
                        state :=startbit;
                        par :='0';
                        dcnt:=0;
                        tcnt:=0;
                    end if;

                when startbit=>
                    if cntdone='1' then
                        if i_rx='0' then
                            state := recdata;
                        -- error
                        else
                            state := idle;  
                         end if;
                    end if;

                    -- data
                when recdata=>
                     if cntdone='1' then
                        tcnt := tcnt+1;
                        if tcnt = 2 then
                            tcnt := 0;
                            dbuf<=i_rx & dbuf(dbuf'left downto 1);
                            par := par xor i_rx;
                            dcnt := dcnt +1;
                            if dcnt = 8 then
                                state:=parity;
                            end if;
                         end if;
                    end if;
                  
                -- even parity stage
                when parity =>
                    if cntdone ='1' then
                        tcnt :=tcnt+1;
                        if tcnt = 2 then
                            tcnt := 0;
                            if par = i_rx then
                                state:=stopbit;
                            -- error
                            else
                                state := idle;
                            end if;
                        end if;
                    end if;

                when stopbit =>
                    if cntdone ='1' then
                        tcnt:=tcnt+1;
                        if tcnt =2 then
                            tcnt :=0;
                            -- error check
                            if i_rx /= '1' then
                                state:=idle;
                            else
                                o_rx_ready<='1';
                                state:=idle;
                            end if;
                        end if;
                    end if;
                end case;
        end if;
    end process;


    -- pure combinatioinal logicc :Ddd xD
    o_data<=dbuf;

end rtl ; 
