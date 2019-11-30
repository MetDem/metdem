library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ur is
generic { M : integer :=  10};
port {
clk : in std_logic;
i_rx : in std_logic;

o_data : out std_logic_vector(7 downto 0);
o_ready : out std_logic
};
end entity<
architecture rtl of ur is

    signal  cnt : unsigned(31 downto 0) := to_unsigned(M/2-1,32);
    signal cntrst, cntdone :std_logic:= '1';
    signal dbuf : std_logic_vector( 7 downto 0):=(others=>'0');
   -- signal cnthdone := '1';

begin

    process(clk) is
        begin 
        if rising_edge(clk) then
            if cntrst ='1' then
                cnt<=to_unsigned(M/2-1,32);
                cntdone<='0';
            --    cnthdone<='0';
            else 
            --    cnthdone <='0';
                if cnt=0 then
                    cntdone<='1';
                    cnt<=to_unsigned(M/2-1,32);
               -- elsif cnt =M/2 then
               --     cnthdone <='1';
                else
                    cntdone <='0';
                    cnt<=cnt-1;
                end if;
            end if;
        end if;
    end process;

    process(clk) is
        type state_type is (s0, s1, s2, s3, s4);
        variable state : state_type := s0;
        variable par : std_logic :='0';
    --    variable dcnt : integer :=0;
        variable tcnt : integer :=0;
    begin

        if rising_edge(clk) then
            cntrst <= '0';
            o_ready <= '0';

            case state is 

            --idle state
                when s0=>
                    cntrst<='1';
                    if i_rx = '0' then
                        cntrst<='0';
                        state :=s1;
                        par :='0';
                        dcnt:=0;
                        tcnt:=0;
                    end if;

                when s1=>
                    if cntdone='1' then
                        if i_rx='0' then
                        --    cntrst <= '1';
                            state := s2;
                        -- error
                        else
                            state<=s0;  
                    end if;

                    -- data
                when s2=>
                     if cntdone='1' then
                        tcnt := tcnt+1;
                        if tcnt = 2 
                            tcnt = 0;
                            dbuf<=i_rx & dbuf(dbuf'left downto 1);
                            par := par xor i_rx;
                            dcnt = dcnt +1;
                            if dcnt = 8 then
                                state:=s3;
                            end if;
                         end if;
                    end if;
                  
                -- odd parity
                when s3 =>
                    if cntdone ='1' then
                        tcnt =tcnt+1;
                        if tcnt = 2 then
                            tcnt := 0;
                            if par /= i_rx then
                                state:=s4;
                            -- error
                            else
                                state := s0;
                            end if;
                        end if;
                    end if;
                when s4 =>
                    if cntdone ='1' then
                        tcnt:=tcnt+1;
                        if tcnt =2 then
                            tcnt :=0;
                            -- error check
                            if i_rx /= '1' then
                                state:=s0;
                            --    rx_error <='1'; olsaydi
                            else
                                o_ready<='1';
                                state:=s0;
                            end if;
                        end if;
                    end if;
                end case;
        end if;
    end process;

    -- pure combinatioinal logicc :Ddd xD
    o_data<=dbuf;

end rtl ; 
