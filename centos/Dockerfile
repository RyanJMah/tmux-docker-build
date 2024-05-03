FROM centos:7

RUN yum -y update

RUN yum install -y  \
    curl            \
    libevent-devel  \
    ncurses-devel   \
    gcc             \
    gcc-c++         \
    bison           \
    pkgconfig       \
    openssl-devel

# Clean up cache to reduce image size
RUN yum clean all && rm -rf /var/cache/yum

WORKDIR /root

ADD common/generic_tmux_install.sh .
ADD vars.sh .

ENTRYPOINT ["bash", "generic_tmux_install.sh"]

