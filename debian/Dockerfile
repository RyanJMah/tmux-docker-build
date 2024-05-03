FROM debian:11

RUN apt update

RUN apt install -y  \
    curl            \
    libevent-dev    \
    ncurses-dev     \
    build-essential \
    bison           \
    pkg-config      \
    libssl-dev

# Clean up cache to reduce image size
RUN apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root

ADD common/generic_tmux_install.sh .
ADD vars.sh .

ENTRYPOINT ["bash", "generic_tmux_install.sh"]
