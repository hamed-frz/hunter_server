#!/bin/bash

# COLOR OUTPUT
NC="\033[0m" # Color reset

# Normal (0;)
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"


_install_packages(){
  echo -e "${YELLOW}! Updating and installing linux packages."${NC}
  apt update &> /dev/null
  apt install vim curl zsh git net-tools tmux build-essential make python3-apt python3-distutils libpcap-dev libssl-dev curl zsh git vim jq postgresql-client -y &> /dev/null
  curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py; python3 get-pip.py &> /dev/null

  echo -e "${YELLOW}! Installing Docker."
  sudo apt install \
      ca-certificates \
      curl \
      gnupg -y &> /dev/null

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update &> /dev/null
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y &> /dev/null

  echo -e "${GREEN}+ packages installing is finished."${NC}
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_install_go(){
  mkdir tools
  cd tools

  wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz  &> /dev/null
  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz 

  echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc
  echo "export PATH=\$PATH:/root/go/bin/" >> /root/.bashrc
  PS1='$ '
  source /root/.bashrc
}

_install_tools(){
  pip3 install dnsgen &> /dev/null
  echo -e "+ dnsgen installed."${NC}
  pip3 install py-altdns==1.0.2
  echo -e "+ altdns installed."${NC}
  go install github.com/projectdiscovery/notify/cmd/notify@latest &> /dev/null
  echo -e "+ notify installed."${NC}
  go install github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest &> /dev/null
  echo -e "+ mapcidr installed."${NC}
  go install github.com/ffuf/ffuf/v2@latest &> /dev/null
  echo -e "+ ffuf installed."${NC}
  go install github.com/tomnomnom/unfurl@latest &> /dev/null
  echo -e "+ unfurl installed."${NC}
  go install github.com/projectdiscovery/httpx/cmd/httpx@latest &> /dev/null
  echo -e "+ httpx installed."${NC}
  go install github.com/bp0lr/gauplus@latest &> /dev/null
  echo -e "+ gauplus installed."${NC}
  go install github.com/projectdiscovery/katana/cmd/katana@latest &> /dev/null
  echo -e "+ katana installed."${NC}
  go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &> /dev/null
  echo -e "+ subfinder installed."${NC}
  go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest &> /dev/null
  echo -e "+ dnsx installed."${NC}
  go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest &> /dev/null
  echo -e "+ shuffledns installed."${NC}
  go install github.com/tomnomnom/anew@latest &> /dev/null
  echo -e "+ anew installed."${NC}
  go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest &> /dev/null
  echo -e "+ nuclei installed."${NC}
  go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
  echo -e "+ naabu installed."${NC}
  go install github.com/OJ/gobuster/v3@latest
  echo -e "+ gobuster installed."${NC}
  go install github.com/tomnomnom/waybackurls@latest
  echo -e "+ waybackurls installed."${NC}
  go install github.com/ImAyrix/cut-cdn@latest
  echo -e "+ cut-cdn installed."${NC}
  
  echo -e "+ Installing is finished."${NC}
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_install_bind(){

  git clone https://github.com/Voorivex/OOB-Server.git
  cd OOB-Server/
  chmod +x setup
  ./setup ${__DOMAIN__} ${__SERVERIP__}

  cat << EOF > /etc/bind/db.local
\$TTL    120
@       IN      SOA     ${__DOMAIN__}. root.${__DOMAIN__}. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
ns1              IN      A       ${__SERVERIP__}
ns2              IN      A       ${__SERVERIP__}
@                IN      A       ${__SERVERIP__}
*                IN      A       ${__SERVERIP__}
@                IN      NS      ns1.${__DOMAIN__}.
@                IN      NS      ns2.${__DOMAIN__}.
local            IN      A       127.0.0.1
aws-ssrf         IN      A       169.254.169.254
EOF

  sudo service named restart #restart service name
  cd ../../
  echo -e "${YELLOW}+ Bind already installed and configured."${NC}
  echo -e "${BLUE}* local.${__DOMAIN__} configured for 127.0.0.1  and  aws-ssrf.${__DOMAIN__} is configured for 169.254.169.254."${NC}
  echo -e "${BLUE}* Now this domains already configured: "${NC}

  echo -e "${BLUE}*** ${__DOMAIN__} ***"${NC}
  echo -e "${BLUE}*** local.${__DOMAIN__} ***"${NC}
  echo -e "${BLUE}*** aws-ssrf.${__DOMAIN__} ***"${NC}

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_get_ssl(){
  #configuration nginx
  #echo "* Get ssl for Domains"

  apt install curl socat -y &> /dev/null
  curl https://get.acme.sh | sh &> /dev/null
  #ssl for root Domain
  ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
  ~/.acme.sh/acme.sh --register-account -m info@${__DOMAIN__}.com
  ~/.acme.sh/acme.sh --issue -d ${__DOMAIN__} --standalone
  ~/.acme.sh/acme.sh --installcert -d ${__DOMAIN__} --key-file nginx/letsencrypt/root/private.key --fullchain-file nginx/letsencrypt/root/cert.crt

  #ssl for bxx Domain
  ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
  ~/.acme.sh/acme.sh --register-account -m info@bxx.${__DOMAIN__}.com
  ~/.acme.sh/acme.sh --issue -d bxx.${__DOMAIN__} --standalone
  ~/.acme.sh/acme.sh --installcert -d bxx.${__DOMAIN__} --key-file nginx/letsencrypt/bxx/private.key --fullchain-file nginx/letsencrypt/bxx/cert.crt


  #ssl for ssrf Domain
  ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
  ~/.acme.sh/acme.sh --register-account -m info@ssrf.${__DOMAIN__}.com
  ~/.acme.sh/acme.sh --issue -d ssrf.${__DOMAIN__} --standalone
  ~/.acme.sh/acme.sh --installcert -d ssrf.${__DOMAIN__} --key-file nginx/letsencrypt/ssrf/private.key --fullchain-file nginx/letsencrypt/ssrf/cert.crt
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_nginx_config(){
  #configuration nginx
  echo -e "${YELLOW}! Running nginx with docker-compose"${NC}

  cp python/bxx/default python/bxx/app.py
  cp python/ssrf/default python/ssrf/app.py

  sed -i "s|__BXX_DISCORD__|${__BXX_DISCORD__}|g" python/bxx/app.py
  sed -i "s|__SSRF_DISCORD__|${__SSRF_DISCORD__}|g" python/ssrf/app.py

  docker build -f python/bxx/Dockerfile --tag bxx-python . &> /dev/null
  docker build -f python/ssrf/Dockerfile --tag ssrf-python . &> /dev/null
  
  cp nginx/default.conf nginx/nginx.conf
  sed -i "s/__DOMAIN__/${__DOMAIN__}/g" nginx/nginx.conf
  sed -i "s/__DOMAIN__/${__DOMAIN__}/g" nginx/html/BXX/index.html

  docker-compose up -d

  echo -e "+ Nginx and APIs is already installed. now this domains should be available.\n"${NC}
  echo -e "${RED}*** https://${__DOMAIN__} ***"${NC}
  echo -e "${RED}*** https://bxx.${__DOMAIN__} ***"${NC}
  echo -e "${RED}*** https://ssrf.${__DOMAIN__} ***\n"${NC}
  echo -e "${RED}*** BXSS API: https://bxx.${__DOMAIN__}/reqBXX ***"${NC}
  echo -e "${RED}*** SSRF API: https://ssrf.${__DOMAIN__}/reqSSRF ***"${NC}
  
  echo -e "${YELLOW}* You can change your domains with change html files in ./nginx/html"${NC}
  #alias sqlmap="python3 tools/sqlmap.py"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_install_zsh(){
  echo -e "${RED}"
  read -p 'Installing zsh, you should be type "exit" after the install zsh finished.(ok?) ' __check__
  echo -e "${nc}"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.zshrc
  echo "export PATH=\$PATH:/root/go/bin/" >> /root/.zshrc
  source /root/.zshrc
}

echo ""
echo -e "Please enter this parameter for configuration your server. "${NC}
#echo "* Installing bind and configuration dns and nginx for domains"
echo -e "${GREEN}"
read -p 'Please enter your Domin name (ex. example.com): ' __DOMAIN__
read -p 'Please enter your Server IP (ex. 187.1.1.1): ' __SERVERIP__
read -p 'Please enter your discord webhook for Blind XSS server (ex. https://discord.com/api/webhooks/11047) : ' __BXX_DISCORD__
read -p 'Please enter your discord webhook for SSRF server (ex. https://discord.com/api/webhooks/11047) : ' __SSRF_DISCORD__
echo -e "${NC}"

#Installing packages
echo -e "\n"
_install_packages

#Installing go if not exist
if ! [ -x "$(command -v go)" ]; then
  echo -e "${RED}- go is not installed."${NC}
  echo -e "${YELLOW}! Installing go..."${NC}
  _install_go
  go version
  echo -e "\n${GREEN}+ Done.\n"${NC}
else
  echo -e "${RED}+ go is already installed in your server so ignore to install it."${NC}
fi


echo -e "${YELLOW}! Installing tools for hunting, please wait for it...."${NC}
_install_tools

if ! [ -s /etc/systemd/system/bind9.service ]; then
  echo -e "${RED}- bind9 is not installed."${NC}
  echo -e "${YELLOW}! Installing bind9"${NC}
  _install_bind
  echo -e "\n${GREEN}+ Done.\n"${NC}
else
  echo -e "+ bind9 is already installed in your server so ignore to install it."${NC}
  echo -e "${BLUE}* if you want add this line in your configuration file:"${NC}
  echo -e "local            IN      A       127.0.0.1"
  echo -e "aws-ssrf         IN      A       169.254.169.254"
fi

echo -e "${YELLOW}! get valid ssl certificate for this domains:"${NC}
echo -e "${BLUE} *${__DOMAIN__}, bxx.${__DOMAIN__}, ssrf.${__DOMAIN__}\n"${NC}
_get_ssl
echo "\n${GREEN}+ Done.\n"${NC}

echo -e "${YELLOW}! Configure nginx and APIs for blind XSS and SSRF attack."${NC}
_nginx_config
echo -e "\n${GREEN}+ Done.\n"${NC}

echo -e "${YELLOW}! Installing zsh."${NC}
_install_zsh
echo -e "\n${GREEN}+ Done.\n"${NC}

#echo ""
