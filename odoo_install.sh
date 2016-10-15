#!/bin/bash
################################################################################
# Script for Installing: ODOO 8 or 9 Community on Ubuntu 16.04
# Author: Gustavo Valverde, iterativo.do 2016
#
# Based on André Schenkels installation script located in github:
# https://github.com/aschenkels-ictstudio/odoo-install-scripts
#-------------------------------------------------------------------------------
# This script will install ODOO Server on a
# clean Ubuntu 16.04 Server
#-------------------------------------------------------------------------------
#
# PREFERRED USE:
# . odoo_install
#
#-------------------------------------------------------------------------------
# IMPORTANT! This script contains extra libraries that are specifically
# needed for Odoo 9.0
#-------------------------------------------------------------------------------
#
################################################################################

#--------------------------------------------------
# Fixed parameters for Odoo
#--------------------------------------------------
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_VIRTENV="venv"
#set the superadmin password
OE_SUPERADMIN="db.p@ssw0rd"
OE_DB="mydb"
OE_INTERFACE='127.0.0.1'


#Set it to false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
#Set the default Odoo port
OE_PORT="8069"
#Choose the Odoo version which you want to install. For example: 9.0, 8.0.
OE_VERSION="9.0"
#Choose the PostgreSQL version which you want to use with Odoo. For example: 9.4, 9.5.
PSQL_VERSION="9.6"
#Change server directory and configuration name
OE_CONFIG="${OE_USER}-server"

###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Set Locale en_US.UTF-8 for PostgreSQL
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*       Changing Locales        *"
echo "*                               *"
echo "*********************************"
# Configure timezone and locale
echo -e "\n---- Setting Locales  ----"
locale-gen --purge "en_US.UTF-8" && \
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
dpkg-reconfigure --frontend=noninteractive locales && \
update-locale LANG=en_US.UTF-8

#---------------------------------------------------
# Timezone for Dominican Republic, change as needed
#---------------------------------------------------
echo -e "\n---- Setting Time Zone  ----"
ln -fs /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

#--------------------------------------------------
# Update the Server
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Updating and upgrading    *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Add PostgreSQL Repository  ----"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
echo -e "\n---- Update and Upgrade  ----"
apt-get update
apt-get dist-upgrade -y

echo "*********************************"
echo "*                               *"
echo "*     ODOO Script initiation    *"
echo "*                               *"
echo "*********************************"

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install dependencies for Odoo build and install ----"
apt-get install -y wget curl git python-pip gdebi-core nano unzip \
python2.7 postgresql-${PSQL_VERSION} gcc python2.7-dev libxml2-dev libxslt1-dev libbz2-dev \
libevent-dev libsasl2-dev libldap2-dev libpq-dev \
libpng12-dev libjpeg-dev  libjpeg8-dev libtiff5-dev \
node-less node-clean-css xfonts-75dpi xfonts-base

#--------------------------------------------------
# Install additional Packages for Odoo
#--------------------------------------------------
echo -e "\n--- Install Less CSS via nodejs and npm"
apt-get -y install npm nodejs
npm install -g npm
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g less
npm install -g less-plugin-clean-css

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
echo -e "\n---- Install dependencies for Odoo build and install ----"
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 9 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  cd /usr/local/src/
  wget $_url
  gdebi --n `basename $_url`
  ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  ln -s /usr/local/bin/wkhtmltoimage /usr/bin
  cd ~
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

echo "*********************************"
echo "*                               *"
echo "*   ODOO system user creation   *"
echo "*                               *"
echo "*********************************"
adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
adduser $OE_USER sudo

#--------------------------------------------------
# Configure PostgreSQL
#--------------------------------------------------
echo -e "\n---- Configure the PostgreSQL database  ----"
sudo -u postgres -i createuser $OE_USER -U postgres -dRS
sudo -u postgres -i createdb -O $OE_USER $OE_DB

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Installing ODOO Server    *"
echo "*                               *"
echo "*********************************"
#echo -e "\n---- As $OE_USER, clone the project repository  ----"
sudo -u $OE_USER -i mkdir $OE_HOME_EXT/
# Here you can clone your specific project configuration, if you have one.
# Code Below must be changed so you don't overwrite this.

