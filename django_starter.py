import re
from sys import argv


PROJECT_NAME = argv[1]
SETTINGS_BASE = f'{PROJECT_NAME}/config/settings/base.py'


def main():
    with open(SETTINGS_BASE, 'r') as settings_base:
        content = settings_base.read()
    new_content = re.sub(r"SECRET_KEY\s*=\s*'.*?'", "SECRET_KEY = environ.get('DJANGO_SECRETKEY')", content)
    new_content = new_content.replace(
        "# SECURITY WARNING: don't run with debug turned on in production!",
        ''
    ).replace(
        'DEBUG = True', ''
    ).replace(
        'ALLOWED_HOSTS = []', ''
    ).replace(
        '\n\n\n\n\n', ''
    ).replace(
        f"WSGI_APPLICATION = '{PROJECT_NAME}.wsgi.application'",
        f"WSGI_APPLICATION = '{PROJECT_NAME}.config.wsgi.application'",
    ).replace(
        f"ROOT_URLCONF = '{PROJECT_NAME}.urls'",
        f"ROOT_URLCONF = '{PROJECT_NAME}.config.urls'",
    )
    with open(SETTINGS_BASE, 'w') as settings_base:
        settings_base.write(
            f"{new_content}\n\n# Override with custom user model\nAUTH_USER_MODEL = 'users.User'"
        )


if __name__ == '__main__':
    main()

