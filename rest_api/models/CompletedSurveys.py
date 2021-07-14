from sqlalchemy import Column, String, Integer, Date
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class CompletedSurveys(Base):
    __tablename__ = "completed_surveys"
    study_code = Column(String, primary_key=True)
    participant_code = Column(String, primary_key=True)
    survey_id = Column(Integer, primary_key=True)
    date = Column(Date, primary_key=True)