echo -e "\n---- As the $OE_USER user, clone the Odoo source code  ----"
sudo -u $OE_USER -i mkdir $OE_HOME_EXT/src
cd $OE_HOME_EXT/src
sudo -u $OE_USER -i git clone --depth 1 --branch $OE_VERSION --single-branch https://www.github.com/odoo/odoo.git $OE_HOME_EXT/src/odoo

echo -e "\n---- Create custom module directory ----"
sudo -u $OE_USER -i mkdir -p $OE_HOME_EXT/data
sudo -u $OE_USER -i mkdir -p $OE_HOME_EXT/src/custom

echo -e "\n---- Creting the log directory ----"
sudo -u $OE_USER -i mkdir $OE_HOME_EXT/log/

echo "*********************************"
echo "*                               *"
echo "*     Creating VirtualEnv       *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Configuring virtualenv for Odoo ----"
cd /usr/local/src/
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install virtualenv
cd ~

echo -e "\n---- Configuring virtualenv for Odoo ----"
sudo -H -u $OE_USER sh -c "virtualenv ~/$OE_VIRTENV"
source /$OE_USER/$OE_VIRTENV/bin/activate

echo -e "\n---- Install Odoo python dependencies in requirements.txt ----"
sudo -H -u $OE_USER sh -c "~/$OE_VIRTENV/bin/pip install --upgrade setuptools"
sudo -H -u $OE_USER sh -c "~/$OE_VIRTENV/bin/pip install -r $OE_HOME_EXT/src/odoo/requirements.txt"

echo -e "\n---- Install additional python dependencies ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04 and 15.04
sudo -H -u $OE_USER sh -c "~/$OE_VIRTENV/bin/pip install suds"
deactivate

echo "*********************************"
echo "*                               *"
echo "*     Installing Optionals      *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Add Optional installation libraries ----"
apt-get -y install libgeoip-dev libffi-dev libssl-dev geoip-database-contrib libboolean-perl
# Additional (kind of optional) dependencies
sudo -H -u $OE_USER sh -c "~/$OE_VIRTENV/bin/pip install unicodecsv urllib3 GeoIP html5lib passlib pysftp num2words"

