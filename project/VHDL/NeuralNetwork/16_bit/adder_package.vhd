library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_signed.all;

package adder_package is

CONSTANT c_size : INTEGER := 16;
CONSTANT N : INTEGER := 2; -- n= # of MAC's (Inputs in each node).,
CONSTANT M : INTEGER := 16; -- m= # of bits of input and coef.
CONSTANT K : INTEGER := 2; -- k= # of Nodes / Layer.,
CONSTANT L : INTEGER := 1; -- l= # of Layers.,
CONSTANT p_size : INTEGER := 5; -- # of inputs to first layer.,
TYPE FIRSTINPUTARRAY IS ARRAY (p_size-1 DOWNTO 0) OF SIGNED(M-1 DOWNTO 0);
TYPE INPUTARRAY IS ARRAY (K-1 DOWNTO 0) OF SIGNED(M-1 DOWNTO 0);
TYPE INPUTMATRIX IS ARRAY (L-1 DOWNTO 0) OF INPUTARRAY;
TYPE INPUTMATRIXARRAY IS ARRAY (L-1 DOWNTO 0) OF INPUTMATRIX;
TYPE WEIGHTINPUTARRAY IS ARRAY (K-1 DOWNTO 0) OF SIGNED(M-1 DOWNTO 0);
TYPE WEIGHTINPUTMATRIX IS ARRAY (L-1 DOWNTO 0) OF SIGNED(M-1 DOWNTO 0);
    
COMPONENT full_adder is
    Port ( A : 	in STD_LOGIC; 		-- First input
           B : 	in STD_LOGIC; 		-- Second input
           CIN :in STD_LOGIC; 		-- Carry in
           COUT : out STD_LOGIC; 	-- Carry out
           S : out STD_LOGIC); 		-- Adder out
END COMPONENT; 

COMPONENT AdderBlock IS
    PORT ( adderA : in STD_LOGIC;   -- first input for the full adder
           adderB : in STD_LOGIC;   -- second imput for the full adder
           andA : in STD_LOGIC;     -- first input for the and gate
           andB : in STD_LOGIC;     -- second imput for the and gate
           sum : out STD_LOGIC;     -- the sum output
           carry : out STD_LOGIC);  -- the carry output
END COMPONENT;

COMPONENT multiplier IS
    generic(N : INTEGER := c_size);                             -- Sets the multiplier to 16 bit default
    PORT( a ,b : in SIGNED;       
		  p : out SIGNED); 
END COMPONENT multiplier;

END package adder_package;

----------------------------------------------
-------------- 2-bit full-adder --------------
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY full_adder IS
    Port ( A : 	in STD_LOGIC; 		-- First input
           B : 	in STD_LOGIC; 		-- Second input
           CIN :in STD_LOGIC; 		-- Carry in
           COUT : out STD_LOGIC; 	-- Carry out
           S : out STD_LOGIC); 		-- Adder out
END full_adder;


ARCHITECTURE dataflow of full_adder IS

	-- intermediate signal declaration
	signal q1, q2, q3 : STD_LOGIC;

BEGIN
	
	-- internal signals
	q1 <= A xor B;
	q2 <= q1 and CIN;
	q3 <= A and B;

	-- output
	S <= q1 xor CIN;
	COUT <= q2 or q3;

END ARCHITECTURE; -- dataflow

--------------------------------------------
----------------- AdderBlock ---------------
--------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY AdderBlock IS
    PORT ( adderA : in STD_LOGIC;   -- first input for the full adder
           adderB : in STD_LOGIC;   -- second imput for the full adder
           andA : in STD_LOGIC;     -- first input for the and gate
           andB : in STD_LOGIC;     -- second imput for the and gate
           sum : out STD_LOGIC;     -- the sum output
           carry : out STD_LOGIC);  -- the carry output
END AdderBlock;

ARCHITECTURE adderBlockDataFlow of AdderBlock IS
    
    COMPONENT full_adder IS
    PORT ( A :     in STD_LOGIC;         -- First input
           B :     in STD_LOGIC;         -- Second input
           CIN :in STD_LOGIC;         -- Carry in
           COUT : out STD_LOGIC;     -- Carry out
           S : out STD_LOGIC);         -- Adder out);
    END COMPONENT;
    
    signal q1 : STD_LOGIC;

BEGIN
    q1 <= andA AND andB;
    
    G1 : full_adder PORT MAP(adderA, adderB, q1, carry, sum);

END adderBlockDataFlow;

----------------------------------------------
----------------- Multiplier -----------------
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_signed.all;

ENTITY multiplier IS
    generic(N : INTEGER := 4);                             -- Sets the multiplier to 16 bit default
	port( a ,b : in SIGNED  (N-1  DOWNTO  0);       
		  p : out SIGNED  (N+N-1  DOWNTO  0)); 
