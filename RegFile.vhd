-- Student name: Stephanie French
-- Student ID number: 62326647

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

-- rs, rt, rd
entity RegFile is 
  port( clk, wr_en                    : in  STD_LOGIC; 		
        rd_addr_1, rd_addr_2, wr_addr : in  REG_addr;	
        d_in                          : in  word; 	
        d_out_1, d_out_2              : out word );
end RegFile;

architecture behavioral of RegFile is
   type   registerFile is array(0 to 31) of word;
   signal reg_File: registerFile;

begin
    process(clk)
    begin
	reg_file(0) <= (others => '0');
	if rising_edge(clk) then
		d_out_1 <= reg_file(to_integer(unsigned(rd_addr_1)));
		d_out_2 <= reg_file(to_integer(unsigned(rd_addr_2)));
        	if (wr_en = '1') AND NOT (wr_addr = "00000") then
        	    reg_file(to_integer(unsigned(wr_addr))) <= d_in;
        	end if;
	end if;
    end process;
end behavioral;