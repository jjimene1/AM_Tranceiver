LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL, STD.textio.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY top IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        ADC_LRCLK : OUT STD_LOGIC; -- ADC signals
        ADC_SCLK : OUT STD_LOGIC;
        ADC_MCLK : OUT STD_LOGIC;
        ADC_SDATA1 : IN STD_LOGIC;
        dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
  dac_LRCK : OUT STD_LOGIC;
  dac_SCLK : OUT STD_LOGIC;
  dac_SDIN : OUT STD_LOGIC
        );
END top;

ARCHITECTURE Behavioral OF top IS
signal count : STD_LOGIC_VECTOR (20 DOWNTO 0);
signal MCLK : STD_LOGIC;
signal SCLK : STD_LOGIC;
signal LRCLK : STD_LOGIC;
signal adout : STD_LOGIC_VECTOR (23 DOWNTO 0) := "000000000000000000000000";
file results : text;
COMPONENT adc_if IS
        PORT (
        SCLK : IN STD_LOGIC; -- serial clock that goes to ADC
  SDATA1 : IN STD_LOGIC; -- serial data channel 1
  LRCLK : IN STD_LOGIC; -- chip select that initiates A/D conversion
  data_1 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0); -- parallel 12-bit data ch1
        dac_data : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
ckp : PROCESS
      BEGIN
        WAIT UNTIL rising_edge(clk_in);
        count <= count + 1; -- counter to generate ADC timing signals
    END PROCESS;
ADC_MCLK <= NOT count(1); -- 25 MHz serial clock
dac_MCLK <= NOT count(1);
SCLK <= count(4); -- 25 / 2^3 = 25 / 8 = 3.125 MHz
LRCLK <= count(9); -- 3.125 / 64 
ADC_LRCLK <= LRCLK;
ADC_SCLK <= SCLK;
dac_LRCK <= LRCLK;
dac_SCLK <= SCLK;
adc : adc_if
    PORT MAP(-- instantiate ADC serial to parallel interface
        SCLK => SCLK, 
        SDATA1 => ADC_SDATA1, 
        LRCLK => LRCLK,
        data_1 => adout,
        dac_data =>dac_SDIN 
    );
process(LRCLK)
variable ILine, OLine : Line;
variable A_in, B_in, C_in, D_in, Z_out : BIT;
variable z : bit_vector(23 downto 0);
variable i : integer := 0;
variable ch : CHARACTER;
variable poo : STD_LOGIC_VECTOR(23 downto 0) := "000000000000000000000000";
begin
file_open(results, "C:/Users/17326/AM_Tranceiver/results.txt", WRITE_MODE);
z := to_bitvector(adout);
write(OLine, z, right, 25);
writeline(results, OLine);
file_close(results);
end process;

END Behavioral;