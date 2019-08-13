FROM ttp10-dckreg.ca-technologies.fr/tec/im_tec_osd_rhe7:7.5.3

#Utilisation du user root pour la mise en place
USER root

#creation de l'utilisateur spécific pour phabricator
RUN useradd -ms /bin/bash phabricator

ENV APACHE_ROOT_DIR="/var/www/html"/
ENV BASEDIR_APACHE="etc/httpd/"
ENV DOMAIN="localhost"
ENV MYSQL_HOST=localhost
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=admin
ENV MYSQL_PORT=3306
ENV REPO="/var/repo/"s


#Mise a jour du system
RUN yum -y distribution-synchronization

#Installation des dépendances necessaires
RUN yum install -y git httpd php php-mysqlnd php-gd php-curl php-cli php-mbstring gettext python-pygments php-extname php-process && yum clean all

#Installation de phabricator
RUN mkdir -p $APACHE_ROOT_DIR && cd $APACHE_ROOT_DIR && git clone https://github.com/phacility/libphutil.git --branch stable && git clone https://github.com/phacility/arcanist.git --branch stable && git clone https://github.com/phacility/phabricator.git --branch stable

#on crée le repo
RUN mkdir -p $REPO

#on donne des droits a l'utilisateur phabricator
RUN chown -R phabricator:root $BASEDIR_APACHE && chown phabricator:root /usr/sbin/httpd && chown -R phabricator:root /run/httpd && chown -R phabricator:root $APACHE_ROOT_DIR  && chown -R phabricator:root $REPO

#Mise en place du fichier de configuration phabricator
COPY local.conf /tmp/local.template

#Mise en place du fichier de configuration apache
COPY httpd.conf /tmp/httpd.template

#Configuration du php.ini
COPY php.ini /etc/php.ini

#on donne des droits a l'utilisateur phabricator
RUN chown phabricator:root /tmp/local.template && chown phabricator:root /tmp/httpd.template

#Copie de l'entrypoint et on donne les droits a l'utilisateur phabricator
COPY docker-entrypoint.sh /opt/var/docker-entrypoint.sh 
RUN chown phabricator:root /opt/var/docker-entrypoint.sh && chmod +x /opt/var/docker-entrypoint.sh

#Utilisation du user phabricator pour la suite possedant les droits apaches et phabricator
#USER phabricator

EXPOSE 80
ENTRYPOINT ["/opt/var/docker-entrypoint.sh"]
