#!/bin/bash -i

tput civis


OUTPUT_ECHO="\e[93m\e[4m\e[1m"
OUTPUT_SUCCESS="\e[92m\e[1m[\xE2\x9C\x94]"
OUTPUT_ERROR="\e[91m\e[1m"
PATH_LOG="/home/$USER/VMSLog.txt"

Spinner() {
    local i sp n
    sp='/-\|'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        printf "%s\b" "${sp:i++%n:1}"
    done
}


echo -e "${OUTPUT_ECHO}[+]UPDATE & CLEAN SYSTEM[+]\e[0m"
printf "Updating..."
Spinner &

sudo apt-get update > /dev/null 2> ${PATH_LOG}
sudo apt-get full-upgrade -y > /dev/null 2> ${PATH_LOG}
sudo apt-get remove libreoffice* gimp* -y > /dev/null 2> ${PATH_LOG}
sudo apt-get autoremove -y > /dev/null 2> ${PATH_LOG}

if [ $? -eq 0 ]; then

    kill "$!"
    printf '\n'

    echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

    sleep 3
    clear
else
    echo -e "${OUTPUT_ERROR} ERROR\e[0m"
    exit 1
fi


echo -e "${OUTPUT_ECHO}[+]INSTALL SYSTEM REQUIREMENT[+]\e[0m"

sudo apt-get install python-pip open-vm-tools-desktop network-manager-openvpn-gnome -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(10%)\r'
sudo apt-get install build-essential openvpn git -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (20%)\r'
sudo apt-get install curl build-essential libreadline-dev -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (30%)\r'
sudo apt-get install libssl-dev libpq5 libpq-dev -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (40%)\r'
sudo apt-get install libreadline5 libsqlite3-dev libpcap-dev -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (50%)\r'
sudo apt-get install git-core autoconf postgresql -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (60%)\r'
sudo apt-get install pgadmin3 zlib1g-dev libxml2-dev -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (70%)\r'
sudo apt-get install libxslt1-dev libyaml-dev zlib1g-dev -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (80%)\r'
sudo apt-get install arc-theme python-gtk2-dev graphviz -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (90%)\r'
sudo apt-get install python-gtksourceview2 dirmngr nmap -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ... (100%)\r'
sudo apt-get install default-jdk sslscan software-properties-common expect -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Finishing ...'
echo -ne '\n'

if [ $? -eq 0 ]; then

    echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

    sleep 3
    clear
else
    echo -e "${OUTPUT_ERROR} ERROR\e[0m"
    exit 1
fi


echo -e "${OUTPUT_ECHO}[+]INSTALL DESKTOP CUSTOMIZATION[+]\e[0m"

printf "Customize..."
Spinner &

  wget -q -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sh > /dev/null 2> ${PATH_LOG}

  xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark"
  xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

if [ $? -eq 0 ]; then

    kill "$!"
    printf '\n'

    echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

    sleep 3
    clear
else
    echo -e "${OUTPUT_ERROR} ERROR\e[0m"
    exit 1
fi

echo -e "${OUTPUT_ECHO}[+]INSTALL RBENV & RUBY[+]\e[0m"

cd ~
git clone -q git://github.com/sstephenson/rbenv.git .rbenv
git clone -q git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone -q git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