sudo chown -R $OE_USER:$OE_USER $OE_HOME/*
sudo -u $OE_USER -i mkdir /$OE_USER/odoo-server/src/marcos_addons
sudo -u $OE_USER -i mkdir /$OE_USER/odoo-server/src/custom

echo "*********************************"
echo "*                               *"
echo "*  Install Third-party Addons   *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Clone all third-party addon repositories in the $OE_HOME_EXT/src subdirectory ----"
sudo -u $OE_USER -i mkdir $OE_HOME_EXT/src/custom/partner-contact
sudo -u $OE_USER -i git clone --depth 1 --branch $OE_VERSION --single-branch https://github.com/OCA/partner-contact.git $OE_HOME_EXT/src/custom/partner-contact

sudo -u $OE_USER -i mkdir $OE_HOME_EXT/src/custom/web
sudo -u $OE_USER -i git clone --depth 1 --branch $OE_VERSION --single-branch https://github.com/OCA/web.git $OE_HOME_EXT/src/custom/web

sudo -u $OE_USER -i mkdir $OE_HOME_EXT/src/custom/contract
sudo -u $OE_USER -i git clone --depth 1 --branch $OE_VERSION --single-branch https://github.com/OCA/contract $OE_HOME_EXT/src/custom/contract

#--------------------------------------------------
# Here starts the configuration of Odoo
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*       Configuring Odoo        *"
echo "*                               *"
echo "*********************************"
#--------------------------------------------------
# Startup File
#--------------------------------------------------
echo -e "* Create the Odoo startup file"
sudo -u $OE_USER -i mkdir $OE_HOME_EXT/bin
sudo -u $OE_USER -i cat <<EOF > $OE_HOME_EXT/bin/start-odoo
#!/bin/sh
PYTHON=~${OE_USER}/$OE_VIRTENV/bin/python
ODOO=~${OE_USER}/${OE_CONFIG}/src/odoo/odoo.py
CONF=~${OE_USER}/${OE_CONFIG}/${OE_CONFIG}.conf
\${PYTHON} \${ODOO} -c \${CONF} \$*
EOF

echo -e "* Make it executable"
chown $OE_USER:$OE_USER -R $OE_HOME_EXT/bin
sudo -u $OE_USER -i chmod +x $OE_HOME_EXT/bin/start-odoo

echo -e "* Create server config file"
sudo -u $OE_USER -i cat <<EOF > $OE_HOME_EXT/${OE_CONFIG}.conf
[options]
addons_path = $OE_HOME_EXT/src/odoo/addons,$OE_HOME_EXT/src/odoo/openerp/addons,$OE_HOME_EXT/src/custom,$OE_HOME_EXT/src/custom/partner-contact,$OE_HOME_EXT/src/custom/web,$OE_HOME_EXT/src/custom/contract
admin_passwd = $OE_SUPERADMIN
data_dir = $OE_HOME_EXT/data
db_host = False
db_maxconn = 64
db_name = $OE_DB
db_password = False
db_port = False
db_template = template1
db_user = False
dbfilter = $OE_DB\$
list_db = True
geoip_database = /usr/share/GeoIP/GeoLiteCity.dat
log_handler = :WARNING,werkzeug:CRITICAL,openerp.service.server:INFO
log_level = warn
logfile = $OE_HOME_EXT/log/$OE_CONFIG$1.log
logrotate = True
proxy_mode = True
workers = 3
without_demo = True
xmlrpc_interface = $OE_INTERFACE
xmlrpc_port = $OE_PORT
longpolling_port = 8072
netrpc_interface = $OE_INTERFACE
EOF

chown $OE_USER:$OE_USER -R $OE_HOME_EXT/*

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Adding ODOO as service    *"
echo "*                               *"
echo "*********************************"
cat <<EOF > /lib/systemd/system/odoo.service
[Unit]
Description=Odoo $OE_VERSION
After=postgresql.service
[Service]
Type=simple
User=$OE_USER
Group=$OE_USER
ExecStart=$OE_HOME_EXT/bin/start-odoo
[Install]
WantedBy=multi-user.target
EOF

echo -e "* Register the service"
systemctl enable odoo.service


#!/bin/bash
#--------------------------------------------------
# Fixed parameters for NGINX
#--------------------------------------------------
#General Domain and Server
DOMAIN_NAME="EXAMPLE.COM" #change with your domain
SRVR_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

#Odoo Web Gui configuration for Nginx
ODOO_SRVC="odoo"
ODOO_IP="127.0.0.1" #$SRVR_IP, Loopback or your private odoo server IP
ODOO_PORT="8069"
HTTP_PORT="80" #HTTP External Port
HTTPS_PORT="443" #HTTPS External Port

#Change to your company details
country="DO"
state="Santo_Domingo"
locality="DN"
organization="iterativo.do"
organizationalunit="IT"
email="help@iterativo.do"
commonname=$DOMAIN_NAME

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Updating and upgrading    *"
echo "*                               *"
echo "*********************************"
sudo apt-get update
sudo apt-get dist-upgrade -y

#--------------------------------------------------
# Nginx Install
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*    NGINX and dependencies     *"
echo "*                               *"
echo "*********************************"
apt-get -y install nginx-light
apt-get -y install openssl
apt-get -y install git bc curl

#--------------------------------------------------
# SSL Self-signed Certificate generation
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*  SSL Certificate generation   *"
echo "*                               *"
echo "*********************************"
if [ -z "$DOMAIN_NAME" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi

echo -e "\n---- Generating RSA private key with 2048 bit RSA key.  ----"
sudo mkdir /etc/nginx/ssl
cd /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.pem -out cert.pem \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

echo -e "\n---- Getting ownership of key.pem and cert.pem.  ----"
sudo chmod a-wx *                     # make files read only
sudo chown www-data:root *            # access only to www-data group
cd ~

#--------------------------------------------------
# NGINX Configuration
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "* NGINX Conf as Reverse Proxy   *"
echo "*                               *"
echo "*********************************"

echo -e "\n---- Setting up Nginx configurations.  ----"
touch /etc/nginx/sites-available/$ODOO_SRVC

echo -e "\n---- Starting conf for $ODOO_SRVC.  ----"
cat <<EOF > /etc/nginx/sites-available/$ODOO_SRVC
upstream $ODOO_SRVC {
    server $ODOO_IP:$ODOO_PORT;
}

upstream ${ODOO_SRVC}-im {
    server $ODOO_IP:8072;
}

## http redirects to https ##

server {
    listen      $HTTP_PORT;
    server_name _;
    add_header Strict-Transport-Security max-age=15768000;

    # Redirect 301 to HTTPS
    return 301 https://\$host:$HTTPS_PORT\$request_uri;

    # log files
    access_log  /var/log/nginx/${ODOO_SRVC}.access.log;
    error_log   /var/log/nginx/${ODOO_SRVC}.error.log;
}

## https site##
server {
    listen      $HTTPS_PORT ssl;
    server_name _;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # add ssl specific settings
    keepalive_timeout         60;

    # increase proxy buffer to handle some OpenERP web requests
    proxy_buffers             16 64k;
    proxy_buffer_size         128k;

    # Specifies the maximum accepted body size of a client request,
    # as indicated by the request header Content-Length.
    client_max_body_size 128M;
    gzip on;

    # force timeouts if the backend dies
    proxy_read_timeout 600s;

    index index.html index.htm index.php;

    # Set headers
    add_header Strict-Transport-Security "max-age=31536000";
    proxy_set_header        Host              \$http_host;
    proxy_set_header        X-Real-IP         \$remote_addr;
    proxy_set_header        X-Forward-For     \$proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto https;
    proxy_set_header        X-Forwarded-Host  \$http_host;

    ## default location ##
    location / {
        proxy_pass              http://$ODOO_SRVC;
        proxy_read_timeout      6h;
        proxy_connect_timeout   5s;
        proxy_redirect          http://\$http_host/ https://\$host:\$server_port/;
        add_header X-Static     no;
        proxy_buffer_size       64k;
        proxy_buffering         off;
        proxy_buffers 4         64k;
        proxy_busy_buffers_size 64k;
        proxy_intercept_errors  on;
    }

    location /longpolling {
        proxy_pass          http://${ODOO_SRVC}-im;
    }

    location ~* /[0-9a-zA-Z_]*/static/ {
        proxy_pass              http://$ODOO_SRVC;
        proxy_cache_valid       200 60m;
        proxy_buffering         on;
        expires                 864000;
    }
} # $ODOO_SRVC Server
EOF

