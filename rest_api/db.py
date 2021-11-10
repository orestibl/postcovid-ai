from datetime import datetime

from sqlalchemy import create_engine, extract
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


def _answered_today(survey, participant_code, hour):
    with Session() as session:
        last_answer = session.query(CompletedSurveys).filter(CompletedSurveys.survey_id == survey.survey_id,
                                                                CompletedSurveys.study_code == survey.study_code,
                                                                CompletedSurveys.participant_code == participant_code,
                                                                extract('year', CompletedSurveys.date) == datetime.now().year,
                                                                extract('month', CompletedSurveys.date) == datetime.now().month,
                                                                extract('day', CompletedSurveys.date) == datetime.now().day
                                                            ).order_by(CompletedSurveys.date.desc()).first()
        if last_answer:
            return last_answer.date.hour >= hour
        else:
            return False


def get_survey_id(study_code, participant_code, hour, weekday):
    with Session() as session:
        surveys = session.query(StudySurveys).filter(StudySurveys.hours.any(hour),
                                                    StudySurveys.weekdays.any(weekday),
                                                    StudySurveys.study_code == study_code).all()
        for survey in surveys:
            if survey and not _answered_today(survey=survey, participant_code=participant_code, hour=hour):
                return survey.survey_id

        return None


def register_completed_survey(study_code, participant_code, survey_id):
    with Session() as session:
        registry = CompletedSurveys(study_code=study_code, participant_code=participant_code,
                                    survey_id=survey_id, date=datetime.utcnow())
        session.add(registry)
        session.commit()
