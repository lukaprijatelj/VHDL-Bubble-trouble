----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:30:00 12/10/2015 
-- Design Name: 
-- Module Name:    NegEdgeFounder - Behavioral 
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



entity NegEdgeFounder is
    Port ( clk 		: in  STD_LOGIC;
           reset 		: in  STD_LOGIC;
           input  	: in  STD_LOGIC;
           output 	: out  STD_LOGIC);
end NegEdgeFounder;



architecture Behavioral of NegEdgeFounder is

	type state_type is ( s0 , s1 , s2); -- možna stanja
	signal state , next_state : state_type;



begin
	
	SYNC_PROC: process ( clk ) -- delovanje registra stanj
	begin
		if (clk'event and clk = '1') then
			if ( reset = '1' ) then
				state <= s0;
			else
				state <= next_state;
			end if;
		end if;
	end process;
	
	NEXT_STATE_DECODE: process (state , input)
	begin
		next_state <= state;
		case ( state ) is
			when s0 =>
				if input = '0' then 
					next_state <= s0;
				else
					next_state <= s1;
				end if;
			when s1 =>
				if input = '0' then 
					next_state <= s2;
				else
					next_state <= s1;
				end if;
			when s2 =>
				if input = '0' then 
					next_state <= s0;
				else
					next_state <= s1;
				end if;
			when others => next_state <= s0;
		end case;
	end process;
	
	OUTPUT_DECODE: process ( state ) -- logika za izhod
	begin
		output <= '0' ;
		case ( state ) is
			when s0 => output <= '0' ;
			when s1 => output <= '0' ;
			when s2 => output <= '1' ;
			when others => output <= '0';
		end case;
	end process;

end Behavioral;

