----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:02:38 08/03/2016 
-- Design Name: 
-- Module Name:    BALL_SMALL - Behavioral 
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




entity BALL_SMALL is
	Generic( 
			data_width:integer := 10;
			data_height:integer := 9; 
			screen_width:integer := 640; 
			screen_height:integer := 480;
			player_width:integer := 32;
			player_height:integer := 40;
			ball_width:integer := 32;
			ball_height:integer := 32
	);
    Port ( clk_i : in  STD_LOGIC;
           reset_i : in  STD_LOGIC;
           enable_i : in  STD_LOGIC;
           gravity_tick_i : in  STD_LOGIC;
		     parent_destroyed_i : in  STD_LOGIC;
		     right_ball_i : in  STD_LOGIC;
			  screen_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
			  screen_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
			  parent_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
			  parent_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
			  -- For player collision check
			  PLAYER_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
           PLAYER_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  PLAYER_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  -- For rope collision check
			  ROPE_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
           ROPE_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  ROPE_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  -- For edge collision check
			  EDGE_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
           EDGE_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  EDGE_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  -- Output ball colors
			  BALL_RED_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
           BALL_GREEN_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
			  BALL_BLUE_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
			  collision_rope_o : out  STD_LOGIC;
			  no_ball_left_o : out STD_LOGIC
	);
end BALL_SMALL;








architecture Behavioral of BALL_SMALL is

-- BALL_RAM --------------------------------------------------------------
	component BALL_RAM32x128
		 Port ( clk_i 		: in  STD_LOGIC;
				  addrOUT_i : in  STD_LOGIC_VECTOR (6 downto 0);
				  data_o 	: out  STD_LOGIC_VECTOR (0 to 31));
	end component;
	signal RAM_addrOUT_i: STD_LOGIC_VECTOR (6 downto 0);
	signal RAM_data_o: STD_LOGIC_VECTOR (0 to 31);
	signal RAM_index_internal: STD_LOGIC_VECTOR (data_width - 1 downto 0);
-- END --------------------------------------------------------------

-- BALL_XSMALL -----------------------------------------------------------
	component BALL_XSMALL
		Generic( 
				data_width:integer := data_width;
				data_height:integer := data_height; 
				screen_width:integer := screen_width; 
				screen_height:integer := screen_height;
				player_width:integer := player_width;
				player_height:integer := player_height;
				ball_width:integer := ball_width;
				ball_height:integer := ball_height
		);
		 Port ( clk_i : in  STD_LOGIC;
				  reset_i : in  STD_LOGIC;
				  enable_i : in  STD_LOGIC;
				  gravity_tick_i : in  STD_LOGIC;
				  parent_destroyed_i : in  STD_LOGIC;
				  right_ball_i : in  STD_LOGIC;
				  screen_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
				  screen_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
				  parent_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
				  parent_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
				  -- For player collision check
				  PLAYER_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  PLAYER_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  PLAYER_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  -- For rope collision check
				  ROPE_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  ROPE_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  ROPE_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  -- For edge collision check
				  EDGE_RED_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  EDGE_GREEN_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  EDGE_BLUE_color_i : in  STD_LOGIC_VECTOR (3 downto 0);
				  -- Output ball colors
				  BALL_RED_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
				  BALL_GREEN_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
				  BALL_BLUE_color_o : out  STD_LOGIC_VECTOR (3 downto 0);
				  collision_rope_o : out  STD_LOGIC;
				  no_ball_left_o : out STD_LOGIC
		);
	end component;
	signal BALL_XSMALL_LEFT_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_LEFT_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_LEFT_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_LEFT_right_internal: STD_LOGIC := '0';
	signal BALL_XSMALL_LEFT_no_more_internal: STD_LOGIC := '0';
	signal BALL_XSMALL_LEFT_rope_collision_internal: STD_LOGIC := '0';
	signal BALL_XSMALL_RIGHT_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_RIGHT_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_RIGHT_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_XSMALL_RIGHT_right_internal: STD_LOGIC := '1';
	signal BALL_XSMALL_RIGHT_rope_collision_internal: STD_LOGIC := '0';
	signal BALL_XSMALL_RIGHT_no_more_internal: STD_LOGIC := '0';
