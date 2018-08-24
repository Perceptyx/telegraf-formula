{% from "telegraf/map.jinja" import telegraf with context %}

{% if grains['os'] == 'Ubuntu' %}
influxdata_repo:
  pkgrepo.managed:
    - humanname: Influxdata repo
    - name: {{ telegraf.pkg_repo }}
    - key_url: http://repos-backend.influxdata.com/influxdb.key
    - file: /etc/apt/sources.list.d/influxdata.list
    - require_in:
      - pkg: telegraf
{% endif %}

{% if grains['os'] == 'Fedora' %}
telegraf_pkg:
  pkg.installed:
    - sources:
      - telegraf: https://dl.influxdata.com/telegraf/releases/telegraf-1.7.3-1.x86_64.rpm
{% else %}

telegraf_pkg:
  pkg.installed:
    - name: telegraf
{% endif %}

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
