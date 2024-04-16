const weekly_survey = r'''{
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
                    "title": "Estado de salud",
                    "optional": false,
                    "identifier": "healthQuestionID",
                    "answer_format": {
                        "__type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "No tengo síntomas",
                                "__type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Tengo síntomas pero no me han diagnosticado",
                                "__type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Me han diagnosticado",
                                "__type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Situación laboral actual",
                    "optional": false,
                    "identifier": "workQuestionID",
                    "answer_format": {
                        "__type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Empleado/a",
                                "__type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Autónomo/a",
                                "__type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Desempleado/a",
                                "__type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "Estudiante",
                                "__type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Jubilado/a",
                                "__type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            },
                            {
                                "text": "Otro",
                                "__type": "RPChoice",
                                "value": 6,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Efecto de la crisis en tu situación laboral",
                    "optional": false,
                    "identifier": "workImpactQuestionID",
                    "answer_format": {
                        "__type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Sin cambios",
                                "__type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Teletrabajo exclusivo",
                                "__type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Teletrabajo parcial",
                                "__type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "Jornada laboral reducida",
                                "__type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Jornada laboral aumentada",
                                "__type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            },
                            {
                                "text": "Regulación temporal de empleo (ERTE)",
                                "__type": "RPChoice",
                                "value": 6,
                                "is_free_text": false
                            },
                            {
                                "text": "Despedido/a",
                                "__type": "RPChoice",
                                "value": 7,
                                "is_free_text": false
                            },
                            {
                                "text": "Nuevo empleo",
                                "__type": "RPChoice",
                                "value": 8,
                                "is_free_text": false
                            },
                            {
                                "text": "Otro",
                                "__type": "RPChoice",
                                "value": 9,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Ejercicio físico semanal",
                    "optional": false,
                    "identifier": "fitnessQuestionID",
                    "answer_format": {
                        "__type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Menos de 2h",
                                "__type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "2 a 4h",
                                "__type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "4 a 6h",
                                "__type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "6 a 8h",
                                "__type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Más de 8h",
                                "__type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Vacuna",
                    "optional": false,
                    "identifier": "vaccineQuestionID",
                    "answer_format": {
                        "__type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "No estoy vacunado/a",
                                "__type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Me falta una dosis de la vacuna",
                                "__type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Estoy vacunado/a completamente",
                                "__type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                }
            ],
            "title": "En relación a la COVID-19",
            "optional": false,
            "identifier": "covidID"
        },
        {
            "__type": "RPFormStep",
            "answer_format": {
                "__type": "RPFormAnswerFormat",
                "question_type": "Form"
            },
            "steps": [
                {
                    "__type": "RPQuestionStep",
                    "title": "Tus relaciones personales",
                    "optional": false,
                    "identifier": "mood2-1ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Tu situación laboral",
                    "optional": false,
                    "identifier": "mood2-2ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Tu situación financiera",
                    "optional": false,
                    "identifier": "mood2-3ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Tu tiempo libre",
                    "optional": false,
                    "identifier": "mood2-4ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Tu salud física",
                    "optional": false,
                    "identifier": "mood2-5ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "Tu salud mental",
                    "optional": false,
                    "identifier": "mood2-6ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "__type": "RPQuestionStep",
                    "title": "El área donde vives",
                    "optional": false,
                    "identifier": "mood2-7ID",
                    "answer_format": {
                        "__type": "RPSliderAnswerFormat",
                        "question_type": "Scale",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                }
            ],
            "title": "Valora la siguiente pregunta: durante la última semana, ¿qué tan satisfecho/a estás con los siguientes ámbitos de tu vida?\n\n1 = Muy insatisfecho\n2 = Insatisfecho\n3 = Satisfecho\n4 = Muy satisfecho",
            "optional": false,
            "identifier": "mood2ID"
        }
    ],
    "identifier": "weeklySurveyTaskID",
    "close_after_finished": true
}
''';
