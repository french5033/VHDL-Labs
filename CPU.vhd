-- Student name: Stephanie French 
-- Student ID number: 62326647

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all; 
USE work.Glob_dcls.all;

entity CPU is
  port ( clk: in std_logic;
    	reset_N : in std_logic
); -- active-low signal for reset
end CPU;

architecture CPU_arch of CPU is
-- component declaration
	-- Datapath (from Lab 5)
component datapath
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
end component;
	-- Controller (you just built)
component control
   port( 
	clk: IN STD_LOGIC;

	reset_n: IN STD_LOGIC;

        opcode: IN opcode; -- declare type for the 6 most significant bits of IR  
   
	func: IN func; -- type for 6 least significant bits of IR    
 	
	shamt: IN shamt;

	zero        : IN STD_LOGIC;  

	PCUpdate: OUT STD_LOGIC; -- this signal controls whether PC is updated or not

	IorD: OUT STD_LOGIC; 

	MemRead: OUT STD_LOGIC; 

	MemWrite: OUT STD_LOGIC; 

	IRWrite: OUT STD_LOGIC;

	MemtoReg    : OUT STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL  	

	RegDst      : OUT STD_LOGIC_VECTOR (1 downto 0);  -- the extra bit is for JAL    	

	RegWrite    : OUT STD_LOGIC;  	
	
	ALUSrcA     : OUT STD_LOGIC;  
	
	ALUSrcB: OUT STD_LOGIC_VECTOR (1 downto 0);  	

	ALUcontrol  : OUT ALU_opcode; 

	PCSource: OUT STD_LOGIC_VECTOR (1 downto 0) );
end component;
-- component specification
-- signal declaration

signal 	opcode: opcode; -- declare type for the 6 most significant bits of IR  
signal 	func: func; -- type for 6 least significant bits of IR    
signal 	shamt: shamt;
signal 	zero: STD_LOGIC;  
signal 	PCUpdate: STD_LOGIC; -- this signal controls whether PC is updated or not
signal 	IorD: STD_LOGIC; 
signal 	MemRead: STD_LOGIC; 
signal 	MemWrite: STD_LOGIC; 
signal 	IRWrite: STD_LOGIC;
signal 	MemtoReg: STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL  	
signal 	RegDst: STD_LOGIC_VECTOR (1 downto 0);  -- the extra bit is for JAL    	
signal 	RegWrite: STD_LOGIC;  	
signal 	ALUSrcA: STD_LOGIC;  
signal 	ALUSrcB: STD_LOGIC_VECTOR (1 downto 0);  	
signal 	ALUcontrol: ALU_opcode; 
signal 	PCSource: STD_LOGIC_VECTOR (1 downto 0);

begin
dp: datapath port map(clk, reset_N, PCUpdate, IOrD, MemRead, MemWrite, IRWrite, MemtoReg, RegDst, RegWrite, ALUSrcA, ALUSrcB, ALUControl, PCSource, opcode, func, shamt, zero);
c: control port map(clk, reset_N, opcode, func, shamt, zero, PCUpdate, IOrD, MemRead, MemWrite, IRWrite, MemtoReg, RegDst, RegWrite, ALUSrcA, ALUSrcB, ALUControl, PCSource);
end CPU_arch;
