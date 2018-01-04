LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;
USE work.adder_Package.all;

PACKAGE OUTPUT_NODE_PACKAGE IS

COMPONENT OUTPUT_NODE
      PORT (x: IN INPUTARRAY;
            clk, rst: IN STD_LOGIC;
            y: OUT INPUTARRAY);
END component;

END package;

-----------------------------------
----------NODE---------------------
-----------------------------------

library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;

USE work.NODE_Package.all;
USE work.MAC_Package.all;
USE work.adder_package.all;
USE work.LUT_package.all;
USE work.OUTPUT_NODE_PACKAGE.all;

ENTITY OUTPUT_NODE IS
      PORT (x: IN INPUTARRAY;
      clk, rst: IN STD_LOGIC;
      y: OUT INPUTARRAY);
END OUTPUT_NODE;

ARCHITECTURE NN of OUTPUT_NODE IS

--SIGNAL output_index : INTEGER;
SIGNAL sum : INPUTARRAY;

begin

sum <= x;
y <= sum;
    
--y <= output_index;

--    PROCESS (x)
--    VARIABLE output_value : SIGNED(M-1 DOWNTO 0);
--    BEGIN
--        output_value := x(0);
--        output_index <= 0;
--        for i in 1 to K-1 loop
--            IF(x(i) > output_value) THEN
--                output_value := x(i);
--                output_index <= i;
--            END IF;
--        end loop;
--    END PROCESS;

END NN;
