LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;

USE work.NODE_Package.all;
USE work.adder_Package.all;

PACKAGE FIRST_LAYER_PACKAGE IS
      COMPONENT FIRST_LAYER
            PORT (x: IN FIRSTINPUTARRAY;
                  clk, rst: IN STD_LOGIC;
                  weightIn: IN SIGNED(M-1 DOWNTO 0);
                  weightOut: OUT SIGNED(M-1 DOWNTO 0);
                  y: OUT INPUTARRAY);
      END component;
END package;

-----------------------------------
----------Layer---------------------
-----------------------------------

library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.FIRST_NODE_Package.all;
USE work.MAC_Package.all;
USE work.FIRST_LAYER_Package.all;
USE work.adder_Package.all;

ENTITY FIRST_LAYER IS
      PORT (x: IN FIRSTINPUTARRAY;
      clk, rst: IN STD_LOGIC;
      weightIn: IN SIGNED(M-1 DOWNTO 0);
      weightOut: OUT SIGNED(M-1 DOWNTO 0);
      y: OUT INPUTARRAY);
END FIRST_LAYER;

ARCHITECTURE NN of FIRST_LAYER IS
    
    SIGNAL sum : INPUTARRAY;        -- Holds the sum outputs for each Node
    SIGNAL acc : FIRSTINPUTARRAY;        -- Holds the acc input for each Node
    SIGNAL weightsOut : WEIGHTINPUTARRAY;
    SIGNAL weightsIn : WEIGHTINPUTARRAY;
BEGIN
    -- Generates each Node in the Layer
    node_loop : for i in 0 to K-1 generate
        node_unit : FIRST_NODE port map(
                                x => acc,
                                weightIn => weightsIn(i),
                                weightOut => weightsOut(i),
                                clk => clk,
                                rst => rst,
                                y => sum(i));
    END generate;
    
    q_loop : for i in 1 to K-1 generate
        weightsIN(i) <= weightsOUT(i-1);
    END generate;
    
    weightsIn(0) <= weightIn;
    weightOut <= weightsOut(K-1);
    y <= sum;
    acc <= x;
    
END NN;
