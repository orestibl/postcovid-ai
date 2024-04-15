const daily_survey = r"""{
    "$type": "RPOrderedTask",
    "steps": [
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "valenceID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "Muy mal",
                        "suffix": "Muy bien",
                        "max_value": 50,
                        "min_value": -50,
                        "init_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "fatigueID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "Sin energía",
                        "suffix": "Lleno de energía",
                        "max_value": 100,
                        "min_value": 0,
                        "init_value": 50
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "arousalID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "Muy tranquilo",
                        "suffix": "Muy inquieto",
                        "max_value": 100,
                        "min_value": 0,
                        "init_value": 50
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Desde tu último registro, ¿has vivido alguna situación destacable a nivel emocional?",
                    "optional": false,
                    "identifier": "extraID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "Sí, muy\ndesagradable",
                        "suffix": "Sí, muy\nagradable",
                        "max_value": 50,
                        "min_value": -50,
                        "init_value": 0
                    }
                }
            ],
            "title": "¿Cómo te sientes ahora?",
            "optional": false,
            "identifier": "moodID"
        }
    ],
    "identifier": "dailySurveyTaskID",
    "close_after_finished": true
}
""";
