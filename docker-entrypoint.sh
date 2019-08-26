#!/bin/bash

envsubst < "/tmp/httpd.template" > "${BASEDIR_APACHE}/conf/httpd.conf"

#On met en place l'host du mysql localhost par defaut
envsubst < "/tmp/local.template" >  "${APACHE_ROOT_DIR}/phabricator/conf/local/local.json"

#On met en place la configuration pour les notifications
envsubst < "/tmp/aphlict.custom.json.template" >  "${APACHE_ROOT_DIR}/phabricator/conf/aphlict/aphlict.custom.json"

# mise en place du registry crédit agricole
npm set strict-ssl $NPM_VERIFY_SSL

# mise en place du registry crédit agricole
npm config set registry $REGISTRY_NPM

#install de ws module pour le lancemente de aphlict pour les notifications
cd ${APACHE_ROOT_DIR}/phabricator/support/aphlict/server && npm install ws

#On met a jour la database si besoin
cd ${APACHE_ROOT_DIR}/phabricator && ./bin/storage upgrade --force

#demarrage du deamon phabricator
echo "demarrage du deamon phabricator"
${APACHE_ROOT_DIR}/phabricator/bin/phd start

#demarrage le server de notification
echo "demarrage du deamon aphlict"
${APACHE_ROOT_DIR}/phabricator/bin/aphlict restart --config ${APACHE_ROOT_DIR}/phabricator/conf/aphlict/aphlict.custom.json

#on demarrage apache
echo "demarrage d'apache"
/usr/sbin/httpd -k restart -D FOREGROUND
