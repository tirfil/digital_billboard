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

entity avalon_read is
	port(
		MCLK			: in	std_logic;
		nRST			: in	std_logic;
		CLEAR			: in	std_logic;
		PAGE			: in	std_logic;
		BLANKING		: in 	std_logic;
		READDATA		: in	std_logic_vector(15 downto 0);
		READDATAVALID	: in	std_logic;
		WAITREQUEST		: in	std_logic;
		BURSTCOUNT		: out	std_logic_vector(3 downto 0);
		ADDRESS			: out	std_logic_vector(22 downto 0);
		READ			: out	std_logic;
		WRITE			: out	std_logic;
		BYTEENABLE		: out	std_logic_vector(1 downto 0);
		FIFO_EMPTY		: in	std_logic;
		FIFO_DIN		: out	std_logic_vector(15 downto 0);
		FIFO_WRITE		: out	std_logic
	);
end avalon_read;

architecture rtl of avalon_read is
type state_t is (S_IDLE,S_START,S_WAIT,S_BLANK);
signal state : state_t;
signal count : INTEGER range 0 to 15;
signal internal_address : std_logic_vector(22 downto 0);
begin

	WRITE <= '0';
	BYTEENABLE <= (others=>'1');
	BURSTCOUNT <= (3=>'1',others=>'0');
	ADDRESS <= internal_address;

	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then 
			FIFO_DIN <= (others=>'1');
			FIFO_WRITE <= '0';
			READ <= '0';
			internal_address <= (others=>'0');
			state <= S_IDLE;
			count <= 0;
		elsif (MCLK'event and MCLK = '1') then
			if (CLEAR = '1') then
				READ <= '0';
				if (BLANKING = '1') then
					state <= S_BLANK;
				else
					state <= S_IDLE;
				end if;
				if (PAGE='1') then
					internal_address <= (20=>'1',others=>'0');
				else
					internal_address <= (others=>'0');
				end if;
			elsif (state = S_IDLE) then
				count <= 0;
				if (FIFO_EMPTY = '1') then
					READ <= '1';
					state <= S_START;
				end if;
			elsif (state = S_START) then
				if (WAITREQUEST = '0') then
					READ <= '0';
					state <= S_WAIT;
				end if;
			elsif (state = S_WAIT) then
				FIFO_WRITE <= '0';
				if (count = 8) then
					internal_address <= std_logic_vector(unsigned(internal_address)+16);
					state <= S_IDLE;
				elsif (READDATAVALID = '1') then
					FIFO_WRITE <= '1';
					FIFO_DIN <= READDATA;
					count <= count + 1;
				end if;
			else -- S_BLANK
				state <= S_BLANK;
			end if;
		end if;
	end process POTO;

end rtl;

