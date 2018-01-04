LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_signed.all;
USE work.adder_package.all;

PACKAGE MAC_Package IS
COMPONENT MAC_Unit IS
    GENERIC (size : INTEGER := c_size);
    PORT( xIn, weightIN: IN SIGNED (size-1 DOWNTO 0);
          acc: IN SIGNED(size+size-1 DOWNTO 0);
          clk, rst: IN STD_LOGIC;
          weightOUT: OUT SIGNED (size-1 DOWNTO 0);
          sum: OUT SIGNED (size+size-1 DOWNTO 0));
END COMPONENT MAC_Unit;

FUNCTION truncate (SIGNAL a, b: SIGNED; size: INTEGER) RETURN SIGNED;
FUNCTION convPosToNeg(SIGNAl a: SIGNED; size: integer) RETURN SIGNED;
FUNCTION truncateSingle (SIGNAL a: SIGNED; size: integer) RETURN SIGNED;

END PACKAGE MAC_Package;
------------------- Package body declarations
PACKAGE BODY MAC_Package IS
FUNCTION truncate (SIGNAL a, b: SIGNED; size: integer) RETURN SIGNED IS
VARIABLE result: SIGNED(size downto 0);
    BEGIN   
        result := a + b;
        IF(a(a'high) = b(b'high)) THEN
            IF(result(result'high) /= a(a'high)) THEN
                IF(a(a'high) = '0') THEN
                    result := (result'high => '0', others => '1');
                   -- result := "01111111";
                ELSE
                    result := (result'high => '1', others => '0');
                    --result := "10000000";
                END if;
            END if;
        END if;       
    RETURN result;
END function truncate;
FUNCTION convPosToNeg(SIGNAL a: SIGNED; size: integer)RETURN SIGNED IS
 VARIABLE result: SIGNED(size downto 0);
 VARIABLE b: UNSIGNED(size downto 0);
 BEGIN
     b := UNSIGNED(a);
     b := b-1;
     FOR i in 0 to b'high loop
         IF(b(i) = '1') THEN
             result(i) := '0';
         ELSE
             result(i):= '1';
         END if;
     END loop;
     RETURN  result;
 END FUNCTION convPosToNeg; 
 FUNCTION truncateSingle (SIGNAL a: SIGNED; size: integer) RETURN SIGNED IS
 VARIABLE result: SIGNED(size downto 0);
     BEGIN   
         result := a;
         IF(a(a'high) = '1') THEN
            result := "1000";
         ELSE
            result := "0111";
         END if;       
     RETURN result;
 END function truncateSingle;
END package body MAC_Package;
