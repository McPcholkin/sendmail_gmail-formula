{% from "sendmail/map.jinja" import sendmail with context %}

{% set user = sendmail.user if sendmail.user is defined else 'root' %}
{% set email = sendmail.account.email %}
{% set password = sendmail.account.password %}
{% set starttls = True %}

{% if email %}
include:
  - sendmail.install

authinfo_config:
  file.managed:
    - name: {{ sendmail.auth_dir }}/{{ sendmail.authinfo }}
    - user: root
    - group: smmsp
    - makedirs: True
    - source: salt://sendmail/files/authinfo.jinja
    - template: jinja
    - defaults:
        user: {{ user }}
        email: {{ email }}
        password: {{ password }}
    - reguire:
      - pkg: install_{{ sendmail.pkg }}
    - watch_in:
      - service: run_{{ sendmail.service }}

create_auth_db:
  cmd.run:
    - name: makemap hash -r {{ sendmail.auth_dir }}/{{ sendmail.authinfo }} < {{ sendmail.auth_dir }}/{{ sendmail.authinfo }}
    {% if not sendmail.account.force %}
    - unless: test -f {{ sendmail.auth_dir }}/{{ sendmail.authinfo }}.db
    {% endif %}
    - reguire:
      - pkg: install_{{ sendmail.pkg }}
      - file: authinfo_config
    - watch:
      - file: authinfo_config
    - watch_in:
      - service: run_{{ sendmail.service }}


config_sendmail:
  file.managed:
    - name: {{ sendmail.config_dir }}/{{ sendmail.config }}
    - user: root
    - group: smmsp
    - source: salt://sendmail/files/sendmail.mc
    - template: jinja
    - defaults:
      starttls: {{ starttls }}
      authinfo_path: {{ sendmail.auth_dir }}/{{ sendmail.authinfo }}.db
    - reguire:
      - file: authinfo_config

make_config_sendmail:
  cmd.run:
    - name: make -C {{ sendmail.config_dir }}
    - reguire:
      - file: config_sendmail
    - watch:
      - file: config_sendmail
    - watch_in:
      - service: run_{{ sendmail.service }}


{% endif %}
