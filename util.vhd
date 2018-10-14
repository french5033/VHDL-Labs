-- Student name: Stephanie French
-- Student ID number: 62326647

-- LAB 5 

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE work.Glob_dcls.all;

entity mux_word_4 is
	Port (	sel	: in STD_LOGIC_VECTOR (1 downto 0);
		in0,in1,in2,in3	: in word;
		outp	: out word);
end mux_word_4;

architecture mux_word_4_arch of mux_word_4 is

begin
	with sel select outp <= in0 when "00",
				in1 when "01",
				in2 when "10",
				in3 when "11",
				(others => 'U') when others;
end mux_word_4_arch;


LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE work.Glob_dcls.all;

entity mux_reg_4 is
	Port (	sel	: in STD_LOGIC_VECTOR (1 downto 0);
		in0,in1,in2,in3	: in reg_addr;
		outp	: out reg_addr);
end mux_reg_4;

architecture mux_reg_4_arch of mux_reg_4 is

begin
	with sel select outp <= in0 when "00",
				in1 when "01",
				in2 when "10",
				in3 when "11",
				(others => 'U') when others;
end mux_reg_4_arch;
