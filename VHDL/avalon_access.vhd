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

entity avalon_access is
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
		ADINC			: in	std_logic;
		ADDRESS_IN		: in	std_logic_vector(22 downto 0);
		ADDRESS_WRITE		: in	std_logic;
		DATA_OUT		: out	std_logic_vector(15 downto 0);
		DATA_DONE		: out	std_logic;
		DATA_IN		: in	std_logic_vector(15 downto 0);
		DATA_WRITE		: in	std_logic;
		DATA_READ		: in	std_logic
	);
end avalon_access;

architecture rtl of avalon_access is
signal address : unsigned(22 downto 0);
signal data : std_logic_vector(15 downto 0);
signal address_incr : std_logic;
type state_t is (S_IDLE,S_READ0,S_READ1,S_WRITE0);
signal state : state_t;
begin

	AV_BYTEENABLE <= "11";
	AV_WRITEDATA <= data;
	AV_ADDRESS <= std_logic_vector(address);
	
	PAD : process(MCLK, nRST)
	begin
		if (nRST = '0') then
			address <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (ADDRESS_WRITE='1') then
				address <= unsigned(ADDRESS_IN);
			elsif (address_incr='1' and ADINC = '1') then
				address <= address + 2;
			end if;
		end if;
	end process PAD;

	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			AV_READ <= '0';
			AV_WRITE <= '0';
			data <= (others=>'0');
			DATA_OUT <= (others=>'0');
			address_incr <= '0';
			DATA_DONE <= '1';
			state <= S_IDLE;
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				address_incr <= '0';
				if (DATA_WRITE = '1') then
					DATA_DONE <= '0';
					AV_WRITE <= '1';
					data <= DATA_IN;
					state <= S_WRITE0;
				elsif (DATA_READ = '1') then
					DATA_DONE <= '0';
					AV_READ <= '1';
					state <= S_READ0;
				end if;
			elsif (state = S_WRITE0) then
				if (AV_WAITREQUEST = '0') then
					AV_WRITE <= '0';
					address_incr <= '1';
					DATA_DONE <= '1';
					state <= S_IDLE;
				end if;
			elsif (state = S_READ0) then
				if (AV_WAITREQUEST = '0') then
					AV_READ <= '0';
					state <= S_READ1;
				end if;
			elsif (state = S_READ1) then
				if (AV_READDATAVALID = '1') then
					DATA_OUT <= AV_READDATA;
					address_incr <= '1';
					DATA_DONE <= '1';
					state <= S_IDLE;
				end if;
			end if;
		end if;
	end process POTO;

end rtl;

