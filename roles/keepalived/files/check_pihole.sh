#!/bin/bash
set -e

PIHOLE_HOME="/home/ohthehugemanatee/pihole"
DHCP_ENABLED=true
VNET_IP=10.10.10.40
DHCP_START=10.10.10.100
DHCP_END=10.10.10.251
DHCP_GATEWAY=10.10.10.1
DHCP_DOMAIN=vert
DHCP_LEASE_TIME=24

# Check if the pihole container is healthy (0) or not (1).
[ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" = "healthy" ] && HEALTHY=0 || HEALTHY=1

# If the container is not healthy, exit 1.
if ! [ ${HEALTHY} ]; then
  exit ${HEALTHY}
fi

# If DHCP is not enabled, or we don't own the virtual IP
if ! ${DHCP_ENABLED} || ! /usr/sbin/ip a |grep -q ${VNET_IP} ; then
    # Ensure DHCP is disabled.
    if [ -f ${PIHOLE_HOME}/dnsmasq.d/02-pihole-dhcp.conf ]; then
        /usr/bin/docker exec -d pihole /usr/local/bin/pihole -a disabledhcp
    fi
    # Exit with the health status of the container (0).
    exit ${HEALTHY}
fi

# Ensure DHCP is enabled.
if ! [ -f ${PIHOLE_HOME}/dnsmasq.d/02-pihole-dhcp.conf ]; then
    /usr/bin/docker exec -d pihole /usr/local/bin/pihole -a enabledhcp "${DHCP_START}" "${DHCP_END}" "${DHCP_GATEWAY}" "${DHCP_LEASE_TIME}" "${DHCP_DOMAIN}"
fi

# Exit with the health status of the container (0).
exit ${HEALTHY}
