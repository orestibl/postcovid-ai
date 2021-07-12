from sqlalchemy import Column, String, Integer
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class StudySurveys(Base):
    __tablename__ = "study_surveys"
    survey_id = Column(Integer, primary_key=True)
    study_code = Column(String, primary_key=True)
    hour = Column(Integer, primary_key=True)
