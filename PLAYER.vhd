----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:31:19 08/02/2016 
-- Design Name: 
-- Module Name:    PLAYER - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;



entity PLAYER is
	Generic( 
			data_width:integer := 10;
			data_height:integer := 10; 
			screen_width:integer := 640; 
			screen_height:integer := 480;
			player_width:integer := 32;
			player_height:integer := 40
	);
    Port ( clk_i : in  STD_LOGIC;
           reset_i : in  STD_LOGIC;
			  enable_i : in  STD_LOGIC;
			  screen_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
			  screen_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
			  -- Walking
           walk_tick_i : in  STD_LOGIC;
			  -- Keyboard
           keyboard_left_i : in  STD_LOGIC;
           keyboard_right_i : in  STD_LOGIC;
			  -- Colors
			  red_color_o : out STD_LOGIC_VECTOR (3 downto 0);
			  green_color_o : out STD_LOGIC_VECTOR (3 downto 0);
			  blue_color_o : out STD_LOGIC_VECTOR (3 downto 0);
           position_x_o : out  STD_LOGIC_VECTOR (data_width - 1 downto 0) -- We only need x position, because Y direction will always be 480!
	);
end PLAYER;





architecture Behavioral of PLAYER is
-- PLAYER RAM -----------------------------------------------
	component PLAYER_RAM32x128
		 Port ( clk_i 		: in  STD_LOGIC;
				  addrOUT_i : in  STD_LOGIC_VECTOR (6 downto 0);
				  data_o 	: out  STD_LOGIC_VECTOR (0 to 31)
				  );
	end component;
	signal RAM_addrOUT_i: STD_LOGIC_VECTOR (6 downto 0);
	signal RAM_data_o: STD_LOGIC_VECTOR (0 to 31);
	signal RAM_index_internal: STD_LOGIC_VECTOR (data_width - 1 downto 0);
	signal RAM_movement_internal: STD_LOGIC_VECTOR (data_height - 1 downto 0) := (others => '0');
-- END ------------------------------------------------------

	signal position_x_internal: STD_LOGIC_VECTOR (data_width - 1 downto 0) := conv_std_logic_vector(320, data_width) - conv_std_logic_vector(16, data_width);
	signal position_y_internal: STD_LOGIC_VECTOR (data_height - 1 downto 0) := conv_std_logic_vector(screen_height, data_height) - conv_std_logic_vector(player_height + 5, data_height);
	signal PLAYER_RED_internal: STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal PLAYER_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal PLAYER_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	





begin
-- INICIALIZATION ------------------------------------------
	PLAYER_RAM : PLAYER_RAM32x128
	port map
	(
		clk_i => clk_i,
	   addrOUT_i => RAM_addrOUT_i,
	   data_o => RAM_data_o
	);
-- END -----------------------------------------------------

	-- SET wires
	position_x_o <= position_x_internal;
	red_color_o <= PLAYER_RED_internal;
	green_color_o <= PLAYER_GREEN_internal;
	blue_color_o <= PLAYER_BLUE_internal;


	DRAW_STATE: process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				PLAYER_RED_internal <= conv_std_logic_vector(0, 4);
				PLAYER_GREEN_internal <= conv_std_logic_vector(0, 4);
				PLAYER_BLUE_internal <= conv_std_logic_vector(0, 4);
				RAM_addrOUT_i <= conv_std_logic_vector(0, 7);
				RAM_movement_internal <= conv_std_logic_vector(0, data_height);

				if(enable_i = '1')
				then
					if(keyboard_left_i = '1')
					then
						RAM_movement_internal <= conv_std_logic_vector(40, data_height);
					elsif (keyboard_right_i = '1')
					then
						RAM_movement_internal <= conv_std_logic_vector(80, data_height);
					end if;
				end if;
				
				-- DRAWING PLAYER
				if(screen_x_i >= position_x_internal AND screen_x_i <= (position_x_internal + player_width))
				then
					if(screen_y_i >= position_y_internal AND screen_y_i <= (position_y_internal + player_height))
					then
						RAM_addrOUT_i <= screen_y_i(6 downto 0) - position_y_internal(6 downto 0) + RAM_movement_internal;
						RAM_index_internal <= screen_x_i - position_x_internal;
				
						if(RAM_data_o(conv_integer(RAM_index_internal)) = '1')
						then
							PLAYER_RED_internal <= conv_std_logic_vector(0, 4);
							PLAYER_GREEN_internal <= conv_std_logic_vector(6, 4);
							PLAYER_BLUE_internal <= conv_std_logic_vector(0, 4);
						end if;
					end if;
				end if;
				
				if(reset_i = '1')
				then
					PLAYER_RED_internal <= conv_std_logic_vector(0, 4);
					PLAYER_GREEN_internal <= conv_std_logic_vector(0, 4);
					PLAYER_BLUE_internal <= conv_std_logic_vector(0, 4);
					RAM_addrOUT_i <= conv_std_logic_vector(0, 7);
					RAM_movement_internal <= (others => '0');
				end if;
			end if;
		end process;
	

	UPDATE_STATE: process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then

				if(enable_i = '1')
				then
					-- PLAYER walking logic
					if(walk_tick_i = '1')
					then
						if(keyboard_left_i = '1')
						then
							if(position_x_internal > 0)
							then
								position_x_internal <= position_x_internal - 1;
							end if;
						elsif (keyboard_right_i = '1')
						then
							if((position_x_internal + player_width) < screen_width)
							then
								position_x_internal <= position_x_internal + 1;
							end if;
						end if;
					end if;
				end if;

				if(reset_i = '1')
				then
					position_x_internal <= conv_std_logic_vector(320, data_width) - conv_std_logic_vector(16, data_width);
					position_y_internal <= conv_std_logic_vector(screen_height, data_height) - conv_std_logic_vector(player_height + 5, data_height);
				end if;
			end if;
		end process;

end Behavioral;

