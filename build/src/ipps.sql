-- CS3810: Principles of Database Systems
-- Instructor: Thyago Mota
-- Student(s): Fin Martinez
-- Description: IPPS database

DROP DATABASE ipps;

CREATE DATABASE ipps;

\c ipps

-- create tables
CREATE TABLE Providers(
    rndrng_prvdr_CCN CHAR(6) PRIMARY KEY,
    rndrng_prvdr_org_name VARCHAR(64) NOT NULL,
    rndrng_prvdr_st VARCHAR(64) NOT NULL,
    rndrng_prvdr_city VARCHAR(64) NOT NULL,
    rndrng_prvdr_state_abrvtn CHAR(2) NOT NULL,
    rndrng_prvdr_zip5 CHAR(5) NOT NULL
);

CREATE TABLE Diagnoses(
    drg_cd VARCHAR(3) PRIMARY KEY,
    drg_desc VARCHAR(255) NOT NULL,
    tot_discharges VARCHAR(5) NOT NULL
);

CREATE TABLE Procedures(
    drg_cd VARCHAR(3) NOT NULL,
    FOREIGN KEY (drg_cd) REFERENCES Diagnoses(drg_cd),
    rndrng_prvdr_CCN VARCHAR(6) NOT NULL,
    FOREIGN KEY (rndrng_prvdr_CCN) REFERENCES Providers(rndrng_prvdr_CCN),
    tot_discharges VARCHAR(5) NOT NULL
);

CREATE TABLE Provider_FIPS(
    rndrng_prvdr_state_abrvtn CHAR(2) NOT NULL,
    rndrng_prvdr_state_FIPS CHAR(2) NOT NULL,
    UNIQUE (rndrng_prvdr_state_abrvtn, rndrng_prvdr_state_FIPS)
);

CREATE TABLE Provider_RUCAs(
    rndrng_prvdr_zip5 CHAR(5) PRIMARY KEY,
    rndrng_prvdr_RUCA DECIMAL(3, 1) NOT NULL,
    rndrng_prvdr_RUCA_desc VARCHAR(255) NOT NULL
);

CREATE TABLE Covered_Charges(
    drg_cd VARCHAR(3) NOT NULL,
    FOREIGN KEY (drg_cd) REFERENCES Diagnoses(drg_cd),
    rndrng_prvdr_CCN VARCHAR(6) NOT NULL,
    FOREIGN KEY (rndrng_prvdr_CCN) REFERENCES Providers(rndrng_prvdr_CCN),
    avg_submtd_cvrd_chrg DECIMAL(16, 8) NOT NULL
);

CREATE TABLE Medicare_Payments(
    drg_cd VARCHAR(6) NOT NULL,
    FOREIGN KEY (drg_cd) REFERENCES Diagnoses(drg_cd),
    avg_mdcr_pymt_amt DECIMAL(16,8) NOT NULL
);

CREATE TABLE Total_Payment_Amounts(
    drg_cd VARCHAR(6) NOT NULL,
    FOREIGN KEY (drg_cd) REFERENCES Diagnoses(drg_cd),
    avg_mdcr_pymt_amt DECIMAL(16,8) NOT NULL,
    avg_tot_pymnt_amt DECIMAL(16,8) NOT NULL
);

-- create user with appropriate access to the tables
CREATE USER ipps PASSWORD 'username';
ALTER USER ipps WITH SUPERUSER;

-- queries

-- a) List all diagnosis in alphabetical order.    
SELECT drg_desc AS drgDescription, drg_cd AS drgCode FROM Diagnoses
ORDER BY 1;

-- b) List the names and correspondent states (including Washington D.C.) of all of the providers in alphabetical order (state first, provider name next, no repetition). 
SELECT DISTINCT rndrng_prvdr_state_abrvtn AS providerState, rndrng_prvdr_org_name AS providerName FROM Providers
ORDER BY rndrng_prvdr_org_name;

-- c) List the total number of providers.
SELECT COUNT(rndrng_prvdr_CCN) AS count FROM Providers;

-- d) List the total number of providers per state (including Washington D.C.) in alphabetical order (also printing out the state).  
SELECT rndrng_prvdr_state_abrvtn AS state, COUNT(rndrng_prvdr_CCN) AS count FROM Providers
GROUP BY rndrng_prvdr_state_abrvtn
ORDER BY 1;

-- e) List the providers names in Denver (CO) or in Lakewood (CO) in alphabetical order
SELECT rndrng_prvdr_org_name AS providerName, rndrng_prvdr_city AS city, rndrng_prvdr_state_abrvtn AS state FROM Providers A
WHERE A.rndrng_prvdr_city = 'Denver' OR A.rndrng_prvdr_city = 'Lakewood' AND A.rndrng_prvdr_state_abrvtn = 'CO'
ORDER BY 1;   

-- f) List the number of providers per RUCA code (showing the code and description)
SELECT A.rndrng_prvdr_RUCA AS RUCA, A.rndrng_prvdr_RUCA_desc AS desc, COUNT(B.rndrng_prvdr_CCN) as count
FROM Provider_RUCAs A INNER JOIN Providers B
ON A.rndrng_prvdr_zip5 = B.rndrng_prvdr_zip5
GROUP BY A.rndrng_prvdr_RUCA, A.rndrng_prvdr_RUCA_desc
ORDER BY A.rndrng_prvdr_RUCA;

-- g) Show the DRG description for code 308
SELECT drg_cd AS drgCode, drg_desc AS description FROM Diagnoses
WHERE drg_cd = '308';

-- h) List the top 10 providers (with their correspondent state) that charged (as described in Avg_Submtd_Cvrd_Chrg) the most for the DRG code 308. Output should display the provider name, their city, state, and the average charged amount in descending order.   
SELECT DISTINCT A.rndrng_prvdr_org_name AS name, A.rndrng_prvdr_city AS city, A.rndrng_prvdr_state_abrvtn AS state, B.avg_submtd_cvrd_chrg AS avgChargedAmountFor308
FROM Providers A INNER JOIN Covered_Charges B
ON A.rndrng_prvdr_CCN = B.rndrng_prvdr_CCN
WHERE B.drg_cd = '308'
ORDER BY avgChargedAmountFor308 DESC
LIMIT 10;

-- i) List the average charges (as described in Avg_Submtd_Cvrd_Chrg) of all providers per state for the DRG code 308. Output should display the state and the average charged amount per state in descending order (of the charged amount) using only two decimals. 
SELECT A.rndrng_prvdr_state_abrvtn AS state, ROUND(AVG(B.avg_submtd_cvrd_chrg), 2) AS avgCharge
FROM Providers A INNER JOIN Covered_Charges B
ON A.rndrng_prvdr_CCN = B.rndrng_prvdr_CCN
WHERE B.drg_cd = '308'
GROUP BY A.rndrng_prvdr_state_abrvtn
ORDER BY avgCharge DESC;

-- j) Which provider and clinical condition pair had the highest difference between the amount charged (as described in Avg_Submtd_Cvrd_Chrg) and the amount covered by Medicare only (as described in Avg_Mdcr_Pymt_Amt)?
SELECT A.rndrng_prvdr_org_name AS provider, B.drg_cd AS code, B.avg_submtd_cvrd_chrg-C.avg_mdcr_pymt_amt AS difference
FROM Providers A INNER JOIN Covered_Charges B
ON A.rndrng_prvdr_CCN = B.rndrng_prvdr_CCN
INNER JOIN Medicare_Payments C
ON B.drg_cd = C.drg_cd
ORDER BY difference DESC
LIMIT 1;