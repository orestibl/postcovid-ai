from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class ParticipantStudy(Base):
    __tablename__ = "participant_study"
    study_id = Column(String)
    participant_code = Column(String, primary_key=True)
