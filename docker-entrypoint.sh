
#Mise en place du fichier de configuration apache
COPY httpd.conf /tmp/httpd.template
RUN envsubst < "/tmp/httpd.template" > "${BASEDIR_APACHE}/conf/httpd.conf"

#On met en place l'host du mysql localhost par defaut
$APACHE_ROOT_DIR/phabricator/bin/config set mysql.host $MYSQL_HOST
#On met en place le user du mysql root par defaut
$APACHE_ROOT_DIR/phabricator/bin/config set mysql.user $MYSQL_USER
#On met en place le password du mysql admin par defaut
$APACHE_ROOT_DIR/phabricator/bin/config set mysql.pass $MYSQL_PASSWORD

#On met a jour la database si besoin
$APACHE_ROOT_DIR/phabricator/bin/storage upgrade --user $MYSQL_USER --password $MYSQL_PASSWORD

#on demarrage apache
/usr/sbin/httpd -D FOREGROUND
