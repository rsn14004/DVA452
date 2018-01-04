library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_signed.all;
USE work.adder_package.all;
USE work.MAC_Package.all;

ENTITY MAC_Unit IS
    GENERIC (size : INTEGER := c_size);
    PORT( xIn, weightIN: IN SIGNED (size-1 DOWNTO 0);
          acc: IN SIGNED(size+size-1 DOWNTO 0);
          clk, rst: IN STD_LOGIC := '0';
          weightOUT: OUT SIGNED (size-1 DOWNTO 0) := (others => '0');
          sum: OUT SIGNED (size+size-1 DOWNTO 0));
END MAC_Unit;

ARCHITECTURE Behavioral of MAC_Unit IS
    SIGNAL prod: SIGNED (size+size-1 DOWNTO 0);
    SIGNAL prodSum: SIGNED (size+size-1 DOWNTO 0);
    SIGNAL xInU : SIGNED(size-1 DOWNTO 0);   -- SIGNAL for convert negative number to positive
    SIGNAL weightU : SIGNED (size-1 DOWNTO 0);   -- SIGNAL for convert negative number to positive
    
BEGIN

    muli : multiplier port map (a => xInU,
                                    b => weightU,
                                    p => prod);

    -- Convert negative number to positive
    PROCESS (xIn, weightIN)
    BEGIN
        -- If the most significant bit in xIn is a one the whole xIn is converted
        IF(xIn(xIn'high) = '1') THEN
            xInU <= convPosToNeg(xIn, size-1);
        ELSE
            xInU  <= xIn;
        END IF;
        -- If the most significant bit in coef is a one the whole coef is converted
        IF(weightIN(weightIN'high) = '1') THEN
            weightU <= convPosToNeg(weightIN, size-1);
        ELSE
            weightU <= weightIN;
        END IF;
    END PROCESS;
    
    -- Sets the prodSum
    PROCESS(prod, xIn, weightIN)
    BEGIN
        -- If the most significant bit in xIn and weightIN is not the same the 
        -- product should be negative, so the prodSum is converted to negative number
        IF(xIn(xIn'high) /= weightIN(weightIN'high)) THEN
            prodSum <= convPosToNeg(prod, size+size-1);
        ELSE
            prodSum <= prod; -- if the product is not negative
        END IF;
    END PROCESS;
    
    -- Makes the addition and truncate for larger sums
    PROCESS(prodSum, acc)
    BEGIN
        Sum <= truncate(prodSum,acc, size+size-1); 
    END PROCESS;
    
    -- Flip-Flops the output of the MAC if the clock is high
    -- Resets the flip-flop is rst is one
    PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            weightOUT <= (others => '0');
        ELSIF (clk'EVENT AND CLK = '1') THEN
            weightOUT <= weightIN;
        END IF;
    END PROCESS;
END Behavioral;
