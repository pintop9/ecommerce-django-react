#!/bin/sh
python -m venv env && \
    . env/bin/activate
python manage.py migrate
python manage.py loaddata db.json
python manage.py runserver 0.0.0.0:7000