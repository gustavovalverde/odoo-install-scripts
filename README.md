# odoo-install-scripts
Automated install scripts for Odoo v8 or v9 (Community or Enterprise editions). This scripts just needs to be preconfigured before being launched, no interaction needed. 

The script is based on the install script from André Schenkels (https://github.com/aschenkels-ictstudio/openerp-install-scripts) and having some additions from the one of Yenthe (https://github.com/Yenthe666/InstallScript) but with a few additions as virtualenv and considerations for proxied installs. 

It also follows the approach recommended in Odoo's documentation (https://www.odoo.com/documentation/9.0/setup/install.html) using pip instead of apt-get for python dependencies

<h3>Installation procedure</h3>
1. Download the script:
```
sudo wget https://raw.githubusercontent.com/gustavovalverde/odoo-install-scripts/master/odoo_install.sh
```
2. Make the script executable:
```
sudo chmod +x odoo_install.sh
```
3. Execute the script:
```
sudo source odoo_install.sh
```
