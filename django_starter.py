import re
from sys import argv


PROJECT_NAME = argv[1]
SETTINGS_BASE = f'{PROJECT_NAME}/config/settings/base.py'


def main():
    with open(SETTINGS_BASE, 'r') as settings_base:
        content = settings_base.read()
    new_content = re.sub(r"SECRET_KEY\s*=\s*'.*?'", "SECRET_KEY = environ.get('DJANGO_SECRET_KEY')", content)
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
    ).replace(
        '# Application definition',
        f'# Application definition\n\nTHIRD_PARTY_APPS = []\n{PROJECT_NAME.upper()}_APPS = ["{PROJECT_NAME}.users.apps.UsersConfig"]'
    ).replace(
        'INSTALLED_APPS',
        'DJANGO_APPS',
    ).replace(
        'MIDDLEWARE = [',
        f'INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + {PROJECT_NAME.upper()}_APPS\n\nMIDDLEWARE = ['
    ).replace(
        'from pathlib import Path', 'from pathlib import Path\n\nfrom os import environ'
    )
    with open(SETTINGS_BASE, 'w') as settings_base:
        settings_base.write(
            f"{new_content}\n\n# Override with custom user model\nAUTH_USER_MODEL = 'users.User'"
        )

    with open('manage.py', 'r') as manage_py:
        content = manage_py.read()

    content = content.replace(
        'import os', ''
    ).replace(
        'import sys',
        'import sys\n\nfrom dotenv import load_dotenv'
    ).replace(
        f"os.environ.setdefault('DJANGO_SETTINGS_MODULE', '{PROJECT_NAME}.settings')",
        'load_dotenv()'
    )
    with open('manage.py', 'w') as manage_py:
        manage_py.write(content)


if __name__ == '__main__':
    main()

