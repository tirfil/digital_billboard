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

entity spidisplay_core is
	port(
		CK12		: in	std_logic;
		nRST		: in	std_logic;
		SCK		: in	std_logic;
		MOSI		: in	std_logic;
		MISO		: out	std_logic;
		SS		: in	std_logic;
		SDRAM_CK		: out	std_logic;
		SDRAM_ADDR		: out	std_logic_vector(11 downto 0);
		SDRAM_BA		: out	std_logic_vector(1 downto 0);
		SDRAM_CASN		: out	std_logic;
		SDRAM_CKE		: out	std_logic;
		SDRAM_CSN		: out	std_logic;
		SDRAM_DQ		: inout	std_logic_vector(15 downto 0);
		SDRAM_DQM		: out	std_logic_vector(1 downto 0);
		SDRAM_RASN		: out	std_logic;
		SDRAM_WEN		: out	std_logic;
		R		: out	std_logic_vector(2 downto 0);
		G		: out	std_logic_vector(2 downto 0);
		B		: out	std_logic_vector(1 downto 0);
		HS		: out	std_logic;
		VS		: out	std_logic;
		LED		: out   std_logic_vector(7 downto 0)
	);
end spidisplay_core;

architecture struct of spidisplay_core is
	component pixpll
		PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC;
			c1			: OUT STD_LOGIC;
			c2			: OUT STD_LOGIC
		);
	end component;
	component display
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
			nRSTOUTX		: out	std_logic;
			DISPLACT		: out	std_logic
		);
	end component;
	component spiaccess
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			AV_ADDRESS		: out	std_logic_vector(22 downto 0);
			AV_WAITREQUEST		: in	std_logic;
			AV_READ		: out	std_logic;
			AV_READDATA		: in	std_logic_vector(15 downto 0);
			AV_READDATAVALID		: in	std_logic;
			AV_WRITE		: out	std_logic;
			AV_WRITEDATA		: out	std_logic_vector(15 downto 0);
			AV_BYTEENABLE		: out	std_logic_vector(1 downto 0);
			SCK		: in	std_logic;
			SS		: in	std_logic;
			MOSI		: in	std_logic;
			MISO		: out	std_logic;
			PAGE		: out	std_logic;
			BLANKING		: out	std_logic;
			UNDERRUN		: in	std_logic;
			SPIACT			: out	std_logic
		);
	end component;
	component sdram is
	port (
		clk_clk                         : in    std_logic                     := 'X';             -- clk
		reset_reset_n                   : in    std_logic                     := 'X';             -- reset_n
		sdram_addr                      : out   std_logic_vector(11 downto 0);                    -- addr
		sdram_ba                        : out   std_logic_vector(1 downto 0);                     -- ba
		sdram_cas_n                     : out   std_logic;                                        -- cas_n
		sdram_cke                       : out   std_logic;                                        -- cke
		sdram_cs_n                      : out   std_logic;                                        -- cs_n
		sdram_dq                        : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
		sdram_dqm                       : out   std_logic_vector(1 downto 0);                     -- dqm
		sdram_ras_n                     : out   std_logic;                                        -- ras_n
		sdram_we_n                      : out   std_logic;                                        -- we_n
		sdram_to_avalon_waitrequest     : out   std_logic;                                        -- waitrequest
		sdram_to_avalon_readdata        : out   std_logic_vector(15 downto 0);                    -- readdata
		sdram_to_avalon_readdatavalid   : out   std_logic;                                        -- readdatavalid
		sdram_to_avalon_burstcount      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- burstcount
		sdram_to_avalon_writedata       : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
		sdram_to_avalon_address         : in    std_logic_vector(22 downto 0) := (others => 'X'); -- address
		sdram_to_avalon_write           : in    std_logic                     := 'X';             -- write
		sdram_to_avalon_read            : in    std_logic                     := 'X';             -- read
		sdram_to_avalon_byteenable      : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
		sdram_to_avalon_debugaccess     : in    std_logic                     := 'X';             -- debugaccess
		avalon_to_sdram_1_waitrequest   : out   std_logic;                                        -- waitrequest
		avalon_to_sdram_1_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
		avalon_to_sdram_1_readdatavalid : out   std_logic;                                        -- readdatavalid
		avalon_to_sdram_1_burstcount    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
		avalon_to_sdram_1_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
		avalon_to_sdram_1_address       : in    std_logic_vector(22 downto 0) := (others => 'X'); -- address
		avalon_to_sdram_1_write         : in    std_logic                     := 'X';             -- write
		avalon_to_sdram_1_read          : in    std_logic                     := 'X';             -- read
		avalon_to_sdram_1_byteenable    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
		avalon_to_sdram_1_debugaccess   : in    std_logic                     := 'X'              -- debugaccess
	);
	end component sdram;
	component ledsm
		port(
			CKRAM		: in	std_logic;
			nRSTRAM		: in	std_logic;
			CKPIX		: in	std_logic;
			nRSTPIX		: in	std_logic;
			TGOUT		: in	std_logic;
			UNDERRUN		: in	std_logic;
			LED1		: out	std_logic;
			SPIACT		: in	std_logic;
			LED2		: out	std_logic;
			DISPLACT		: in	std_logic;
			LED3		: out	std_logic
		);
	end component;
	component tim1sec
		port(
			CK12		: in	std_logic;
			nRST		: in	std_logic;
			TGOUT		: out	std_logic
		);
	end component;
	
