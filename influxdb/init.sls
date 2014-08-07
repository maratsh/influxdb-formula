{% from "influxdb/map.jinja" import map with context %}

influxdb_package:
  file:
    - managed
    - name: /tmp/influxdb.deb
    - source: http://s3.amazonaws.com/influxdb/{{ map["package"] }}
    - source_hash: md5={{ map["md5"] }}

install_influxdb:
  pkg:
    - installed
    - sources:
      - influxdb: /tmp/influxdb.deb
    - require:
      - file: influxdb_package
    - watch:
      - file: influxdb_package

influxdb_confdir:
  file:
    - directory
    - name: /etc/influxdb
    - owner: root
    - gropp: root
    - mode: 755

influxdb_config:
  file:
    - managed
    - name: /etc/influxdb/config.toml
    - source: salt://influxdb/templates/config.toml.jinja
    - owner: root
    - gropp: root
    - mode: 644
    - template: jinja

start_influxdb:
  service:
    - running
    - name: influxdb
    - enable: True
    - watch:
      - pkg: install_influxdb
      - file: influxdb_package
      - file: influxdb_config
    - require:
      - pkg: install_influxdb
      - file: influxdb_package
