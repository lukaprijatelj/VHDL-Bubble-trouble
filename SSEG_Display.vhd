----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    SSEG_Display - Behavioral  
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Modul za prikazovanje na sedem segmentnem prikazovalniku.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity SSEG_Display is
    Port ( 
			displayNumber_i : in  STD_LOGIC_VECTOR (3 downto 0);
			selectedDisplay_i : in STD_LOGIC_VECTOR (3 downto 0);
			cathode_o : out  STD_LOGIC_VECTOR (6 downto 0);
			anode : out  STD_LOGIC_VECTOR (7 downto 0)
	  );
end SSEG_Display;

architecture Behavioral of SSEG_Display is

begin

	-- Anode poskrbi za preklapljanje med 8-imi prikazovalniki
	anode_o <=  "11111110" when selectedDisplay_i = "0000" else
					"11111101" when selectedDisplay_i = "0001" else
					"11111011" when selectedDisplay_i = "0010" else
					"11110111" when selectedDisplay_i = "0011" else
					"11101111" when selectedDisplay_i = "0100" else
					"11011111" when selectedDisplay_i = "0101" else
					"10111111" when selectedDisplay_i = "0110" else
					"01111111" when selectedDisplay_i = "0111" else
					"00000000";
	
	-- Cathode poskrbi za prikazovanje številk na prikazovalnik
	cathode_o <= "1000000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0000") else
					"1111001" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0001") else
					"0100100" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0010") else
					"0110000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0011") else
					"0011001" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0100") else
					"0010010" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0101") else
					"0000010" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0110") else
					"1011000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "0111") else
					"0000000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1000") else
					"0010000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1001") else
					"0001000" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1010") else
					"0000011" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1011") else
					"1000110" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1100") else
					"0100001" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1101") else
					"0000110" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1110") else
					"0001110" when (selectedDisplay_i = "0000" and displayNumber_i(3 downto 0) = "1111") else
					
					"1000000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0000") else
					"1111001" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0001") else
					"0100100" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0010") else
					"0110000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0011") else
					"0011001" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0100") else
					"0010010" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0101") else
					"0000010" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0110") else
					"1011000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "0111") else
					"0000000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1000") else
					"0010000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1001") else
					"0001000" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1010") else
					"0000011" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1011") else
					"1000110" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1100") else
					"0100001" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1101") else
					"0000110" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1110") else
					"0001110" when (selectedDisplay_i = "0001" and displayNumber_i(7 downto 4) = "1111") else
					
					"1000000";

end Behavioral;

