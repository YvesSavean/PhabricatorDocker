FROM ttp10-dckreg.ca-technologies.fr/tec/im_tec_osd_rhe7:7.5.3

#Utilisation du user root pour la mise en place
USER root

#creation de l'utilisateur spécific pour phabricator
RUN useradd -ms /bin/bash phabricator

ENV APACHE_PORT=8081
ENV APACHE_ROOT_DIR="/var/www/html"/
ENV BASEDIR_APACHE="etc/httpd/"
ENV DOMAIN="localhost"
ENV MYSQL_HOST=localhost
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=admin
ENV MYSQL_PORT=3306
ENV REPO="/var/repo/"
ENV NODE_VERSION="v12.8.0"

#PATH du repertoire contenant nodejs
ENV PATH_NODE=/usr/local/lib/nodejs
ENV REGISTRY_NPM="http://10.166.93.83:8081/repository/npm-public/"
ENV NPM_VERIFY_SSL=false


#Port de connexion pour les notifications, a gérer en fonction du firewall
ENV  NOTIFICATION_PORT_CLIENT: 8082
ENV NOTIFICATION_PORT_ADMIN: 8083


#Mise a jour du systems
RUN yum -y distribution-synchronization

#Installation des dépendances necessaires
RUN yum install -y git httpd php php-mysqlnd php-gd php-curl php-cli php-mbstring gettext python-pygments php-process && yum clean all

#creation du repertoire node
RUN mkdir -p ${PATH_NODE}

#Copie du tgz node, Decompression du node JS dans le PATH NODE et Suppression du tgz récupérer
COPY nodeJs/node-${NODE_VERSION}-linux-x64.tar.gz /tmp/node-${NODE_VERSION}-linux-x64.tar.gz 
RUN tar -xvzf /tmp/node-${NODE_VERSION}-linux-x64.tar.gz -C ${PATH_NODE} && rm -f /tmp/node-$NODE_VERSION-linux-x64.tar.gz

#Copie du header tgz node 
COPY nodeJs/node-$NODE_VERSION-headers.tar.gz ${PATH_NODE}/node-$NODE_VERSION-headers.tar.gz

#donne les droits au user node sur le repertoire crée
RUN chown -R phabricator:root ${PATH_NODE}

# creation des variables NODEJS_HOME et ajout dans le PATH
ENV NODEJS_HOME=${PATH_NODE}/node-$NODE_VERSION-linux-x64/bin
ENV PATH=${NODEJS_HOME}:${PATH}

#Configuration du User pour npm, Définissez sur true pour supprimer la commutation UID / GID lors de l'exécution des scripts de package. Si la valeur false est définie explicitement, l'installation en tant qu'utilisateur non-root échouera.
RUN npm -g config set user phabricator&& npm -g config set unsafe-perm=true


#Installation de phabricator
# RUN mkdir -p $APACHE_ROOT_DIR && cd $APACHE_ROOT_DIR && git clone https://github.com/phacility/libphutil.git --branch stable && git clone https://github.com/phacility/arcanist.git --branch stable && git clone https://github.com/phacility/phabricator.git --branch stable
COPY libphutil $APACHE_ROOT_DIR/libphutil
COPY arcanist $APACHE_ROOT_DIR/arcanist
COPY phabricator $APACHE_ROOT_DIR/phabricator

#on crée le repo
RUN mkdir -p $REPO

#On corrige le bug qui empeche de lancer des commandes git
RUN ln -s /usr/libexec/git-core/git-http-backend /usr/bin/git-http-backend

#on donne des droits a l'utilisateur phabricator
RUN chown -R phabricator:root $BASEDIR_APACHE \
&& chown -R phabricator:root /usr/bin/git-http-backend \
&& chown phabricator:root /usr/sbin/httpd \
&& chown -R phabricator:root /etc/httpd/ \
&& chown -R phabricator:root /run/httpd \
&& chown -R phabricator:root /var/log/httpd \
&& chown -R phabricator:root /usr/lib64/httpd/modules \
&& chown -R phabricator:root /run/httpd \
&& chown -R phabricator:root $APACHE_ROOT_DIR  \
&& chown -R phabricator:root $REPO

#Mise en place du fichier de configuration phabricator
COPY local.conf /tmp/local.template

#Mise en place du fichier de configuration aphlict
COPY aphlict.custom.json /tmp/aphlict.custom.json.template

#Mise en place du fichier de configuration apache
COPY httpd.conf /tmp/httpd.template

#Configuration du php.ini
COPY php.ini /etc/php.ini

#on donne des droits a l'utilisateur phabricator
RUN chown phabricator:root /tmp/local.template && chown phabricator:root /tmp/httpd.template

#Copie de l'entrypoint et on donne les droits a l'utilisateur phabricator
COPY docker-entrypoint.sh /opt/var/docker-entrypoint.sh 
RUN chown phabricator:root /opt/var/docker-entrypoint.sh && chmod +x /opt/var/docker-entrypoint.sh

VOLUME $REPO

#Utilisation du user phabricator pour la suite possedant les droits apaches et phabricator
USER phabricator

ENTRYPOINT ["/opt/var/docker-entrypoint.sh"]
