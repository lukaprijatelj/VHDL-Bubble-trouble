----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    GlobalTime - Behavioral 
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		NEXYS 4: Implementira èas za igrico. MaxTick ima frekvenco 10 MHz (maxValue=10).
--	   NEXYS 2: Implementira èas za igrico. MaxTick ima frekvenco 100 mHZ (maxValue=50000).
-- 	Ob vsakem MaxTick-u, se nasprotniki pomaknejo eno vrstico nižje.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity TIMER is
	 Generic( 
			data_width:integer := 25;
			maxValue:integer := 50000 -- Maksimalna vrednost, ki resetira števec
		);
    Port ( 
			clk_i : in  STD_LOGIC;
			reset_i : in  STD_LOGIC;
			enable_i : in  STD_LOGIC;
			tick_o : out  STD_LOGIC
		);
end TIMER;

architecture Behavioral of TIMER is
	signal count:std_logic_vector(data_width - 1 downto 0);
	signal enable:std_logic;
begin
	
	tick_o <= enable;
	
	process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				if(enable_i = '1')
				then
					if(count = (maxValue - 1)) 
					then
						-- Resets the count[26:0] to all zeros (eg. 0000000000..)
						count <= (others => '0');
						enable <= '1';
					else
						count <= count + 1;	
						enable <= '0';
					end if;
					
					if( reset_i = '1' )
					then
						count <= (others => '0');
						enable <= '0';
					end if;
				end if;
			end if;
		end process;
	
	
end Behavioral;
