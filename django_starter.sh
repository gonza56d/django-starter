#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided for project name."
    echo "Usage: $0 <project-name>"
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
## create env files
touch .env
touch .env.copy
echo "DJANGO_SECRET_KEY=" >> .env.copy
echo "DJANGO_SECRET_KEY=" >> .env

## run python script
python3 django_starter.py $1
