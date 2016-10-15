# odoo-install-scripts
Automated install scripts for Odoo v8 or v9 (Community editions). This scripts just needs to be preconfigured before being launched, no interaction needed. 

The script is based on the install script from André Schenkels (https://github.com/aschenkels-ictstudio/openerp-install-scripts) and having some additions from the one of Yenthe (https://github.com/Yenthe666/InstallScript) but with a lot of additions as virtualenv and considerations for proxied installs, Nginx, and extra tools. 

It also follows the approach recommended in Odoo's documentation (https://www.odoo.com/documentation/9.0/setup/install.html) using pip instead of apt-get for python dependencies

> It's recommended to install this script with **elevated privileges**, so there's no need to use **sudo** to execute this procedure.

<h3>Installation procedure</h3>
1.  Download the script
  ```bash
  wget https://raw.githubusercontent.com/gustavovalverde/odoo-install-scripts/16.04/odoo_install.sh
  ```

2.  **THIS IS IMPORTANT!** Modify this variables, otherwise you might get hacked too easily
  ```bash
    OE_USER="odoo"
    OE_VIRTENV="venv"
    OE_SUPERADMIN="admin"
  ```

3.  Modify this Odoo variables based on your needs
  ```bash
    INSTALL_WKHTMLTOPDF="True"
    OE_PORT="8069"
    OE_VERSION="9.0"
    OE_DB="mydb"
    OE_INTERFACE='127.0.0.1'
    PSQL_VERSION="9.6"
```

4.  Modify this Nginx variables based on your needs
  ```bash
    DOMAIN_NAME="EXAMPLE.COM" #change with your domain

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
```

5.  Make the script executable
  ```bash
    chmod +x odoo_install.sh
  ```

6. Execute the script:
  ```bash
    /odoo_install.sh
  ```
