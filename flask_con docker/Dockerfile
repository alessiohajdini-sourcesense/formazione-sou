FROM python:3.11-slim

LABEL authors="alessiohajdini"

WORKDIR /app

COPY app.py .

RUN pip install flask

EXPOSE 8000

CMD ["python" , "app.py"]