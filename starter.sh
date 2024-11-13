#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided for project name."
    echo "Usage: $0 <project-name>"
    exit 1
fi

echo " *** Generating a new Django project with THE PROPER layout."
echo " Remember to have Django installed in your environment."
echo " *** Project name: $1"
# generate project
django-admin startproject  $1 .
