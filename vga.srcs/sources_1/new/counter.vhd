library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter is
  Port (
    clk : in std_logic;
    rst : in std_logic
    
   );
end counter;

architecture Behavioral of counter is
    signal h_counter : INTEGER RANGE 0 TO 10 - 1 := 0;
    signal v_counter : INTEGER RANGE 0 TO 5 - 1 := 0;
    
begin

counter : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            h_counter <= 0;
            v_counter <= 0;
        else
    end if;
end process;


end Behavioral;
