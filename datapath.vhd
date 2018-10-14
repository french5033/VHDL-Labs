-- Student name: Stephanie French
-- Student ID number: 62326647

-- LAB 5 

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity datapath is 
  port (
    clk        : in  std_logic;
    reset_N    : in  std_logic;
    
    PCUpdate   : in  std_logic;         -- write_enable of PC

    IorD       : in  std_logic;         -- Address selection for memory (PC vs. store address)
    MemRead    : in  std_logic;		-- read_enable for memory
    MemWrite   : in  std_logic;		-- write_enable for memory

    IRWrite    : in  std_logic;         -- write_enable for Instruction Register
    MemtoReg   : in  std_logic_vector(1 downto 0);  -- selects ALU or MEMORY or PC to write to register file.
    RegDst     : in  std_logic_vector(1 downto 0);  -- selects rt, rd, or "31" as destination of operation
    RegWrite   : in  std_logic;         -- Register File write-enable
    ALUSrcA    : in  std_logic;         -- selects source of A port of ALU
    ALUSrcB    : in  std_logic_vector(1 downto 0);  -- selects source of B port of ALU
    
    ALUControl : in  ALU_opcode;	-- receives ALU opcode from the controller
    PCSource   : in  std_logic_vector(1 downto 0);  -- selects source of PC

    opcode_out : out opcode;		-- send opcode to controller
    func_out   : out func;		-- send func field to controller
    shamt_out  : out shamt;		-- send shamt field to controller
    zero       : out std_logic);	-- send zero to controller (cond. branch)

end datapath;

architecture datapath_arch of datapath is
type   registerSet5 is array(0 to 5) of word;
-- 0: ALUA 
-- 1: ALUB 
-- 2: ALU Out 
-- 3: Instruction Storage 
-- 4: Data temp storage 
-- 5: PC

signal Temp: registerSet5;
signal R2T1, R2T2	: word; --RF 2 Temp (0,1)
signal A2T		: word; --ALU 2 Temp (2)
signal T2R1		: word; --ITemp 2 RF (3)
signal T2R2		: word;	--DTemp 2 RF (4)
signal MemOut		: word; --Memory out to I, D (3, 4)

signal rd		: reg_addr;

signal unused_word	: word := Zero_word;
signal unused_reg	: reg_addr := (others => '0');

signal JMP2M		: word; --JMP 2 Mux
signal BR2M		: word; --Branch 2 Mux
signal M2PC		: word; --Mux 2 PC
signal Mx2Mem		: word;

signal IorD2		: std_logic_vector (1 downto 0); -- pad to 2 bits
signal ALUSrcA2		: std_logic_vector (1 downto 0); -- pad to 2 bits
signal PC2Mx		: word; -- Program Counter to IDMux

signal Rx2RF		: word; --Register File Data Mux to Register File

signal AMxA2A		: word; --ALU Mux A to ALU A.
signal AMxB2B		: word; --ALU Mux B to ALU B.

signal four		: word := "00000000000000000000000000000100"; --the number four.
signal InstSE, InstSE2	: word; --Sign Extended Instruction...

component ALU
  PORT( op_code  : in ALU_opcode; 
	in0, in1 : in word;	
        C	 : in std_logic_vector(4 downto 0);  -- shift amount	
        ALUout   : out word; 
	Zero     : out std_logic );
end component;

component RegFile
  port( clk, wr_en                    : in  STD_LOGIC; 		
        rd_addr_1, rd_addr_2, wr_addr : in  REG_addr;	
        d_in                          : in  word; 	
        d_out_1, d_out_2              : out word );
end component;

component mem
   PORT (MemRead, MemWrite	: IN std_logic;
	 d_in, address		: IN   word;		 
	 d_out			: OUT  word 
	 );
end component;

component mux_word_4
 Port (	sel	: in STD_LOGIC_VECTOR (1 downto 0);
	in0,in1,in2,in3	: in word;
	outp	: out word);
end component;
component mux_reg_4
 Port (	sel	: in STD_LOGIC_VECTOR (1 downto 0);
	in0,in1,in2,in3	: in reg_addr;
	outp	: out reg_addr);
end component;

BEGIN
	--Datapath process
	R: RegFile port map(clk, RegWrite, Temp(3)(25 downto 21), Temp(3)(20 downto 16), rd, Rx2RF, R2T1, R2T2);
	A: ALU port map( ALUControl, AMxA2A, AMxB2B, Temp(3)(10 downto 6), A2T, zero);
	PCMux: mux_word_4 port map (PCSource, A2T, Temp(2), JMP2M, unused_word, M2PC); -- Mux to select PC Source
	IDMux: mux_word_4 port map (IorD2, Temp(5), Temp(2), unused_word, unused_word, Mx2Mem); --Mux for Memory Address
	RDMux: mux_word_4 port map (MemtoReg, Temp(2), Temp(4), Temp(5), unused_word, Rx2RF); --Register File Data Mux
	AMxA: mux_word_4 port map (ALUSrcA2, Temp(5), Temp(0), unused_word, unused_word, AMxA2A); --Mux for ALU A
	AMxB: mux_word_4 port map (ALUSrcB, Temp(1), Four, InstSE, InstSE2, AMxB2B); --Mux for ALU B.
	RWMux: mux_reg_4 port map (RegDst, Temp(3)(20 downto 16), Temp(3)(15 downto 11), "11111", unused_reg, rd); --Mux to select register Write
	Munified: mem port map(MemRead, MemWrite, Temp(1), Mx2Mem, MemOut);
	IorD2(0) <= IorD;
	IorD2(1) <= '0';
	ALUSrcA2(0) <= ALUSrcA;
	ALUSrcA2(1) <= '0';
	
	InstSE(31 downto 16) <= (others => Temp(3)(15));
	InstSE(15 downto 0) <= Temp(3)(15 downto 0);
	
	InstSE2(31 downto 18) <= (others => Temp(3)(15));
	InstSE2(17 downto 2) <= Temp(3)(15 downto 0);
	InstSE2(1 downto 0) <= "00";
	
	JMP2M(31 downto 28) <= Temp(5)(31 downto 28);
	JMP2M(27 downto 2) <= Temp(3)(25 downto 0);
	JMP2M(1 downto 0) <= "00";

	opcode_out <= Temp(3)(31 downto 26);
	shamt_out <= Temp(3)(10 downto 6);
	func_out <= Temp(3)(5 downto 0);

	PROCESS (clk, reset_N) -- Majority of the work happens here
	BEGIN
		IF (rising_edge(reset_N)) THEN
			Temp(0) <= (others => '0');
			Temp(1) <= Zero_word;
			Temp(2) <= Zero_word;
			Temp(3) <= Zero_word;
			Temp(4) <= Zero_word;
			Temp(5) <= Zero_word;
		ELSIF (rising_edge(clk)) THEN
			Temp(0) <= R2T1;
			Temp(1) <= R2T2;
			Temp(2) <= A2T;
			IF (IRWrite = '1') THEN
				Temp(3) <= MemOut;
			END IF;
			Temp(4) <= MemOut;
			IF (PCUpdate = '1') THEN
				Temp(5) <= M2PC;
			END IF;
		END IF;
	END PROCESS;

end datapath_arch;