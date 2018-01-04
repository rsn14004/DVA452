LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;
USE work.adder_Package.all;

PACKAGE NODE_PACKAGE IS

COMPONENT NODE
      PORT (x: IN INPUTARRAY;
            weightIn: IN SIGNED(M-1 DOWNTO 0);
            weightOut: OUT SIGNED(M-1 DOWNTO 0);
            clk, rst: IN STD_LOGIC;
            y: OUT SIGNED(M-1 DOWNTO 0));
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


ENTITY NODE IS
    PORT (x: IN INPUTARRAY;
          weightIn: IN SIGNED(M-1 DOWNTO 0);
          weightOut: OUT SIGNED(M-1 DOWNTO 0);
          clk, rst: IN STD_LOGIC;
          y: OUT SIGNED(M-1 DOWNTO 0));
END NODE;

ARCHITECTURE NN of NODE IS

    TYPE matrixWeight is array (0 to N-1) of SIGNED(M-1 DOWNTO 0); 
    SIGNAL weightsIN : matrixWeight;   -- Holds the weight inputs for each MAC
    SIGNAL weightsOut : matrixWeight;     -- Holds the weight outputs for each MAC
    
    TYPE matrix is array (0 to N-1) of SIGNED(M+M-1 DOWNTO 0); 
    SIGNAL sum : matrix;        -- Holds the sum outputs for each MAC
    SIGNAL acc : matrix;        -- Holds the acc input for each MAC
    
    SIGNAL node_out : SIGNED(M-1 DOWNTO 0);
    SIGNAL mac_to_lut : SIGNED(M+M-1 DOWNTO 0);

BEGIN
    
    -- Generates each MAC in the Node
    mac_loop : for i in 0 to K-1 generate
        MU : MAC_Unit port map( xIn => x(i), 
                                weightIN => weightsIN(i), 
                                acc => acc(i),
                                clk => clk, 
                                rst => rst,
                                weightOUT => weightsOUT(i),
                                sum => sum(i));
    END generate;

        MU : LUT port map( x => mac_to_lut,
                           y => node_out);

    weightOut <= weightsOut(N-1);
    weightsIN(0) <= weightIn;                -- Sets the first MACs weight input to the node's weight input.
    acc(0) <= (others => '0');  -- Sets the first MACs acc input to zeros 
    y <= node_out;
    mac_to_lut <= sum(N-1);
    
    -- Generates all the connections between each MAC
    q_loop : for i in 1 to N-1 generate
        weightsIN(i) <= weightsOUT(i-1);
        acc(i) <= sum(i-1);
    END generate;
    
END NN;
