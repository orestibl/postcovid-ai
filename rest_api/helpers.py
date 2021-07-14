import logging

from sqlalchemy.exc import IntegrityError

import db
from exceptions import UnauthorizedException

logger = logging.getLogger('app')


def get_study(code):
    try:
        # Take the first digits of the code
        participant_code = code[:5]  # TODO set length
        study_id = db.get_study_id(participant_code)
        if not study_id:
            raise UnauthorizedException()
        study_code = code[5:]
        study = db.get_study(study_id, study_code)
        if not study:
            raise UnauthorizedException()
        return {
            "status": 200,
            "description": "OK",
            "data": study.to_dict()
        }
    except UnauthorizedException:
        return {"status": 403, "description": "Unauthorized"}


def perform_onboarding(participant_code, device_id):
    try:
        db.register_device(participant_code, device_id)
    except IntegrityError:
        logger.error("Participant %s device %s tried to be registered again", participant_code, device_id)
        return {"status": 412, "description": "Device already exists"}
    return {"status": 200, "description": "OK"}


def get_survey_id(code, hour):
    study_code = code[5:]
    participant_code = code[:5]
    survey_id = db.get_survey_id(study_code=study_code, hour=hour, participant_code=participant_code)
    return {
        "status": 200,
        "description": "OK",
        "data": {
            "survey_id": survey_id
        }
    }
