# Use the Python version shown in your terminal (3.13)
FROM python:3.13-slim

WORKDIR /app

# Copy the requirements file from your BackEnd folder
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy everything from the BackEnd folder into the container
COPY . .

# FastAPI typically runs on 8000
EXPOSE 8000

# Command based on your terminal: python -m uvicorn app.main:app
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]