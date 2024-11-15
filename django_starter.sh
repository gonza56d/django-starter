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
## Copy seret key and clean up $1/config/settings/base.py
# Extract the value of SECRET_KEY
SECRET_KEY=$(sed -n "s/^SECRET_KEY = '\(.*\)'$/\1/p" $1/config/settings/base.py)

# Check for macOS and use pbcopy
if command -v pbcopy &> /dev/null; then
    echo -n "$SECRET_KEY" | pbcopy
    pbpaste > .env
    pbpaste > .env.copy
# Check for Linux and use xclip or xsel
elif command -v xclip &> /dev/null; then
    echo -n "$SECRET_KEY" | xclip -selection clipboard
    xclip -selection clipboard -o > .env
    xclip -selection clipboard -o > .env.copy
elif command -v xsel &> /dev/null; then
    echo -n "$SECRET_KEY" | xsel --clipboard
    xsel --clipboard --output > .env
    xsel --clipboard --output > .env.copy
else
    echo "No clipboard tool found. Please install pbcopy and pbpaste (macOS) or xclip/xsel (Linux)."
    exit 1
fi


sed -i "s/# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-tov=m1&m)qjx&f-%ds^sip*gm%iu=5!yma9ekx4_b)r!b58#e1'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


//g" $1/config/settings/base.py

echo "Info: SECRET_KEY moved to your .env and .env.copy files."

