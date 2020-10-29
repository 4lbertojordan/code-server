# Visual Studio Code Server ad-hoc

Own code server to develop from iPad

All the sources used to make this repository:

#### Code Server 
https://github.com/cdr/code-server

#### ZSH Docker
https://github.com/deluan/zsh-in-docker/

#### ZSH POWERLEVEL10K
https://github.com/romkatv/powerlevel10k

## Installation

I'm using Dockerfile to include all features ad-hoc
If you need anything, add new features in "# Utils" within Dockerfile

##### Nginx configuration

Right now, I´m using Letsencrypt to secure the connection.
I´ve got generate a new certificate in local env. I attach the certificate trough volumes

```bash
    volumes:
       - /tools/visual-studio/config:/root/.config/code-server
       - /tools/visual-studio/project:/root/.local/share/code-server
       - /tools/visual-studio/certbot:/etc/letsencrypt
```

If you want to change the domain edit the Dockerfile variable.

```nginx
server {
    listen 8443 ssl;
      ssl_certificate /etc/letsencrypt/live/yourdomain.com/cert.pem;
      ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
      ssl_protocols TLSv1.2 TLSv1.3;
      # Enable modern TLS cipher suites
      ssl_ciphers 
      'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';

# The order of cipher suites matters
ssl_prefer_server_ciphers on;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8080/;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
```

It´s very important secure Nginx to prevent future issues.
I´m working to improve the security.

## Usage
To check first in local without docker-compose and volumes.

```bash
docker build -t codeserver:jordancodes . && docker run --rm -p 8340:80 codeserver:jordancodes
```
#
##### Docker-compose start

```bash
docker-compose up
```
##### Docker-compose stop

```bash
docker-compose stop
docker-compose down (optional)
```

## Pending tasks

Install more binaries.
Improve the security on Nginx.
Install fonts for ZSH and Powerleve10k.
Set zsh as default prompt in Visual Studio.
Set Dark theme as default.
Connect to external Docker daemon.

## Ideas

Connect to Jenkins.
Connect to Ansible Tower.
Connect to Docker Dashboard.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.