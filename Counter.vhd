----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    Counter - Behavioral 
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Števec, ki šteje do value in se nato resetira.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH. ALL;
use IEEE.STD_LOGIC_UNSIGNED. ALL;
use IEEE.NUMERIC_STD.ALL;


entity Counter is
	 Generic( 
			data_width:integer := 4;
			value:integer := 10
		);
    Port ( 
			clk_i : in  STD_LOGIC;
			reset_i : in  STD_LOGIC;
			enable_i : in  STD_LOGIC;
			count_o : out  STD_LOGIC_VECTOR (data_width - 1 downto 0)
		);
end Counter;

architecture Behavioral of Counter is
	signal count:std_logic_vector(data_width - 1 downto 0);
begin
	
	count_o <= count;
	
	process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				if( enable_i = '1')
				then
					if( count = (value - 1) ) 
					then
						count <= (others => '0');
					else
						count <= count + 1;
					end if;
				else
					count <= count;
				end if;
				
				if( reset_i = '1' ) 
				then
					count <= (others => '0');
				end if;
				
			end if;
		end process;
		
end Behavioral;

