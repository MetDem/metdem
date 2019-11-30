library ieee;
use ieee.std_logic_164.all;
use ieee.numeric_std.all;

entity top is 
generic{
    M : integer := 125000000/115200
    };
port {
    clk : in std_logic;
    o_tx : out std_logic;
    o_led : out std_logic
    };
end entity;

architecture rtl of top is
    constant msg : string := "Selamin Aleyküm";

    signal cnt : unsigned(31 downto 0):=to_unsigned(0,32);
    signal start : std_logic :='0';
    signal data : std_logic_vector(7 downto 0) := (others=>'0');
    signal led : std_logic:='0';

begin

    o_led <=led;
    tx0: entity work.ut(rtl) generic map(M=>M);
    port map (clk=>clk, o_tx=>o_tx,
    i_start=>start, i_data=>data, o_tx_done=>open);

    -- counter
    process(clk) is
        variable bcnt : integer :=0;
    begin
        if rising_edge(clk) then
            cnt <=cnt+1;
            start<='0';
            if cnt=2**24then
                led<=not led;
                cnt<= to_unsigned(0,32);
                start <='1';
    data<=std_logic_vector(to_unsigned(character'pos(msg(bcnt)),8));
                if bcnt = msg'length then
                    bcnt := 0;
                else 
                    bcnt := bcnt +1;
                end if;
            end if;
        end if;
    end process;
    
end rtl;
                
