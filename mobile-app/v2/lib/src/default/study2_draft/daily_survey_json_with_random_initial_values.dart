const daily_survey_with_random_initial_values = r"""{
    "__type": "RPOrderedTask",
    "steps": [
        {
            "__type": "RPFormStep",
            "answer_format": {
                "__type": "RPFormAnswerFormat",
                "question_type": "Form"
            },
            "steps": [
                {
                    "__type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "valenceID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "Muy mal",
                        "suffix": "Muy bien",
                        "divisions": 10,
                        "max_value": 50,
                        "min_value": -50,
                        "random_init_value": true
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "fatigueID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "Sin energía",
                        "suffix": "Lleno de energía",
                        "divisions": 10,
                        "max_value": 100,
                        "min_value": 0,
                        "random_init_value": true
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "",
                    "optional": false,
                    "identifier": "arousalID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "Muy tranquilo",
                        "suffix": "Muy inquieto",
                        "divisions": 10,
                        "max_value": 100,
                        "min_value": 0,
                        "random_init_value": true
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Desde tu último registro, ¿has vivido alguna situación destacable a nivel emocional?",
                    "optional": false,
                    "identifier": "extraID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "Sí, muy\ndesagradable",
                        "suffix": "Sí, muy\nagradable",
                        "divisions": 10,
                        "max_value": 50,
                        "min_value": -50,
                        "random_init_value": true
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
