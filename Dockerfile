FROM python:3.10
WORKDIR /app
RUN apt-get update && apt-get install -y python3-distutils
RUN python -m venv venv
RUN . venv/bin/activate && pip install --upgrade pip && pip install django==3.2
COPY . .
RUN . venv/bin/activate && python manage.py migrate
EXPOSE 8000
CMD ["/app/venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
