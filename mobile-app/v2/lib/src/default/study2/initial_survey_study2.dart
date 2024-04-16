const initial_survey_study2 = r"""{
  "steps": [
    {
      "text": "Antes de empezar, necesitamos conocer algunos datos sobre ti.\n\nA continuación tendrás que completar una serie de cuestionarios, con una duración aproximada de unos 10 minutos. Este paso sólo tendrá que ser realizado la primera vez que se utiliza la app.",
      "title": "¡Hola!",
      "__type": "RPInstructionStep",
      "identifier": "instructions"
    },
    {
      "steps": [
        {
          "title": "Género",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "gender",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Femenino",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Masculino",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Otro",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Año de nacimiento",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "birth_year",
          "answer_format": {
            "__type": "RPIntegerAnswerFormat",
            "max_value": 2006,
            "min_value": 1900,
            "question_type": "Integer"
          }
        },
        {
          "title": "Código postal",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "postcode",
          "answer_format": {
            "__type": "RPIntegerAnswerFormat",
            "max_value": 99999,
            "min_value": 0,
            "question_type": "Integer"
          }
        },
        {
          "title": "Ingreso anual neto",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "income",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Menos de 12.450€",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "12.450 a 20.200€",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "20.200 a 35.200€",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "35.200 a 60.000€",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de 60.000€",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Responde a las siguientes cuestiones:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "general_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "En general, ¿cómo dirías que es tu salud?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "health",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Mala",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Regular",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Buena",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy buena",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Excelente",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Cuál ha sido el impacto de la COVID-19 en tu salud física?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "covid_physical_health",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy negativo",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Negativo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ninguno",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Positivo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy positivo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Cuál ha sido el impacto de la COVID-19 en tu bienestar mental?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "covid_mental_health",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy negativo",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Negativo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ninguno",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Positivo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy positivo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "En general, ¿cuánto ejercicio físico haces a la semana?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "physical_activity",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Menos de 2h",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "2 a 4h",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "4 a 6h",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "6 a 8h",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de 8h",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Estás vacunado(a) contra la COVID-19?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "covid_vaccine",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Sí",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "No",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Responde a las siguientes cuestiones:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "health_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Situación laboral",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "current_employment",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Empleado(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Autónomo(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Desempleado(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Estudiante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Jubilado(a)",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Otro",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Modalidad laboral",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "employment_type",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Presencial",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Teletrabajo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mixta",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Otra",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ninguna",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Dedicación",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "employment_dedication",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Tiempo completo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Tiempo parcial",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ninguna",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Cuál ha sido el impacto de la COVID-19 en tu situación laboral?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "employment_impact",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy negativo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Negativo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ninguno",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Positivo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy positivo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Responde a las siguientes cuestiones:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "employment_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Afectado(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Agresivo(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Despierto(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Avergonzado(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Inspirado(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Nervioso(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Decidido(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_7",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Concentrado(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_8",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Miedoso(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_9",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Activo(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "IPSF_10",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada o muy ligeramente",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Un poco",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Moderadamente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Valora la opción que refleje mejor cómo te sientes en general, es decir, normalmente:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "IPSF_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "En general, ¿qué tan satisfecho(a) estás con tu vida?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GLS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "En general, ¿qué tan satisfecho(a) estás con los siguientes ámbitos de tu vida?  \n\nTus relaciones personales",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "RELAT_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tu situación laboral",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "WORK_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tu situación financiera",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FINAN_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tu tiempo libre",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "TIME_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tu salud física",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHYS_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tu bienestar mental",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "MENT_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "El área donde vives",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AREA_LS",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Muy insatisfecho(a)",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Insatisfecho(a)",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Satisfecho(a)",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy satisfecho(a)",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Valora las siguientes preguntas:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "LS_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Mi objetivo es conseguir una vida plena y significativa",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Mis relaciones sociales son gratificantes y me ofrecen el apoyo que necesito",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Me implico y me intereso en mis actividades diarias",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Contribuyo activamente a la felicidad y el bienestar de otros",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Soy competente y capaz en las tareas que son importantes para mí",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Soy una buena persona y tengo una buena vida",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Veo mi futuro con optimismo",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_7",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "La gente me respeta",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "FS_8",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "En desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente en desacuerdo",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ni de acuerdo ni en desacuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Ligeramente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "De acuerdo",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Indica en que grado de acuerdo o desacuerdo estás con cada una de las siguientes afirmaciones:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "FS_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Has tenido poco interés o placer en hacer cosas",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has sentido decaído(a), deprimido(a) o sin esperanzas",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has tenido dificultad para quedarte o permanecer dormido(a), o has dormido demasiado",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has sentido cansado(a) o con poca energía",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has tenido falta de apetito o has comido en exceso",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has sentido mal contigo mismo(a) - o que eres un fracaso o que has quedado mal contigo mismo(a) o con tu familia",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has tenido dificultad para concentrarte en ciertas actividades, tales como leer el periódico o ver la televisión",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_7",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has movido o hablado tan lento que otras personas podrían haberlo notado. O lo contrario, has estado tan inquieto(a) o agitado(a) que has estado moviéndote mucho más de lo normal",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_8",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has tenido pensamientos de que estarías mejor muerto(a) o de lastimarte de alguna manera",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "PHQ_9",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Durante las últimas 2 semanas, ¿con qué frecuencia has tenido molestias debido a los siguientes problemas?",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "PHQ_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Te has sentido nervioso(a), ansioso(a) o con los nervios de punta",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "No has podido parar o controlar tu preocupación",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has preocupado demasiado por motivos diferentes",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has tenido dificultad para relajarte",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has sentido tan intranquilo(a) que no has podido quedarte quieto(a)",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Te has enfadado o irritado fácilmente",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Has sentido miedo de que algo terrible fuera a pasar",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "GAD_7",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Ningún día",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Varios días",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Más de la mitad de los días",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi todos los días",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Durante las últimas 2 semanas, ¿con qué frecuencia has tenido molestias debido a los siguientes problemas?",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "GAD_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Tiendo a recuperarme rápidamente después de haberlo pasado mal",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Lo paso mal cuando tengo que enfrentarme a situaciones estresantes",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "No tardo mucho en recuperarme después de una situación estresante",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Es difícil para mí recuperarme cuando me ocurre algo malo",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Aunque pase por situaciones difíciles, normalmente no lo paso demasiado mal",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Suelo tardar mucho tiempo en recuperarme de los contratiempos que me ocurren en mi vida",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "BRS_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Totalmente en desacuerdo",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante en desacuerdo",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Indiferente",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Bastante de acuerdo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Totalmente de acuerdo",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "A continuación hay seis afirmaciones con las cuales puedes estar de acuerdo o en desacuerdo. Lee cada una de ellas y después selecciona la respuesta que mejor describa en qué grado estás de acuerdo o en desacuerdo:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "BRS_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "Mis experiencias y recuerdos dolorosos hacen que me sea difícil vivir la vida que querría",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Tengo miedo de mis sentimientos",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Me preocupa no ser capaz de controlar mis preocupaciones y sentimientos",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Mis recuerdos dolorosos me impiden llevar una vida plena",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_4",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Mis emociones interfieren en cómo me gustaría que fuera mi vida",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_5",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Parece que la mayoría de la gente lleva su vida mejor que yo",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_6",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "Mis preocupaciones interfieren en el camino de lo que quiero conseguir",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "AAQ_7",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nunca es verdad",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Muy raramente es verdad",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Raramente es verdad",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "A veces es verdad",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Frecuentemente es verdad",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Casi siempre es verdad",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Siempre es verdad",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Debajo encontrarás una lista de afirmaciones. Por favor, puntúa en qué grado cada afirmación es verdad para ti:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "AAQ_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "¿Con qué frecuencia sientes que te falta compañía?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "TILS_1",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Casi nunca",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Algunas veces",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Con frecuencia",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Con qué frecuencia te sientes excluido(a)?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "TILS_2",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Casi nunca",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Algunas veces",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Con frecuencia",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        },
        {
          "title": "¿Con qué frecuencia te sientes aislado(a) de los demás?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "TILS_3",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Casi nunca",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Algunas veces",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Con frecuencia",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Las siguientes preguntas se refieren a cómo te sientes con respecto a distintos aspectos de tu vida. Para cada uno de ellos, di con qué frecuencia te sientes así:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "TILS_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "¿En qué medida percibes que entre la gente de la que te rodea existe desigualdad económica, esto es, en los ingresos y riqueza que poseen?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "economic_inequality",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "Nada, no percibo desigualdad económica",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Percibo muy poca",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Percibo poca",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Percibo algo",
                "value": 4,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Percibo bastante",
                "value": 5,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Percibo mucha",
                "value": 6,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Mucho, percibo muchísima desigualdad económica",
                "value": 7,
                "__type": "RPChoice",
                "is_free_text": false
              }
            ],
            "answer_style": "SingleChoice",
            "question_type": "SingleChoice"
          }
        }
      ],
      "title": "Responde a la siguiente pregunta:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "economic_inequality_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "text": "Muchas gracias por finalizar la encuesta, a partir de este momento solo tendrás que contestar a unas sencillas preguntas cuando recibas una notificación en tu teléfono\n\n¡Muchas gracias por tu colaboración!",
      "title": "¡Completado!",
      "__type": "RPCompletionStep",
      "identifier": "completion"
    }
  ],
  "__type": "RPOrderedTask",
  "identifier": "initial_survey",
  "close_after_finished": true
}
""";