signal LOGIC_0 : std_logic;
signal LOGIC_1 : std_logic;
signal LOGIC_1B : std_logic_vector(0 downto 0);
signal miso_i  : std_logic;
signal CKRAM, CKPIX : std_logic;
signal nrstpix, nrstram : std_logic;
signal page, blanking, underrun : std_logic;
signal readdata			: std_logic_vector(15 downto 0);
signal writedata			: std_logic_vector(15 downto 0);
signal readdatavalid	: std_logic;
signal waitrequest		: std_logic;
signal burstcount		: std_logic_vector(3 downto 0);
signal address			: std_logic_vector(22 downto 0);
signal read				: std_logic;
signal write			: std_logic;
signal byteenable		: std_logic_vector(1 downto 0);
signal readdata2			: std_logic_vector(15 downto 0);
signal writedata2			: std_logic_vector(15 downto 0);
signal readdatavalid2	: std_logic;
signal waitrequest2		: std_logic;
signal address2			: std_logic_vector(22 downto 0);
signal read2				: std_logic;
signal write2			: std_logic;
signal byteenable2		: std_logic_vector(1 downto 0);

signal displact : std_logic;
signal spiact : std_logic;
signal tgout  : std_logic;

begin
	LOGIC_0 <= '0';
	LOGIC_1 <= '1';
	LOGIC_1B <= "1";
	
	LED(7 downto 3) <= (others=>'0');
	
	MISO <= miso_i when SS='0' else 'Z';


	I_pixpll : pixpll
		port map (
			inclk0 => CK12,
			c0 => CKPIX,			-- 25.175 MHz 	- ratio 1007/480
			c1 => CKRAM,			-- 72 MHz 		- ratio 6
			c2 => SDRAM_CK			-- 72 MHz 		- ratio 6  -5 ns
		);
	I_display_0 : display
		port map (
			CKRAM		=> CKRAM,
			CKPIX		=> CKPIX,
			nRST		=> nRST,   -- external
			nRSTOUT		=> nrstram,
			PAGE		=> page,
			BLANKING		=> blanking,
			UNDERRUN		=> underrun,
			R		=> R,
			G		=> G,
			B		=> B,
			HS		=> HS,
			VS		=> VS,
			READDATA		=> readdata,
			READDATAVALID		=> readdatavalid,
			WAITREQUEST		=> waitrequest,
			BURSTCOUNT		=> burstcount,
			ADDRESS		=> address,
			READ		=> read,
			WRITE		=> write,
			BYTEENABLE		=> byteenable,
			nRSTOUTX	=> nrstpix,
			DISPLACT => displact
		);
	I_spiaccess_0 : spiaccess
		port map (
			MCLK		=> CKRAM,
			nRST		=> nrstram,
			AV_ADDRESS		=> address2,
			AV_WAITREQUEST		=> waitrequest2,
			AV_READ		=> read2,
			AV_READDATA		=> readdata2,
			AV_READDATAVALID		=> readdatavalid2,
			AV_WRITE		=> write2,
			AV_WRITEDATA		=> writedata2,
			AV_BYTEENABLE		=> byteenable2,
			SCK		=> SCK,
			SS		=> SS,
			MOSI		=> MOSI,
			MISO		=> miso_i,
			PAGE		=> page,
			BLANKING		=> blanking,
			UNDERRUN		=> underrun,
			SPIACT	=> spiact
		);	
		u0 : component sdram
		port map (
			clk_clk                         => CKRAM,                         --               clk.clk
			reset_reset_n                   => nrstram,                   --             reset.reset_n
			sdram_addr                      => SDRAM_ADDR,                      --             sdram.addr
			sdram_ba                        => SDRAM_BA,                        --                  .ba
			sdram_cas_n                     => SDRAM_CASN,                     --                  .cas_n
			sdram_cke                       => SDRAM_CKE,                       --                  .cke
			sdram_cs_n                      => SDRAM_CSN,                      --                  .cs_n
			sdram_dq                        => SDRAM_DQ,                        --                  .dq
			sdram_dqm                       => SDRAM_DQM,                       --                  .dqm
			sdram_ras_n                     => SDRAM_RASN,                     --                  .ras_n
			sdram_we_n                      => SDRAM_WEN,                      --                  .we_n
			sdram_to_avalon_waitrequest   => waitrequest,   -- sdram_to_avalon.waitrequest
			sdram_to_avalon_readdata      => readdata,      --                .readdata
			sdram_to_avalon_readdatavalid => readdatavalid, --                .readdatavalid
			sdram_to_avalon_burstcount    => burstcount,    --                .burstcount
			sdram_to_avalon_writedata     => writedata,     --                .writedata
			sdram_to_avalon_address       => address,       --                .address
			sdram_to_avalon_write         => write,         --                .write
			sdram_to_avalon_read          => read,          --                .read
			sdram_to_avalon_byteenable    => byteenable,    --                .byteenable
			sdram_to_avalon_debugaccess   => LOGIC_0,   --                .debugaccess
			avalon_to_sdram_1_waitrequest   => waitrequest2,   -- avalon_to_sdram_1.waitrequest
			avalon_to_sdram_1_readdata      => readdata2,      --                  .readdata
			avalon_to_sdram_1_readdatavalid => readdatavalid2, --                  .readdatavalid
			avalon_to_sdram_1_burstcount    => LOGIC_1B,    --                  .burstcount
			avalon_to_sdram_1_writedata     => writedata2,     --                  .writedata
			avalon_to_sdram_1_address       => address2,       --                  .address
			avalon_to_sdram_1_write         => write2,         --                  .write
			avalon_to_sdram_1_read          => read2,          --                  .read
			avalon_to_sdram_1_byteenable    => byteenable2,    --                  .byteenable
			avalon_to_sdram_1_debugaccess   => LOGIC_0    --                  .debugaccess
		);
		I_ledsm_0 : ledsm
		port map (
			CKRAM		=> CKRAM,
			nRSTRAM		=> nrstram,
			CKPIX		=> CKPIX,
			nRSTPIX		=> nrstpix,
			TGOUT		=> tgout,
			UNDERRUN		=> underrun,
			LED1		=> LED(0),
			SPIACT		=> spiact,
			LED2		=> LED(1),
			DISPLACT		=> displact,
			LED3		=> LED(2)
		);
		I_tim1sec_0 : tim1sec
		port map (
			CK12		=> CK12,
			nRST		=> nRST,
			TGOUT		=> tgout
		);
end struct;

