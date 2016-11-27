----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    VSYNC - Behavioral  
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Modul za vertikalno sinhronizacijo prikazovanja preko VGA protokola.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH. ALL;
use IEEE.STD_LOGIC_UNSIGNED. ALL;
use IEEE.NUMERIC_STD.ALL;





entity VSYNC is
	 Generic (
			DT : integer := 480; -- Display Time
			FP : integer := 29; -- Front Porch
			BP : integer := 10; -- Back Porch
			SP : integer := 2	 -- Sync Pulse
	 );
    Port ( 
			clk_i : in  STD_LOGIC;
			reset_i : in  STD_LOGIC;
			ROWCLK_i : in  STD_LOGIC;
			VSYNC_o : out  STD_LOGIC;
			VVIDON_o : out  STD_LOGIC;
			ROW_o : out  STD_LOGIC_VECTOR (9 downto 0)
	  );
end VSYNC;






architecture Behavioral of VSYNC is
-- COUNTER ---------------------------------------------------
	component COUNTER
		Generic ( 
				data_width:integer := 10;
				value:integer := 525
		);
		Port (
				clk_i : in  STD_LOGIC;
				reset_i : in  STD_LOGIC;
				enable_i : in  STD_LOGIC;
				count_o : out  STD_LOGIC_VECTOR (data_width - 1 downto 0)
		);
	end component;
	signal ROW_internal: STD_LOGIC_VECTOR (9 downto 0);
-- END --------------------------------------------------------





begin
-- INICIALIZATION ---------------------------------------------
	COUNTER_Module : COUNTER
	generic map
	(
		data_width => 10,
		value => 521
	)
	port map
	(
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => ROWCLK_i,
		count_o => ROW_internal
	);
-- END ---------------------------------------------------------

	-- SET OUTPUT wires
	ROW_o <= ROW_internal;
	
	VSYNC_LOGIC : process(ROW_internal)
		begin			
			-- IF PIXEL IS VISIBLE
			if( ROW_internal >= DT )  
			then
				VVIDON_o <= '0';
			else
				VVIDON_o <= '1';
			end if;
			
			if ( ROW_internal >= (DT + BP) AND ROW_internal < (DT + BP + SP) ) 
			then
				VSYNC_o <= '0'; -- (eniške stevilke morajo biti brez narekovajev)
			else
				VSYNC_o <= '1';
			end if;

			if( reset_i = '1' ) 
			then
				VVIDON_o <= '0';
				VSYNC_o <= '0';
			end if;
				
		end process;

end Behavioral;

