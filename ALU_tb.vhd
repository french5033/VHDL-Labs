-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity ALU_tb is
end ALU_tb;

architecture ALU_tb_arch of ALU_tb is
component RegFile
  port( clk, wr_en                    : in  STD_LOGIC;
        rd_addr_1, rd_addr_2, wr_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
        d_in                          : in  STD_LOGIC_VECTOR(31 downto 0); 
        d_out_1, d_out_2              : out STD_LOGIC_VECTOR(31 downto 0) );
end component;

signal clk, wr_en 						: std_logic;
signal rd_addr_1, rd_addr_2, wr_addr 	: STD_LOGIC_VECTOR( 4 downto 0);	
signal d_in								: STD_LOGIC_VECTOR(31 downto 0); 
signal d_out_1, d_out_2					: STD_LOGIC_VECTOR(31 downto 0);


begin
	rf: RegFile port map (clk, wr_en, rd_addr_1, rd_addr_2, wr_addr, d_in, d_out_1, d_out_2);
	process
	begin
		clk <= '0';
		wait for 50 ps;
		clk <= '1';
		wait for 50 ps;
	end process;
	process
	begin
		rd_addr_1 	<= "00000";
		rd_addr_2 	<= "00000";
		wr_addr		<= "00001";
		wr_en		<= '1';
		d_in		<= "00000000000010000000000000000000";
		wait until clk 	= '1';
		wait until clk 	= '0';
		assert (d_out_1 = "00000000000000000000000000000000") REPORT "Error reading from R0";
		assert (d_out_2 = "00000000000000000000000000000000") REPORT "Error reading from R0";

		rd_addr_1 	<= "00001";
		rd_addr_2	<= "00010";
		wr_addr		<= "00010";
		wr_en		<= '1';
		d_in		<= "00000100000000000000000000000000";
		wait until clk 	= '1';
		wait until clk 	= '0';
		assert (d_out_1 = "00000000000010000000000000000000") REPORT "Error reading from R1";
		
		rd_addr_1 	<= "00001";
		rd_addr_2 	<= "00010";
		wr_addr		<= "00011";
		wr_en		<= '1';
		d_in		<= "00000000000000000000001000000000";
		wait until clk 	= '1';
		wait until clk 	= '0';
		assert (d_out_1 = "00000000000010000000000000000000") REPORT "Error reading from R1";
		assert (d_out_2 = "00000100000000000000000000000000") REPORT "Error reading from R2";

		rd_addr_1 	<= "00011";
		rd_addr_2 	<= "00010";
		wr_addr		<= "00011";
		wr_en		<= '0';
		d_in		<= "00000001000000000000001000000000";
		wait until clk 	= '1';
		wait until clk 	= '0';
		assert (d_out_1 = "00000000000000000000001000000000") REPORT "Error reading from R3";
		--assert (d_out_2 = "00000100000000000000000000000000") REPORT "Error reading from R2";

		rd_addr_1 	<= "00011";
		rd_addr_2 	<= "00010";
		wr_addr		<= "00011";
		wr_en		<= '0';
		d_in		<= "00000001000000000000001000000000";
		wait until clk 	= '1';
		wait until clk 	= '0';
		assert (d_out_1 = "00000000000000000000001000000000") REPORT "Error unintended write to R3";
		--assert (d_out_2 = "00000100000000000000000000000000") REPORT "Error reading from R2";

	end process;
	
end ALU_tb_arch;

