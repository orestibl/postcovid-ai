import sys
import os
import pandas as pd
from sqlalchemy import create_engine, Table, Column, MetaData, Text, insert

from sqlalchemy.dialects.postgresql import ENUM
from sklearn.preprocessing import MinMaxScaler
from datetime import datetime, timedelta




def get_engine_connection():
    return create_engine(
        "postgresql+psycopg2://postgres:postgres@indicators:5432/postcovid_indicators"
    )

if __name__ == "__main__":

    try:
        print(f"Connecting to database")
        conn = get_engine_connection()
    except Exception as e:
        print(f"An error occurred while obtaining connection to database: {e}")

    try:
        print("Starting data ingestion")
        
        estudio1 = pd.read_csv('csv/initial_survey_estudio_1.csv')
        estudio1 = estudio1[['participant', 'age', 'gender', 'income', 'postcode']]
        estudio1.rename(columns={"participant": "id", "postcode": "zip_code"}, inplace=True)

        # Calculate birth year based on age
        estudio1['age'] = datetime.now().year - estudio1['age']

        # Create birth_date column with January 1 as the birth date
        estudio1['age'] = pd.to_datetime(estudio1['age'].astype(str) + '-01-01')

        estudio1 = estudio1.rename(columns={'age': 'birth_date'})

        estudio2 = pd.read_csv('csv/initial_survey_estudio_2.csv')
        estudio2 = estudio2[['participant', 'birth_year', 'gender', 'income', 'postcode']]
        estudio2.rename(columns={"participant": "id", "postcode": "zip_code"}, inplace=True)
        # Convert birth_year to birth_date with January 1 as the birth date
        estudio2['birth_year'] = pd.to_datetime(estudio2['birth_year'].astype(str) + '-01-01')

        # Drop the birth_year column as it's no longer needed
        estudio2 = estudio2.rename(columns={'birth_year': 'birth_date'})
        
        estudio1['studyId'] = 'aFeH8'
        estudio2['studyId'] = 'H39eC'

        indicadores = pd.read_csv('/app/csv/indicators.csv')

        indicadores.rename(columns={"study_id": "studyId", "participant": "participantId", "indicator_id": "indicatorNameId"}, inplace=True)

        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(2, 6)

        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(1, 2)
        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(4, 2)

        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(5, 1)

        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(3, 4)
        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(7, 4)

        indicadores['indicatorNameId'] = indicadores['indicatorNameId'].replace(6, 3)

        scaler = MinMaxScaler(feature_range=(0, 100))# Define the original values


        indicadores.loc[indicadores['indicatorNameId'] == 1, 'value'] = scaler.fit_transform(indicadores.loc[indicadores['indicatorNameId'] == 1, 'value'].values.reshape(-1, 1))
        indicadores.loc[indicadores['indicatorNameId'] == 2, 'value'] = scaler.fit_transform(indicadores.loc[indicadores['indicatorNameId'] == 2, 'value'].values.reshape(-1, 1))
        indicadores.loc[indicadores['indicatorNameId'] == 3, 'value'] = scaler.fit_transform(indicadores.loc[indicadores['indicatorNameId'] == 3, 'value'].values.reshape(-1, 1))
        indicadores.loc[indicadores['indicatorNameId'] == 4, 'value'] = scaler.fit_transform(indicadores.loc[indicadores['indicatorNameId'] == 4, 'value'].values.reshape(-1, 1))

        indicator_name = pd.DataFrame(columns=['name'])
        indicator_name['name'] = ['social_interaction', 'physical_activity', 'emmotional_state', 'overall_wellbeing']


        criterion = pd.DataFrame(columns=['name', 'nature'])
        criterion['name'] = ['gender', 'income', 'zip_code', 'age']
        # Define the mapping
        criterion['nature'] = [1, 1, 1, 0]
        
        
        studies = pd.DataFrame({
        'id': ['aFeH8', 'H39eC'],
        'name': ['Estudio 1', 'Estudio 2'],
        'description': ['Estudio 1', 'Estudio 2']})

        estudio1['zip_code'] = estudio1['zip_code'].fillna(0)
        estudio2['zip_code'] = estudio2['zip_code'].fillna(0)

        # Convert 'zip_code' column to string in estudio1 and estudio2
        estudio1['zip_code'] = estudio1['zip_code'].astype(int).astype(str)
        estudio2['zip_code'] = estudio2['zip_code'].astype(int).astype(str)
       

        studies.to_sql('study', conn, if_exists='append', index=False)
        criterion.to_sql('criterion', conn, if_exists='append', index=False)
        indicator_name.to_sql('indicator_name', conn, if_exists='append', index=False)
        estudio1.to_sql('participant', conn, if_exists='append', index=False)
        estudio2.to_sql('participant', conn, if_exists='append', index=False)
        indicadores.to_sql('indicator', conn, if_exists='append', index=False)
        
    except Exception as e:
        print(f"An error occurred while reading data from csv: {e}")

    # indicators = indicators.rename(columns={"study_id": "studyId", "indicator_id": "indicatorNameId", "participant": "participantId"})
    
    # print(f'Columns: {df.columns} ')

    # print(f'Participants: {df.participantId.nunique()}')

    # Group by studyId and create a DataFrame with participantId as columns
    # participant_columns = df.groupby('studyId')['participantId'].unique().apply(pd.Series)
    
    # sv = df.groupby("studyId").participantId.unique().reset_index()
    
    # participant_columns = participant_columns.applymap(lambda x: f'"{x}"' if pd.notnull(x) else x)

    # participant_columns.to_csv(f'/app/csv/{sys.argv[1]}_participants.csv')
    
    # print(participant_columns.head())
    