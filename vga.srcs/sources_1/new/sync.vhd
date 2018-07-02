library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity sync is
  Port ( 
    clk_100MHz      : in std_logic;
    rst             : in std_logic;
    
    clk_out         : out std_logic;
    active_display  : out std_logic;
    h_sync          : out std_logic;
    v_sync          : out std_logic
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
constant h_display      : INTEGER   := 640;
constant h_front_porch  : INTEGER   := 16;
constant h_sync_pulse   : INTEGER   := 96;
constant h_back_porch   : INTEGER   := 48;
constant h_sum          : INTEGER   := h_display + h_front_porch + h_sync_pulse + h_back_porch;
--Vertical (rows)
constant v_display      : INTEGER   := 480;
constant v_front_porch  : INTEGER   := 10;
constant v_sync_pulse   : INTEGER   := 2;
constant v_back_porch   : INTEGER   := 33;
constant v_sum          : INTEGER   := v_display + v_front_porch + v_sync_pulse + v_back_porch;

--borders
constant h_sync_periode_start   : INTEGER   := h_display + h_front_porch - 1;
constant v_sync_periode_start   : INTEGER   := v_display + v_front_porch - 1;
constant h_sync_periode_end     : INTEGER   := h_sync_periode_start + h_sync_pulse - 1;
constant v_sync_periode_end     : INTEGER   := v_sync_periode_start + v_sync_pulse - 1;


signal clk  : STD_LOGIC;
signal h_counter : INTEGER RANGE 0 TO h_sum := 0;
signal v_counter : INTEGER RANGE 0 TO v_sum := 0;

begin

counter : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            h_counter <= 0;
            v_counter <= 0;
        else
            --Range of output
            if(h_counter < h_display and v_counter < v_display) then
                active_display <= '1';
            else
                active_display <= '0';
            end if;
        
            --Range of no output in horizontal
            if(h_counter = h_sync_periode_start) then
                h_sync <= '0';
            elsif(h_counter = h_sync_periode_end) then
                h_sync <= '1';
            end if;
            
            --Range of no output in vertical
            if(v_counter = v_sync_periode_start) then
                v_sync <= '0';
            elsif(v_counter = v_sync_periode_end) then
                v_sync <= '1';
            end if;
            
        end if;
    end if;
end process;

---------------------
--clock
---------------------
clk_wiz_0_0 : clk_wiz_0
port map(
	clk_in1 => clk_100MHz,
	clk_out1 => clk
);
clk_out    <= clk;

end Behavioral;
