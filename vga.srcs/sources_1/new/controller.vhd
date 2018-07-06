library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity controller is
    Port ( 
        clk      : in std_logic;
        rst        : in std_logic;
        colors_in  : in std_logic_vector(11 downto 0);
        
        --VGA
        h_sync     : out std_logic;
        v_sync     : out std_logic;
        colors     : out std_logic_vector(11 downto 0)
);
end controller;

architecture Behavioral of controller is
    
    signal active_display : std_logic;
    
    --integrate sync
    component sync
    port
    (
        clk_100MHz      : in std_logic;
        rst             : in std_logic;
        
        active_display  : out std_logic;
        h_sync          : out std_logic;
        v_sync          : out std_logic
    );
    end component;
 
begin

    colorchange : process(colors_in, active_display)
    begin
        if (active_display = '1') then
            --colors <= colors_in;
            colors <= x"0F0"; --GREEN
        end if;
    end process;

    --sync binding
    sync_0 : sync
    port map(
        clk_100MHz => clk,
        rst => rst,
        h_sync => h_sync,
        v_sync => v_sync,
        active_display => active_display 
    );

end Behavioral;
