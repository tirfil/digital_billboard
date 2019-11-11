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

entity tb_display is
end tb_display;

architecture stimulus of tb_display is

-- COMPONENTS --
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
			BYTEENABLE		: out	std_logic_vector(1 downto 0)
		);
	end component;

--
-- SIGNALS --
	signal CKRAM		: std_logic;
	signal CKPIX		: std_logic;
	signal nRST		: std_logic;
	signal nRSTOUT		: std_logic;
	signal PAGE		: std_logic;
	signal BLANKING		: std_logic;
	signal UNDERRUN		: std_logic;
	signal R		: std_logic_vector(2 downto 0);
	signal G		: std_logic_vector(2 downto 0);
	signal B		: std_logic_vector(1 downto 0);
	signal HS		: std_logic;
	signal VS		: std_logic;
	signal READDATA		: std_logic_vector(15 downto 0);
	signal READDATAVALID		: std_logic;
	signal WAITREQUEST		: std_logic;
	signal BURSTCOUNT		: std_logic_vector(3 downto 0);
	signal ADDRESS		: std_logic_vector(22 downto 0);
	signal READ		: std_logic;
	signal WRITE		: std_logic;
	signal BYTEENABLE		: std_logic_vector(1 downto 0);

--
	signal RUNNING	: std_logic := '1';
	signal lfsr		: std_logic_vector(16 downto 0);
	signal iburstcount : integer := 0;
	signal number : integer := 0;

begin

-- PORT MAP --
	I_display_0 : display
		port map (
			CKRAM		=> CKRAM,
			CKPIX		=> CKPIX,
			nRST		=> nRST,
			nRSTOUT		=> nRSTOUT,
			PAGE		=> PAGE,
			BLANKING		=> BLANKING,
			UNDERRUN		=> UNDERRUN,
			R		=> R,
			G		=> G,
			B		=> B,
			HS		=> HS,
			VS		=> VS,
			READDATA		=> READDATA,
			READDATAVALID		=> READDATAVALID,
			WAITREQUEST		=> WAITREQUEST,
			BURSTCOUNT		=> BURSTCOUNT,
			ADDRESS		=> ADDRESS,
			READ		=> READ,
			WRITE		=> WRITE,
			BYTEENABLE		=> BYTEENABLE
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			CKPIX <= '1';
			wait for 5 ns;
			CKPIX <= '0';
			wait for 5 ns;
		end loop;
		wait;
	end process CLOCK;
	
	CLOCK2: process
	begin
		while (RUNNING = '1') loop
			CKRAM <= '1';
			wait for 3 ns;
			CKRAM <= '0';
			wait for 3 ns;
		end loop;
		wait;
	end process CLOCK2;
	
--  avalon read model

	BYTEENABLE <= "11";
	WRITE <= '0';
	
	PLFSR: process(CKRAM, nRSTOUT)
	begin
		if (nRSTOUT = '0') then
			lfsr <= "11100011100011100";
		elsif (CKRAM'event and CKRAM = '1') then
			lfsr(0) <= lfsr(16) xor lfsr(13);
			lfsr(16 downto 1) <= lfsr(15 downto 0);
		end if;
	end process PLFSR;
	
	WAITREQUEST <= '0' when (lfsr(1 downto 0) /= "11") else '1';
	
	P_READ_SLAVE: process(CKRAM,nRSTOUT)
	begin
		if (nRSTOUT='0') then
			READDATAVALID <= '0';
			READDATA <= x"DEAD";
		elsif (CKRAM'event and CKRAM='1') then
			if (WAITREQUEST='0') then
				if (READ='1') then
					if (WAITREQUEST='0') then
						iburstcount <= to_integer(unsigned(BURSTCOUNT))-1;
						READDATA <= std_logic_vector(to_unsigned(number,16));
						READDATAVALID <= '1';
						if (number = 65535) then
							number <= 0;
						else
							number <= number + 1;
						end if;
					end if;
				elsif (iburstcount = 0) then
					READDATAVALID <= '0';
				else
					READDATA <= std_logic_vector(to_unsigned(number,16));
					if (number = 65535) then
						number <= 0;
					else
						number <= number + 1;
					end if;
					READDATAVALID <= '1';
					iburstcount <= iburstcount - 1;
				end if;
			else
				READDATAVALID <= '0';
			end if;
		end if;
	end process P_READ_SLAVE;	

--  avalon read model

	GO: process
	begin
		nRST <= '0';
		PAGE <= '0';
		BLANKING <= '0';
		wait for 1000 ns;
		nRST <= '1';
		wait for 10000000 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
