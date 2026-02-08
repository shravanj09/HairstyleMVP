FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY local_app /app/local_app

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "local_app.app:app", "--host", "0.0.0.0", "--port", "8000"]
