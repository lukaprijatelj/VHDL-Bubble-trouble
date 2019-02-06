----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:49:26 10/29/2015 
-- Design Name: 
-- Module Name:    ShiftRegister - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;



entity ShiftRegister is
	Generic (
		width : integer := 9
	);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  shiftEnable : in STD_LOGIC;
			  newValue : in STD_LOGIC;
           reg : out  STD_LOGIC_VECTOR (width-1 downto 0));
end ShiftRegister;


architecture Behavioral of ShiftRegister is
	signal regLocal : STD_LOGIC_VECTOR (width-1 downto 0);
	
	
	
begin
	reg <= regLocal;
	
	UPDATE: process(clk)
		begin
			if clk'event and clk = '1' then
				if(reset = '1') then
					regLocal <= (others => '0');
				else
					if(shiftEnable = '1') then
						regLocal(width-2 downto 0) <= regLocal(width-1 downto 1);
						regLocal(width-1) <= newValue;
					else
						regLocal <= regLocal;
					end if;
				end if;
			end if;
		end process ;

end Behavioral;

