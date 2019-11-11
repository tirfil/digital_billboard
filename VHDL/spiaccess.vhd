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

entity spiaccess is
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
end spiaccess;

architecture struct of spiaccess is
	component spiregister
		port(
			MCLK			: in	std_logic;
			nRST			: in	std_logic;
			PIN				: in	std_logic_vector(7 downto 0);
			NIB				: in	std_logic_vector(3 downto 0);
			POUT			: out	std_logic_vector(7 downto 0);
			VAL_PIN			: in	std_logic;
			VAL_NIB			: in	std_logic;
			LOAD			: in	std_logic;
			UNDERRUN		: in	std_logic;
			DATA_DONE		: in	std_logic;
			PAGE			: out	std_logic;
			ADINC			: out	std_logic;
			BLANKING		: out	std_logic;
			ADDRESS			: out	std_logic_vector(22 downto 0);
			ADDRESS_WRITE	: out	std_logic;
			DATA_READ		: out	std_logic;
			DATA_IN			: out	std_logic_vector(15 downto 0);
			DATA_WRITE		: out	std_logic;
			DATA_OUT		: in	std_logic_vector(15 downto 0)
		);
	end component;
	component spislave
		port(
			SCK			: in	std_logic;
			SS			: in	std_logic;
			MOSI		: in	std_logic;
			MISO		: out	std_logic;
			PIN			: out	std_logic_vector(7 downto 0);
			VALID		: out	std_logic;
			POUT		: in	std_logic_vector(7 downto 0);
			LOAD		: out	std_logic;
			NIBBLE		: out	std_logic_vector(3 downto 0);
			VALNIB		: out	std_logic
		);
	end component;
	component avalon_access
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			AV_ADDRESS		: out	std_logic_vector(22 downto 0);
			AV_WAITREQUEST		: in	std_logic;
			AV_BYTEENABLE		: out	std_logic_vector(1 downto 0);
			AV_READ		: out	std_logic;
			AV_READDATA		: in	std_logic_vector(15 downto 0);
			AV_READDATAVALID		: in	std_logic;
			AV_WRITE		: out	std_logic;
			AV_WRITEDATA		: out	std_logic_vector(15 downto 0);
			ADINC		: in	std_logic;
			ADDRESS_IN		: in	std_logic_vector(22 downto 0);
			ADDRESS_WRITE		: in	std_logic;
			DATA_OUT		: out	std_logic_vector(15 downto 0);
			DATA_DONE		: out	std_logic;
			DATA_IN		: in	std_logic_vector(15 downto 0);
			DATA_WRITE		: in	std_logic;
			DATA_READ		: in	std_logic
		);
	end component;	
	
	signal PIN			: std_logic_vector(7 downto 0);
	signal NIB			: std_logic_vector(3 downto 0);
	signal POUT			: std_logic_vector(7 downto 0);
	signal VAL_PIN		: std_logic;
	signal VAL_NIB		: std_logic;
	signal DATA_DONE	: std_logic;
	signal ADINC		: std_logic;
	signal ADDRESS		: std_logic_vector(22 downto 0);
	signal ADDRESS_WRITE		: std_logic;
	signal DATA_READ	: std_logic;
	signal DATA_IN		: std_logic_vector(15 downto 0);
	signal DATA_WRITE	: std_logic;
	signal DATA_OUT		: std_logic_vector(15 downto 0);
	signal LOAD			: std_logic;
	
	
begin
-- PORT MAP --
	I_spiregister_0 : spiregister
		port map (
			MCLK			=> MCLK,
			nRST			=> nRST,
			PIN				=> PIN,
			NIB				=> NIB,
			POUT			=> POUT,
			VAL_PIN			=> VAL_PIN,
			VAL_NIB			=> VAL_NIB,
			LOAD 			=> LOAD,
			UNDERRUN		=> UNDERRUN,
			DATA_DONE		=> DATA_DONE,
			PAGE			=> PAGE,
			ADINC			=> ADINC,
			BLANKING		=> BLANKING,
			ADDRESS			=> ADDRESS,
			ADDRESS_WRITE	=> ADDRESS_WRITE,
			DATA_READ		=> DATA_READ,
			DATA_IN			=> DATA_IN,
			DATA_WRITE		=> DATA_WRITE,
			DATA_OUT		=> DATA_OUT
		);

	I_spislave_0 : spislave
		port map (
			SCK			=> SCK,
			SS			=> SS,
			MOSI		=> MOSI,
			MISO		=> miso,
			PIN			=> PIN,
			VALID		=> VAL_PIN,
			POUT		=> POUT,
			LOAD		=> LOAD,
			NIBBLE		=> NIB,
			VALNIB		=> VAL_NIB
		);
	I_avalon_access_0 : avalon_access
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			AV_ADDRESS		=> AV_ADDRESS,
			AV_WAITREQUEST		=> AV_WAITREQUEST,
			AV_BYTEENABLE		=> AV_BYTEENABLE,
			AV_READ		=> AV_READ,
			AV_READDATA		=> AV_READDATA,
			AV_READDATAVALID		=> AV_READDATAVALID,
			AV_WRITE		=> AV_WRITE,
			AV_WRITEDATA		=> AV_WRITEDATA,
			ADINC		=> ADINC,
			ADDRESS_IN		=> ADDRESS,
			ADDRESS_WRITE		=> ADDRESS_WRITE,
			DATA_OUT		=> DATA_OUT,
			DATA_DONE		=> DATA_DONE,
			DATA_IN		=> DATA_IN,
			DATA_WRITE		=> DATA_WRITE,
			DATA_READ		=> DATA_READ
		);
	
	-- for led2	
	SPIACT <= not(DATA_DONE);

end struct;

