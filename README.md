# Introduction

The Centers for Medicare and Medicaid Services (CMS) is a U.S. agency that administers the Medicare program and works in partnership with state governments to administer Medicaid. CMS makes health related data available to the public through its website [data.cms.gov](https://data.cms.gov). In this assignment you will use their IPPS dataset that contains hospital charge data. More specifically, the IPPS dataset contains information about 2020 charges of top 536 groups of similar clinical conditions (diagnosis) by different health providers in the U.S. and the correspondent amounts covered by health insurance.  What is interesting about the IPPS dataset is that it shows how the same treatment for a clinical condition can result in very different costs for patients depending on the health care provider. 

# Data Model 

The IPPS dataset has 165,281 rows and 15 columns.  The goal of this assignment is for you to normalize this dataset into a Postgres database called **ipps**. The **ipps** database has to be designed so that all of its tables are normalized up to 3NF (third normal form). All Data Definition Language (DDL) SQL statements (CREATE DATABASE and CREATE TABLE statements) and DCL (Data Control Language) statements (CREATE USER, GRANT statements) should be submitted in a file named **ipps.sql**.  In summary, all ipps’s tables of your database should be normalized up to 3NF, have primary keys, and appropriate foreign keys with referential integrity constraints in place. You should also create a user named **ipps** with full control of all tables in the **ipps** database.  

The attributes used in your **ipps** database MUST preserve the column names of the **ipps** dataset. Below is a detailed description of each of the columns and their meaning of the **ipps** dataset (also [here](https://data.cms.gov/resources/medicare-inpatient-hospitals-by-provider-and-service-data-dictionary)): 

* Rndrng_Prvdr_CCN: The CMS Certification Number (CCN) of the provider billing for outpatient hospital services.
* Rndrng_Prvdr_Org_Name: The name of the provider.
* Rndrng_Prvdr_St: The street address in which the provider is physically located.
* Rndrng_Prvdr_City: The city in which the provider is physically located.
* Rndrng_Prvdr_State_Abrvtn: The state abbreviation for the state in which the provider is physically located.
* Rndrng_Prvdr_State_FIPS: The state FIPS code for the state in which the provider is physically located.
* Rndrng_Prvdr_Zip5: The zip code in which the provider is physically located.
* Rndrng_Prvdr_RUCA: The Rural-Urban Commuting Area (RUCA) code for the zip code in which the provider is physically located.
* Rndrng_Prvdr_RUCA_Desc: The description of the RUCA code.
* DRG_Cd: Classification system that groups similar clinical conditions (diagnoses) and the procedures furnished by the hospital during the stay.
* DRG_Desc: Description of the classification system (DRG) that groups similar clinical conditions (diagnoses) and the procedures furnished by the hospital during the stay.
* Tot_Dschrgs: The number of discharges billed by all providers for inpatient hospital services.
* Avg_Submtd_Cvrd_Chrg: The average charge of all providers' services covered by Medicare for discharges in the DRG. In other words: **what the provider billed Medicare (on average) for the diagnosis**.  
* Avg_Tot_Pymt_Amt: The average total payments to all providers for the DRG including the MS-DRG amount, teaching,  disproportionate share, capital, and outlier payments for all cases. In other words: **what Medicare actually paid (on average) for the diagnosis, including amounts paid by the patients**. 
* Avg_Mdcr_Pymt_Amt: The average amount that Medicare pays to the provider for Medicare's share of the MS-DRG. In other words: **what Medicare actually paid (on average) for the diagnosis, NOT including amounts paid by the patients**.

# Data Load Script

In order to load the **ipps** dataset into your (normalized) **ipps** database you are asked to write a data load script in Python. This program should be named **ipps.py** and it is the second deliverable of this assignment. Data access secrets (user and password) should be protected in the code using a **ConfigFile.properties** file. SQL statements should be written as **prepared statements** to follow good coding practices. Also, you MUST use the **psycopg2** module to connect to the database. 

Please note that you are not allowed to pre-process or modify the CSV file using an external program, like a spreadsheet application, for example.  To be clear: I will test your data load program using the **ipps** dataset. The CSV file should be the MUP_IHP_RY22_P02_V10_DY20_PrvSvc.csv. Because this file is large and it can be downloaded from the internet, there is no need to submit it through Canvas.  

# Queries 
 
Your final task in this project is to answer the following queries using SQL. Write your answers to all queries updating the **ipps.sql** file.  

* List all diagnosis in alphabetical order.    
* List the names and correspondent states (including Washington D.C.) of all of the providers in alphabetical order (state first, provider name next, no repetition).    
* List the total number of providers.   
* List the total number of providers per state (including Washington D.C.) in alphabetical order (also printing out the state).    
* List the providers names in Denver (CO) or in Lakewood (CO) in alphabetical order  
* List the number of providers per RUCA code (showing the code and description) 
* Show the DRG description for code 308 
* List the top 10 providers (with their correspondent state) that charged (as described in Avg_Submtd_Cvrd_Chrg) the most for the DRG code 308. Output should display the provider name, their city, state, and the average charged amount in descending order.   
* List the average charges (as described in Avg_Submtd_Cvrd_Chrg) of all providers per state for the DRG code 308. Output should display the state and the average charged amount per state in descending order (of the charged amount) using only two decimals.    
* Which provider and clinical condition pair had the highest difference between the amount charged (as described in Avg_Submtd_Cvrd_Chrg) and the amount covered by Medicare only (as described in Avg_Mdcr_Pymt_Amt)?   

# Submission 

You must zip **ipps.sql** and *ipps.py** into **ipps.zip** that should have the following structure: 

```
ipps.zip
|__ipps.sql
|__ipps.py
```

Make sure you add your name (and of your partner) in the comments section of both files (sql and python source code).  If working together, only one of you needs to submit on canvas. 

# Grading 

```
+25 Normalization
+10 Tables Creation
+5 Users Creation and Access 
+35 Data Load Script
+25 Queries
-5 didn't write your names in the comments sections of sql and python script
-5 didn't submit a zip file in the correct format
-10 have secrets hard-coded in the python script
-5 didn't use prepared statement when writing insert statements
```