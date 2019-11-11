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

entity tb_spiregister is
end tb_spiregister;

architecture stimulus of tb_spiregister is

-- COMPONENTS --
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
	
	constant TCK	: time := 20 ns;
	
--
-- SIGNALS --
	signal MCLK			: std_logic;
	signal nRST			: std_logic;
	signal PIN			: std_logic_vector(7 downto 0);
	signal NIB			: std_logic_vector(3 downto 0);
	signal POUT			: std_logic_vector(7 downto 0);
	signal VAL_PIN		: std_logic;
	signal VAL_NIB		: std_logic;
	signal UNDERRUN		: std_logic;
	signal DATA_DONE	: std_logic;
	signal PAGE			: std_logic;
	signal ADINC		: std_logic;
	signal BLANKING		: std_logic;
	signal ADDRESS		: std_logic_vector(22 downto 0);
	signal ADDRESS_WRITE		: std_logic;
	signal DATA_READ	: std_logic;
	signal DATA_IN		: std_logic_vector(15 downto 0);
	signal DATA_WRITE	: std_logic;
	signal DATA_OUT		: std_logic_vector(15 downto 0);
	signal LOAD			: std_logic;
	
	signal SCK			: std_logic;
	signal MOSI			: std_logic;
	signal MISO			: std_logic;
	signal SS			: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin


	UNDERRUN <= '0';
	DATA_OUT <= x"1234";
	DATA_DONE <= '1';
	
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
--

	P_MISO: process(SCK,SS)
	variable temp : std_logic_vector(7 downto 0);
	variable i : integer;
	begin
		if (SS='1') then
			temp := (others=>'0');
			i := 0;
		elsif (SCK='1' and SCK'event) then
			temp(7 downto 1) := temp(6 downto 0);
			temp(0) := MISO;
			i := i mod 8 + 1;
			assert(i/=8) report "=> " & integer'image(to_integer(unsigned(temp))) severity note;
		end if;
	end process P_MISO;
	

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
	procedure send(value : std_logic_vector) is
		variable temp : std_logic_vector(7 downto 0);
	begin
		temp := value;
		for I in 0 to 7 loop
			MOSI <= temp(7); 
			wait for TCK;
			SCK <= '1';
			wait for TCK;
			SCK <= '0';
			temp(7 downto 1) := temp(6 downto 0);
		end loop;
	end send;
	begin
		nRST <= '0';
		SCK <= '0';
		MOSI <= '1';
		SS <= '1';
		wait for 1000 ns;
		nRST <= '1';
		wait for 1000 ns;
		SS <= '0';
		send(x"02"); -- address
		send(x"01");
		send(x"02");
		send(x"03");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"01"); -- write data
		send(x"AA");
		send(x"55");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"30"); -- read data
		send(x"FF");
		send(x"FF");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"40"); -- read status
		send(x"FF");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"50"); -- read control
		send(x"FF");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"05"); -- write control
		send(x"AA");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"50"); -- read control
		send(x"FF");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"03"); -- read cmd
		SS <= '1';
		wait for 1000 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
