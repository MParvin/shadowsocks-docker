# shadowsocks-docker
ShadowSocks docker compose

## Usage

Server and Client on the same machine:

1. Clone this repository
2. Rename .env.example to .env
3. Change the encryption_key and other credentials in the .env file
4. Run `docker-compose up -d`

Server and Client on different machines:
Server:
Do the steps 1-3 from above
1. Run `docker-compose -f docker-compose-server.yml up -d`

Client:
Do the steps 1-3 same as above
1. Run `docker-compose -f docker-compose-client.yml up -d`

Test the connection:
1. Run `curl --socks5-hostname YOUR_CLIENT_IP:1080 http://httpbin.org/ip`