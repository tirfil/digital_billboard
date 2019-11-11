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

entity tb_resynchro is
end tb_resynchro;

architecture stimulus of tb_resynchro is

-- COMPONENTS --
	component resynchro
		port(
			CKRAM		: in	std_logic;
			CKPIX		: in	std_logic;
			nRST		: in	std_logic;
			nRSTRAM		: out	std_logic;
			nRSTPIX		: out	std_logic;
			VS		: in	std_logic;
			CLEARPIX		: out	std_logic;
			CLEARRAM		: out	std_logic
		);
	end component;

--
-- SIGNALS --
	signal CKRAM		: std_logic;
	signal CKPIX		: std_logic;
	signal nRST		: std_logic;
	signal nRSTRAM		: std_logic;
	signal nRSTPIX		: std_logic;
	signal VS		: std_logic;
	signal CLEARPIX		: std_logic;
	signal CLEARRAM		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_resynchro_0 : resynchro
		port map (
			CKRAM		=> CKRAM,
			CKPIX		=> CKPIX,
			nRST		=> nRST,
			nRSTRAM		=> nRSTRAM,
			nRSTPIX		=> nRSTPIX,
			VS		=> VS,
			CLEARPIX		=> CLEARPIX,
			CLEARRAM		=> CLEARRAM
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			CKPIX <= '1';
			wait for 8 ns;
			CKPIX <= '0';
			wait for 8 ns;
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

	GO: process
	begin
		nRST <= '0';
		VS <= '1';
		wait for 1001 ns;
		nRST <= '1';
		wait for 600 ns;
		VS <= '0';
		wait for 100 ns;
		VS <= '1';
		wait for 500 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
