# odoo-install-scripts
Automated install scripts for Odoo v8 or v9 (Community or Enterprise editions). This scripts just needs to be preconfigured before being launched, no interaction needed. 

The script is based on the install script from André Schenkels (https://github.com/aschenkels-ictstudio/openerp-install-scripts) and having some additions from the one of Yenthe (https://github.com/Yenthe666/InstallScript) but with a few additions as virtualenv and considerations for proxied installs. 

It also follows the approach recommended in Odoo's documentation (https://www.odoo.com/documentation/9.0/setup/install.html) using pip instead of apt-get for python dependencies

It's recommended to install this script with **elevated privileges**, so there's no need to use **sudo** to execute this procedure.

<h3>Installation procedure</h3>
1. Download the script:
```bash
wget https://raw.githubusercontent.com/gustavovalverde/odoo-install-scripts/master/odoo_install.sh
```

2. *THIS IS IMPORTANT!* Modify this variables, otherwise you might get hacked too easily:
```bash
  OE_USER="odoo"
  OE_VIRTENV="venv"
  OE_SUPERADMIN="admin"
```

3. Modify this variables based on your needs:
```bash
  INSTALL_WKHTMLTOPDF="True"
  HAVE_PROXY="False" 
  OE_PORT="8069"
  OE_VERSION="9.0"
  IS_ENTERPRISE="False"
```

4. Make the script executable:
```bash
chmod +x odoo_install.sh
```

5. Execute the script:
```bash
. odoo_install.sh
```
