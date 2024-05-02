# Use the official Debian 11 image as the base
FROM debian:11

RUN apt update

RUN apt install -y  \
    git             \
    sudo            \
    python3         \
    python3-pip     \
    curl            \
    libssl-dev      \
    pkg-config 

# Clean up cache to reduce image size
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Do nothing forever
CMD ["bash", "-c", "while true; do sleep 30; done;"]

