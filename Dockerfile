FROM ubuntu:focal

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
    # Reverse proxy
    nginx \
    # Finish
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y

ENV LANG en_US.utf8

COPY start.sh /
COPY code-server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/code-server.conf /etc/nginx/sites-enabled/code-server.conf

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