-- END --------------------------------------------------------------------

	-- PHYSICS variables
	signal FORCE_RIGHT_internal:STD_LOGIC_VECTOR(data_width - 1 downto 0) := conv_std_logic_vector(4, data_width);
	signal FORCE_LEFT_internal:STD_LOGIC_VECTOR(data_width - 1 downto 0) := conv_std_logic_vector(0, data_width);
	signal FORCE_UP_internal:STD_LOGIC_VECTOR(data_height - 1 downto 0) := conv_std_logic_vector(0, data_width);
	signal FORCE_DOWN_internal:STD_LOGIC_VECTOR(data_height - 1 downto 0) := conv_std_logic_vector(3, data_width);
	
	signal position_x_internal:STD_LOGIC_VECTOR(data_width - 1 downto 0) := conv_std_logic_vector(320, data_width) - conv_std_logic_vector(16, data_width);
	signal position_y_internal:STD_LOGIC_VECTOR(data_height - 1 downto 0) := conv_std_logic_vector(240, data_height) - conv_std_logic_vector(16, data_height);

	signal BALL_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);
	
	signal THIS_BALL_parent_position_copied: STD_LOGIC := '0';
	signal THIS_BALL_destroyed: STD_LOGIC := '0';
	signal Collision_rope_internal: STD_LOGIC := '0';
	signal Collision_edge_x_position_internal:STD_LOGIC_VECTOR(data_width - 1 downto 0);
	signal Collision_edge_y_position_internal:STD_LOGIC_VECTOR(data_height - 1 downto 0);
	signal Collision_edge_internal: STD_LOGIC := '0';
	
	
	
begin
-- START INICIALIZATION --------------------------------------------------------
	BALL_RAM : BALL_RAM32x128
	port map
	(
		clk_i => clk_i,
		addrOUT_i => RAM_addrOUT_i,
		data_o => RAM_data_o
	);
	
	BALL_XSMALL_LEFT : BALL_XSMALL
	generic map (
		data_width => data_width,
		data_height => data_height,
		screen_width => screen_width,
		screen_height => screen_height,
		player_width => player_width,
		player_height => player_height,
		ball_width => ball_width,
		ball_height => ball_height	
	)
	port map
	(
	   clk_i => clk_i,
	   reset_i => reset_i,
	   enable_i => enable_i,
	   gravity_tick_i => gravity_tick_i,
	   parent_destroyed_i => THIS_BALL_destroyed,
	   right_ball_i => BALL_XSMALL_LEFT_right_internal,
	   screen_x_i => screen_x_i,
	   screen_y_i => screen_y_i,
	   parent_x_i => position_x_internal,
	   parent_y_i => position_y_internal,
	   -- For player collision check
	   PLAYER_RED_color_i => PLAYER_RED_color_i,
	   PLAYER_GREEN_color_i => PLAYER_GREEN_color_i,
	   PLAYER_BLUE_color_i => PLAYER_BLUE_color_i,
	   -- For rope collision check
	   ROPE_RED_color_i => ROPE_RED_color_i,
	   ROPE_GREEN_color_i => ROPE_GREEN_color_i,
	   ROPE_BLUE_color_i => ROPE_BLUE_color_i,
	   -- For edge collision check
	   EDGE_RED_color_i => EDGE_RED_color_i,
	   EDGE_GREEN_color_i => EDGE_GREEN_color_i,
	   EDGE_BLUE_color_i => EDGE_BLUE_color_i,
	   -- Output ball colors
	   BALL_RED_color_o => BALL_XSMALL_LEFT_RED_internal,
	   BALL_GREEN_color_o => BALL_XSMALL_LEFT_GREEN_internal,
	   BALL_BLUE_color_o => BALL_XSMALL_LEFT_BLUE_internal,
	   collision_rope_o => BALL_XSMALL_LEFT_rope_collision_internal,
		no_ball_left_o =>BALL_XSMALL_LEFT_no_more_internal
	);
	
	BALL_XSMALL_RIGHT : BALL_XSMALL
	generic map (
		data_width => data_width,
		data_height => data_height,
		screen_width => screen_width,
		screen_height => screen_height,
		player_width => player_width,
		player_height => player_height,
		ball_width => ball_width,
		ball_height => ball_height	
	)
	port map
	(
	   clk_i => clk_i,
	   reset_i => reset_i,
	   enable_i => enable_i,
	   gravity_tick_i => gravity_tick_i,
	   parent_destroyed_i => THIS_BALL_destroyed,
	   right_ball_i => BALL_XSMALL_RIGHT_right_internal,
	   screen_x_i => screen_x_i,
	   screen_y_i => screen_y_i,
	   parent_x_i => position_x_internal,
	   parent_y_i => position_y_internal,
	   -- For player collision check
	   PLAYER_RED_color_i => PLAYER_RED_color_i,
	   PLAYER_GREEN_color_i => PLAYER_GREEN_color_i,
	   PLAYER_BLUE_color_i => PLAYER_BLUE_color_i,
	   -- For rope collision check
	   ROPE_RED_color_i => ROPE_RED_color_i,
	   ROPE_GREEN_color_i => ROPE_GREEN_color_i,
	   ROPE_BLUE_color_i => ROPE_BLUE_color_i,
	   -- For edge collision check
	   EDGE_RED_color_i => EDGE_RED_color_i,
	   EDGE_GREEN_color_i => EDGE_GREEN_color_i,
	   EDGE_BLUE_color_i => EDGE_BLUE_color_i,
	   -- Output ball colors
	   BALL_RED_color_o => BALL_XSMALL_RIGHT_RED_internal,
	   BALL_GREEN_color_o => BALL_XSMALL_RIGHT_GREEN_internal,
	   BALL_BLUE_color_o => BALL_XSMALL_RIGHT_BLUE_internal,
	   collision_rope_o => BALL_XSMALL_RIGHT_rope_collision_internal,
		no_ball_left_o =>BALL_XSMALL_RIGHT_no_more_internal
	);
