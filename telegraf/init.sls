{% from "telegraf/map.jinja" import telegraf with context %}

{% if not grains['os'] == 'FreeBSD' %}
influxdata_repo:
  pkgrepo.managed:
    - humanname: Influxdata repo
    - name: {{ telegraf.pkg_repo }}
    - key_url: http://repos-backend.influxdata.com/influxdb.key
    - file: /etc/apt/sources.list.d/influxdata.list
    - require_in:
      - pkg: telegraf
{% endif %}

telegraf_pkg:
  pkg.installed:
    - name: telegraf

telegraf_conf:
  file.managed:
    {% if grains['os'] == 'FreeBSD' %}
    - name: /usr/local/etc/telegraf.conf
    {% else %}
    - name: /etc/telegraf/telegraf.conf
    {% endif %}
    - source: salt://telegraf/templates/telegraf.conf
    - template: jinja

telegraf_service:
  service.running:
    - name: telegraf
    - enable: True
    - watch:
      - file: telegraf_conf
    - require:
      - pkg: telegraf

{% if grains['os'] == 'FreeBSD' %}
telegraf_newsyslog_conf:
  file.managed:
    - name: /etc/newsyslog.conf.d/telegraf
    - source: salt://telegraf/templates/telegraf
    - owner: root
    - group: wheel
    - template: jinja
{% endif %}
