const informed_consent = r'''
{
    "__type": "RPOrderedTask",
    "steps": [
        {
            "text": "",
            "__type": "RPConsentReviewStep",
            "identifier": "consentreviewstepID",
            "title": "",
            "text": "",
            "optional": false,
            "consent_document": {
                "__type": "RPConsentDocument",
                "title": "Consentimiento informado",
                "signatures": [],
                "sections": [
                    {
                        "type": "Overview",
                        "__type": "RPConsentSection",
                        "title": "Tu participación en el estudio",
                        "summary": "",
                        "content": "Tu participación en esta iniciativa consistirá en instalar una aplicación en tu teléfono móvil que registrará automáticamente datos de algunos de los sensores de tu dispositivo (luz y ruido ambiental, estado de la pantalla, movimiento del dispositivo, tipo de conexión a internet, puntos de acceso Wi-Fi cercanos). Para ello deberás otorgar una serie de permisos que te aparecerán tras aceptar este consentimiento.  Después, deberás responder a un cuestionario inicial sobre tu bienestar. A partir de ese momento recibirás una notificación de la app que te solicitará responder a cuatro preguntas sobre cómo te sientes en ese momento y si has vivido alguna situación a nivel emocional desde la última notificación. Esta encuesta se repetirá 6 veces al día."
                    },
                    {
                        "type": "Goals",
                        "__type": "RPConsentSection",
                        "title": "Objetivos del estudio",
                        "summary": "",
                        "content": "El proyecto POSTCOVID-AI está dirigido por el Profesor Oresti Baños (oresti@ugr.es), junto con un equipo de investigadores de la Universidad de Granada y de la Universidad Complutense de Madrid. El objetivo es estudiar el impacto del contexto diario posterior a la COVID-19 en el bienestar de la población española."
                    },
                    {
                        "type": "Privacy",
                        "__type": "RPConsentSection",
                        "title": "Política de privacidad",
                        "summary": "",
                        "content": "Para proteger tu privacidad, los datos recogidos se identificarán usando un código alfanumérico y se almacenarán en formato electrónico de manera totalmente anónima. Los datos serán utilizados para su análisis y posterior estudio por el investigador principal y los otros miembros del grupo investigador. Los resultados derivados de este estudio serán de dominio público para que cualquier organismo competente pueda considerarlos en la gestión de la (post)crisis provocada por el coronavirus. Además, los datos y resultados podrán publicarse en alguna revista o congreso científico, con el propósito de compartir la investigación con el resto de la comunidad científica."
                    },
                    {
                        "type": "Withdrawing",
                        "__type": "RPConsentSection",
                        "title": "Derechos del participante",
                        "summary": "",
                        "content": "La participación en el estudio es libre y voluntaria. En cualquier momento podrás retirarte del estudio. Durante la realización del estudio podrás ejercer en todo momento tu derecho de acceso, rectificación, cancelación y oposición a tus datos ante el investigador responsable, tal como establecen la Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y garantía de los derechos digitales y el Reglamento (UE) 2016/679 del Parlamento Europeo y del Consejo, de 27 de abril de 2016."
                    }
                ]
            },
            "reason_for_consent": "Si pulsas el botón “ACEPTO” se considera que eres mayor de edad, que has leído la información proporcionada y que decides voluntariamente participar en este proyecto."
        }
    ],
    "identifier": "consentTaskID",
    "close_after_finished": false
}
''';
