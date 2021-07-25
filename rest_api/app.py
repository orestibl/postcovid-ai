from datetime import datetime

from flask import Flask, request

import helpers

app = Flask(__name__)
logger = app.logger


@app.route("/get_study", methods=["POST"])
def get_study():
    try:
        payload = request.json
        user_code = payload['code']
        assert isinstance(user_code, str)
        assert len(user_code) == 10
        response = helpers.get_study(user_code)
        return response
    except (KeyError, AssertionError, TypeError):
        return {"status": 400, "description": "Invalid parameters"}
    except Exception as e:
        logger.exception("Exception getting study %s", request.json)
        return {"status": 500, "description": str(e)}


@app.route("/register_device", methods=["POST"])
def register_device():
    try:
        payload = request.json
        participant_code = payload['participant_code']
        device_id = payload['device_id']
        response = helpers.perform_onboarding(participant_code, device_id)
        return response
    except Exception as e:
        logger.exception("Exception registering device %s", request.json)
        return {"status": 500, "description": str(e)}


@app.route("/get_survey_id", methods=["POST"])
def get_survey_id():
    try:
        payload = request.json
        code = payload['code']
        hour = int(datetime.utcnow().strftime("%H"))
        weekday = datetime.utcnow().isoweekday()
        response = helpers.get_survey_id(code=code, hour=hour, weekday=weekday)
        return response
    except Exception as e:
        logger.exception("Exception getting survey %s", request.json)
        return {"status": 500, "description": str(e)}


@app.route("/register_completed_survey", methods=["POST"])
def register_completed_survey():
    try:
        payload = request.json
        code = payload['code']
        survey_id = payload['survey_id']
        response = helpers.register_completed_survey(code=code, survey_id=survey_id)
        return response
    except Exception as e:
        logger.exception("Exception registering completed survey %s", request.json)
        return {"status": 500, "description": str(e)}
