FROM ubuntu:focal

ENV DOMAIN=localhost

RUN apt-get update \
    && apt-get -y upgrade && apt-get -y dist-upgrade

RUN apt-get install -y \
    apt-utils \
    ca-certificates \
    --no-install-recommends \
    # Utils
    wget \
    curl \
    python3 \
    ansible \
    mysql-client \
    postgresql-client \
    certbot \
    python3-certbot-nginx \
    unzip \
    # Reverse proxy
    nginx \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y

# Install extra
# Terraform
RUN cd /tmp \
    && TER_VER="curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'" \
    && wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip \
    && unzip terraform_${VER}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && which terraform \
    && terraform -v

# Copy initialization script
COPY start.sh /

RUN echo " \n\
server { \n\
    listen 8443 ssl; \n\
      ssl_certificate /etc/letsencrypt/live/${DOMAIN}/cert.pem; \n\
      ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem; \n\
      ssl_protocols TLSv1.2; \n\
      # Enable modern TLS cipher suites \n\
      ssl_ciphers \n\
      'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256'; \n\
      # The order of cipher suites matters \n\
      ssl_prefer_server_ciphers on; \n\
    server_name ${DOMAIN}; \n\
\n\
    location / { \n\
        proxy_pass http://localhost:8080/; \n\
        proxy_set_header Upgrade \$http_upgrade; \n\
        proxy_set_header Connection upgrade; \n\
        proxy_set_header Accept-Encoding gzip; \n\
    }\n\
}\n\
" >> /etc/nginx/sites-available/code-server.conf \
  && ln -s /etc/nginx/sites-available/code-server.conf /etc/nginx/sites-enabled/code-server.conf \
  && cat /etc/nginx/sites-enabled/code-server.conf

# Install Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install ZSH wit Powerlevel10k
RUN sh -c "$(curl -fsSL https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -a 'CASE_SENSITIVE="true"' \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

EXPOSE 8340

ENTRYPOINT ["/start.sh"]