echo -e "\n---- Enable the new sites configuration in the /etc/nginx/sites-enabled.  ----"
ln -s /etc/nginx/sites-available/$ODOO_SRVC /etc/nginx/sites-enabled/$ODOO_SRVC

echo -e "\n---- Disabled the default site by deleting the symbolic link for it.  ----"
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

echo -e "\n---- Verify Nginx conf file has the right syntax.  ----"
nginx -t

echo -e "\n---- Restart the services to load the new configurations.  ----"
service nginx restart

# We uninstall gcc at the end of the process so that if an attacker gains access,
# he will not beable to use this to recompile executables locally.
echo -e "* Uninstall gcc"
apt-get -y  remove gcc

echo -e "* Uninstall trash"
apt-get -y autoremove

echo "-----------------------------------------------------------"
echo "Done! The Nginx Server is up and Running. Specifications:"
echo "-------------------------------------------"
echo "--Below is your /etc/hosts for validation -"
echo "-------------------------------------------"
echo
cat /etc/hosts
echo
echo "------------------------------------------------------------"

echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "Service Interface: $OE_INTERFACE"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_HOME_EXT"
echo "Addons folder: $OE_HOME_EXT/src/custom"
echo "Start Odoo service: sudo service  $OE_USER start"
echo "Stop Odoo service: sudo service $OE_USER stop"
echo "Restart Odoo service: sudo service $OE_USER restart"
echo "-----------------------------------------------------------"
