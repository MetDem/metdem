library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity uart_packer is
    port ( 
        i_clk      : in std_logic;                           
        i_packer_ready : in std_logic;
        i_packer       : in std_logic_vector(D downto 0);
        
        o_packer   : out std_logic_vector(D downto 0); 
        o_ready    : out std_logic
        
        
    );
end entity uart_packer;

architecture rtl of uart_packer is
    type state_type is (rst, src, dst, ident, payload, check,encryp, send_data);
    signal state : state_type := rst;
    signal s_buffer: std_logic_vector(ULEN_1 downto 0) := (others=>'0'); 
    signal s_buff_src_addr: std_logic_vector(D downto 0) := (others=>'0');
    signal s_buff_dst_addr: std_logic_vector(D downto 0) := (others=>'0');
    signal s_buff_ident:    std_logic_vector(D downto 0) := (others=>'0');
    signal s_buff_payload:  std_logic_vector(127 downto 0) := (others=>'0');
    signal s_buff_checksum: std_logic_vector(D downto 0) := (others => '0');
    signal s_encryp_data : std_logic_vector(127 downto 0) := (others=> '0');
    signal s_key : std_logic_vector(7 downto 0) := (others=> '1');



    signal s_cnt : unsigned(3 downto 0) := "0000";
    signal s_cntdone : unsigned(3 downto 0) := "1111" ;

    signal s_reset        : std_logic := '1';
    signal s_packer_ready : std_logic := '0';
    signal s_encryp_ready : std_logic := '0';
    signal s_packer_done  : std_logic := '0'; 

    signal s_src_addr_ready : std_logic := '0';
    signal s_dst_addr_ready : std_logic := '0';
    signal s_identifier_ready : std_logic := '0';
    signal s_payload_ready    : std_logic := '0';
    signal s_checksum_ready   : std_logic := '0';
    signal s_send_data_ready : std_logic := '0';

    signal cntrst : std_logic := '0';
    signal cntdone : std_logic := '0';
    signal cnt     : unsigned(31 downto 0) := (others=>'0');

begin

    process(i_clk) is
    begin 
    if rising_edge(i_clk) then
        if cntrst ='1' then
            cnt<= to_unsigned(((TIMER/2)-1),32);
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


process(i_clk) is

begin

    if rising_edge(i_clk) then
        cntrst <= '0';
        o_ready <= '0';
        o_packer <= x"00";

        case state is 

            when rst =>
                cntrst <= '1';
                s_buff_payload <= (others=>'0');
                s_buffer <= (others=>'0');
                s_encryp_data <= (others=>'0');


                if (i_packer_ready = '1') then 
                    cntrst <= '0';
                    s_src_addr_ready <= '1';
                    state <= src;
                end if;

            when src => 
                if(s_src_addr_ready = '1') then
                    s_buff_src_addr <= OUR_ADDRESS;
                    s_src_addr_ready <= '0';
                    s_dst_addr_ready <= '1';
                    state <= dst;
                end if;
            
            when dst =>
                if(s_dst_addr_ready = '1') then
                    s_buff_dst_addr <= DST_ADDRESS;
                    s_dst_addr_ready <= '0';
                    s_identifier_ready <= '1';
                    state <= ident;
                end if;
            
            when ident =>
                if(s_identifier_ready = '1') then
                    s_buff_ident <= IDENTIFIER;
                    s_identifier_ready <= '0';
                    s_payload_ready <= '1';
                    state <= payload;
                end if;
            
            when payload => 
                if(cntdone = '1' and s_payload_ready = '1') then 
                    if(i_packer /= x"10") then
                        s_buff_payload <= i_packer & s_buff_payload(127 downto 8);
                        if(s_cnt = s_cntdone) then
                            s_checksum_ready <= '1';
                            state <= check;
                            s_cnt <= "0000";
                            s_payload_ready <= '0';
                        else
                            s_cnt <= s_cnt + 1;
                            state <= payload;
                            s_payload_ready <= '1';
                        end if;    
                    else
                        state <= check;
                    end if;
                end if;

                when check => 
                if(s_checksum_ready = '1') then
                    s_buff_checksum <= CHECKSUM;
                    s_checksum_ready <= '0';
                    s_encryp_ready <= '1';
                    s_buffer <= s_buff_checksum & s_buff_payload & s_buff_ident & s_buff_dst_addr & s_buff_src_addr;
                    state <= encryp;
                end if;


            when encryp => 
                if(s_encryp_ready = '1') then 
                    s_encryp_data(127 downto 120) <= s_key xor s_buffer(151 downto 144);
                    s_buffer(151 downto 24) <= s_buffer(143 downto 24) & s_buffer(151 downto 144);
                    
                    if(s_cnt = s_cntdone) then
                        s_send_data_ready <= '1';
                        s_encryp_ready <= '0';
                        s_buffer <= s_buff_checksum & s_encryp_data & s_buff_ident & s_buff_dst_addr & s_buff_src_addr;
                        state <= send_data; 
                        s_cnt <= "0000";
                    else
                        s_encryp_data <= s_encryp_data(119 downto 0) & s_encryp_data(127 downto 120);
                        s_cnt <= s_cnt +1;
                        s_encryp_ready <= '1';
                        state <= encryp;
                    end if;
                end if;

            when send_data => 
                if(s_send_data_ready = '1' and cntdone = '1') then
                    o_packer <= s_buffer(7 downto 0);
                    if(s_cnt = s_cntdone) then
                        s_send_data_ready <= '0';
                        s_cnt <= "0000";
                        state <= rst;
                        o_ready <= '1';
                    else
                        s_buffer <= s_buffer(7 downto 0) & s_buffer(159 downto 8);
                        s_cnt <= s_cnt + 1;
                        s_send_data_ready <= '1';
                        state <= send_data;
                    end if;
                end if;
            end case;
    end if;

    end process;

end rtl;
