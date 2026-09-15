FROM python:3.9-slim
WORKDIR /app
RUN apt-get update && apt-get install curl -y
COPY app.py .
RUN pip install flask
ENV FLASK_APP=app.py
CMD ["flask", "run", "--host=0.0.0.0"]