RUBYVERSION=$(wget https://raw.githubusercontent.com/rapid7/metasploit-framework/master/.ruby-version -q -O - )

printf "\e[38;5;208m[!]Installing Ruby[!]\e[0m"
Spinner &
source ~/.bashrc
rbenv install $RUBYVERSION > /dev/null
rbenv global $RUBYVERSION > /dev/null
kill "$!"
printf '\n'


if [ $? -eq 0 ]; then

    echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

    sleep 3
    clear
else
    echo -e "${OUTPUT_ERROR} ERROR\e[0m"
    exit 1
fi



echo -e "${OUTPUT_ECHO}[+]CONFIGURE POSTGRESQL[+]\e[0m"

Username="Moba"
Password="jyGfrU"
Database="MSF"

sudo -u postgres createuser ${Username} -P -S -R -D
sudo -u postgres createdb -O ${Username} ${Password}

if [ $? -eq 0 ]; then
    echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

    sleep 3
    clear
else
    echo -e "${OUTPUT_ERROR} ERROR\e[0m"
    exit 1
fi

echo -e "${OUTPUT_ECHO}[+]DOWNLOAD & INSTALL METASPLOIT-FRAMEWORK[+]\e[0m"

printf "Downloading & Metasploit..."
Spinner &

cd /opt
sudo git clone -q https://github.com/rapid7/metasploit-framework.git Metasploit
sudo chown -R `whoami` /opt/Metasploit

cd /opt/Metasploit
gem install --silent bundler
bundle install --quiet

sudo bash -c 'for MSF in $(ls msf*); do ln -s /opt/Metasploit/$MSF /usr/local/bin/$MSF;done'

sudo sh -c "echo 'production:
 adapter: postgresql
 database: ${Database}
 username: ${Username}
 password: ${Password}
 host: 127.0.0.1
 port: 5432
 pool: 75
 timeout: 5' >> /opt/Metasploit/config/database.yml"


 sudo sh -c "echo export MSF_DATABASE_CONFIG=/opt/Metasploit/config/database.yml >> /etc/profile"

 if [ $? -eq 0 ]; then
     kill "$!"
     printf '\n'
     echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

     sleep 3
     clear
 else
     echo -e "${OUTPUT_ERROR} ERROR\e[0m"
     exit 1
 fi


 echo -e "${OUTPUT_ECHO}[+]DOWNLOAD & INSTALL ADVANCED DEPENDENCIES[+]\e[0m"

STEP_1="\e[38;5;208m[!]Installing Pip Requirements[!]\e[0m"
STEP_2="\e[38;5;208m[!]Installing NodeJS & NPM[!]\e[0m"
STEP_2="\e[38;5;208m[!]Installing DEB Packages[!]\e[0m"

echo -e "${STEP_1}"

 sudo pip install pyClamd==0.4.0 PyGithub==1.21.0 GitPython==2.1.3 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(10%)\r'
 sudo pip install pybloomfiltermmap==0.3.14 phply==0.9.1 nltk==3.0.1 chardet==3.0.4 tblib==0.2.0 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(20%)\r'
 sudo pip install pdfminer==20140328 futures==3.2.0 pyOpenSSL==18.0.0 ndg-httpsclient==0.4.0 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(30%)\r'
 sudo pip install pyasn1==0.4.2 lxml==3.4.4 scapy==2.4.0 guess-language==0.2 cluster==1.1.1b3 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(40%)\r'
 sudo pip install msgpack==0.5.6 python-ntlm==1.0.1 halberd==0.2.4 darts.util.lru==0.5 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(50%)\r'
 sudo pip install Jinja2==2.10 vulndb==0.1.0 markdown==2.6.1 psutil==2.2.1 ds-store==1.1.2 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(60%)\r'
 sudo pip install termcolor==1.1.0 mitmproxy==0.13 ruamel.ordereddict==0.4.8 Flask==0.10.1 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(70%)\r'
 sudo pip install PyYAML==3.12 tldextract==1.7.2 pebble==4.3.8 acora==2.1 esmre==0.3.1 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(80%)\r'
 sudo pip install diff-match-patch==20121119 bravado-core==5.0.2 lz4==1.1.0 > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(90%)\r'
 sudo pip install vulners==1.3.0 xdot==0.6 selenium > /dev/null 2> ${PATH_LOG} | echo -ne 'Finishing ...\r'

 if [ $? -eq 0 ]; then
     echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

     sleep 3
     clear
     echo -e "${OUTPUT_ECHO}[+]DOWNLOAD & INSTALL ADVANCED DEPENDENCIES[+]\e[0m"
 else
     echo -e "${OUTPUT_ERROR} ERROR\e[0m"
     exit 1
 fi

echo -e "${STEP_2}"

printf "Installing ..."
Spinner &

 cd ~
 curl -sL https://deb.nodesource.com/setup_11.x | sudo bash - > /dev/null 2> ${PATH_LOG}
 sudo apt-get install nodejs -y > /dev/null 2> ${PATH_LOG}
 sudo npm install -g retire &>/dev/null


 if [ $? -eq 0 ]; then
     kill "$!"
     printf '\n'
     echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

     sleep 3
     clear
     echo -e "${OUTPUT_ECHO}[+]DOWNLOAD & INSTALL ADVANCED DEPENDENCIES[+]\e[0m"
 else
     echo -e "${OUTPUT_ERROR} ERROR\e[0m"
     exit 1
 fi

echo -e "${STEP_3}"

 cd ~
 wget -q http://ftp.cn.debian.org/debian/pool/main/p/python-support/python-support_1.0.15_all.deb | echo -ne 'Downloading ...(10%)\r'
 sudo dpkg -i python-support_1.0.15_all.deb > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(20%)\r'

 wget -q http://ftp.cn.debian.org/debian/pool/main/p/pywebkitgtk/python-webkit_1.1.8-3_amd64.deb | echo -ne 'Downloading ...(30%)\r'
 sudo dpkg -i python-webkit_1.1.8-3_amd64.deb > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(40%)\r'

 wget -q http://ftp.cn.debian.org/debian/pool/main/p/pywebkitgtk/python-webkit-dev_1.1.8-3_all.deb | echo -ne 'Downloading ...(50%)\r'
 sudo dpkg -i python-webkit-dev_1.1.8-3_all.deb > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(60%)\r'

 sudo apt-get install -f -y > /dev/null 2> ${PATH_LOG} | echo -ne 'Downloading ...(70%)\r'

 rm python-webkit-dev_1.1.8-3_all.deb | echo -ne 'Deleting ...(80%)\r'
 rm python-webkit_1.1.8-3_amd64.deb | echo -ne 'Deleting ...(90%)\r'
 rm python-support_1.0.15_all.deb | echo -ne 'Deleting ...\r'

 if [ $? -eq 0 ]; then
     echo -e  "${OUTPUT_SUCCESS} SUCCESS\e[0m"

     sleep 3
     clear
 else
     echo -e "${OUTPUT_ERROR} ERROR\e[0m"
     exit 1
 fi
