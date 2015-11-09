#!/bin/bash

set -e 

[ "$DEBUG" == "1" ] && set -x && set +e

if [ -z "${GLUSTER_IDENTITY}" ]; then
   echo "*** Must specify a GLUSTER_IDENTITY to use - Exiting ..."
   exit 1
fi

if [ "${ROOT_PASSWORD}" == "**ChangeMe**" -o -z "${ROOT_PASSWORD}" ]; then
   echo "*** ERROR: you need to define ROOT_PASSWORD environment variable - Exiting ..."
   exit 1
fi

if [ "${GLUSTER_PEERS}" == "**ChangeMe**" -o -z "${GLUSTER_PEERS}" ]; then
   echo "*** ERROR: you need to define GLUSTER_PEERS environment variable - Exiting ..."
   exit 1
fi

if [ "$USE_PUBLIC_IP_ADDRESS" == "true" ]; then
   echo "*** INFO: Determining public IP address..."
   export MY_CLOUD_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
else
   echo "*** INFO: Determining private IP address..."
   export MY_CLOUD_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
fi

if [ -z "${MY_CLOUD_IP}" ]; then
   echo "*** WARNING: Could not determine IP address, attempting workaround..."
   export MY_CLOUD_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi

if [ -z "${MY_CLOUD_IP}" ]; then
   echo "*** ERROR: Could not determine IP address - Exiting ..."
   exit 1
else
   echo "*** INFO: Determined following IP address as my own: ${MY_CLOUD_IP}"
fi

echo "root:${ROOT_PASSWORD}" | chpasswd

# Prepare a shell to initialize docker environment variables for ssh
echo "#!/bin/bash" > ${GLUSTER_CONF_FLAG}
echo "ROOT_PASSWORD=\"${ROOT_PASSWORD}\"" >> ${GLUSTER_CONF_FLAG}
echo "SSH_PORT=\"${SSH_PORT}\"" >> ${GLUSTER_CONF_FLAG}
echo "SSH_USER=\"${SSH_USER}\"" >> ${GLUSTER_CONF_FLAG}
echo "SSH_OPTS=\"${SSH_OPTS}\"" >> ${GLUSTER_CONF_FLAG}
echo "GLUSTER_VOL=\"${GLUSTER_VOL}\"" >> ${GLUSTER_CONF_FLAG}
echo "GLUSTER_BRICK_PATH=\"${GLUSTER_BRICK_PATH}\"" >> ${GLUSTER_CONF_FLAG}
echo "DEBUG=\"${DEBUG}\"" >> ${GLUSTER_CONF_FLAG}
echo "MY_CLOUD_IP=\"${MY_CLOUD_IP}\"" >> ${GLUSTER_CONF_FLAG}
echo "GLUSTER_IDENTITY=\"${GLUSTER_IDENTITY}\"" >> ${GLUSTER_CONF_FLAG}

join-gluster.sh &
/usr/bin/supervisord
