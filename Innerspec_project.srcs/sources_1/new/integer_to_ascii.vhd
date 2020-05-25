----------------------------------------------------------------------------------
-- Company: Innerspec
-- Engineer: Juanma Manchado
-- 
-- Create Date: 29/05/2020 11:55:13 AM
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This set of functions is used to convert a four digit integer to its 
-- corresponding ASCII characters to display its value from the serial port.
-- they are taken from  https://stackoverflow.com/questions/36824638/vhdl-how-to-efficiently-convert-integer-to-ascii-or-8-bit-slv/36846455#36846455
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

---------------------------------
-- package declaration section --
--------------------------------- 
    
package integer_to_ascii is

	type char_array is array (NATURAL range <>) of std_logic_vector(7 downto 0);
    type fir_array is array (NATURAL range <>) of std_logic_vector(15 downto 0);


	function get_ascii_array_from_int(i : integer range -9999 to 9999) return 
		char_array;

	function get_ascii_array_from_int_hundreds (i : integer range 0 to 999) return 
		char_array;

	function get_ascii_array_from_int_tens (i : integer range 0 to 99) return
		char_array;

	function get_ascii_array_from_int_ones (i : integer range 0 to 9) return 
		std_logic_vector;
		
    function ascii_to_std_logic_vector (input : char_array) return
        std_logic_vector;


end package integer_to_ascii;
 
--------------------------
-- package body section --
--------------------------  

package body integer_to_ascii is
 
function get_ascii_array_from_int_ones (i : integer range 0 to 9) return std_logic_vector is
    variable result : std_logic_vector(7 downto 0) := (x"30"); -- 0
    begin
        if i < 1 then
             result := x"30"; -- 0
        elsif i < 2 then
             result := x"31"; -- 1
        elsif i < 3 then
             result := x"32"; -- 2
        elsif i < 4 then
             result := x"33"; -- 3
        elsif i < 5 then
             result := x"34"; -- 4
        elsif i < 6 then
             result := x"35"; -- 5
        elsif i < 7 then
             result := x"36"; -- 6
        elsif i < 8 then
             result := x"37"; -- 7
        elsif i < 9 then
             result := x"38"; -- 8
        else
             result := x"39"; -- 9
        end if;
        return result;
    end get_ascii_array_from_int_ones;
    
function get_ascii_array_from_int_tens (i : integer range 0 to 99) return char_array is
    variable result : char_array (1 downto 0) := (x"30", x"30"); -- 00
    begin
        if i < 10 then
             result(0) := x"30"; -- 0
             result(1) := get_ascii_array_from_int_ones(i);
        elsif i < 20 then
             result(0) := x"31"; -- 1
             result(1) := get_ascii_array_from_int_ones(i-10);
        elsif i < 30 then
             result(0) := x"32"; -- 2
             result(1) := get_ascii_array_from_int_ones(i-20);
        elsif i < 40 then
             result(0) := x"33"; -- 3
             result(1) := get_ascii_array_from_int_ones(i-30);
        elsif i < 50 then
             result(0) := x"34"; -- 4
             result(1) := get_ascii_array_from_int_ones(i-40);
        elsif i < 60 then
             result(0) := x"35"; -- 5
             result(1) := get_ascii_array_from_int_ones(i-50);
        elsif i < 70 then
             result(0) := x"36"; -- 6
             result(1) := get_ascii_array_from_int_ones(i-60);
        elsif i < 80 then
             result(0) := x"37"; -- 7
             result(1) := get_ascii_array_from_int_ones(i-70);
        elsif i < 90 then
             result(0) := x"38"; -- 8
             result(1) := get_ascii_array_from_int_ones(i-80);
        else
             result(0) := x"39"; -- 9
             result(1) := get_ascii_array_from_int_ones(i-90);
        end if;
        return result;
    end get_ascii_array_from_int_tens;

function get_ascii_array_from_int_hundreds (i : integer range 0 to 999) return char_array is
    variable result : char_array (2 downto 0) := (x"30", x"30", x"30"); -- 000
    begin
        if i < 100 then
             result(0) := x"30"; -- 0
             result(2 downto 1) := get_ascii_array_from_int_tens(i);
        elsif i < 200 then
             result(0) := x"31"; -- 1
             result(2 downto 1) := get_ascii_array_from_int_tens(i-100);
        elsif i < 300 then
             result(0) := x"32"; -- 2
             result(2 downto 1) := get_ascii_array_from_int_tens(i-200);
        elsif i < 400 then
             result(0) := x"33"; -- 3
             result(2 downto 1) := get_ascii_array_from_int_tens(i-300);
        elsif i < 500 then
             result(0) := x"34"; -- 4
             result(2 downto 1) := get_ascii_array_from_int_tens(i-400);
        elsif i < 600 then
             result(0) := x"35"; -- 5
             result(2 downto 1) := get_ascii_array_from_int_tens(i-500);
        elsif i < 700 then
             result(0) := x"36"; -- 6
             result(2 downto 1) := get_ascii_array_from_int_tens(i-600);
        elsif i < 800 then
             result(0) := x"37"; -- 7
             result(2 downto 1) := get_ascii_array_from_int_tens(i-700);
        elsif i < 900 then
             result(0) := x"38"; -- 8
             result(2 downto 1) := get_ascii_array_from_int_tens(i-800);
        else
             result(0) := x"39"; -- 9
             result(2 downto 1) := get_ascii_array_from_int_tens(i-900);
        end if;
        return result;
    end get_ascii_array_from_int_hundreds;

