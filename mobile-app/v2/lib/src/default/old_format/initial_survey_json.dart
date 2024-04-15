const initial_survey = r'''{
    "$type": "RPOrderedTask",
    "steps": [
        {
            "text": "Antes de empezar, necesitamos conocer algunos datos sobre ti.\n\nA continuación tendrás que completar una serie de cuestionarios, con una duración total de unos 10 minutos. Este paso sólo tendrá que ser realizado la primera vez que se utiliza la app.",
            "$type": "RPInstructionStep",
            "title": "¡Hola!",
            "identifier": "instructionsID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Género",
                    "optional": false,
                    "identifier": "genderQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Femenino",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "Masculino",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "Otro",
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
                    "title": "Edad",
                    "optional": false,
                    "identifier": "ageQuestionID",
                    "answer_format": {
                        "$type": "RPIntegerAnswerFormat",
                        "suffix": "años",
                        "max_value": 200,
                        "min_value": 16,
                        "question_type": "Integer"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Código postal",
                    "optional": false,
                    "identifier": "postcodeQuestionID",
                    "answer_format": {
                        "$type": "RPIntegerAnswerFormat",
                        "max_value": 99999,
                        "min_value": 0,
                        "question_type": "Integer"
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Ingreso anual neto",
                    "optional": false,
                    "identifier": "incomeQuestionID",
                    "answer_format": {
                        "$type": "RPChoiceAnswerFormat",
                        "choices": [
                            {
                                "text": "Menos de 12.450€",
                                "$type": "RPChoice",
                                "value": 1,
                                "is_free_text": false
                            },
                            {
                                "text": "12.450 a 20.200€",
                                "$type": "RPChoice",
                                "value": 2,
                                "is_free_text": false
                            },
                            {
                                "text": "20.200 a 35.200€",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "35.200 a 60.000€",
                                "$type": "RPChoice",
                                "value": 3,
                                "is_free_text": false
                            },
                            {
                                "text": "Más de 60.000€",
                                "$type": "RPChoice",
                                "value": 5,
                                "is_free_text": false
                            }
                        ],
                        "answer_style": "SingleChoice",
                        "question_type": "SingleChoice"
                    }
                }
            ],
            "title": "Datos demográficos y socio-económicos",
            "optional": false,
            "identifier": "demographicID"
        },
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
                    "title": "Afectado/a",
                    "optional": false,
                    "identifier": "mood1-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Agresivo/a",
                    "optional": false,
                    "identifier": "mood1-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Despierto/a",
                    "optional": false,
                    "identifier": "mood1-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Avergonzado/a",
                    "optional": false,
                    "identifier": "mood1-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Inspirado/a",
                    "optional": false,
                    "identifier": "mood1-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Nervioso/a",
                    "optional": false,
                    "identifier": "mood1-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Decidido/a",
                    "optional": false,
                    "identifier": "mood1-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Concentrado/a",
                    "optional": false,
                    "identifier": "mood1-8ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Miedoso/a",
                    "optional": false,
                    "identifier": "mood1-9ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Activo/a",
                    "optional": false,
                    "identifier": "mood1-10ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "En general, ¿qué tan satisfecho/a estás con tu vida?\n\n1 = Muy insatisfecho\n2 = Insatisfecho\n3 = Satisfecho\n4 = Muy satisfecho",
                    "optional": false,
                    "identifier": "moodA-11ID",
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
            "title": "Valora la opción que refleje mejor cómo te sientes en general, es decir, normalmente\n\n1 = Nada o muy ligeramente\n2 = Un poco\n3 = Moderadamente\n4 = Bastante\n5 = Mucho",
            "optional": false,
            "identifier": "mood1ID"
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
            "title": "Valora la siguiente pregunta: en general, ¿qué tan satisfecho/a estás con los siguientes ámbitos de tu vida?\n\n1 = Muy insatisfecho\n2 = Insatisfecho\n3 = Satisfecho\n4 = Muy satisfecho",
            "optional": false,
            "identifier": "mood2ID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Mi objetivo es conseguir una vida plena y significativa",
                    "optional": false,
                    "identifier": "mood3-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Mis relaciones sociales son gratificantes y me ofrecen el apoyo que necesito",
                    "optional": false,
                    "identifier": "mood3-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Me implico y me intereso en mis actividades diarias",
                    "optional": false,
                    "identifier": "mood3-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Contribuyo activamente a la felicidad y el bienestar de otros",
                    "optional": false,
                    "identifier": "mood3-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Soy competente y capaz en las tareas que son importantes para mí",
                    "optional": false,
                    "identifier": "mood3-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Soy una buena persona y tengo una buena vida",
                    "optional": false,
                    "identifier": "mood3-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Veo mi futuro con optimismo",
                    "optional": false,
                    "identifier": "mood3-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "La gente me respeta",
                    "optional": false,
                    "identifier": "mood3-8ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                }
            ],
            "title": "Indica en que grado de acuerdo o desacuerdo estás con cada una de las siguientes afirmaciones\n\n1 = Totalmente en desacuerdo\n7 = Totalmente de acuerdo",
            "optional": false,
            "identifier": "mood3ID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido poco interés o placer en hacer cosas",
                    "optional": false,
                    "identifier": "mood4-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has sentido decaído/a, deprimido/a o sin esperanzas",
                    "optional": false,
                    "identifier": "mood4-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido dificultad para quedarte o permanecer dormido/a, o has dormido demasiado",
                    "optional": false,
                    "identifier": "mood4-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has sentido cansado/a o con poca energía",
                    "optional": false,
                    "identifier": "mood4-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido falta de apetito o has comido en exceso",
                    "optional": false,
                    "identifier": "mood4-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has sentido mal contigo mismo/a - o que eres un fracaso o que has quedado mal contigo mismo/a o con tu familia",
                    "optional": false,
                    "identifier": "mood4-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido dificultad para concentrarte en ciertas actividades, tales como leer el periódico o ver la televisión",
                    "optional": false,
                    "identifier": "mood4-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "¿Te has movido o hablado tan lento que otras personas podrían haberlo notado? O lo contrario - tan inquieto/a o agitado/a que has estado moviéndote mucho más de lo normal",
                    "optional": false,
                    "identifier": "mood4-8ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido pensamientos de que estarías mejor muerto/a o de lastimarte de alguna manera",
                    "optional": false,
                    "identifier": "mood4-9ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                }
            ],
            "title": "Durante las últimas 2 semanas, ¿con qué frecuencia has tenido molestias debido a los siguientes problemas?\n\n0 = Ningún día\n1 = Varios días\n2 = Más de la mitad de los días\n3 = Casi todos los días",
            "optional": false,
            "identifier": "mood4ID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has sentido nervioso/a, ansioso/a o con los nervios de punta",
                    "optional": false,
                    "identifier": "mood5-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "No has podido parar o controlar tu preocupación",
                    "optional": false,
                    "identifier": "mood5-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has preocupado demasiado por motivos diferentes",
                    "optional": false,
                    "identifier": "mood5-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has tenido dificultad para relajarte",
                    "optional": false,
                    "identifier": "mood5-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has sentido tan intranquilo/a que no has podido quedarte quieto/a",
                    "optional": false,
                    "identifier": "mood5-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Te has enfadado o irritado fácilmente",
                    "optional": false,
                    "identifier": "mood5-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Has sentido miedo de que algo terrible fuera a pasar",
                    "optional": false,
                    "identifier": "mood5-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 3,
                        "max_value": 3,
                        "min_value": 0
                    }
                }
            ],
            "title": "Durante las últimas 2 semanas, ¿con qué frecuencia has tenido molestias debido a los siguientes problemas?\n\n0 = Ningún día\n1 = Varios días\n2 = Más de la mitad de los días\n3 = Casi todos los días",
            "optional": false,
            "identifier": "mood5ID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Tiendo a recuperarme rápidamente después de haberlo pasado mal",
                    "optional": false,
                    "identifier": "mood6-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Lo paso mal cuando tengo que enfrentarme a situaciones estresantes",
                    "optional": false,
                    "identifier": "mood6-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "No tardo mucho en recuperarme después de una situación estresante",
                    "optional": false,
                    "identifier": "mood6-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Es difícil para mí recuperarme cuando me ocurre algo malo",
                    "optional": false,
                    "identifier": "mood6-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Aunque pase por situaciones difíciles, normalmente no lo paso demasiado mal",
                    "optional": false,
                    "identifier": "mood6-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Suelo tardar mucho tiempo en recuperarme de los contratiempos que me ocurren en mi vida",
                    "optional": false,
                    "identifier": "mood6-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 4,
                        "max_value": 5,
                        "min_value": 1
                    }
                }
            ],
            "title": "A continuación hay seis afirmaciones con las cuales puedes estar de acuerdo o en desacuerdo. Lee cada una de ellas y después selecciona la respuesta que mejor describa en qué grado estás de acuerdo o en desacuerdo.\n\n1 = Totalmente en desacuerdo\n2 = Bastante en desacuerdo\n3 = Indiferente\n4 = Bastante de acuerdo\n5 = Totalmente de acuerdo",
            "optional": false,
            "identifier": "mood6ID"
        },
        {
            "$type": "RPFormStep",
            "steps": [
                {
                    "$type": "RPQuestionStep",
                    "title": "Mis experiencias y recuerdos dolorosos hacen que me sea difícil vivir la vida que querría",
                    "optional": false,
                    "identifier": "mood7-1ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Tengo miedo de mis sentimientos",
                    "optional": false,
                    "identifier": "mood7-2ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Me preocupa no ser capaz de controlar mis preocupaciones y sentimientos ",
                    "optional": false,
                    "identifier": "mood7-3ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Mis recuerdos dolorosos me impiden llevar una vida plena",
                    "optional": false,
                    "identifier": "mood7-4ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Mis emociones interfieren en cómo me gustaría que fuera mi vida",
                    "optional": false,
                    "identifier": "mood7-5ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Parece que la mayoría de la gente lleva su vida mejor que yo",
                    "optional": false,
                    "identifier": "mood7-6ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                },
                {
                    "$type": "RPQuestionStep",
                    "title": "Mis preocupaciones interfieren en el camino de lo que quiero conseguir",
                    "optional": false,
                    "identifier": "mood7-7ID",
                    "answer_format": {
                        "$type": "RPSliderAnswerFormat",
                        "prefix": "",
                        "suffix": "",
                        "divisions": 6,
                        "max_value": 7,
                        "min_value": 1
                    }
                }
            ],
            "title": "Debajo encontrarás una lista de afirmaciones. Por favor, puntúa en qué grado cada afirmación es verdad para ti.\n\n1 = Nunca es verdad\n2 = Muy raramente es verdad\n3 = Raramente es verdad\n4 = A veces es verdad\n5 = Frecuentemente es verdad\n6 = Casi siempre es verdad\n7 = Siempre es verdad.",
            "optional": false,
            "identifier": "mood7ID"
        },
        {
            "text": "Muchas gracias por finalizar la encuesta, a partir de este momento solo tendrás que contestar a unas sencillas preguntas cuando recibas una notificación en tu teléfono\n\n¡Muchas gracias por tu colaboración!",
            "$type": "RPCompletionStep",
            "title": "¡Completado!",
            "identifier": "completionID"
        }
    ],
    "identifier": "initialSurveyTaskID",
    "close_after_finished": true
}
''';
