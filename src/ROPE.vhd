----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:09:26 08/02/2016 
-- Design Name: 
-- Module Name:    ROPE - Behavioral 
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




entity ROPE is
	 Generic( 
			data_width:integer := 10;
			data_height:integer := 10; 
			screen_width:integer := 640; 
			screen_height:integer := 480;
			player_width:integer := 32;
			player_height:integer := 40;
			rope_width:integer := 2
	 );
    Port ( clk_i : in  STD_LOGIC;
           reset_i : in  STD_LOGIC;
           enable_i : in  STD_LOGIC;
           rope_tick_i : in  STD_LOGIC;
			  screen_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
			  screen_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
           keyboard_shoot_i : in  STD_LOGIC;
			  collision_i : in  STD_LOGIC;
           player_position_x_i : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
			  ROPE_RED_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
           ROPE_GREEN_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
			  ROPE_BLUE_color_o : out  STD_LOGIC_VECTOR (3 downto 0)
			  );
end ROPE;







architecture Behavioral of ROPE is

	signal position_x_internal: STD_LOGIC_VECTOR (data_width - 1 downto 0) := conv_std_logic_vector(1023, data_width);
	signal position_y_internal: STD_LOGIC_VECTOR (data_height - 1 downto 0) := conv_std_logic_vector(1023, data_height);
	signal rope_shot: STD_LOGIC;
	signal ROPE_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal ROPE_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal ROPE_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);




begin
-- INICIALIZATION -----------------------------------------
	ROPE_RED_color_o <= ROPE_RED_internal;
	ROPE_GREEN_color_o <= ROPE_GREEN_internal;
	ROPE_BLUE_color_o <= ROPE_BLUE_internal;
-- END ----------------------------------------------------


	DRAW_STATE: process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				ROPE_RED_internal <= conv_std_logic_vector(0, 4);
				ROPE_GREEN_internal <= conv_std_logic_vector(0, 4);
				ROPE_BLUE_internal <= conv_std_logic_vector(0, 4);
	
				-- DRAWING ROPE
				if(rope_shot = '1')
				then
					if(screen_x_i >= position_x_internal AND screen_x_i <= (position_x_internal + rope_width))
					then
						if(screen_y_i >= position_y_internal AND screen_y_i <= (screen_height - 1))
						then
							ROPE_RED_internal <= conv_std_logic_vector(7, 4);
							ROPE_GREEN_internal <= conv_std_logic_vector(7, 4);
							ROPE_BLUE_internal <= conv_std_logic_vector(1, 4);
						end if;
					end if;
				end if;
								
				if(reset_i = '1')
				then
					ROPE_RED_internal <= conv_std_logic_vector(0, 4);
					ROPE_GREEN_internal <= conv_std_logic_vector(0, 4);
					ROPE_BLUE_internal <= conv_std_logic_vector(0, 4);
				end if;
			end if;
		end process;

	UPDATE_STATE: process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then	
				if(enable_i = '1')
				then
					-- BALL collision detected
					if (collision_i = '1')
					then
						rope_shot <= '0';
						position_x_internal <= conv_std_logic_vector(1023, data_width);
						position_y_internal <= conv_std_logic_vector(1023, data_height);
					end if;
				
					-- KEYBOARD shot pressed
					if(keyboard_shoot_i = '1' and rope_shot = '0')
					then
						rope_shot <= '1';
						position_x_internal <= player_position_x_i + (player_width / 2) - (rope_width / 2);
						position_y_internal <= conv_std_logic_vector(screen_height - 1, data_height);
					end if;
				
					-- ROPE shooting logic
					if (rope_shot = '1')
						then
						if(rope_tick_i = '1')
						then
							if(position_y_internal > 0)
							then
								position_y_internal <= position_y_internal - 1;
							else
								rope_shot <= '0';
								position_x_internal <= conv_std_logic_vector(1023, data_width);
								position_y_internal <= conv_std_logic_vector(1023, data_height);
							end if;
						end if;
					end if;
				end if;
								
				if(reset_i = '1')
				then
					position_x_internal <= conv_std_logic_vector(1023, data_width);
					position_y_internal <= conv_std_logic_vector(1023, data_height);
					rope_shot <= '0';
				end if;
			end if;
		end process;
end Behavioral;

