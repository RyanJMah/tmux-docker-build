FROM centos:7

RUN yum -y update

RUN yum install -y  \
    curl            \
    libevent-devel  \
    ncurses-devel   \
    gcc             \
    gcc-c++         \
    make            \
    bison           \
    pkgconfig       \
    openssl-devel

# Clean up cache to reduce image size
RUN yum clean all && rm -rf /var/cache/yum

WORKDIR /root

ADD common/generic_tmux_install.sh .
ADD vars.sh .

RUN bash generic_tmux_install.sh

CMD ["sleep", "infinity"]
