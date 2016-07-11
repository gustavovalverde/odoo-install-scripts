#!/bin/bash
################################################################################
# Script for Installing: ODOO 8 or 9 Community/Enterprise on Ubuntu 14.04
# Author: Gustavo Valverde, iterativo.do 2016
#
# Based on André Schenkels installation script located in github:
# https://github.com/aschenkels-ictstudio/odoo-install-scripts
#-------------------------------------------------------------------------------
# This script will install ODOO Server on a
# clean Ubuntu 14.04 Server
#-------------------------------------------------------------------------------
# PREFERRED USE:
# . odoo_install or source odoo_install
#
# CAN WORK WITH (NOT RECOMMENDED AS VIRTUALENV MITH NOT WORK CORRECTLY):
# ./odoo-install
#
#-------------------------------------------------------------------------------
# IMPORTANT! This script contains extra libraries that are specifically
# needed for Odoo 9.0
#-------------------------------------------------------------------------------
#
################################################################################
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
sudo locale-gen --purge "en_US.UTF-8" && \
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
sudo dpkg-reconfigure --frontend=noninteractive locales && \
sudo update-locale LANG=en_US.UTF-8
#---------------------------------------------------
# Timezone for Dominican Republic, change as needed
#---------------------------------------------------
echo -e "\n---- Setting Time Zone  ----"
echo "America/Santo_Domingo" > /etc/timezone && \
sudo dpkg-reconfigure -f noninteractive tzdata && \

#--------------------------------------------------
# Update the Server
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Updating and upgrading    *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Adding PostgreSQL 9.5  ----"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt-get update
sudo apt-get dist-upgrade -y

#--------------------------------------------------
# Fixed parameters for Odoo
#--------------------------------------------------
OE_USER="[odoo_admin_user]"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_VIRTENV="[virtualenv_name]"

#Set it to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"

#Set it to true if you have your Odoo install behind a Proxy.
HAVE_PROXY="False"

#Set the default Odoo port
OE_PORT="8069"

#Choose the Odoo version which you want to install. For example: 9.0, 8.0.
OE_VERSION="9.0"

# Set this to True if you want to install Odoo 9 Enterprise!
IS_ENTERPRISE="False"

#set the superadmin password
OE_SUPERADMIN="[@_v3ry_str0ng_p@ssw0rd!]"
OE_CONFIG="${OE_USER}-server"

###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb


echo "*********************************"
echo "*                               *"
echo "*     ODOO Script initiation    *"
echo "*                               *"
echo "*********************************"
#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     PostgreSQL Install        *"
echo "*                               *"
echo "*********************************"
sudo apt-get -y install postgresql-9.5 libpq-dev

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser $OE_USER -U postgres -dRS" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*    Installing Dependencies    *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Install dependencies for Odoo install and management ----"
sudo apt-get -y install wget subversion git bzr bzrtools python-pip gdebi-core unzip
sudo apt-get -y install python-dev build-essential libldap2-dev libsasl2-dev libxml2-dev libxslt-dev libevent-dev libjpeg-dev libjpeg8-dev libtiff5-dev

echo -e "\n---- Install build dependencies for Python 2.7.9 ----"
sudo apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

echo -e "\n---- Install and Upgrade pip and virtualenv ----"
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenv

#--------------------------------------------------
# Odoo uses Python 2.7.9, a best practice would
# be to have a virtualenv with this version
# where Odoo could run with its own dependencies
#--------------------------------------------------
echo -e "\n---- Build and install Python 2.7.9 ----"
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
tar xfz Python-2.7.9.tgz
cd Python-2.7.9/
./configure --prefix /usr/local/lib/python2.7.9 --enable-ipv6
make
sudo make install

echo -e "\n---- Test python 2.7.9 install ----"
/usr/local/lib/python2.7.9/bin/python -V

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*   ODOO system user creation   *"
echo "*                               *"
echo "*********************************"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo "*********************************"
echo "*                               *"
echo "*     Creating LOG Directory    *"
echo "*                               *"
echo "*********************************"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

echo "*********************************"
echo "*                               *"
echo "*     Installing ODOO Server    *"
echo "*                               *"
echo "*********************************"
sudo git clone --depth 1 --branch $OE_VERSION --single-branch https://www.github.com/odoo/odoo $OE_HOME_EXT/

if [ $IS_ENTERPRISE = "True" ]; then
    # Odoo Enterprise install!
    echo -e "\n---- Create enterprise module directory ----"
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise"
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise/addons"

    echo -e "\n---- Adding Enterprise code under $OE_HOME/enterprise/addons ----"
    sudo git clone --depth 1 --branch 9.0 https://www.github.com/odoo/enterprise "$OE_HOME/enterprise/addons"
else
    echo -e "\n---- Create custom module directory ----"
    sudo su $OE_USER -c "mkdir $OE_HOME/custom"
    sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"
