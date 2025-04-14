"""
CS3810: Principles of Database Systems
Instructor: Thyago Mota
Student(s): Fin Martinez
Description: A data load script for the IPPS database
"""

import psycopg2
import configparser as cp
import csv
import os

config = cp.RawConfigParser()
config.read('ConfigFile.properties')
params = dict(config.items('db'))
filepath = '/Users/finmartinez/Code/CS3810/23SCS3810/db_02_ipps/build/data/MUP_IHP_RY22_P02_V10_DY20_PrvSvc.csv'
file_object = csv.reader(open(filepath))

conn = psycopg2.connect(**params)
if conn: 
    print('Connection to Postgres database ' + params['dbname'] + ' was successful!')
    cur = conn.cursor()
    if os.path.isfile(filepath):

        #counts to track load progress
        entry_count = 0
        row_count = len(list(file_object))
        ipps = csv.DictReader(open(filepath), delimiter=',', quotechar='"')
        for row in ipps:
            providers_sql = '''INSERT INTO Providers VALUES (%s, %s, %s, %s, %s, %s)
                               ON CONFLICT (Rndrng_Prvdr_CCN) DO UPDATE
                               SET Rndrng_Prvdr_Org_Name = EXCLUDED.Rndrng_Prvdr_Org_Name;'''
            cur.execute(providers_sql, (row['Rndrng_Prvdr_CCN'],row['Rndrng_Prvdr_Org_Name'],row['Rndrng_Prvdr_St'],
                               row['Rndrng_Prvdr_City'],row['Rndrng_Prvdr_State_Abrvtn'],row['Rndrng_Prvdr_Zip5']))
            conn.commit()

            diagnoses_sql = '''INSERT INTO Diagnoses VALUES (%s, %s, %s)
                               ON CONFLICT (DRG_cd) DO UPDATE
                               SET DRG_Desc = EXCLUDED.DRG_Desc;'''
            cur.execute(diagnoses_sql, (row['DRG_Cd'], row['DRG_Desc'], row['Tot_Dschrgs']))
            conn.commit()

            procedures_sql = "INSERT INTO Procedures VALUES (%s, %s, %s);"
            cur.execute(procedures_sql, (row['DRG_Cd'], row['Rndrng_Prvdr_CCN'], row['Tot_Dschrgs']))
            conn.commit()

            provider_fips_sql = '''INSERT INTO Provider_FIPs VALUES (%s, %s)
                                   ON CONFLICT (Rndrng_Prvdr_State_Abrvtn, Rndrng_Prvdr_State_FIPS) DO UPDATE
                                   SET Rndrng_Prvdr_State_Abrvtn = EXCLUDED.Rndrng_Prvdr_State_Abrvtn;'''
            cur.execute(provider_fips_sql, (row['Rndrng_Prvdr_State_Abrvtn'], row['Rndrng_Prvdr_State_FIPS']))
            conn.commit()

            provider_rucas_sql = '''INSERT INTO Provider_RUCAs VALUES (%s, %s, %s)
                                    ON CONFLICT (Rndrng_Prvdr_Zip5) DO UPDATE
                                    SET Rndrng_Prvdr_Zip5 = EXCLUDED.Rndrng_Prvdr_Zip5;'''
            cur.execute(provider_rucas_sql, (row['Rndrng_Prvdr_Zip5'], row['Rndrng_Prvdr_RUCA'], row['Rndrng_Prvdr_RUCA_Desc']))
            conn.commit()

            covered_charges_sql = "INSERT INTO Covered_Charges VALUES (%s, %s, %s);"
            cur.execute(covered_charges_sql, (row['DRG_Cd'], row['Rndrng_Prvdr_CCN'], float(row['Avg_Submtd_Cvrd_Chrg'])))
            conn.commit()

            medicare_payments_sql = "INSERT INTO Medicare_Payments VALUES (%s, %s);"
            cur.execute(medicare_payments_sql, (row['DRG_Cd'], float(row['Avg_Mdcr_Pymt_Amt'])))
            conn.commit()

            total_payment_amounts = "INSERT INTO Total_Payment_Amounts VALUES (%s, %s, %s);"
            cur.execute(total_payment_amounts, (row['DRG_Cd'], float(row['Avg_Mdcr_Pymt_Amt']), float(row['Avg_Tot_Pymt_Amt'])))
            conn.commit()
            entry_count += 1
            progress = round((entry_count/row_count)*100, 2)
            print(' Data Load ' + str(progress) + '% Complete ', end='\r')

    print('\nData load successfull!')
    conn.close()
