LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY adc_if IS
	PORT (
		SCLK : IN STD_LOGIC; -- serial clock that goes to ADC
		SDATA1 : IN STD_LOGIC; -- serial data channel 1
		LRCLK : IN STD_LOGIC; -- chip select that initiates A/D conversion
		data_1 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0); -- parallel 12-bit data ch1
        dac_data : OUT STD_LOGIC);
END adc_if;

ARCHITECTURE Behavioral OF adc_if IS
	SIGNAL pdata1 : std_logic_vector (23 DOWNTO 0); -- 12-bit shift registers
	signal start : std_logic;
BEGIN
	-- this process waits for CS=0 and then clocks serial data from ADC into shift register
	-- MSBit first. After 16 SCK's, four leading zeros will have fallen out of the most significant
	-- end of the shift register and the register will contain the parallel 12-bit data
	startReading : PROCESS(LRCLK) --execute process when LRCLK changes
	BEGIN
		start <= '1';	
	END PROCESS;
	
	startReading2 : PROCESS(SCLK)
    variable c : integer range 0 to 25 := 0;
	BEGIN
	    if(start = '1' AND falling_edge(SCLK)) THEN
	       pdata1 <= pdata1(22 DOWNTO 0) & SDATA1;
	       dac_data <= SDATA1;
	       c := c + 1;
	    end if;
	    if(c = 25) then
	       c := 0;
	       start <= '0';
	       data_1 <= pdata1;
	    end if;
	END PROCESS;
	-- this process waits for rising edge of CS and then loads parallel data
	-- from shift register into appropriate output port

END Behavioral;