function get_ascii_array_from_int(i : integer range -9999 to 9999) return char_array is
    variable result : char_array (4 downto 0) := (x"30", x"30", x"30", x"30", x"2B"); -- 0000
    variable i_neg : integer range -9999 to 9999;
    begin
        if i >= 0 then
            result(0) := x"2B";     -- +
            if i < 1000 then
                result(1) := x"30"; -- 0
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i);
            elsif i < 2000 then
                result(1) := x"31"; -- 1
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-1000);
            elsif i < 3000 then
                result(1) := x"32"; -- 2
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-2000);
            elsif i < 4000 then
                result(1) := x"33"; -- 3
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-3000);
            elsif i < 5000 then
                result(1) := x"34"; -- 4
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-4000);
            elsif i < 6000 then
                result(1) := x"35"; -- 5
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-5000);
            elsif i < 7000 then
                result(1) := x"36"; -- 6
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-6000);
            elsif i < 8000 then
                result(1) := x"37"; -- 7
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-7000);
            elsif i < 9000 then
                result(1) := x"38"; -- 8
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-8000);
            else
                result(1) := x"39"; -- 9
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-9000);
            end if;
        else
            result(0) := x"2D";     -- -
            --result := (x"6e", x"65", x"67", x"23"); -- "neg#" 
            i_neg := -i;
            if i_neg < 1000 then
                result(1) := x"30"; -- 0
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg);
            elsif i_neg < 2000 then
                result(1) := x"31"; -- 1
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-1000);
            elsif i_neg < 3000 then
                result(1) := x"32"; -- 2
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-2000);
            elsif i_neg < 4000 then
                result(1) := x"33"; -- 3
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-3000);
            elsif i_neg < 5000 then
                result(1) := x"34"; -- 4
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-4000);
            elsif i_neg < 6000 then
                result(1) := x"35"; -- 5
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-5000);
            elsif i_neg < 7000 then
                result(1) := x"36"; -- 6
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-6000);
            elsif i_neg < 8000 then
                result(1) := x"37"; -- 7
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-7000);
            elsif i_neg < 9000 then
                result(1) := x"38"; -- 8
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i_neg-8000);
            else
                result(1) := x"39"; -- 9
                result(4 downto 2) := get_ascii_array_from_int_hundreds(i-9000);
            end if;
        end if;

        return result;

    end get_ascii_array_from_int;
    
    function ascii_to_std_logic_vector (input : char_array) return std_logic_vector is
    variable size : integer range 0 to 32:= 0;
    variable aux  : integer := 0;
    variable mult  : integer := 0;
    variable neg  : std_logic := '0';
    variable number : integer := 0;
    variable output : signed (15 downto 0) := (others => '0');
    begin
    
    if input (0) = "00101101" then    -- "-" :=  "00101101";-- X"2D"
        --negative number
        neg := '1';
    end if;
    
    -- lenght calculation
    if neg = '1' then
        for i in 1 to 31 loop
            if (input(i) = "00001101") then      -- CR :=  "00001101";-- X"0D"
			     size := i-1;
			     exit;
		    elsif (input(i) < "00110000") or (input(i) > "00111001") then --i<"0" o i>"9"
                 -- error
                 size:= 0;
                 output:= (others => '1');
                 exit;
		     end if;
        end loop;
    elsif neg = '0' then
        for i in 0 to 31 loop
             if (input(i) = "00001101") then      -- CR :=  "00001101";-- X"0D"
			     size := i;
			     exit;
		     elsif (input(i) < "00110000") or (input(i) > "00111001") then --i<"0" o i>"9"
                 -- error
                 size:= 0;
                 --output:= (others => '1');
                 output:= to_signed(-32767,16);
                 exit;
		      end if;
        end loop;
    end if;
    
    -- acumulation
    -- from -32000 to 32000
    if neg = '0' then
        --0x"30" is 0 is 48d
        if size > 0 then
            for i in 0 to 31 loop
                if (input(i) /= "00001101") then --until "CR" to make sintetizable loop
                    --aux := 10**(size-i);
                    aux := size-i-1;
                    if aux = 0 then
                        mult:=1;
                    elsif aux = 1 then
                        mult:=10;
                    elsif aux = 2 then
                        mult:=100;
                    elsif aux = 3 then
                        mult:=1000;
                    elsif aux = 4 then
                        mult:=10000;
                    elsif aux = 5 then
                        mult:=100000;
                    elsif aux = 6 then
                       mult:=1000000;
                    else 
                        mult:=0;
                    end if;                  
                    number := to_integer(unsigned(input(i)))-48;
                    output := output + (number * mult);
                 else
                    exit;
                 end if;
            end loop;
         end if;
    elsif neg = '1' then
         --0x"30" is 0 is 48d
        if size > 0 then
            for i in 1 to 31 loop
                if (input(i) /= "00001101") then --until "CR" to make sintetizable loop
                --aux := 10**(size-i);
                    aux := size-i;
                    if aux = 0 then
                       mult:=1;
                    elsif aux = 1 then
                        mult:=10;
                    elsif aux = 2 then
                        mult:=100;
                    elsif aux = 3 then
                        mult:=1000;
                    elsif aux = 4 then
                        mult:=10000;
                    elsif aux = 5 then
                        mult:=100000;
                    elsif aux = 6 then
                        mult:=1000000;
                    else 
                        mult:=0;
                    end if;                  
                    number := to_integer(unsigned(input(i)))-48;
                    output := output + (number * mult);
                else
                    exit;
                end if;
            end loop;
         end if;
         output := -output;
    end if;
        
    return std_logic_vector(output);
    
end ascii_to_std_logic_vector;
 
end package body integer_to_ascii;
