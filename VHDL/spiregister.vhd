--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################


-- SPI COMMAND LIST
-- ----------------
-- 01 XH XL				write data
-- 02 XH XM XL			write address 
-- 03 					read cmd
-- 3X ?H ?L				read data
-- 4X ??				read status register
-- 05 XX				write control register
-- 5X ??				read control register	

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spiregister is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		PIN		: in	std_logic_vector(7 downto 0);
		NIB		: in	std_logic_vector(3 downto 0);
		POUT		: out	std_logic_vector(7 downto 0);
		VAL_PIN		: in	std_logic;
		VAL_NIB		: in	std_logic;
		LOAD		: in	std_logic;
		UNDERRUN		: in	std_logic;
		DATA_DONE		: in	std_logic;
		PAGE		: out	std_logic;
		ADINC		: out	std_logic;
		BLANKING		: out	std_logic;
		ADDRESS		: out	std_logic_vector(22 downto 0);
		ADDRESS_WRITE		: out	std_logic;
		DATA_READ		: out	std_logic;
		DATA_IN		: out	std_logic_vector(15 downto 0);
		DATA_WRITE		: out	std_logic;
		DATA_OUT		: in	std_logic_vector(15 downto 0)
	);
end spiregister;

architecture rtl of spiregister is
-- read
constant STATUS_NIBBLE 		: std_logic_vector(3 downto 0) := x"4";
constant CONTROL_NIBBLE 	: std_logic_vector(3 downto 0) := x"5";
constant DATA_NIBBLE 		: std_logic_vector(3 downto 0) := x"3";
-- write
constant WRITE_DATA			: std_logic_vector(7 downto 0) := x"01";
constant WRITE_ADDRESS		: std_logic_vector(7 downto 0) := x"02";
constant READ_CMD			: std_logic_vector(7 downto 0) := x"03";
constant WRITE_CONTROL		: std_logic_vector(7 downto 0) := x"05";

signal VAL_NIB_RESY, VN0, VN1, VN2	: std_logic;
signal VAL_PIN_RESY, VP0, VP1, VP2	: std_logic;
signal LOAD_RESY, LD0, LD1, LD2 	: std_logic;
type state_t is (S_IDLE,S_WBYTE,S_WWORD,S_CMD,S_WAIT,S_REG0,S_REG1,S_REG2);
signal state 						: state_t;
signal clear_status 				: std_logic;
signal operation 					: std_logic_vector(7 downto 0);
signal control_reg 					: std_logic_vector(7 downto 0);
signal status_reg 					: std_logic_vector(7 downto 0);
signal under0, under1, under 		: std_logic;
signal reg0,reg1 					: std_logic_vector(7 downto 0);
begin
	PUNDER: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			under0 <= '0';
			under1 <= '0';
			under <= '0';
		 elsif (MCLK'event and MCLK = '1') then
			under0 <= UNDERRUN;
			under1 <= under0;
			if (under1 = '1') then
				under <= '1';
			elsif (clear_status = '1') then
				under <= '0';
			end if;
		end if;
	end process PUNDER;
	
	status_reg(0) <= DATA_DONE;
	status_reg(7) <= under;
	status_reg(6 downto 1) <= (others=>'0');
	
	BLANKING <= control_reg(0);
	PAGE <= control_reg(1);
	ADINC <= control_reg(2);
				

	PRESY: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			VN0 <= '0';
			VN1 <= '0';
			VN2 <= '0';
			VP0 <= '0';
			VP1 <= '0';
			VP2 <= '0';
			LD0 <= '0';
			LD1 <= '0';
			LD2 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			VN0 <= VAL_NIB;
			VP0 <= VAL_PIN;
			VN1 <= VN0;
			VN2 <= VN1;
			VP1 <= VP0;
			VP2 <= VP1;
			LD0 <= LOAD;
			LD1 <= LD0;
			LD2 <= LD1;
		end if;
	end process PRESY;
	
	VAL_NIB_RESY <= VN1 and not(VN2);
	VAL_PIN_RESY <= VP1 and not(VP2);
	LOAD_RESY <= LD1 and not(LD2);
	
	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			clear_status <= '0';
			POUT <= (others=>'1');
			DATA_READ <= '0';
			ADDRESS_WRITE <= '0';
			DATA_WRITE <= '0';
			ADDRESS <= (others=>'0');
			control_reg <= "00000101";  -- blanking + address increment
			ADDRESS <= (others=>'0');
			DATA_IN <= (others=>'0');
			reg0 <= (others=>'0');
			reg1 <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (VAL_NIB_RESY = '1') then
				DATA_READ <= '0';   -- protection
				ADDRESS_WRITE <= '0';
				DATA_WRITE <= '0';
				case (NIB) is
					when STATUS_NIBBLE =>
						clear_status <= '1';
						POUT <= status_reg;
						state <= S_WBYTE;
					when CONTROL_NIBBLE =>
						POUT <= control_reg;
						state <= S_WBYTE;
					when DATA_NIBBLE =>
						POUT <= DATA_OUT(15 downto 8);
						state <= S_WWORD;
					when others =>
						POUT <= (others=>'1');
						state <= S_CMD;
				end case;
			-- spi read
			elsif (state = S_IDLE) then
				POUT <= (others=>'1');
				clear_status <= '0';
				DATA_READ <= '0';
				ADDRESS_WRITE <= '0';
				DATA_WRITE <= '0';
			elsif (state = S_WAIT) then
				POUT <= (others=>'1');
				if (VAL_PIN_RESY = '1') then
					state <= S_IDLE;
				end if;
			elsif (state = S_WBYTE) then
				clear_status <= '0';
				if (LOAD_RESY = '1') then
					state <= S_WAIT;
				end if;
			elsif (state = S_WWORD) then
				if (LOAD_RESY = '1') then
					POUT <= DATA_OUT(7 downto 0);
					state <= S_WBYTE;
				end if;
			-- spi write
			elsif (state = S_CMD) then
				if (VAL_PIN_RESY = '1') then
					operation <= PIN;
					state <= S_REG0;
				end if;
			elsif (state = S_REG0) then
				if (operation = READ_CMD) then
					DATA_READ <= '1';
					state <= S_IDLE;
				elsif (VAL_PIN_RESY = '1') then
					reg0 <= PIN;
					state <= S_REG1;
				end if;
			elsif (state = S_REG1) then
				if (operation = WRITE_CONTROL) then
					control_reg <= reg0;
					state <= S_IDLE;
				elsif (VAL_PIN_RESY = '1') then
					reg1 <= PIN;
					state <= S_REG2;
				end if;
			elsif(state = S_REG2) then
				if (operation = WRITE_DATA) then
					DATA_WRITE <= '1';
					DATA_IN(15 downto 8) <= reg0;
					DATA_IN(7 downto 0) <= reg1;
					state <= S_IDLE;
				elsif (VAL_PIN_RESY = '1') then
					-- last case: WRITE_ADDRESS
					if (operation = WRITE_ADDRESS) then
						ADDRESS(22 downto 16) 	<= reg0(6 downto 0);
						ADDRESS(15 downto 8)  	<= reg1;
						ADDRESS(7 downto 0) 	<= PIN;
						ADDRESS_WRITE <= '1';
					end if;
					state <= S_IDLE;
				end if;
			else
				state <= S_IDLE;
			end if;
		end if;
	end process POTO;
end rtl;

