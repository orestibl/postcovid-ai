from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class Study(Base):
    __tablename__ = "study_details"
    study_id = Column(String, primary_key=True)
    study_code = Column(String)
    username = Column(String)
    password = Column(String)
    client_id = Column(String)
    client_secret = Column(String)
    consent_id = Column(String)
    protocol_name = Column(String)
    initial_survey_id = Column(String)

    def to_dict(self):
        return {
            "username": self.username,
            "password": self.password,
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "consent_id": self.consent_id,
            "study_id": self.study_id,
            "protocol_name": self.protocol_name,
            "initial_survey_id": self.initial_survey_id
        }
