library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sync is
  Port ( 
    clk_100MHz      : in std_logic;
    rst             : in std_logic;
    
    h_sync          : out std_logic;
    v_sync          : out std_logic;
    active_display  : out std_logic;
    
    h_counter_out   : out std_logic_vector(31 downto 0);
    v_counter_out   : out std_logic_vector(31 downto 0);
    
    h_size          : out std_logic_vector(31 downto 0);
    v_size          : out std_logic_vector(31 downto 0)
    
  );
end sync;

architecture Behavioral of sync is

--integrate clock wizard
component clk_wiz_0
port
(
      clk_in1   : in    std_logic;
      clk_out1  : out   std_logic
 );
 end component;

--Horizontal (pixel clocks)
constant h_display      : std_logic_vector(31 downto 0)   := x"00000280"; --640
constant h_front_porch  : std_logic_vector(31 downto 0)   := x"00000010"; --16 
constant h_sync_pulse   : std_logic_vector(31 downto 0)   := x"00000060"; --96
constant h_back_porch   : std_logic_vector(31 downto 0)   := x"00000030"; --48
constant h_sum          : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(h_display) + unsigned(h_front_porch) + unsigned(h_sync_pulse) + unsigned(h_back_porch) - 1);
--Vertical (rows)
constant v_display      : std_logic_vector(31 downto 0)   := x"000001E0"; --480
constant v_front_porch  : std_logic_vector(31 downto 0)   := x"0000000A"; --10
constant v_sync_pulse   : std_logic_vector(31 downto 0)   := x"00000002"; --2
constant v_back_porch   : std_logic_vector(31 downto 0)   := x"00000021"; --33
constant v_sum          : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(v_display) + unsigned(v_front_porch) + unsigned(v_sync_pulse) + unsigned(v_back_porch) - 1);

--borders
constant h_sync_periode_start   : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(h_display) + unsigned(h_front_porch) - 1);
constant v_sync_periode_start   : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(v_display) + unsigned(v_front_porch) - 1);
constant h_sync_periode_end     : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(h_sync_periode_start) + unsigned(h_sync_pulse) - 1);
constant v_sync_periode_end     : std_logic_vector(31 downto 0)   := std_logic_vector( unsigned(v_sync_periode_start) + unsigned(v_sync_pulse) - 1);

signal clk  : std_logic;
signal h_counter : std_logic_vector(31 downto 0) := (others => '0');
signal v_counter : std_logic_vector(31 downto 0) := (others => '0');

begin

---------------------------------------------------------------
--COUNTER
--
--Info:
--Counting lines and pixels-per-line
---------------------------------------------------------------
counter : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            h_counter <= (others => '0');
            v_counter <= (others => '0');
        else
            --if right border?
            if(unsigned(h_counter) = unsigned(h_sum)) then
                h_counter <= (others => '0');
                
                --if bottom?
                if(unsigned(v_counter) = unsigned(v_sum)) then
                    v_counter <= (others => '0');
                else
                    v_counter <= std_logic_vector( unsigned(v_counter) + 1);
                end if;
                
            else
                h_counter <=  std_logic_vector( unsigned(h_counter) + 1);
            end if;
        end if;
    end if;
end process;
h_counter_out <= h_counter;
v_counter_out <= v_counter;
h_size <= h_display;
v_size <= v_display;

---------------------------------------------------------------
--BORDER SIGNALS
--
--Info:
--Set Signals between images, porches and pulses
---------------------------------------------------------------
def_borders : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            v_sync <= '1';
            h_sync <= '1';
            active_display <= '0';
        else
            --Range of output
            if( unsigned(h_counter) < unsigned(h_display) and unsigned(v_counter) < unsigned(v_display)) then
                active_display <= '1';
            else
                active_display <= '0';
            end if;
        
            --Range of no output in horizontal
            if(unsigned(h_counter) = unsigned(h_sync_periode_start)) then
                h_sync <= '0';
            elsif(unsigned(h_counter) = unsigned(h_sync_periode_end)) then
                h_sync <= '1';
            end if;
            
            --Range of no output in vertical
            if((unsigned(v_counter) = unsigned(v_sync_periode_start)) and (unsigned(h_sum) = unsigned(h_counter))) then
                v_sync <= '0';
            elsif((unsigned(v_counter) = unsigned(v_sync_periode_end)) and (unsigned(h_sum) = unsigned(h_counter))) then
                v_sync <= '1';
            end if;
            
        end if;
    end if;
end process;


---------------------------------------------------------------
--CLOCK
--
--Info:
--For image refreshing, specific MHz value is needed.
---------------------------------------------------------------
clk_wiz_0_0 : clk_wiz_0
port map(
	clk_in1 => clk_100MHz,
	clk_out1 => clk
);

end Behavioral;
