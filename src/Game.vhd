----------------------------------------------------------------------------------
-- Company: Fakulteta za raèunalništvo in informatiko
-- Engineer: Luka Prijatelj
-- Create Date:    19:31:24 01/20/2016 
-- Module Name:    Game - Behavioral 
-- Project Name:		SeminarskaNaloga
-- Target Devices: 	Digilent Nexys 4
-- Tool versions:		ISE Project Suite
-- Description: 
--		Glavni modul za seminarsko nalogo.
-- 	Igra je na temo popularne online igrice imenovane "Bubble Trouble".
----------------------------------------------------------------------------------

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;




entity Game is
	Generic( 
			data_width:integer := 10;
			data_height:integer := 10; 
			screen_width:integer := 640; 
			screen_height:integer := 480
	);
   Port ( 
			clk_i : in STD_LOGIC;
			reset_i : in STD_LOGIC;
			pause_game_i : in STD_LOGIC;
			-- PS2
			kbdclk_i : in std_logic;
		   kbddata_i : in std_logic;
			-- VGA display 
			Hsync_o : out  STD_LOGIC;
		   Vsync_o : out STD_LOGIC;
		   vgaRed_o : out  STD_LOGIC_VECTOR (3 downto 0);
		   vgaGreen_o : out  STD_LOGIC_VECTOR (3 downto 0);
		   vgaBlue_o : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end Game;




architecture Behavioral of Game is

-- HSYNC for VGA -----------------------------------------
	component HSYNC
		Generic (
			  DT : integer := 640;
			  FP : integer := 48;
			  BP : integer := 16;
			  SP : integer := 96	
		);
		Port (  clk_i : in  STD_LOGIC;
				  reset_i : in  STD_LOGIC;
				  HSYNC_o : out  STD_LOGIC;
				  HVIDON_o : out  STD_LOGIC;
				  ROWCLK_o : out  STD_LOGIC;
				  COLUMN_o : out  STD_LOGIC_VECTOR (9 downto 0)
		);
	end component;	
	signal HVIDON_internal: STD_LOGIC := '0';
	signal COLUMN_internal: STD_LOGIC_VECTOR (9 downto 0);
-- END ----------------------------------------------------
	
-- VSYNC for VGA ------------------------------------------
	component VSYNC
		Generic (
			  DT : integer := 480;
			  FP : integer := 29;
			  BP : integer := 10;
			  SP : integer := 2	
		);
		Port (  clk_i : in  STD_LOGIC;
				  reset_i : in  STD_LOGIC;
				  ROWCLK_i : in  STD_LOGIC;
				  VSYNC_o : out  STD_LOGIC;
				  VVIDON_o : out  STD_LOGIC;
				  ROW_o : out  STD_LOGIC_VECTOR (9 downto 0)
		);
	end component;
	signal ROWCLK_internal: STD_LOGIC := '0';
	signal VVIDON_internal: STD_LOGIC := '0';
	signal ROW_internal: STD_LOGIC_VECTOR (9 downto 0);
-- END -----------------------------------------------------

-- TIMER_Gravity ---------------------------------------------
	component TIMER
		Generic( 
			data_width:integer := 25;
			maxValue:integer := 50000 -- Maksimalna vrednost, ki resetira števec
		);
		Port ( clk_i: in STD_LOGIC; 
				 reset_i: in STD_LOGIC;
				 enable_i: in STD_LOGIC;
				 tick_o: out STD_LOGIC
		);
	end component;
	signal TIMER_Gravity_Tick: STD_LOGIC;
	signal TIMER_Gravity_Enabled: STD_LOGIC := '1';
-- END -----------------------------------------------------

-- TIMER_Rope ---------------------------------------------
	signal TIMER_Rope_Tick: STD_LOGIC;
	signal TIMER_Rope_Enabled: STD_LOGIC := '1';
-- END ----------------------------------------------------
	
-- TIMER_Walk ---------------------------------------------
	signal TIMER_Walk_Tick: STD_LOGIC;
	signal TIMER_Walk_Enabled: STD_LOGIC := '1';
-- END ----------------------------------------------------
	
-- PLAYER_User ---------------------------------------------
	component PLAYER
		Generic ( data_width:integer := data_width;
					data_height:integer := data_height; 
					screen_width:integer := screen_width; 
					screen_height:integer := screen_height;
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
				 position_x_o : out  STD_LOGIC_VECTOR (data_width - 1 downto 0) 
		);
	end component;
	signal PLAYER_Enabled: STD_LOGIC := '1';
	signal PLAYER_RED_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal PLAYER_GREEN_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal PLAYER_BLUE_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal PLAYER_X_Position : STD_LOGIC_VECTOR (data_width - 1 downto 0);
	signal PLAYER_collision: STD_LOGIC := '0';
-- END -----------------------------------------------------
	
-- ROPE_User -----------------------------------------------
	component ROPE
		 Generic( 
				data_width:integer := data_width;
				data_height:integer := data_height; 
				screen_width:integer := screen_width; 
				screen_height:integer := screen_height;
				player_width:integer := 32;
				player_height:integer := 40;
				rope_width:integer := 2
		 );
		 Port (clk_i : in  STD_LOGIC;
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
	end component;
	signal ROPE_Enabled: STD_LOGIC := '1';
	signal ROPE_Shooting: STD_LOGIC := '0';
	signal ROPE_Collision: STD_LOGIC := '0';
	signal ROPE_RED_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal ROPE_GREEN_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal ROPE_BLUE_Color: STD_LOGIC_VECTOR (3 downto 0);
-- END -------------------------------------------------------
	
-- BALL_SERVICE ----------------------------------------------
	component BALL_BIG
		Generic( 
				data_width:integer := data_width;
				data_height:integer := data_height; 
				screen_width:integer := screen_width; 
				screen_height:integer := screen_height;
				player_width:integer := 32;
				player_height:integer := 40;
				ball_width:integer := 32;
				ball_height:integer := 32
		);
		 Port ( clk_i : in  STD_LOGIC;
				  reset_i : in  STD_LOGIC;
				  enable_i : in  STD_LOGIC;
				  gravity_tick_i : in  STD_LOGIC;
				  screen_x_i : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
			     screen_y_i : in STD_LOGIC_VECTOR (data_height - 1 downto 0);
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
	signal BALL_Enabled: STD_LOGIC := '1';
	signal BALL_No_Ball_Left: STD_LOGIC := '0';
	signal BALL_RED_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_GREEN_Color: STD_LOGIC_VECTOR (3 downto 0);
	signal BALL_BLUE_Color: STD_LOGIC_VECTOR (3 downto 0);
-- END --------------------------------------------------------
	
-- END SCREEN -----------------------------------------------
	component END_SCREEN_RAM80x256
		 Port ( clk_i 		: in  STD_LOGIC;
				  addrOUT_i : in  STD_LOGIC_VECTOR (7 downto 0);
				  data_o 	: out  STD_LOGIC_VECTOR (0 to 79)
				  );
	end component;
	signal RAM_addrOUT_i: STD_LOGIC_VECTOR (7 downto 0);
	signal RAM_data_o: STD_LOGIC_VECTOR (0 to 79);
	signal RAM_index_internal: STD_LOGIC_VECTOR (data_width - 1 downto 0);
-- END ------------------------------------------------------	

-- PS2 Keyboard -----------------------------------------------
	component PS2Controller
		port(
			clk : IN std_logic;
			reset : IN std_logic;
			kbdclk : IN std_logic;
			kbddata : IN std_logic;          
			data_out : OUT std_logic_vector(7 downto 0);
			sc_ready : OUT std_logic
		);
	end component;
	signal data_out : std_logic_vector(7 downto 0);
	signal sc_ready : std_logic := '0';
	signal keyboard_left_internal : STD_LOGIC;
	signal keyboard_right_internal : STD_LOGIC;
	signal keyboard_shoot_internal : STD_LOGIC;
	signal data_out_internal : std_logic_vector(7 downto 0);
	signal sc_ready_internal : std_logic;
-- END --------------------------------------------------------

	-- GENERAL VARIABLES
	signal Game_enabled_internal: STD_LOGIC := '1';
	signal EDGE_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal EDGE_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal EDGE_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal VGA_RED_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal VGA_GREEN_internal: STD_LOGIC_VECTOR (3 downto 0);
	signal VGA_BLUE_internal: STD_LOGIC_VECTOR (3 downto 0);
	
	
	
	
	
	
	
begin

-- START INICIALIZATION --------------------------------------------
	HSYNC_VGA : HSYNC
	port map
	(
		clk_i => clk_i,
		reset_i => reset_i,
		HSYNC_o => Hsync_o,
		HVIDON_o => HVIDON_internal,
		ROWCLK_o => ROWCLK_internal,
		COLUMN_o => COLUMN_internal
	);
	
	VSYNC_VGA : VSYNC
	port map
	(
		clk_i => clk_i,
		reset_i => reset_i,
		ROWCLK_i => ROWCLK_internal,
		VSYNC_o => Vsync_o,
		VVIDON_o => VVIDON_internal,
		ROW_o => ROW_internal
	);
	
	TIMER_Rope : TIMER
	generic map (
		data_width => 25,
		maxValue => 250000
	 )
	port map (
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => TIMER_Rope_Enabled,
		tick_o => TIMER_Rope_Tick
	);
	
	TIMER_Walk : TIMER
	generic map (
		data_width => 25,
		maxValue => 500000
	 )
	port map (
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => TIMER_Walk_Enabled,
		tick_o => TIMER_Walk_Tick
	);

	TIMER_Gravity : TIMER
	generic map (
		data_width => 25,
		maxValue => 650000 	
	 )
	port map (
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => TIMER_Gravity_Enabled,
		tick_o => TIMER_Gravity_Tick
	);	
	
	PLAYER_User : PLAYER
	port map (
		clk_i => clk_i,
		reset_i => reset_i,
		enable_i => PLAYER_Enabled,
		screen_x_i => COLUMN_internal,
		screen_y_i => ROW_internal,
		walk_tick_i => TIMER_Walk_Tick,
		keyboard_left_i => keyboard_left_internal,
	   keyboard_right_i => keyboard_right_internal,
		red_color_o => PLAYER_RED_Color,
	   green_color_o => PLAYER_GREEN_Color,
		blue_color_o => PLAYER_BLUE_Color,
		position_x_o => PLAYER_X_Position
	);
	
	ROPE_User : ROPE
	port map (
		clk_i => clk_i,
	   reset_i => reset_i,
	   enable_i => ROPE_Enabled,
	   rope_tick_i => TIMER_Rope_Tick,
		screen_x_i => COLUMN_internal,
		screen_y_i => ROW_internal,
		keyboard_shoot_i => keyboard_shoot_internal,
		collision_i => ROPE_Collision,
		player_position_x_i => PLAYER_X_Position,
		ROPE_RED_color_o => ROPE_RED_Color,
		ROPE_GREEN_color_o => ROPE_GREEN_Color,
		ROPE_BLUE_color_o => ROPE_BLUE_Color
	);
	
	BALLS_Service : BALL_BIG
	port map (
		clk_i => clk_i,
	   reset_i => reset_i,
	   enable_i => BALL_Enabled,
	   gravity_tick_i => TIMER_Gravity_Tick,
	   screen_x_i => COLUMN_internal,
	   screen_y_i => ROW_internal,
	   -- For player collision check
	   PLAYER_RED_color_i => PLAYER_RED_Color,
	   PLAYER_GREEN_color_i => PLAYER_GREEN_Color,
	   PLAYER_BLUE_color_i => PLAYER_BLUE_Color,
	   -- For rope collision check
	   ROPE_RED_color_i => ROPE_RED_Color,
	   ROPE_GREEN_color_i => ROPE_GREEN_Color,
 	   ROPE_BLUE_color_i => ROPE_BLUE_Color,
		-- For edge collision check
		EDGE_RED_color_i => EDGE_RED_internal,
		EDGE_GREEN_color_i => EDGE_GREEN_internal,
		EDGE_BLUE_color_i => EDGE_BLUE_internal,
	   -- Output ball colors
	   BALL_RED_color_o => BALL_RED_Color,
	   BALL_GREEN_color_o => BALL_GREEN_Color,
	   BALL_BLUE_color_o => BALL_BLUE_Color,
	   collision_rope_o => ROPE_Collision,
		no_ball_left_o => BALL_No_Ball_Left
	);
	
	END_SCREEN_RAM : END_SCREEN_RAM80x256
	port map
	(
		clk_i => clk_i,
	   addrOUT_i => RAM_addrOUT_i,
	   data_o => RAM_data_o
	);
	
	PS2_KEYBOARD: PS2Controller 
	port map(
		clk => clk_i,
		reset => reset_i,
		kbdclk => kbdclk_i,
		kbddata => kbddata_i,
		data_out => data_out_internal,
		sc_ready => sc_ready_internal
	);
-- END INICIALIZATION ---------------------------------------------


	-- SET wires
	Game_enabled_internal <= '0' when (PLAYER_collision = '1' OR pause_game_i = '1') else '1';
	
	-- SET timer wires
	TIMER_Rope_Enabled <= Game_enabled_internal;
	TIMER_Walk_Enabled <= Game_enabled_internal;
	TIMER_Gravity_Enabled <= Game_enabled_internal;
	
	-- SET ball wires
	BALL_Enabled <= Game_enabled_internal;
	
	-- SET player wires
	PLAYER_Enabled <= Game_enabled_internal;
	
	-- SET rope wires
	ROPE_Enabled <= Game_enabled_internal;
		
	-- SET VGA wires
	vgaRed_o <= VGA_RED_internal;
	vgaGreen_o <= VGA_GREEN_internal;
	vgaBlue_o <= VGA_BLUE_internal;

	-- PS2 Keyboard
	keyboard_left_internal <= '1' when (data_out_internal = 107 and sc_ready_internal = '1') else '0';
	keyboard_right_internal <= '1' when (data_out_internal = 116 and sc_ready_internal = '1') else '0';
	keyboard_shoot_internal <= '1' when (data_out_internal = 117 and sc_ready_internal = '1') else '0';

	-- DRAW EDGE
	EDGE_RED_internal <= conv_std_logic_vector(4, 4) when (COLUMN_internal > 635 OR COLUMN_internal < 5 OR ROW_internal < 5 OR ROW_internal > 475) else conv_std_logic_vector(0, 4);
	EDGE_GREEN_internal <= conv_std_logic_vector(4, 4) when (COLUMN_internal > 635 OR COLUMN_internal < 5 OR ROW_internal < 5 OR ROW_internal > 475) else conv_std_logic_vector(0, 4);
	EDGE_BLUE_internal <= conv_std_logic_vector(2, 4) when (COLUMN_internal > 635 OR COLUMN_internal < 5 OR ROW_internal < 5 OR ROW_internal > 475) else conv_std_logic_vector(0, 4);



	UPDATE_STATE : process(clk_i, BALL_RED_Color, BALL_GREEN_Color, BALL_BLUE_Color, PLAYER_RED_Color, PLAYER_GREEN_Color, PLAYER_BLUE_Color)
	begin
		if clk_i'event and clk_i = '1' 
		then
			if(BALL_RED_Color > 0 or BALL_GREEN_Color > 0 or BALL_BLUE_Color > 0)
			then
				if(PLAYER_RED_Color > 0 or PLAYER_GREEN_Color > 0 or PLAYER_BLUE_Color > 0)
				then
					PLAYER_collision <= '1';
				end if;
			end if;
			
			if(reset_i = '1')
			then
				PLAYER_collision <= '0';
			end if;
		end if;
	end process;


	-- COMBINED LOGIC FOR DISPLAYING VIA VGA
	VGA_DRAW_LOGIC : process(clk_i)
	begin
		if clk_i'event and clk_i = '1' 
		then
			if( VVIDON_internal = '1' and HVIDON_internal = '1' )
			then				
				VGA_RED_internal <= BALL_RED_Color or EDGE_RED_internal or ROPE_RED_Color or PLAYER_RED_Color; 
				VGA_GREEN_internal <= BALL_GREEN_Color or EDGE_GREEN_internal or ROPE_GREEN_Color or PLAYER_GREEN_Color;
				VGA_BLUE_internal <= BALL_BLUE_Color or EDGE_BLUE_internal or ROPE_BLUE_Color or PLAYER_BLUE_Color; 
				
				if(PLAYER_collision = '1')
				then
					-- YOU LOST screen
					RAM_index_internal <= std_logic_vector(unsigned(COLUMN_internal) srl 3);
					RAM_addrOUT_i <= std_logic_vector(unsigned(ROW_internal) srl 3) + 60;
				
					if(RAM_data_o(conv_integer(RAM_index_internal)) = '1')
					then
						VGA_RED_internal <= conv_std_logic_vector(7, 4);
					end if;
				elsif(BALL_No_Ball_Left = '1')
				then
					-- YOU WON screen
					RAM_index_internal <= std_logic_vector(unsigned(COLUMN_internal) srl 3);
					RAM_addrOUT_i <= std_logic_vector(unsigned(ROW_internal) srl 3);
				
					if(RAM_data_o(conv_integer(RAM_index_internal)) = '1')
					then
						VGA_GREEN_internal <= conv_std_logic_vector(7, 4);
					end if;
				elsif(pause_game_i = '1')
				then
					-- PAUSE screen
					RAM_index_internal <= std_logic_vector(unsigned(COLUMN_internal) srl 3);
					RAM_addrOUT_i <= std_logic_vector(unsigned(ROW_internal) srl 3) + 120;
				
					if(RAM_data_o(conv_integer(RAM_index_internal)) = '1')
					then
						VGA_GREEN_internal <= conv_std_logic_vector(7, 4);
					end if;
				end if;
				
			else
				-- Field not in visible area (not in display time)!
				-- So set it to default BLACK color (not necessary)
				VGA_RED_internal <= (others => '0');
				VGA_GREEN_internal <= (others => '0');
				VGA_BLUE_internal <= (others => '0');
			end if;
		end if;
	end process;


end Behavioral;

