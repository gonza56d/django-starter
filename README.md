# Django Starter
## What's this?
A small project with custom scripting for initializing new Django projects with the layout suggested from Two Scoops Of Django book, a custom User model and Users app for auth, and your project will start Dockerized with postgres, mongo and redis containers with your Django app connected to these.

## Requirements
Have Django installed in your environment, if you have it in a virtual environment, make sure to activate this environment before running this.

## How to run?
Execute `./django_starter.sh <project_name>` and wait for magic to happen. Once it's ready, you'll find your Django app running at http://localhost:8000.

## Troubleshooting
Make sure to use only letters and underscores for your poject name.
If something goes wrong, delete everything except by `django_starter.sh` and `django_starter.py`. (Note that also .env and .env.copy files could've been created, delete these too).
