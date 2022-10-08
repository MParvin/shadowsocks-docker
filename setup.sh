#!/bin/bash
# This script will gets outside firewall IP address and username and gets the inside firewall IP address and username
read -p "Enter the outside firewall IP address: " outside
read -p "Enter the outside firewall username: " outsideuser
echo "Getting inside firewall IP address and username"
read -p "Enter the inside firewall IP address: " inside
read -p "Enter the inside firewall username: " insideuser

# Generate encryption key and show as recommended to user
key=$(openssl rand -base64 32)
echo "This is example encryption key, that you can use in next step: $key"
# get encrypted key
read -p "Enter the encryption key, Press enter to use generated key : " enc_key
if [ -z "$enc_key" ]; then
    enc_key=$key
fi

# Default server port is 8488, ask user if they want to change it
read -p "Enter the server port (default is 8488): " port
if [ -z "$port" ]; then
    port=8488
fi

# Default client port is 1080, ask user if they want to change it
read -p "Enter the client port (default is 1080): " client_port
if [ -z "$client_port" ]; then
    client_port=1080
fi

# Install docker on both servers
echo "Installing docker on both servers"
ssh $outsideuser@$outside "wget -qO- https://get.docker.com/ | sudo sh"
ssh $insideuser@$inside "wget -qO- https://get.docker.com/ | sudo sh"

# Install docker-compose on both servers
echo "Installing docker-compose on both servers"
ssh $outsideuser@$outside "sudo apt-get install -y python3-pip git"
ssh $outsideuser@$outside "sudo pip install docker-compose"

ssh $insideuser@$inside "sudo apt-get install -y python3-pip git"
ssh $insideuser@$inside "sudo pip install docker-compose"

# git clone https://github.com/MParvin/shadowsocks-docker.git
echo "Cloning shadowsocks-docker repo"
ssh $outsideuser@$outside "git clone https://github.com/MParvin/shadowsocks-docker.git /opt/src/shadowsocks-docker"
ssh $insideuser@$inside "git clone https://github.com/MParvin/shadowsocks-docker.git /opt/src/shadowsocks-docker"

ssh $outsideuser@$outside "mv /opt/src/showdowsocks-docker/docker-compose-server.yml /opt/src/shadowsocks-docker/docker-compose.yml"
ssh $insideuser@$inside "mv /opt/src/showdowsocks-docker/docker-compose-client.yml /opt/src/shadowsocks-docker/docker-compose.yml"

# create .env file with encryption key, server port and client port and $outside as server IP
echo "Creating .env file"
echo "encryption_key=$enc_key" > .env
echo "server_port=$port" >> .env
echo "client_port=$client_port" >> .env
echo "server_ip=$outside" >> .env

# copy .env file to both servers
echo "Copying .env file to both servers"
scp .env $outsideuser@$outside:/opt/src/shadowsocks-docker/.env
scp .env $insideuser@$inside:/opt/src/shadowsocks-docker/.env

# run docker-compose up -d on both servers
echo "Running docker-compose up -d on both servers"
ssh $outsideuser@$outside "cd /opt/src/shadowsocks-docker && docker-compose up -d"
ssh $insideuser@$inside "cd /opt/src/shadowsocks-docker && docker-compose up -d"

# show client IP and port
echo "Client IP: $inside"
echo "Client port: $client_port"
echo "You can use it in telegram as Socks5 proxy"
exit 0
