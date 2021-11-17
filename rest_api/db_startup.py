from models import CompletedSurveys, OngoingSurveys, ParticipantDevice, ParticipantStudy, Study, StudySurveys
from sqlalchemy import create_engine, inspect
from credentials import db_string

# Access DB
db = create_engine(db_string)
inspector = inspect(db)

# Get table names
tables = inspector.get_table_names()

# Create tables if not exist
if not CompletedSurveys.CompletedSurveys.__tablename__ in tables:
    CompletedSurveys.Base.metadata.create_all(db)

if not OngoingSurveys.OngoingSurveys.__tablename__ in tables:
    OngoingSurveys.Base.metadata.create_all(db)

if not ParticipantDevice.ParticipantDevice.__tablename__ in tables:
    ParticipantDevice.Base.metadata.create_all(db)

if not ParticipantStudy.ParticipantStudy.__tablename__ in tables:
    ParticipantStudy.Base.metadata.create_all(db)

if not Study.Study.__tablename__ in tables:
    Study.Base.metadata.create_all(db)

if not StudySurveys.StudySurveys.__tablename__ in tables:
    StudySurveys.Base.metadata.create_all(db)