#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided for project name."
    echo "Usage: $0 <project-name>"
    exit 1
fi
if [[ "$1" == *"-"* ]]; then
    echo "Error: Project name should not contain the '-' character."
    exit 1
fi

echo " *** Generating a new Django project with THE PROPER layout."
echo " Remember to have Django installed in your environment."
echo " *** Project name: $1"
## generate project
django-admin startproject  $1 .
## generate main folders and init files.
mkdir $1/config
mkdir $1/config/settings
touch $1/config/__init__.py
mv $1/settings.py $1/config/settings/base.py
touch $1/config/settings/__init__.py
mkdir tests
touch tests/__init__.py
## move urls and asgi/wsgi
mv $1/urls.py $1/config/urls.py
mv $1/asgi.py $1/config/asgi.py
mv $1/wsgi.py $1/config/wsgi.py
## write local and production files
# settings
touch $1/config/settings/local.py
touch $1/config/settings/production.py
echo "from .base import *


DEBUG = True
ALLOWED_HOSTS = [
    '*',
    'localhost',
    '127.0.0.1',
]" >> $1/config/settings/local.py
echo "from .base import *


DEBUG = False
ALLOWED_HOSTS = []" >> $1/config/settings/production.py
## user model override
mkdir $1/users
touch $1/users/__init__.py 
touch $1/users/apps.py 
touch $1/users/models.py 
echo "from django.apps import AppConfig


class UsersConfig(AppConfig):
    name = '$1.users'
    verbose_name = 'Users'" >> $1/users/apps.py 
echo "from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):

    def create_user(self, email: str, password: str, is_admin: bool = False):
        user = User(email=email, is_staff=is_admin, is_superuser=is_admin)
        user.set_password(password)
        user.save()


class User(AbstractUser):

    username = None
    email = models.EmailField(unique=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = UserManager()" >> $1/users/models.py 

## create env files
touch .env
touch .env.copy
echo "DJANGO_SECRET_KEY=
DJANGO_SETTINGS_MODULE=$1.config.settings.local

# POSTGRES
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=$1

# MONGO
DOCUMENT_DB=$1
DOCUMENT_HOST=mongo
DOCUMENT_PORT=27017

# REDIS
CACHE_PORT=6379
CACHE_SESSION_SECRET_KEY=xCOZkoc-zUyYrB1QWH7EiwPkr-qBtCuymBL81oijC_k
CACHE_TOKEN_EXPIRATION_MINUTES=60" >> .env.copy
echo "DJANGO_SECRET_KEY=
DJANGO_SETTINGS_MODULE=$1.config.settings.local

# POSTGRES
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=$1

# MONGO
DOCUMENT_DB=$1
DOCUMENT_HOST=mongo
DOCUMENT_PORT=27017

# REDIS
CACHE_PORT=6379
CACHE_SESSION_SECRET_KEY=xCOZkoc-zUyYrB1QWH7EiwPkr-qBtCuymBL81oijC_k
CACHE_TOKEN_EXPIRATION_MINUTES=60" >> .env

## requirements
touch requirements.txt
echo "Django==5.1.3
python-dotenv==1.0.1" >> requirements.txt

## run python script
python3 django_starter.py $1

## Dockerize project
touch Dockerfile
touch docker-compose.yml
echo "FROM python:3.10-slim

# Upgrade pip and set work directory
RUN pip install --upgrade pip
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of the application code
COPY . ." >> Dockerfile
echo "services:

  $1:
    build:
      context: .
    env_file:
      - .env
    volumes:
      - .:/app
    ports:
      - '8000:8000'
    command: python manage.py runserver 0.0.0.0:8000
    depends_on:
      - postgres
      - mongo
      - redis

  postgres:
    image: postgres:14.7
    volumes:
      - postgres_data:/var/lib/postgresql/data
    env_file:
      - .env
    ports:
      - '5432:5432'

  mongo:
    image: mongo:4.4.27-rc0
    env_file:
      - .env
    ports:
      - '27017:27017'
    volumes:
      - mongo_data:/data/db

  redis:
    image: redis:7.2.3
    env_file:
      - .env
    ports:
      - '6379:6379'

volumes:
  postgres_data:
  mongo_data:" >> docker-compose.yml
# build and run
docker compose build
docker compose run $1 python manage.py makemigrations users
docker compose run $1 python manage.py migrate
docker compose up
### END ###
echo "\n\n*** DJANGO STARTER ***"
echo "Project created"
echo "**********************"
