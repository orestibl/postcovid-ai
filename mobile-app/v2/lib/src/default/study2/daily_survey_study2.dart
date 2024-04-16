const daily_survey_study2 = r"""{
  "steps": [
    {
      "steps": [
        {
          "title": "",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "valence",
          "answer_format": {
            "__type": "RPSliderAnswerFormat",
            "prefix": "Muy mal",
            "suffix": "Muy bien",
            "divisions": 100,
            "max_value": 50,
            "min_value": -50,
            "init_value": 0,
            "question_type": "Scale"
          }
        },
        {
          "title": "",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "energetic_arousal",
          "answer_format": {
            "__type": "RPSliderAnswerFormat",
            "prefix": "Sin\nenergía",
            "suffix": "Lleno(a)\nde energía",
            "divisions": 100,
            "max_value": 100,
            "min_value": 0,
            "init_value": 50,
            "question_type": "Scale"
          }
        },
        {
          "title": "",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "tense_arousal",
          "answer_format": {
            "__type": "RPSliderAnswerFormat",
            "prefix": "Muy\ntranquilo(a)",
            "suffix": "Muy\ninquieto(a)",
            "divisions": 100,
            "max_value": 100,
            "min_value": 0,
            "init_value": 50,
            "question_type": "Scale"
          }
        },
        {
          "title": "Desde tu último registro, ¿has vivido alguna situación destacable a nivel emocional?",
          "__type": "RPQuestionStep",
          "optional": true,
          "identifier": "emotional_event",
          "answer_format": {
            "__type": "RPSliderAnswerFormat",
            "prefix": "Sí, muy\ndesagradable",
            "suffix": "Sí, muy\nagradable",
            "divisions": 100,
            "max_value": 50,
            "min_value": -50,
            "init_value": 0,
            "question_type": "Scale"
          }
        }
      ],
      "title": "¿Cómo te sientes ahora?",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "affect_and_emotional_event_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    },
    {
      "steps": [
        {
          "title": "¿Te has relacionado con otras personas (en persona o por redes sociales)?",
          "__type": "RPQuestionStep",
          "optional": false,
          "identifier": "social_quantity",
          "answer_format": {
            "__type": "RPChoiceAnswerFormat",
            "choices": [
              {
                "text": "No",
                "value": 0,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Sí, con 1 persona",
                "value": 1,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Sí, con 2 personas",
                "value": 2,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Sí, con entre 3 y 5 personas",
                "value": 3,
                "__type": "RPChoice",
                "is_free_text": false
              },
              {
                "text": "Sí, con más de 5 personas",
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
          "title": "En el caso de que sí hayas tenido interacción con otras personas, ¿cómo te has sentido?",
          "__type": "RPQuestionStep",
          "optional": true,
          "identifier": "social_quality",
          "answer_format": {
            "__type": "RPSliderAnswerFormat",
            "prefix": "Muy mal",
            "suffix": "Muy bien",
            "divisions": 100,
            "max_value": 50,
            "min_value": -50,
            "init_value": 0,
            "question_type": "Scale"
          }
        }
      ],
      "title": "Desde tu último registro:",
      "__type": "RPFormStep",
      "optional": false,
      "identifier": "social_interaction_questionnaire",
      "answer_format": {
        "__type": "RPFormAnswerFormat",
        "question_type": "Form"
      }
    }
  ],
  "__type": "RPOrderedTask",
  "identifier": "daily_survey",
  "close_after_finished": true
}
""";
