-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity datapath_tb is
end datapath_tb;

architecture datapath_tb_arch of datapath_tb is
component DP is
  PORT( C	    : in std_logic_vector(4 downto 0);
	clk         : in std_logic;        -- If clock is high, rd/wr value
	Imm	        : in word;
  op_code     : in ALU_opcode; 	  -- How do I use the opcode in here?
	wr_en       : in std_logic; 	  -- Write when wr_en = '1'
	rs, rt, rd  : in REG_addr;  	  --  rs: rd_addr_1, rt: rd_addr_2, rd: wr_addr
	d_in        : in word;
  d_out       : out word;
	Zero        : out std_logic ); end component;

component RegR is
port(   clk, wr_en                    : in  STD_LOGIC;
        rd_addr_1, rd_addr_2, wr_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
        d_in                          : in  STD_LOGIC_VECTOR(31 downto 0);
        d_out_1, d_out_2              : out STD_LOGIC_VECTOR(31 downto 0)
); end component;

component mux is
port( opcode: in STD_LOGIC;
	regA: in std_logic;
	regB: in std_logic;
	zero: out std_logic;
	d_out: out std_logic
); end component;

signal wr_en 	 : std_logic := '0';

signal DIN	 	 : std_logic := '0';
signal r_s		 : REG_addr;
signal r_t		 : REG_addr;
signal r_d		 : REG_addr;
signal d_out		 : word;
SIGNAL Rf : REG_addr; --register file contents
signal CLK  : std_logic := '0';

begin
	--WritePort: PROCESS (clk)
	process(CLK)
	BEGIN
		IF (CLK'EVENT AND CLK = '1') THEN
			IF (wr_en = '1') THEN
				--d_out <= r_s;
				--d_out <= r_d;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (r_s, r_t, r_d)
	BEGIN
		IF (r_s = "000001") then
	--		d_out <= Rf; -- convert bit VECTOR to integer
		--ELSE
			--d_out <= (others => 'Z');
		END IF;
	END PROCESS;

	--ReadRdAddr2: PROCESS (rs, Rd)
	--BEGIN -- rd_addr_2
		--IF (Rt = '1') then
	--		d_out <= Rf(CONV_INTEGER(Rd)); -- convert bit VECTOR to integer
		--ELSE
	--		d_out <= (others => 'Z');
		--END IF;
	--END PROCESS;

end datapath_tb_arch;
