const weekly_survey_study2 = r"""{
  "steps": [
    {
      "steps": [
        {
          "title": "¿Cómo dirías que ha sido tu salud?",
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
          "title": "¿Cuánto ejercicio físico has hecho?",
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
        }
      ],
      "title": "Durante la última semana:",
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
          "title": "¿Con qué frecuencia has sentido que te faltaba compañía?",
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
          "title": "¿Con qué frecuencia te has sentido excluido(a)?",
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
          "title": "¿Con qué frecuencia te has sentido aislado(a) de los demás?",
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
      "title": "Durante la última semana:",
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
          "title": "¿Qué tan satisfecho(a) has estado con tu vida?",
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
          "title": "¿Qué tan satisfecho(a) has estado con los siguientes ámbitos de tu vida?  \n\nTus relaciones personales",
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
      "title": "Durante la última semana:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "LS_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    }
  ],
  "__type": "RPOrderedTask",
  "identifier": "weekly_survey",
  "close_after_finished": true
}
""";
