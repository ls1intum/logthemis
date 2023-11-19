FROM python:3.10

WORKDIR /app
COPY requirements.txt /app
RUN pip3 install -r requirements.txt

COPY app.py /app/app.py
COPY ai.py /app/ai.py

EXPOSE 5000
CMD ["python3", "app.py"]