-- END --------------------------------------------------------------------------


	-- SET OUTPUT wires
	BALL_RED_color_o <= BALL_RED_internal or BALL_XSMALL_LEFT_RED_internal or BALL_XSMALL_RIGHT_RED_internal; 
	BALL_GREEN_color_o <= BALL_GREEN_internal or BALL_XSMALL_LEFT_GREEN_internal or BALL_XSMALL_RIGHT_GREEN_internal;
	BALL_BLUE_color_o <= BALL_BLUE_internal or BALL_XSMALL_LEFT_BLUE_internal or BALL_XSMALL_RIGHT_BLUE_internal;
	no_ball_left_o <= '1' when (BALL_XSMALL_RIGHT_no_more_internal = '1' and BALL_XSMALL_LEFT_no_more_internal = '1' and THIS_BALL_destroyed = '1') else '0';
	collision_rope_o <= Collision_rope_internal or BALL_XSMALL_LEFT_rope_collision_internal or BALL_XSMALL_RIGHT_rope_collision_internal;
	
	
	DRAW_STATE: process(clk_i)
	begin
		if clk_i'event and clk_i = '1' 
		then
			RAM_addrOUT_i <= conv_std_logic_vector(0, 7);
			BALL_RED_internal <= conv_std_logic_vector(0, 4);
			BALL_GREEN_internal <= conv_std_logic_vector(0, 4);
			BALL_BLUE_internal <= conv_std_logic_vector(0, 4);
			
			if(parent_destroyed_i = '1')
			then				
				-- DRAWING BALL
				if(THIS_BALL_destroyed = '0')
				then	
					if(screen_x_i >= position_x_internal AND screen_x_i <= (position_x_internal + ball_width))
					then
						if(screen_y_i >= position_y_internal AND screen_y_i <= (position_y_internal + ball_height))
						then
							RAM_addrOUT_i <= screen_y_i - position_y_internal + ball_height + ball_height;
							RAM_index_internal <= screen_x_i - position_x_internal;
					
							if(RAM_data_o(conv_integer(RAM_index_internal)) = '1')
							then
								BALL_RED_internal <= conv_std_logic_vector(5, 4);
								BALL_GREEN_internal <= conv_std_logic_vector(0, 4);
								BALL_BLUE_internal <= conv_std_logic_vector(0, 4);
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	UPDATE_STATE: process(clk_i)
		begin
			if clk_i'event and clk_i = '1' 
			then
				Collision_rope_internal <= '0';
				
				if(parent_destroyed_i = '1')
				then
					if(THIS_BALL_parent_position_copied = '0')
					then
						if(right_ball_i = '1')
						then
							FORCE_RIGHT_internal <= conv_std_logic_vector(4, data_width);
							FORCE_LEFT_internal <= conv_std_logic_vector(0, data_width);
						else
							FORCE_RIGHT_internal <= conv_std_logic_vector(0, data_width);
							FORCE_LEFT_internal <= conv_std_logic_vector(4, data_width);
						end if;
					
						FORCE_UP_internal <= conv_std_logic_vector(3, data_height);
						FORCE_DOWN_internal <= conv_std_logic_vector(0, data_height);
					
						position_x_internal <= parent_x_i;
						position_y_internal <= parent_y_i;
						THIS_BALL_parent_position_copied <= '1';
					end if;
					
					if(enable_i = '1')
					then
						-- WARNING: Only if ball has not yet been destroyed!
						if(THIS_BALL_destroyed = '0')
						then	
							Collision_edge_internal <= '0';

							-- COLLISION CHECKS (works by checking if any pixels of player or rope are overlapping)
							if(BALL_RED_internal > 0 or BALL_GREEN_internal > 0 or BALL_BLUE_internal > 0)
							then
								if(ROPE_RED_color_i > 0 or ROPE_GREEN_color_i > 0 or ROPE_BLUE_color_i > 0)
								then
									THIS_BALL_destroyed <= '1';
									Collision_rope_internal <= '1';
								end if;
								if(EDGE_RED_color_i > 0 or EDGE_GREEN_color_i > 0 or EDGE_BLUE_color_i > 0)
								then
									Collision_edge_x_position_internal <= screen_x_i;
									Collision_edge_y_position_internal <= screen_y_i;
									Collision_edge_internal <= '1';
								end if;
							end if;
							
							if(Collision_edge_internal = '1' or position_x_internal > 1000 or position_y_internal > 1000)
							then
								if(Collision_edge_x_position_internal < 5 or position_x_internal > 1000)
								then
									FORCE_RIGHT_internal <= conv_std_logic_vector(4, data_width);
									FORCE_LEFT_internal <= conv_std_logic_vector(0, data_width);
								elsif(Collision_edge_x_position_internal > 635)
								then
									FORCE_LEFT_internal <= conv_std_logic_vector(4, data_width);
									FORCE_RIGHT_internal <= conv_std_logic_vector(0, data_width);
								end if;
								
								if(Collision_edge_y_position_internal < 5 or position_y_internal > 1000)
								then
									FORCE_DOWN_internal <= conv_std_logic_vector(3, data_height);
									FORCE_UP_internal <= conv_std_logic_vector(0, data_height);
								elsif(Collision_edge_y_position_internal > 475)
								then
									FORCE_UP_internal <= conv_std_logic_vector(3, data_height);
									FORCE_DOWN_internal <= conv_std_logic_vector(0, data_height);
								end if;
							end if;
							
							-- PHYSICS/GRAVITY logic
							if(gravity_tick_i = '1')
							then
								position_x_internal <= position_x_internal + FORCE_RIGHT_internal - FORCE_LEFT_internal;
								position_y_internal <= position_y_internal + FORCE_DOWN_internal - FORCE_UP_internal;
							end if;
						end if;
					end if;
				end if;
				
				if(reset_i = '1')
				then
					if(right_ball_i = '1')
					then
						FORCE_RIGHT_internal <= conv_std_logic_vector(4, data_width);
						FORCE_LEFT_internal <= conv_std_logic_vector(0, data_width);
					else
						FORCE_RIGHT_internal <= conv_std_logic_vector(0, data_width);
						FORCE_LEFT_internal <= conv_std_logic_vector(4, data_width);
					end if;
					
					FORCE_UP_internal <= conv_std_logic_vector(3, data_height);
					FORCE_DOWN_internal <= conv_std_logic_vector(0, data_height);
					position_x_internal <= conv_std_logic_vector(320, data_width) - conv_std_logic_vector(16, data_width);
					position_y_internal <= conv_std_logic_vector(240, data_height) - conv_std_logic_vector(16, data_height);
					THIS_BALL_destroyed <= '0';
					Collision_rope_internal <= '0';
					Collision_edge_internal <= '0';
				   THIS_BALL_parent_position_copied <= '0';
				end if;
			end if;
		end process;

end Behavioral;

