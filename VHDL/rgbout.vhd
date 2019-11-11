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

entity rgbout is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		CLEAR		: in	std_logic;
		R		: out	std_logic_vector(2 downto 0);
		G		: out	std_logic_vector(2 downto 0);
		B		: out	std_logic_vector(1 downto 0);
		DISP_ENA		: in	std_logic;
		FIFO_EMPTY		: in	std_logic;
		FIFO_FULL		: in	std_logic;
		DIN		: in	std_logic_vector(15 downto 0);
		NXT		: out	std_logic;
		UNDERRUN		: out	std_logic;
		BLANKING		: in	std_logic
	);
end rgbout;

architecture rtl of rgbout is
type state_t is (S_IDLE,S_LSB,S_MSB);
signal state : state_t;
signal rgb : std_logic_vector(7 downto 0);
signal blank : std_logic;
signal fifo_full_resy : std_logic;
signal ff0 : std_logic;
signal bl0, bl1 : std_logic;
begin

	R <= rgb(7 downto 5) when DISP_ENA = '1' else (others=>'0');
	G <= rgb(4 downto 2) when DISP_ENA = '1' else (others=>'0');
	B <= rgb(1 downto 0) when DISP_ENA = '1' else (others=>'0');
	
	PRESY: process(MCLK, nRST)
	begin
		if (nRST = '0') then	
			fifo_full_resy <= '0';
			ff0 <= '0';
			bl0 <= '0';
			bl1 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			ff0 <= FIFO_FULL;
			fifo_full_resy <= ff0;
			bl0 <= BLANKING;
			bl1 <= bl0;
		end if;
	end process PRESY;

	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			rgb <= (others=>'0');
			blank <= '1';
			UNDERRUN <= '0';
			NXT <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (CLEAR = '1') then
				state <= S_IDLE;
				rgb <= (others=>'0');
				blank <= bl1;	
				UNDERRUN <= '0';
			elsif (state = S_IDLE) then
				rgb <= (others=>'0');
				UNDERRUN <= '0';
				NXT <= '0';
				rgb <= (others=>'0');
				if (fifo_full_resy = '1') then
					if (blank = '1') then
						rgb <= (others=>'0');
					else
						rgb <= DIN(7 downto 0);
					end if;
					state <= S_MSB;
				end if;
			elsif (state = S_MSB) then
				UNDERRUN <= '0';
				NXT <= '0';
				if (DISP_ENA = '1') then
					if (blank = '1') then
						rgb <= (others=>'0');
					else
						rgb <= DIN(15 downto 8);
					end if;
					NXT <= '1';
					if (FIFO_EMPTY = '1') then
						UNDERRUN <= '1';
					end if;
					state <= S_LSB;
				end if;
			elsif (state = S_LSB) then
				UNDERRUN <= '0';
				NXT <= '0';
				if (DISP_ENA = '1') then
					if (blank = '1') then
						rgb <= (others=>'0');
					else
						rgb <= DIN(7 downto 0);
					end if;
					state <= S_MSB;
				end if;
			end if;
		end if;
	end process POTO;

end rtl;

