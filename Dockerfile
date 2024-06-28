FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app
COPY ./backend /app/backend
SHELL ["/bin/bash", "-c"]
RUN source /app/backend/env/Scripts/activate
COPY ./requirements.txt /app/requirements.txt
COPY ./manage.py /app/manage.py
COPY ./base /app/base
COPY ./frontend /app/frontend
COPY ./media/images /app/media/images
COPY ./db.json /app
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
RUN pip install -r requirements.txt
EXPOSE 7000
ENTRYPOINT ["/startup.sh"]
 