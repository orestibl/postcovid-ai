from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from credentials import db_string
from models.ParticipantDevice import ParticipantDevice
from models.ParticipantStudy import ParticipantStudy
from models.Study import Study

db = create_engine(db_string)
Session = sessionmaker(bind=db)


def get_study_id(participant_code):
    with Session() as session:
        result = session.query(ParticipantStudy).filter(ParticipantStudy.participant_code == participant_code).first()
    return result.study_id if result else None


def get_study(study_id, study_code):
    with Session() as session:
        result = session.query(Study).filter(Study.study_id == study_id, Study.study_code == study_code).first()
    return result if result else None


def register_device(participant_code, device_id):
    with Session() as session:
        participant_device = ParticipantDevice(device_id=device_id, participant_code=participant_code)
        session.add(participant_device)
        session.commit()
