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

entity tb_spiaccess is
end tb_spiaccess;

architecture stimulus of tb_spiaccess is

-- COMPONENTS --
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
			UNDERRUN		: in	std_logic
		);
	end component;

	constant TCK	: time := 20 ns;
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal AV_ADDRESS		: std_logic_vector(22 downto 0);
	signal AV_WAITREQUEST		: std_logic;
	signal AV_READ		: std_logic;
	signal AV_READDATA		: std_logic_vector(15 downto 0);
	signal AV_READDATAVALID		: std_logic;
	signal AV_WRITE		: std_logic;
	signal AV_WRITEDATA		: std_logic_vector(15 downto 0);
	signal AV_BYTEENABLE		: std_logic_vector(1 downto 0);
	signal SCK		: std_logic;
	signal SS		: std_logic;
	signal MOSI		: std_logic;
	signal MISO		: std_logic;
	signal PAGE		: std_logic;
	signal BLANKING		: std_logic;
	signal UNDERRUN		: std_logic;

--
	signal RUNNING	: std_logic := '1';
	signal lfsr		: std_logic_vector(16 downto 0);
	signal iburstcount : integer := 0;
	signal number : integer := 0;

begin

-- PORT MAP --
	I_spiaccess_0 : spiaccess
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			AV_ADDRESS		=> AV_ADDRESS,
			AV_WAITREQUEST		=> AV_WAITREQUEST,
			AV_READ		=> AV_READ,
			AV_READDATA		=> AV_READDATA,
			AV_READDATAVALID		=> AV_READDATAVALID,
			AV_WRITE		=> AV_WRITE,
			AV_WRITEDATA		=> AV_WRITEDATA,
			AV_BYTEENABLE		=> AV_BYTEENABLE,
			SCK		=> SCK,
			SS		=> SS,
			MOSI		=> MOSI,
			MISO		=> MISO,
			PAGE		=> PAGE,
			BLANKING		=> BLANKING,
			UNDERRUN		=> UNDERRUN
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
	
	--  avalon model

	AV_BYTEENABLE <= "11";
	UNDERRUN <= '0';
	
	PLFSR: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			lfsr <= "11100011100011100";
		elsif (MCLK'event and MCLK = '1') then
			lfsr(0) <= lfsr(16) xor lfsr(13);
			lfsr(16 downto 1) <= lfsr(15 downto 0);
		end if;
	end process PLFSR;
	
	AV_WAITREQUEST <= '0' when (lfsr(1 downto 0) = "11") else '1';
	
	P_SLAVE: process(MCLK,nRST)
	begin
		if (nRST='0') then
			AV_READDATAVALID <= '0';
			AV_READDATA <= x"DEAD";
		elsif (MCLK'event and MCLK='1') then
			if (AV_WAITREQUEST='0') then
				if (AV_READ='1') then
					AV_READDATA <= std_logic_vector(to_unsigned(number,16));
					AV_READDATAVALID <= '1';
					if (number = 65535) then
						number <= 0;
					else
						number <= number + 1;
					end if;
				elsif (AV_WRITE='1') then
					AV_READDATAVALID <= '0';
					AV_READDATA <= AV_WRITEDATA;
				else
					AV_READDATAVALID <= '0';
				end if;
			else
				AV_READDATAVALID <= '0';
			end if;
		end if;
	end process P_SLAVE;	
	
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
		send(x"03"); -- read op
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
		send(x"AE");
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
		wait for 2*TCK;
		SS <= '0';
		send(x"30"); -- read data
		send(x"FF");
		send(x"FF");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"05"); -- write control
		send(x"05");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"02"); -- address
		send(x"00");
		send(x"00");
		send(x"00");
		SS <= '1';
		wait for 2*TCK;	
		SS <= '0';
		send(x"01"); -- write data
		send(x"CC");
		send(x"33");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"01"); -- write data
		send(x"3C");
		send(x"C3");
		SS <= '1';
		wait for 2*TCK;
		SS <= '0';
		send(x"01"); -- write data
		send(x"12");
		send(x"34");
		SS <= '1';
		wait for 2*TCK;			
		wait for 1000 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
