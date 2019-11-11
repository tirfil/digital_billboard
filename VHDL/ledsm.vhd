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

entity ledsm is
	port(
		CKRAM		: in	std_logic;
		nRSTRAM		: in	std_logic;
		CKPIX		: in	std_logic;
		nRSTPIX		: in	std_logic;
		TGOUT		: in	std_logic;   -- 1 sec
		UNDERRUN		: in	std_logic;
		LED1		: out	std_logic;
		SPIACT		: in	std_logic;
		LED2		: out	std_logic;
		DISPLACT		: in	std_logic;
		LED3		: out	std_logic
	);
end ledsm;

architecture rtl of ledsm is
signal FA1, FA2, FA3 : std_logic := '0';
signal FX1, FX2, FX3 : std_logic := '0';
signal PLSA, PLSX : std_logic;
signal det1, det2, det3 : std_logic;

begin

	PRSYRAM: process(CKRAM)
	begin
	  if (CKRAM'event and CKRAM = '1') then
		FA1 <= TGOUT;
		FA2 <= FA1;
		FA3 <= FA2;
	  end if;
	end process PRSYRAM;
	
	PLSA <= FA2 xor FA3;
	
	PRSYPIX: process(CKPIX)
	begin
	  if (CKPIX'event and CKPIX = '1') then
		FX1 <= TGOUT;
		FX2 <= FX1;
		FX3 <= FX2;
	  end if;
	end process PRSYPIX;
	
	PLSX <= FX2 xor FX3;
	
	PLED1: process(CKPIX,nrstpix)
	begin
		if (nrstpix = '0') then
			LED1 <= '0';
			det1 <= '0';
		elsif(CKPIX'event and CKPIX = '1') then
			if (PLSX = '1') then
				det1 <= '0';
				LED1 <= det1;
			end if;
			if (UNDERRUN = '1') then
				det1 <= '1';
			end if;
		end if;
	end process PLED1;
	
	PLED2: process(CKRAM,nrstram)
	begin
		if (nrstram = '0') then
			LED2 <= '0';
			det2 <= '0';
		elsif(CKRAM'event and CKRAM = '1') then
			if (PLSA = '1') then
				det2 <= '0';
				LED2 <= det2;
			end if;
			if (SPIACT = '1') then
				det2 <= '1';
			end if;
		end if;
	end process PLED2;

	PLED3: process(CKRAM,nrstram)
	begin
		if (nrstram = '0') then
			LED3 <= '0';
			det3 <= '0';
		elsif(CKRAM'event and CKRAM = '1') then
			if (PLSA = '1') then
				det3 <= '0';
				LED3 <= det3;
			end if;
			if (DISPLACT = '1') then
				det3 <= '1';
			end if;
		end if;
	end process PLED3;

end rtl;

