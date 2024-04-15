bind = '0.0.0.0:8000'
workers = 2
errorlog = '/var/log/postcovid-ai/error.log'
loglevel = 'debug'
accesslog = '/var/log/postcovid-ai/access.log'
proc_name = "POSTCOVID-AI REST API"
raw_env = [
    "SCRIPT_NAME=/postcovid_rest"
]
