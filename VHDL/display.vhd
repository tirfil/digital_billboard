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
library RAM_LIB;
use RAM_LIB.all;

entity display is
	port(
		CKRAM		: in	std_logic;
		CKPIX		: in	std_logic;
		nRST		: in	std_logic;
		nRSTOUT		: out	std_logic;
		PAGE		: in	std_logic;
		BLANKING		: in	std_logic;
		UNDERRUN		: out	std_logic;
		R		: out	std_logic_vector(2 downto 0);
		G		: out	std_logic_vector(2 downto 0);
		B		: out	std_logic_vector(1 downto 0);
		HS		: out	std_logic;
		VS		: out	std_logic;
		READDATA		: in	std_logic_vector(15 downto 0);
		READDATAVALID		: in	std_logic;
		WAITREQUEST		: in	std_logic;
		BURSTCOUNT		: out	std_logic_vector(3 downto 0);
		ADDRESS		: out	std_logic_vector(22 downto 0);
		READ		: out	std_logic;
		WRITE		: out	std_logic;
		BYTEENABLE		: out	std_logic_vector(1 downto 0);
		nRSTOUTX 	: out std_logic;
		DISPLACT	: out std_logic
	);
end display;

architecture struct of display is
	-- COMPONENTS --
	component avalon_read
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			CLEAR		: in	std_logic;
			PAGE		: in	std_logic;
			BLANKING 	: in	std_logic;
			READDATA		: in	std_logic_vector(15 downto 0);
			READDATAVALID		: in	std_logic;
			WAITREQUEST		: in	std_logic;
			BURSTCOUNT		: out	std_logic_vector(3 downto 0);
			ADDRESS		: out	std_logic_vector(22 downto 0);
			READ		: out	std_logic;
			WRITE		: out	std_logic;
			BYTEENABLE		: out	std_logic_vector(1 downto 0);
			FIFO_EMPTY		: in	std_logic;
			FIFO_DIN		: out	std_logic_vector(15 downto 0);
			FIFO_WRITE		: out	std_logic
		);
	end component;
	component fifo_control
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			FIFO_WRITE		: in	std_logic;
			FIFO_READ		: in	std_logic;
			WRADDRESS		: out	std_logic_vector(2 downto 0);
			RDADDRESS		: out	std_logic_vector(2 downto 0);
			FIFO_FULL		: out	std_logic;
			SET_FULL		: out	std_logic;
			SET_EMPTY		: out	std_logic;
			FIFO_EMPTY		: out	std_logic;
			CLEAR			: in	std_logic
		);
	end component;
	component dp8x16
		port(
		address_a		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock_a			: IN STD_LOGIC  := '1';
		clock_b			: IN STD_LOGIC  := '1';
		data_a			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		data_b			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		wren_a			: IN STD_LOGIC  := '0';
		wren_b			: IN STD_LOGIC  := '0';
		q_a				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		q_b				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	end component;	
	component fifo_inter
		port(
			MCLK			: in	std_logic;
			nRST			: in	std_logic;
			EMPTY			: in	std_logic;
			SET_FULL		: in	std_logic;
			FULL			: in	std_logic;
			DIN				: in	std_logic_vector(15 downto 0);
			DOUT			: out	std_logic_vector(15 downto 0);
			FIFO_READ		: out	std_logic;
			FIFO_WRITE		: out	std_logic;
			CLEAR			: in	std_logic
		);
	end component;
	component cdcfifo8
		port(
			RCLK		: in	std_logic;
			WCLK		: in	std_logic;
			RRSTN		: in	std_logic;
			WRSTN		: in	std_logic;
			DIN			: in	std_logic_vector(15 downto 0);
			DOUT		: out	std_logic_vector(15 downto 0);
			WRITE		: in	std_logic;
			READ		: in	std_logic;
			READ_OUT	: out	std_logic;
			SET_FULL		: out	std_logic;
			FULL		: out	std_logic;
			EMPTY		: out	std_logic;
			CLEAR_RD	: in 	std_logic;
			CLEAR_WR	: in 	std_logic
		);
	end component;
	component vga_controller
	GENERIC(
		h_pulse 	:	INTEGER := 96;    	--horiztonal sync pulse width in pixels
		h_bp	 	:	INTEGER := 48;		--horiztonal back porch width in pixels
		h_pixels	:	INTEGER := 640;		--horiztonal display width in pixels
		h_fp	 	:	INTEGER := 16;		--horiztonal front porch width in pixels
		h_pol		:	STD_LOGIC := '0';		--horizontal sync pulse polarity (1 = positive, 0 = negative)
		v_pulse 	:	INTEGER := 2;			--vertical sync pulse width in rows
		v_bp	 	:	INTEGER := 33;			--vertical back porch width in rows
		v_pixels	:	INTEGER := 480;		--vertical display width in rows
		v_fp	 	:	INTEGER := 10;			--vertical front porch width in rows
		v_pol		:	STD_LOGIC := '0');	--vertical sync pulse polarity (1 = positive, 0 = negative)
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
			FIFO_FULL		: in	std_logic;
			DIN				: in	std_logic_vector(15 downto 0);
			NXT				: out	std_logic;
			UNDERRUN		: out	std_logic;
			BLANKING		: in	std_logic
		);
	end component;	
	component resynchro
		port(
			CKRAM		: in	std_logic;
			CKPIX		: in	std_logic;
			nRST		: in	std_logic;
			nRSTRAM		: out	std_logic;
			nRSTPIX		: out	std_logic;
			VS		: in	std_logic;
			CLEARPIX		: out	std_logic;
			CLEARRAM		: out	std_logic
		);
	end component;

	
	signal fiforam_empty		: std_logic;
	signal fiforam_din			: std_logic_vector(15 downto 0);
	signal fiforam_dout			: std_logic_vector(15 downto 0);
	signal fiforam_write		: std_logic;
	signal fiforam_read			: std_logic;
	signal fiforam_write_addr 	: std_logic_vector(2 downto 0);
	signal fiforam_read_addr 	: std_logic_vector(2 downto 0);
	signal cdc_full				: std_logic;
	signal cdc_set_full			: std_logic;
	signal cdc_read				: std_logic;
	signal cdc_write			: std_logic;
	signal cdc_din				: std_logic_vector(15 downto 0);
	signal cdc_dout				: std_logic_vector(15 downto 0);
	signal cdc_empty			: std_logic;
	signal vs_i					: std_logic;
	signal nrstram, nrstpix		: std_logic;
	signal clearram, clearpix : std_logic;
	signal logic_0			  : std_logic;
	signal disp_ena				: std_logic;
	signal zero16				: std_logic_vector(15 downto 0);
	
