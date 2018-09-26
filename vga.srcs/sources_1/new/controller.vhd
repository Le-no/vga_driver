library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller is
    Port ( 
        clk_in      : in std_logic;
        rst        : in std_logic;
        
        --VGA
        h_sync     : out std_logic;
        v_sync     : out std_logic;
        colors     : out std_logic_vector(11 downto 0)
);
end controller;

architecture Behavioral of controller is
    
    signal active_display : std_logic;
    signal h_counter      : std_logic_vector(31 downto 0);
    signal v_counter      : std_logic_vector(31 downto 0);
    signal h_size : std_logic_vector(31 downto 0);
    signal v_size : std_logic_vector(31 downto 0);
    
    --integrate sync
    component sync
    port
    (
        clk_100MHz      : in std_logic;
        rst             : in std_logic;
        
        active_display  : out std_logic;
        h_sync          : out std_logic;
        v_sync          : out std_logic;
        
        h_counter_out   : out std_logic_vector(31 downto 0);
        v_counter_out   : out std_logic_vector(31 downto 0);
        
        v_size          : out std_logic_vector(31 downto 0);
        h_size          : out std_logic_vector(31 downto 0)
    );
    end component;
 
begin

    colorchange : process(v_counter, h_counter, active_display)
    begin
        if (active_display = '1') then
            if ((unsigned(v_size) / 2) > unsigned(v_counter)) then
                if ((unsigned(h_size) / 2) > unsigned(h_counter)) then
                    colors <= x"F00";
                else
                    colors <= x"0F0";
                end if;
            else
                if ((unsigned(h_size) / 2) > unsigned(h_counter)) then
                    colors <= x"00F";
                else
                    colors <= x"FFF";
                end if;
            end if;
        end if;
    end process;

    --sync binding
    sync_0 : sync
    port map(
        clk_100MHz => clk_in,
        rst => rst,
        h_sync => h_sync,
        v_sync => v_sync,
        active_display => active_display,
        v_counter_out => v_counter,
        h_counter_out => h_counter,
        h_size => h_size,
        v_size => v_size 
    );

end Behavioral;
