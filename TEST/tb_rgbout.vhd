--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_rgbout is
end tb_rgbout;

architecture stimulus of tb_rgbout is

-- COMPONENTS --
	component rgbout
		port(
			MCLK			: in	std_logic;
			nRST			: in	std_logic;
			CLEAR			: in	std_logic;
			R				: out	std_logic_vector(2 downto 0);
			G				: out	std_logic_vector(2 downto 0);
			B				: out	std_logic_vector(1 downto 0);
			DISP_ENA		: in	std_logic;
			FIFO_EMPTY		: in	std_logic;
			DIN				: in	std_logic_vector(15 downto 0);
			NXT				: out	std_logic;
			UNDERRUN		: out	std_logic;
			BLANKING		: in	std_logic
		);
	end component;
	component vga_controller
	GENERIC(
		h_pulse 	:	INTEGER := 96;    	--horiztonal sync pulse width in pixels
		h_bp	 	:	INTEGER := 48;		--horiztonal back porch width in pixels
		h_pixels	:	INTEGER := 640;		--horiztonal display width in pixels
		h_fp	 	:	INTEGER := 128;		--horiztonal front porch width in pixels
		h_pol		:	STD_LOGIC := '0';		--horizontal sync pulse polarity (1 = positive, 0 = negative)
		v_pulse 	:	INTEGER := 2;			--vertical sync pulse width in rows
		v_bp	 	:	INTEGER := 33;			--vertical back porch width in rows
		v_pixels	:	INTEGER := 480;		--vertical display width in rows
		v_fp	 	:	INTEGER := 10;			--vertical front porch width in rows
		v_pol		:	STD_LOGIC := '1');	--vertical sync pulse polarity (1 = positive, 0 = negative)
	PORT(
		pixel_clk	:	IN		STD_LOGIC;	--pixel clock at frequency of VGA mode being used
		reset_n		:	IN		STD_LOGIC;	--active low asycnchronous reset
		h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
		disp_ena		:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		column		:	OUT	INTEGER;		--horizontal pixel coordinate
		row			:	OUT	INTEGER;		--vertical pixel coordinate
		n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
		n_sync		:	OUT	STD_LOGIC); --sync-on-green output to DAC
	end component;
--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal CLEAR		: std_logic;
	signal R		: std_logic_vector(2 downto 0);
	signal G		: std_logic_vector(2 downto 0);
	signal B		: std_logic_vector(1 downto 0);
	signal DISP_ENA		: std_logic;
	signal FIFO_EMPTY		: std_logic;
	signal DIN		: std_logic_vector(15 downto 0);
	signal NXT		: std_logic;
	signal UNDERRUN		: std_logic;
	signal BLANKING		: std_logic;
	signal HS		: std_logic;
	signal VS		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_rgbout_0 : rgbout
		port map (
			MCLK			=> MCLK,
			nRST			=> nRST,
			CLEAR			=> CLEAR,
			R				=> R,
			G				=> G,
			B				=> B,
			DISP_ENA		=> DISP_ENA,
			FIFO_EMPTY		=> FIFO_EMPTY,
			DIN				=> DIN,
			NXT				=> NXT,
			UNDERRUN		=> UNDERRUN,
			BLANKING		=> BLANKING
		);
	I_vga : vga_controller
		port map (
			pixel_clk => MCLK,  -- 25.175 MHz
			reset_n => nRST,  -- TODO fix async reset 
			h_sync => HS,
			v_sync => VS,
			disp_ena => DISP_ENA,
			column => open,
			row => open,
			n_blank => open,
			n_sync => open
		);
--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			MCLK <= '1';
			wait for 10 ns;
			MCLK <= '0';
			wait for 10 ns;
		end loop;
		wait;
	end process CLOCK;


	GO: process
	begin
		nRST <= '0';
		FIFO_EMPTY <= '1';
		BLANKING <= '1';
		CLEAR <= '0';
		DIN <= "0100010101000101";
		wait for 1001 ns;
		nRST <= '1';
		BLANKING <= '0';
		FIFO_EMPTY <= '0';
		wait until VS = '0';
		CLEAR <= '1';
		wait for 21 ns;
		CLEAR <= '0';
		DIN <= "1000101010001010";
		wait until VS = '0';
		CLEAR <= '1';
		wait for 21 ns;
		CLEAR <= '0';
		DIN <= "0001010000010100";
		wait until VS = '0';
		CLEAR <= '1';
		wait for 21 ns;
		CLEAR <= '0';
		DIN <= "0010100100101001";
		wait until VS = '0';
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
