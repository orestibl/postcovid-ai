from datetime import datetime, timedelta

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from credentials import db_string
from models.CompletedSurveys import CompletedSurveys
from models.ParticipantDevice import ParticipantDevice
from models.ParticipantStudy import ParticipantStudy
from models.Study import Study
from models.StudySurveys import StudySurveys

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


def _answered_today(survey, participant_code):
    with Session() as session:
        today = datetime(datetime.today().year, datetime.today().month, datetime.today().day)
        tomorrow = today + timedelta(days=1)
        times_answered = session.query(CompletedSurveys).filter(CompletedSurveys.survey_id == survey.survey_id,
                                                                CompletedSurveys.date > today,
                                                                CompletedSurveys.date <= tomorrow,
                                                                CompletedSurveys.study_code == survey.study_code,
                                                                CompletedSurveys.participant_code ==
                                                                participant_code).count()
        max_times_answered = len(survey.hours)
    return times_answered >= max_times_answered


def get_survey_id(study_code, participant_code, hour):
    with Session() as session:
        survey = session.query(StudySurveys).filter(StudySurveys.hours.any(hour),
                                                    StudySurveys.study_code == study_code).first()
        if survey and not _answered_today(survey=survey, participant_code=participant_code):
            return survey.survey_id
        else:
            return None
