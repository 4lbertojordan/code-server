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

Right now, I haven't included the SSL setup for NGINX yet.

If you want to change the domain edit the code-server.conf file

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name yourdomain;

    location / {
        proxy_pass http://localhost:8080/;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
```

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

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.