----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    Prescaler - Behavioral 
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Prescaler, ki deli uro.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH. ALL;
use IEEE.STD_LOGIC_UNSIGNED. ALL;
use IEEE.NUMERIC_STD.ALL;


entity PRESCALER is
	 Generic( 
			data_width:integer := 3;
			value:integer := 2  -- 100MHz / 100M = 1 Hz, en Hz pomeni eno sekundo
		); 
    Port ( 
			clk_i : in  STD_LOGIC;
			reset_i : in  STD_LOGIC;
			enable_o : out  STD_LOGIC
		);
end Prescaler;

architecture Behavioral of PRESCALER is
	signal count:std_logic_vector(data_width - 1 downto 0);
	signal enable:std_logic;
begin
	
	enable_o <= enable;
	
	process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				if(count = (value - 1)) 
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
		end process;
	
	
end Behavioral;

