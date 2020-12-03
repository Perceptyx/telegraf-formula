{% from "telegraf/map.jinja" import telegraf with context %}

{% if grains['os_family'] == 'Debian' %}
influxdata_repo:
  pkgrepo.managed:
    - humanname: Influxdata repo
    - name: {{ telegraf.pkg_repo }}
    - key_url: http://repos-backend.influxdata.com/influxdb.key
    - file: /etc/apt/sources.list.d/influxdata.list
    - require_in:
      - pkg: telegraf
{% elif grains['os_family'] == 'RedHat' %}
influxdata_repo:
  pkgrepo.managed:
    - humanname: CentOS-$releasever - Base
    - baseurl: https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
    - gpgcheck: 1
    - gpgkey: https://repos.influxdata.com/influxdb.key
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
