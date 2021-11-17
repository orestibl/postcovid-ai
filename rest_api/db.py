from datetime import datetime, timedelta
import pytz

from sqlalchemy import create_engine, extract
from sqlalchemy.orm import sessionmaker

from credentials import db_string
from models.CompletedSurveys import CompletedSurveys
from models.OngoingSurveys import OngoingSurveys
from models.ParticipantDevice import ParticipantDevice
from models.ParticipantStudy import ParticipantStudy
from models.Study import Study
from models.StudySurveys import StudySurveys

db = create_engine(db_string)
Session = sessionmaker(bind=db)
tz = pytz.timezone('Europe/Madrid')


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


def _survey_answered(survey, participant_code, hour):
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

def _survey_ongoing(participant_code, hour):
    with Session() as session:
        last_record = session.query(OngoingSurveys).filter(OngoingSurveys.participant_code == participant_code,
                                                            extract('year', OngoingSurveys.date) == datetime.now().year,
                                                            extract('month', OngoingSurveys.date) == datetime.now().month,
                                                            extract('day', OngoingSurveys.date) == datetime.now().day
                                                            ).order_by(OngoingSurveys.date.desc()).first()
        
        if last_record:
            if last_record.date.hour >= hour:
                return last_record.date
            else:
                return False
        else:
            return False

def get_survey_id(study_code, participant_code, hour, weekday):
    with Session() as session:
        # Query surveys table
        surveys = session.query(StudySurveys).filter(StudySurveys.hours.any(hour),
                                                    StudySurveys.weekdays.any(weekday),
                                                    StudySurveys.study_code == study_code).all()
        for survey in surveys:
            # if survey time, continue - otherwise return None
            if survey:
                # if not answered, continue - otherwise return None
                if not _survey_answered(survey=survey, participant_code=participant_code, hour=hour):
                    # if not showing recently, send code - otherwise continue
                    last_record = _survey_ongoing(participant_code=participant_code, hour=hour)
                    if not last_record:
                        return survey.survey_id
                    else:
                        # if showed less than 5 min ago, send code - otherwise return None
                        timeframe_over = ((last_record + timedelta(minutes=5)) < tz.localize(datetime.now()))
                        if timeframe_over:
                            return survey.survey_id

        return None


def register_completed_survey(study_code, participant_code, survey_id):
    with Session() as session:
        registry = OngoingSurveys(participant_code=participant_code, date=datetime.utcnow())
        session.add(registry)
        session.commit()
