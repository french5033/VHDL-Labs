-- Student name: Stephanie French
-- Student ID number: 62326647


LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.all;
USE work.Glob_dcls.all;

ENTITY mem IS
   PORT (MemRead	: IN std_logic;
	 MemWrite	: IN std_logic;
	 d_in		: IN   word;		 
	 address	: IN   word;
	 d_out		: OUT  word 
	 );
END mem;

ARCHITECTURE mem_arch OF mem IS

-- component declaration
-- given in Glob_dcls.vhd
-- component specification


-- signal declaration
	signal addr: unsigned(29 downto 0);
	--Add delayed memory control signals
	signal LOCAL_MemRead  : std_logic;
	signal LOCAL_MemWrite : std_logic;
	
	signal MEM : RAM:=("10001100000000010000000001010000",	
	                   "00100000001000100000000000000101",	
	                   "00000000000000100001100001000010",	
	                   "00010100001000110000000000000011",	
	                   "00010000001000110000000000000001",	
	                   "00000000011000100010000000100000",	
	                   "00000000011000100010000000100010",	
	                   "10101100000001000000000001011100",	
	                   "00001100000000000000000000000001",	
	                   "11111111111111111111111111111111",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "11111111111111111111111111111111",	
	                   "00000000000000000000000000000100",	
	                   "00000000000000000000000000000001",	
	                   "00000000000000000000000000000010",	
	                   "00000000000000000000000000000011",	
	                   "00000000000000000000000000000010",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000",	
	                   "00000000000000000000000000000000"
                      );
	
BEGIN

addr <= unsigned(address(31 downto 2));

--Delay memory control signals by 1ns
	LOCAL_MemRead <= MemRead after 1 ns;
	LOCAL_MemWrite <= MemWrite after 1 ns;

memory: process(LOCAL_MemRead, LOCAL_MemWrite)
	
begin
	if LOCAL_MemWrite'event and LOCAL_MemWrite = '1' then
     		MEM(TO_INTEGER(addr)) <= d_in after WR_LATENCY;
	elsif LOCAL_MemRead'event and LOCAL_MemRead = '1' then
     		d_out <= MEM(TO_INTEGER(addr)) after RD_LATENCY;
	else
     		null;
	end if;
end process memory;

END mem_arch;

