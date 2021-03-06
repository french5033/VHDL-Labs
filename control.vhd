-- Student name: Stephanie French 
-- Student ID number: 62326647

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all; 
USE IEEE.std_logic_unsigned.all; 
USE IEEE.numeric_std.all; 
USE work.Glob_dcls.all;

--- Execution of each instruction in the specified number of steps (defined above). 
entity control is 

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

end control;

architecture control_arch of control is

-- component declaration 
-- component specification 

-- signal declaration

	subtype controlword IS std_logic_vector (17 downto 0);
	subtype CW_ADDR is integer range 0 to 13;
	type CW is array (CW_ADDR) of controlword;
	--signal nextState: CW_ADDR;

	constant C: CW:= (
		"101011111000100000", -- 0 IF
		"000001111001100000", -- 1 ID/RF
		"000001111011000000", -- 2 LW/SW Memory Address Computation
		"011001111010000000", -- 3 LW Memory Access
		"010000100110000000", -- 4 LW Write Back to Reg
		"010101111010000000", -- 5 SW Writeback to RAM
		"0000011110100UUU00", -- 6 R-type
		"000000001110000000", -- 7 R-type completion
		"000001111010000100", -- 8 Branch 1
		"U00001101010000001", -- 9 Branch 2
		"100001111010000010", -- 10 J type
		"000001111010000000", -- 11 Error condition/Reset pressed
		"0000011110100UUU00", -- 12 I type Computational
		"000000000111000000"  -- 13 I type computational Completion
		);

	signal cw_out: controlword;
	signal state: CW_ADDR;
begin
	PCUpdate	<= cw_out(17);
	IorD		<= cw_out(16);
	MemRead		<= cw_out(15);
	MemWrite	<= cw_out(14);
	IRWrite		<= cw_out(13);
	MemtoReg(1)	<= cw_out(12);
	MemtoReg(0)	<= cw_out(11);
	RegDst(1)	<= cw_out(10);
	RegDst(0)	<= cw_out(09);
	RegWrite	<= cw_out(08);
	ALUSrcA		<= cw_out(07);
	ALUSrcB(1)	<= cw_out(06);
	ALUSrcB(0)	<= cw_out(05);
	ALUControl(2)	<= cw_out(04);
	ALUControl(1)	<= cw_out(03);
	ALUControl(0)	<= cw_out(02);
	PCSource(1)	<= cw_out(01);
	PCSource(0)	<= cw_out(00);

	PROCESS (clk, reset_N) -- Majority of the work happens here
	BEGIN
		IF (rising_edge(reset_N)) THEN
			cw_out<= C(11);
			state <= 11;
		ELSIF (rising_edge(clk)) THEN
			CASE state is
				WHEN 6 =>
					--cw_out <= C(state); --calculate ALUControl
					cw_out(17 downto 05) <= C(state)(17 downto 05);
					case func is
						when "000000" => cw_out(04 downto 02) <= "010";
						when "000010" => cw_out(04 downto 02) <= "011";
						when "000011" => cw_out(04 downto 02) <= "011";
						when "100001" => cw_out(04 downto 02) <= "000";
						when "100011" => cw_out(04 downto 02) <= "001";
						when "100100" => cw_out(04 downto 02) <= "100";
						when "100101" => cw_out(04 downto 02) <= "101";
						when "100110" => cw_out(04 downto 02) <= "110";
						when "100111" => cw_out(04 downto 02) <= "111";
						when others => cw_out(04 downto 02) <= "000";
					end case;
				WHEN 9 =>
					cw_out(16 downto 0) <= C(state)(16 downto 0); --calculate PCUpdate
					if(opcode(0) = '0') then cw_out(17) <= zero; --BEQ
					else cw_out(17) <= not zero; --BNE
					end if;
				--WHEN 10 =>
				--	cw_out <= C(state); --Todo: Make JR and JALR work.
				WHEN 12 =>
					--cw_out <= C(state); --calculate ALUControl
					cw_out(17 downto 05) <= C(state)(17 downto 05);
					if(opcode(2 downto 0) = "001") then
						cw_out(04 downto 02) <= "000";
					else
						cw_out(04 downto 02) <= opcode(2 downto 0);
					end if;
					cw_out(01 downto 00) <= C(state)(01 downto 00);
				WHEN OTHERS =>
					cw_out <= C(state);
			END CASE;
			CASE state is
				WHEN 0 => state <= 1;
				WHEN 1 =>
					if ( opcode(5) = '1' ) then
						state <= 2;
					elsif ( (opcode(5 downto 1) = "00001" ) OR (opcode = "000000" AND func(5 downto 1) = "00100") ) then
						state <= 10;
					elsif ( opcode = "000000" ) then
						state <= 6;
					elsif ( opcode(5 downto 3) = "001" ) then
						state <= 12;
					elsif ( opcode(5 downto 2) = "0001" ) then
						state <= 8;
					else
						state <= 11; --Error
					end if;
				WHEN 2 =>
					if ( opcode(3) = '1' ) then
						state <= 5;
					else
						state <= 3;
					end if;
				WHEN 3 => state <= 4;
				WHEN 6 => state <= 7;
				WHEN 8 => state <= 9;
				WHEN 12 => state <= 13;
				WHEN OTHERS => state <= 0;
			END CASE;
		END IF;
	END PROCESS;
end control_arch;






















