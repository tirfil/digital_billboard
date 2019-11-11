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

entity resynchro is
	port(
		CKRAM		: in	std_logic;
		CKPIX		: in	std_logic;
		nRST		: in	std_logic;
		nRSTRAM		: out	std_logic;
		nRSTPIX		: out	std_logic;
		VS			: in	std_logic;
		CLEARPIX		: out	std_logic;
		CLEARRAM		: out	std_logic
	);
end resynchro;

architecture rtl of resynchro is
signal ff0,ff1,ff2,ff3,ff4,ff5 : std_logic;
signal cb0,cb1 : std_logic;
signal cp0, vs0 : std_logic;
signal clearpix_i, clearram_i, clear_in : std_logic;

begin

	PRSTPIX: process(CKPIX, nRST)
	begin
		if (nRST = '0') then
			ff0 <= '0';
			ff1 <= '0';
			ff2 <= '0';
			vs0 <= '0';
		elsif (CKPIX'event and CKPIX = '1') then
			ff0 <= '1';
			ff1 <= ff0;
			ff2 <= ff1;
			vs0 <= VS;
		end if;
	end process PRSTPIX;
	
	clear_in <= not VS and vs0;
	
	PRSTRAM: process(CKRAM, nRST)
	begin
		if (nRST = '0') then
			ff3 <= '0';
			ff4 <= '0';
			ff5 <= '0';
		elsif (CKRAM'event and CKRAM = '1') then
			ff3 <= ff2;
			ff4 <= ff3;
			ff5 <= ff4;
		end if;
	end process PRSTRAM;
	
	nRSTPIX <= ff2;
	nRSTRAM <= ff5;
	
	PCLEARPIX: process(CKPIX, ff2)
	begin
		if (ff2 = '0') then
			clearpix_i <= '0';
			cb0 <= '0';
			cb1 <= '0';
		elsif (CKPIX'event and CKPIX = '1') then
			cb0 <= clearram_i;  -- back
			cb1 <= cb0;
			if (clear_in = '1') then
				clearpix_i <= '1';
			elsif (cb1 = '1') then
				clearpix_i <= '0';
			end if;
		end if;
	end process PCLEARPIX;
	
	PCLEARRAM : process(CKRAM, ff5)
	begin
		if (ff5 = '0') then
			clearram_i <= '0';
			cp0 <= '0';
		elsif(CKRAM'event and CKRAM = '1') then
			cp0 <= clearpix_i;
			clearram_i <= cp0;
		end if;
	end process PCLEARRAM;
			
	CLEARRAM <= clearram_i;
	CLEARPIX <= clearpix_i;

end rtl;

