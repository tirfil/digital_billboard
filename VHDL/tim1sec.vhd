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

entity tim1sec is
	port(
		CK12		: in	std_logic; -- 12 MHz
		nRST		: in	std_logic; -- async
		TGOUT		: out	std_logic   -- toogle
	);
end tim1sec;

architecture rtl of tim1sec is
signal nrstout, nrst1 : std_logic;
signal cnt : unsigned (23 downto 0);
signal t1s : std_logic;
signal toggle : std_logic := '0';

begin

	PRESTRESY: process(CK12, nRST)
	begin
		if (nRST = '0') then
			nrst1 <= '0';
			nrstout <= '0';
		elsif (CK12'event and CK12 = '1') then
			nrst1 <= '1';
			nrstout <= nrst1;
		end if;
	end process PRESTRESY;
	
	
	-- one second
	t1s <= cnt(23) and cnt(21) and cnt(20) and cnt(18) and cnt(17) and cnt(16) and cnt(12) and cnt(11) and cnt(9) and cnt(8);
	
	PCNT : process(CK12, nrstout)
	begin
		if (nrstout = '0') then
			cnt <= (others=>'0');
		elsif (CK12'event and CK12 = '1') then
			if (t1s = '1') then
				cnt <= (0=>'1',others=>'0');
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process PCNT;
	
	PTOG : process(CK12)
	begin
		if (CK12'event and CK12 = '1') then
			if (t1s = '1') then
				toggle <= not(toggle);
			end if;
		end if;
	end process PTOG;
	
	TGOUT <= toggle;
	
end rtl;