fi

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

#--------------------------------------------------
# Virtualenv not working as expected
# Do not use in a production environment
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Creating VirtualEnv       *"
echo "*                               *"
echo "*********************************"
echo -e "\n---- Configuring virtualenv for Odoo ----"
cd $OE_HOME_EXT
sudo virtualenv --python=/usr/local/lib/python2.7.9/bin/python $OE_VIRTENV
source $OE_HOME_EXT/$OE_VIRTENV/bin/activate
activate () {
  . $OE_HOME_EXT/$OE_VIRTENV/bin/activate
}

echo -e "\n---- Install Odoo python dependencies in requirements.txt ----"
$OE_HOME_EXT/$OE_VIRTENV/bin/pip install -r $OE_HOME_EXT/requirements.txt
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

#--------------------------------------------------
# Here starts the configuration of Odoo
#--------------------------------------------------
cd ~
echo "*********************************"
echo "*                               *"
echo "*       Configuring Odoo        *"
echo "*                               *"
echo "*********************************"
echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/openerp-server.conf /etc/${OE_CONFIG}.conf
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
if [  $IS_ENTERPRISE = "True" ]; then
    sudo su root -c "echo 'addons_path=$OE_HOME/enterprise/addons,$OE_HOME_EXT/addons' >> /etc/${OE_CONFIG}.conf"
else
    sudo su root -c "echo 'addons_path = $OE_HOME_EXT/addons,$OE_HOME/custom/addons' >> /etc/${OE_CONFIG}.conf"
fi
if [  $HAVE_PROXY = "True" ]; then
    sudo su root -c "echo 'proxy_mode = 1' >> /etc/${OE_CONFIG}.conf"
else
    sudo su root -c "echo 'proxy_mode = 0' >> /etc/${OE_CONFIG}.conf"
fi
echo -e "* Change default xmlrpc port"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"

echo -e "* Rest of ${OE_CONFIG}.conf"
cat <<EOF >> /etc/${OE_CONFIG}.conf

# Workers and timeouts
workers = 4
limit_time_real = 3600
limit_time_cpu = 3600
EOF

#--------------------------------------------------
# Startup File
#--------------------------------------------------
echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh


#--------------------------------------------------
# Install additional Packages for Odoo
#--------------------------------------------------
echo "*********************************".
echo "*                               *"
echo "*    Install other packages     *"
echo "*                               *"
echo "*********************************"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04 and 15.04
sudo -H pip install suds

echo -e "\n--- Install Less CSS via nodejs and npm"
curl -sL https://deb.nodesource.com/setup_0.12 | sudo -E bash -
sudo apt-get -y install nodejs npm
sudo npm install -g npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less
sudo npm install -g less-plugin-clean-css

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*Install Wkhtmltopdf (if needed)*"
echo "*                               *"
echo "*********************************"
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 9 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------
echo "*********************************"
echo "*                               *"
echo "*     Adding ODOO as service    *"
echo "*                               *"
echo "*********************************"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Odoo ERP
# Description: ODOO Business Applications
### END INIT INFO

PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/openerp-server
NAME=$OE_CONFIG
DESC=$OE_CONFIG

# Specify the user name (Default: odoo).
USER=$OE_USER

# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"

# pidfile
PIDFILE=/var/run/${NAME}.pid

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"

[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0

checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}

case "\${1}" in
start)
echo -n "Starting \${DESC}: "

source $OE_HOME_EXT/$OE_VIRTENV/bin/activate

start-stop-daemon --start --quiet --pidfile \${PIDFILE} \
--chuid \${USER} --background --make-pidfile \
--exec \${DAEMON} -- \${DAEMON_OPTS}

echo "\${NAME}."
;;

stop)
echo -n "Stopping \${DESC}: "

start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \
--oknodo

echo "\${NAME}."
;;

restart|force-reload)
echo -n "Restarting \${DESC}: "

start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \
--oknodo

sleep 1

start-stop-daemon --start --quiet --pidfile \${PIDFILE} \
--chuid \${USER} --background --make-pidfile \
--exec \${DAEMON} -- \${DAEMON_OPTS}

echo "\${NAME}."
;;

*)
N=/etc/init.d/\${NAME}
echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
exit 1
;;
esac

exit 0
EOF

echo "*********************************"
echo "*                               *"
echo "*         Securing ODOO         *"
echo "*                               *"
echo "*********************************"
echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
# Change the odoo-server file permissions and ownership so only root can write to it,
# while odoo user will only be able to read and execute it.
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo "*********************************"
echo "*                               *"
echo "*         Starting ODOO         *"
echo "*                               *"
echo "*********************************"
echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"

echo "***************************"
echo "*                         *"
echo "*         Updating        *"
echo "*                         *"
echo "***************************"
apt-get update

echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"
