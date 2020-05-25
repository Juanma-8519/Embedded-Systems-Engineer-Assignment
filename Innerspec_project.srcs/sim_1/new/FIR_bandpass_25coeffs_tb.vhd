library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.integer_to_ascii.all;

entity fir_tb is
end entity;


architecture behav of fir_tb is

    ---------------------------------------
    -- Component declaration for the UUT --
    ---------------------------------------
     
    component fir_filter is
        port ( 
                clk_i 	      : in std_logic;
                reset_i       : in std_logic;
                x             : in std_logic_vector(11 downto 0);
                digitizer_fir : in std_logic_vector(15 downto 0);
                coeffs_fir    : in fir_array (24 downto 0);
                y_32          : out signed(31 downto 0);
                y_16          : out signed(15 downto 0);
                y_12          : out std_logic_vector(11 downto 0)
            );
            end component;
            
            

  signal clk_i          : std_logic :='0';
  signal reset_i        : std_logic;
  signal x              : std_logic_vector(11 downto 0) := (others => '0') ;
  signal digitizer_fir  : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(12000,16));
  signal y_32           : signed(31 downto 0)  := (others => '0') ;
  signal y_16           : signed(15 downto 0)  := (others => '0') ;
  signal y_12           : std_logic_vector(11 downto 0)  := (others => '0') ;

  --signal y_32    : signed(31 downto 0);
  
  signal coeffs_fir     : fir_array (24 downto 0) := (
                                std_logic_vector(to_signed(45,16)),
                                std_logic_vector(to_signed(0,16)),
                                std_logic_vector(to_signed(-136,16)),
                                std_logic_vector(to_signed(-204,16)),
                                std_logic_vector(to_signed(-34,16)),
                                std_logic_vector(to_signed(306,16)),
                                std_logic_vector(to_signed(2082,16)),
                                std_logic_vector(to_signed(0,16)),
                                std_logic_vector(to_signed(-3637,16)),
                                std_logic_vector(to_signed(-4859,16)),
                                std_logic_vector(to_signed(-1409,16)),
                                std_logic_vector(to_signed(4290,16)),
                                std_logic_vector(to_signed(7114,16)),
                                std_logic_vector(to_signed(4290,16)),
                                std_logic_vector(to_signed(-1409,16)),
                                std_logic_vector(to_signed(-4859,16)),
                                std_logic_vector(to_signed(-3637,16)),
                                std_logic_vector(to_signed(0,16)),
                                std_logic_vector(to_signed(2082,16)),
                                std_logic_vector(to_signed(306,16)),
                                std_logic_vector(to_signed(-34,16)),
                                std_logic_vector(to_signed(-204,16)),
                                std_logic_vector(to_signed(-136,16)),
                                std_logic_vector(to_signed(0,16)),
                                std_logic_vector(to_signed(45,16))
                                );

  file samples : TEXT open READ_MODE is "D:\Innerspec\Innerspec_project\Innerspec_project.srcs\sim_1\new\input samples positives.txt";
  file filtered : TEXT open WRITE_MODE is "output.txt";
begin

    -------------------------
    -- instantiate the UUT --
    -------------------------
    


    UUT: fir_filter port map (
        clk_i                               => clk_i,
        reset_i                             => reset_i,
        x                                   => x,
        digitizer_fir                       => digitizer_fir,
        coeffs_fir                          => coeffs_fir,
        y_32                                => y_32,   
        y_16                                => y_16,   
        y_12                                => y_12      
    );


clk_i   <= not(clk_i) after 10 ns;
reset_i <= '0', '1' after 10 ns, '0' after 20 ns;

process(clk_i)
  variable sample_line : LINE;
  variable x_int : integer;

begin
  if(rising_edge(clk_i)) then
    readline(samples,sample_line);
    read(sample_line,x_int);
    x <= std_logic_vector(to_signed(x_int,12));
  end if; 
end process;


process(clk_i)
  variable output_line : LINE;
  variable x_int : integer := 0;

begin
  if(falling_edge(clk_i)) then
    write(output_line,to_integer(unsigned(y_12)));
    writeline(filtered,output_line);

  end if; 
end process;

end architecture;