begin

	VS <= vs_i;
	logic_0 <= '0';
	zero16 <= (others=>'0');
	nRSTOUT <= nrstram;
	
	
	-- for led3
	nRSTOUTX <= nrstpix;
	DISPLACT <= READDATAVALID;

-- PORT MAP --
	I_avalon_read_0 : avalon_read
		port map (
			MCLK		=> CKRAM,
			nRST		=> nrstram,
			CLEAR		=> clearram,
			PAGE		=> PAGE,
			BLANKING		=> BLANKING,
			READDATA		=> READDATA,
			READDATAVALID		=> READDATAVALID,
			WAITREQUEST		=> WAITREQUEST,
			BURSTCOUNT		=> BURSTCOUNT,
			ADDRESS		=> ADDRESS,
			READ		=> READ,
			WRITE		=> WRITE,
			BYTEENABLE		=> BYTEENABLE,
			FIFO_EMPTY		=> fiforam_empty,
			FIFO_DIN		=> fiforam_din,
			FIFO_WRITE		=> fiforam_write
	);
	I_fifo_control_0 : fifo_control
		port map (
			MCLK		=> CKRAM,
			nRST		=> nrstram,
			FIFO_WRITE		=> fiforam_write,
			FIFO_READ		=> fiforam_read,
			WRADDRESS		=> fiforam_write_addr,
			RDADDRESS		=> fiforam_read_addr,
			FIFO_FULL		=> open,
			SET_FULL		=> open,
			SET_EMPTY		=> open,
			FIFO_EMPTY		=> fiforam_empty,
			CLEAR			=> clearram
		);
	I_dpram8 : dp8x16
		port map (
			address_a => fiforam_write_addr,
			address_b => fiforam_read_addr,
			clock_a   => CKRAM,
			clock_b   => CKRAM,
			data_a 	  => fiforam_din,
			data_b	  => zero16,  -- hope simplification
			wren_a	  => fiforam_write,
			wren_b	  => LOGIC_0,	-- always read
			q_a		  => open, 		-- not used
			q_b		  => fiforam_dout
	);
	I_fifo_inter_0 : fifo_inter
		port map (
			MCLK		=> CKRAM,
			nRST		=> nrstram,
			EMPTY		=> fiforam_empty,
			FULL		=> cdc_full,
			SET_FULL	=> cdc_set_full,
			DIN			=> fiforam_dout,
			DOUT		=> cdc_din,
			FIFO_READ	=> fiforam_read,
			FIFO_WRITE	=> cdc_write,
			CLEAR 		=> clearram
	);
	I_cdcfifo8_0 : cdcfifo8
		port map (
			RCLK		=> CKPIX,
			WCLK		=> CKRAM,
			WRSTN		=> nrstram,
			RRSTN		=> nrstpix,
			DIN			=> cdc_din,
			DOUT		=> cdc_dout,
			WRITE		=> cdc_write,		--ckram
			READ		=> cdc_read,		--ckpix
			READ_OUT	=> open,
			FULL		=> cdc_full,     	--ckram
			SET_FULL	=> cdc_set_full,	--ckram
			EMPTY		=> cdc_empty,		--ckpix
			CLEAR_RD	=> clearpix,
			CLEAR_WR	=> clearram
		);
	I_vga : vga_controller
		port map (
			pixel_clk => CKPIX,  -- 25.175 MHz
			reset_n => nrstpix, 
			h_sync => HS,
			v_sync => vs_i,
			disp_ena => disp_ena,
			column => open,
			row => open,
			n_blank => open,
			n_sync => open
	);
	I_rgbout_0 : rgbout
		port map (
			MCLK			=> CKPIX,
			nRST			=> nrstpix,
			CLEAR			=> clearpix,
			R				=> R,
			G				=> G,
			B				=> B,
			DISP_ENA		=> disp_ena,
			FIFO_EMPTY		=> cdc_empty,
			FIFO_FULL		=> cdc_full,
			DIN				=> cdc_dout,
			NXT				=> cdc_read,
			UNDERRUN		=> UNDERRUN,
			BLANKING		=> BLANKING
	);
	I_resynchro_0 : resynchro
	port map (
		CKRAM		=> CKRAM,
		CKPIX		=> CKPIX,
		nRST		=> nRST,
		nRSTRAM		=> nrstram,
		nRSTPIX		=> nrstpix,
		VS			=> vs_i,
		CLEARPIX		=> clearpix,
		CLEARRAM		=> clearram
	);

end struct;

