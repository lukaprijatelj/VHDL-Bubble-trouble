----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:51:38 12/17/2015 
-- Design Name: 
-- Module Name:    PS2Controller - Behavioral 
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



entity PS2Controller is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           kbdclk : in  STD_LOGIC;
           kbddata : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           sc_ready : out  STD_LOGIC
	 );
end PS2Controller;



architecture Behavioral of PS2Controller is
	component NegEdgeFounder
    Port ( clk 		: in  STD_LOGIC;
           reset 		: in  STD_LOGIC;
           input  	: in  STD_LOGIC;
           output 	: out  STD_LOGIC
    );
	end component;
	
	component ShiftRegister is
		Generic (
				width : integer := 9
		);
		Port ( 
			  clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  shiftEnable : in STD_LOGIC;
			  newValue : in STD_LOGIC;
           reg : out  STD_LOGIC_VECTOR (width-1 downto 0)
	   );
	end component;

	type state_type is ( start , bit0 , bit1, bit2, bit3, bit4, bit5, bit6, bit7, parity, idle);
	signal state , next_state : state_type;
	signal synckbddata : STD_LOGIC;
	signal synckbdclk : STD_LOGIC;
	signal synckbddataneg : STD_LOGIC;
	signal pulse : STD_LOGIC;
	signal shr_en : STD_LOGIC;
	signal shift_signal : STD_LOGIC;
	signal data : STD_LOGIC_VECTOR (8 downto 0);

begin
	
	data_out <= data(7 downto 0);
		
	FIND_NEG_EDGE : NegEdgeFounder
		port map (
			clk => clk,
			reset => reset,
			input => synckbdclk,
			output => pulse
			
		);
	SHIFT_REG : ShiftRegister
		port map (
			clk => clk,
			reset => reset,
			shiftEnable => shift_signal,
			newValue => synckbddata,
			reg => data
			
		);
	
	
	-- Sinhronizacija registra stanj, kbdata in kdataclk
	SYNC_PROC: process ( clk ) 
		begin
			if (clk'event and clk = '1') then
				if (reset = '1') 
				then
					state <= idle;
					synckbddata <= '1';
					synckbdclk <= '1';
				else
					state <= next_state;
					synckbddata <= kbddata;
					synckbdclk <= kbdclk; 
				end if;
			end if;
		end process;
	
	NEXT_STATE_DECODE: process (state, pulse, synckbddata)
	begin
		next_state <= state;
		case ( state ) is
			when idle =>
			   if pulse = '1' and synckbddata = '0' then 
					next_state <= start;
				else
					next_state <= idle;
				end if;
			when start =>
				if pulse = '1' then 
					next_state <= bit0;
				else
					next_state <= start;
				end if;
			when bit0 =>
				if pulse = '1' then 
					next_state <= bit1;
				else
					next_state <= bit0;
				end if;
			when bit1 =>
				if pulse = '1' then 
					next_state <= bit2;
				else
					next_state <= bit1;
				end if;
			when bit2 =>
				if pulse = '1' then 
					next_state <= bit3;
				else
					next_state <= bit2;
				end if;
			when bit3 =>
				if pulse = '1' then 
					next_state <= bit4;
				else
					next_state <= bit3;
				end if;
			when bit4 =>
				if pulse = '1' then 
					next_state <= bit5;
				else
					next_state <= bit4;
				end if;
			when bit5 =>
				if pulse = '1' then 
					next_state <= bit6;
				else
					next_state <= bit5;
				end if;
			when bit6 =>
				if pulse = '1' then 
					next_state <= bit7;
				else
					next_state <= bit6;
				end if;
			when bit7 =>
				if pulse = '1' then 
					next_state <= parity;
				else
					next_state <= bit7;
				end if;
			when parity =>
				if pulse = '1' then 
					next_state <= idle;
				else
					next_state <= parity;
				end if;
			when others => next_state <= idle;
		end case;
	end process;
	
	OUTPUT_DECODE: process ( state ) 
	begin
		sc_ready <= '0';
		if state = start then
			shr_en <= '1';
		elsif state = parity then
			shr_en <= '0';
		elsif state = idle then
			shr_en <= '0';
			sc_ready <= '1';
		else
			shr_en <= '1';
		end if;
		
	end process;
	
	SHIFT_SIGNAL_PROCES: process (shr_en, pulse)
	begin
		if shr_en = '1' and pulse = '1' then
			shift_signal <= '1';
		else
			shift_signal <= '0';
		end if;
	end process;


end Behavioral;

