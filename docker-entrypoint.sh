#!/bin/bash

#envsubst < "/tmp/httpd.template" > "${BASEDIR_APACHE}/conf/httpd.conf"

#On met en place l'host du mysql localhost par defaut
envsubst < "/tmp/local.template" >  "${APACHE_ROOT_DIR}/phabricator/conf/local/local.json"

#On met a jour la database si besoin
#cd ${APACHE_ROOT_DIR}/phabricator && ./bin/storage upgrade --force

#on demarrage apache
/usr/sbin/httpd -D FOREGROUND