END multiplier; 

ARCHITECTURE multiarch of multiplier IS
	
	-- just the full adder component
    COMPONENT full_adder IS
        Port ( A :  in STD_LOGIC;       -- First input
               B :  in STD_LOGIC;       -- Second input
               CIN : in STD_LOGIC;      -- Carry in
               COUT : out STD_LOGIC;    -- Carry out
               S : out STD_LOGIC);      -- Adder out
    END COMPONENT;

    -- block with both AND-gate and full adder
	COMPONENT AdderBlock IS
	    port ( adderA : in STD_LOGIC;   -- first input for the full adder
	           adderB : in STD_LOGIC;   -- second imput for the full adder
	           andA : in STD_LOGIC;     -- first input for the and gate
	           andB : in STD_LOGIC;     -- second imput for the and gate
	           sum : out STD_LOGIC;     -- the sum output
	           carry : out STD_LOGIC);  -- the carry output
	END COMPONENT;

    -- signals for all regular adderblocks defined as matrices
    type matrix is array (0 to N-1) of SIGNED(N-1 downto 0); 
    SIGNAL sumIn : matrix;
    SIGNAL carryIn : matrix;
    SIGNAL sum : matrix;
    SIGNAL carry : matrix;
    
    -- input output signals for the bottom adderblocks
    SIGNAL bottomSumIn : SIGNED(0 to N-1);
    SIGNAL bottomSumOut : SIGNED(0 to N-1);
    SIGNAL bottomCarryIn : SIGNED(0 to N-1);
    SIGNAL bottomCarryOut : SIGNED(0 to N-1);
    SIGNAL bottomCarryIn2 : SIGNED(0 to N-1);

BEGIN
	
	-- generates all regular adderblocks
    a_loop : for i in 0 to N-1 generate
        b_loop : for j in 0 to N-1 generate
            AB : AdderBlock PORT MAP(adderA => sumIn(i)(j), 
                                     adderB => carryIn(i)(j),
                                     andA => a(i),
                                     andB => b(j),
                                     sum => sum(i)(j),
                                     carry => carry(i)(j));
        END generate;
    END generate;
    
    -- generates the bottom most adderblocks which are just basicly adders
    final_row_loop : for j in 0 to N-2 generate
        bottomAB : AdderBlock PORT MAP( adderA => bottomSumIn(j), 
                                        adderB => bottomCarryIn(j),
                                        andA => bottomCarryIn2(j),
                                        andB => bottomCarryIn2(j),
                                        sum => bottomSumOut(j),
                                        carry => bottomCarryOut(j));
    END generate;
    
    -- Initializes all sum ins on the top most adderblocks to 0
    init_sumIn : for j in 0 to N-1 generate
        sumIn(0)(j) <= '0';
    END generate;
    
    -- Sets the connection for all sum ins as the upper left adjecent adderblock
    sumIn_a_loop : for i in 1 to N-1 generate
        sumIn_b_loop : for j in 0 to N-2 generate
            sumIn(i)(j) <= sum(i-1)(j+1);
        end generate;
        sumIn(i)(N-1) <= '0'; -- Sets the left most adderblocks sum in to 0
    END generate;
    
    -- Sets all carry ins to the upper adjecent adderblock carry out
    carryIn_b_loop : for j in 0 to N-1 generate
        carryIn(0)(j) <= '0';                   -- sets the uppermost adderblcks carry in to 0
        carryIn_a_loop : for i in 1 to N-1 generate
            carryIn(i)(j) <= carry(i-1)(j);
        END generate;
    END generate;
    
    --  Sets product out to sum out om the coresponding adderblock upp to N-1
    p_a_loop : for i in 0 to N-1 generate
        p(i) <= sum(i)(0);
    END generate;
    
    -- sets the second carry in on the bottom adderblocks to the right carry out
    bottomCarryIn2(0) <= '0';                       -- Sets the ritghtmost adderblocks second carry in to 0
    bottom_carryIn2_loop : for j in 1 to N-2 generate
            bottomCarryIn2(j) <= carry(N-1)(j-1);
    END generate;

    -- Sets the sum in for the bottom adderblocks to the upper left adjecent adderblock sum out
    -- Sets the carry in for bottom adderblocks to the upper adjecent adderblock carry out
    -- Finally sets the product out to the sum of the coresponding upper adderblock
    p_b_loop : for j in 0 to N-2 generate
            bottomSumIn(j) <= sum(N-1)(j+1);
            bottomCarryIn(j) <= carry(N-1)(j);
            
            p(N+j) <= bottomSumOut(j);
    END generate;
    p(N+N-1) <= bottomCarryOut(N-2); -- Sets the last product bit to the carry out from the leftmost bottom adderblock
	
END architecture; -- multiarch
