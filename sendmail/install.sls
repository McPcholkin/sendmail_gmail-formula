{% from "sendmail/map.jinja" import sendmail with context %}

install_{{ sendmail.pkg }}:
  pkg.installed:
    - name: {{ sendmail.pkg }}

run_{{ sendmail.service }}:
  service.running:
    - name: {{ sendmail.service }}
    - enable: True
    - require:
      - pkg: install_{{ sendmail.pkg }}
