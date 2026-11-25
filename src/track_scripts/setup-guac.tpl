#!/bin/bash
# Guacamole gateway: one RDP connection per Windows VM. Used by the "SQL" and "Windows" tabs.
set -euxo pipefail
mkdir -p /config/guacamole
cat > /config/guacamole/user-mapping.xml <<'XML'
<user-mapping>
  <authorize username="guac_user" password="guac_password">
    <connection name="kp-sql01">
      <protocol>rdp</protocol>
      <param name="hostname">kp-sql01</param>
      <param name="port">3389</param>
      <param name="username">instruqt</param>
      <param name="password">Passw0rd!</param>
      <param name="ignore-cert">true</param>
    </connection>
    <connection name="kp-win01">
      <protocol>rdp</protocol>
      <param name="hostname">kp-win01</param>
      <param name="port">3389</param>
      <param name="username">instruqt</param>
      <param name="password">Passw0rd!</param>
      <param name="ignore-cert">true</param>
    </connection>
  </authorize>
</user-mapping>
XML
