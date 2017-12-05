library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED;

entity main is
    Generic(N : INTEGER := 15);
    Port (A, B : IN STD_LOGIC_VECTOR(N-1 downto 0);
          CLK : IN STD_LOGIC;
          S : OUT STD_LOGIC_VECTOR(N-1 downto 0));
end main;

architecture Behavioral of main is

COMPONENT c_addsub
  PORT (
    A : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    S : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END COMPONENT;

COMPONENT voter is
    Generic(N : INTEGER := 15);
    Port ( A : 	in STD_LOGIC_VECTOR(N-1 DOWNTO 0); 		-- First input
           B : 	in STD_LOGIC_VECTOR(N-1 DOWNTO 0); 		-- Second input
           CIN : in STD_LOGIC_VECTOR(N-1 DOWNTO 0); 	-- Carry in
           COUT : out STD_LOGIC_VECTOR(N-1 DOWNTO 0)); 	-- Carry out
end COMPONENT;


SIGNAL S1,S2,S3 : STD_LOGIC_VECTOR(14 DOWNTO 0);

begin

-- First instance of the adder
adder1 : c_addsub
  PORT MAP (
    A => A,
    B => B,
    CLK => CLK,
    CE => '1',
    S => S1
  );
  
-- Second instance of the adder
adder2 : c_addsub
    PORT MAP (
      A => A,
      B => B,
      CLK => CLK,
      CE => '1',
      S => S2
    );
	
-- Third instance of the adder
adder3 : c_addsub
  PORT MAP (
    A => A,
    B => B,
    CLK => CLK,
    CE => '1',
    S => S3
  );
  
-- Instance of the voter (Full adder)
  voter1 : voter
  PORT MAP  (
    A => S1,
    B => S2,
    CIN => S3,
    COUT => S);

end Behavioral;