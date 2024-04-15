from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class ParticipantDevice(Base):
    __tablename__ = "participant_device"
    device_id = Column(String, primary_key=True)
    participant_code = Column(String, primary_key=True)
