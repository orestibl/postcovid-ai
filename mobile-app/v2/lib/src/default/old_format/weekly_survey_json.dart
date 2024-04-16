const weekly_survey = r'''{
    "$type": "RPOrderedTask",
    "steps": [
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Estado de salud",
                    "optional": false,
                    "identifier": "healthQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "No tengo síntomas",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Tengo síntomas pero no me han diagnosticado",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Me han diagnosticado",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Situación laboral actual",
                    "optional": false,
                    "identifier": "workQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Empleado/a",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Autónomo/a",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Desempleado/a",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "Estudiante",
                                "$type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Jubilado/a",
                                "$type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            },
                            {
                                "text": "Otro",
                                "$type": "RPChoice",
                                "value": 6,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Efecto de la crisis en tu situación laboral",
                    "optional": false,
                    "identifier": "workImpactQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Sin cambios",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Teletrabajo exclusivo",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Teletrabajo parcial",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "Jornada laboral reducida",
                                "$type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Jornada laboral aumentada",
                                "$type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            },
                            {
                                "text": "Regulación temporal de empleo (ERTE)",
                                "$type": "RPChoice",
                                "value": 6,
                                "is_free_text": false
                            },
                            {
                                "text": "Despedido/a",
                                "$type": "RPChoice",
                                "value": 7,
                                "is_free_text": false
                            },
                            {
                                "text": "Nuevo empleo",
                                "$type": "RPChoice",
                                "value": 8,
                                "is_free_text": false
                            },
                            {
                                "text": "Otro",
                                "$type": "RPChoice",
                                "value": 9,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Ejercicio físico semanal",
                    "optional": false,
                    "identifier": "fitnessQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Menos de 2h",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "2 a 4h",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "4 a 6h",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "6 a 8h",
                                "$type": "RPChoice",
                                "value": 4,
                                "is_free_text": false
                            },
                            {
                                "text": "Más de 8h",
                                "$type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Vacuna",
                    "optional": false,
                    "identifier": "vaccineQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "No estoy vacunado/a",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Me falta una dosis de la vacuna",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Estoy vacunado/a completamente",
                                "$type": "RPChoice",
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
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Tus relaciones personales",
                    "optional": false,
                    "identifier": "mood2-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tu situación laboral",
                    "optional": false,
                    "identifier": "mood2-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tu situación financiera",
                    "optional": false,
                    "identifier": "mood2-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tu tiempo libre",
                    "optional": false,
                    "identifier": "mood2-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tu salud física",
                    "optional": false,
                    "identifier": "mood2-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tu salud mental",
                    "optional": false,
                    "identifier": "mood2-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 4,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "El área donde vives",
                    "optional": false,
                    "identifier": "mood2-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
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
