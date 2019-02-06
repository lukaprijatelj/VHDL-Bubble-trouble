----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    HSYNC - Behavioral  
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Modul za horizontalno sinhronizacijo prikazovanja preko VGA protokola.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH. ALL;
use IEEE.STD_LOGIC_UNSIGNED. ALL;
use IEEE.NUMERIC_STD.ALL;




entity HSYNC is
	 Generic (
			DT : integer := 640; -- Display Time
			FP : integer := 48; -- Front Porch
			BP : integer := 16; -- Back Porch
			SP : integer := 96 -- Sync Pulse
	 );
    Port ( 
			clk_i : in  STD_LOGIC;
			reset_i : in  STD_LOGIC;
			HSYNC_o : out  STD_LOGIC;
			HVIDON_o : out  STD_LOGIC;
			ROWCLK_o : out  STD_LOGIC;
			COLUMN_o : out  STD_LOGIC_VECTOR (9 downto 0)
	);
end HSYNC;






architecture Behavioral of HSYNC is

-- PRESCALER --------------------------------------------------
	component PRESCALER
		Generic ( 
				data_width : integer := 2; 
				value : integer := 2			 
		);
		Port (
				clk_i: in STD_LOGIC; 
				reset_i: in STD_LOGIC;
				enable_o: out STD_LOGIC
		);
	end component;
	signal prescaled_CLK_internal: STD_LOGIC := '0';
-- END --------------------------------------------------------

-- COUNTER ----------------------------------------------------
	component COUNTER
		Generic ( 
				data_width:integer := 10;
				value:integer := 800
		);
		Port ( 
				clk_i : in  STD_LOGIC;
				reset_i : in  STD_LOGIC;
				enable_i : in  STD_LOGIC;
				count_o : out  STD_LOGIC_VECTOR (data_width - 1 downto 0)
		);
	end component;
	signal COLUMN_internal: STD_LOGIC_VECTOR (9 downto 0);
	signal ROW_internal : STD_LOGIC := '0';
-- END --------------------------------------------------------
	
	
	
	
	
	
	
begin
-- INICIALIZATION ---------------------------------------------
	PRESCALER_Module : PRESCALER
	generic map (
		data_width => 2,
		value => 2 -- 25MHz for pixel displaying
	)
	port map (
		clk_i => clk_i,
		reset_i => reset_i,
		enable_o => prescaled_CLK_internal
	);
	
	COUNTER_Module : COUNTER
	generic map
	(
		data_width => 10,
		value => 800
	)
	port map
	(
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => prescaled_CLK_internal,
		count_o => COLUMN_internal
	);
-- END ---------------------------------------------------------


	-- SET OUTPUT wires
	COLUMN_o <= COLUMN_internal;
	ROWCLK_o <= ROW_internal;
		
		
	HSYNC_LOGIC : process(COLUMN_internal)
		begin
			-- IF PIXEL IS VISIBLE
			if( COLUMN_internal >= DT )  
			then
				HVIDON_o <= '0';
			else
				HVIDON_o <= '1';
			end if;
		
			if( COLUMN_internal >= (DT + BP) AND COLUMN_internal < (DT + BP + SP) ) 
			then
				HSYNC_o <= '0';
			else
				HSYNC_o <= '1';
			end if;

			if( reset_i = '1' ) 
			then
				HVIDON_o <= '0';
				HSYNC_o <= '0';
			end if;
		end process;
	
	END_OF_LINE_JUMP_TO_NEW_LINE : process(COLUMN_internal)
		begin
			-- Check if we came to right end of the monitor. If so then go to new line and back from the start.
			if( COLUMN_internal = (DT + BP + FP + SP - 1) ) 
			then
				ROW_internal <= '1' and prescaled_CLK_internal;
			else
				ROW_internal <= '0';
			end if;
		
		end process;
	
end Behavioral;

