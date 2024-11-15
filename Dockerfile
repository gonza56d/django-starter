# Use a lightweight Linux distribution
FROM alpine:latest

# Install bash and sed
RUN apk add --no-cache bash sed

VAR PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
VAR DJANGO_VERSION
ENV DJANGO_VERSION=${DJANGO_VERSION}
RUN pip install Django==${DJANGO_VERSION}
# Copy your script into the container
COPY django_starter.sh /usr/local/bin/django_starter.sh

# Make the script executable
RUN chmod +x /usr/local/bin/django_starter.sh
