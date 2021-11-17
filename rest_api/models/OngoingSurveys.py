from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class OngoingSurveys(Base):
    __tablename__ = "ongoing_surveys"
    participant_code = Column(String, primary_key=True)
    date = Column(DateTime(timezone=True), primary_key=True)

    def __init__(self, participant_code, date):
        self.participant_code = participant_code
        self.date = date
