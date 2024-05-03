# Runs on the docker container

set -e

source vars.sh

mkdir -p $INSTALL_DIR

# install libevent

curl -LO https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz

tar -zxf libevent-*.tar.gz
rm libevent-*.tar.gz

cd libevent-*/

./configure --prefix=$INSTALL_DIR --enable-shared
make -j && make install

cd ..

# install ncurses
curl -LO https://ftp.gnu.org/gnu/ncurses/ncurses-6.3.tar.gz

tar -zxf ncurses-*.tar.gz
rm ncurses-*.tar.gz

cd ncurses-*/
./configure --prefix=$INSTALL_DIR --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$INSTALL_DIR/lib/pkgconfig
make -j && make install

cd ..

# install tmux
curl -LO "https://github.com/tmux/tmux/releases/download/${TMUX_VER}/tmux-${TMUX_VER}.tar.gz"

tar -zxf tmux-*.tar.gz
rm tmux-*.tar.gz

cd tmux-*/
PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig ./configure --prefix=$INSTALL_DIR
make -j && make install

cd ../

# Create the tarball
tar -czf tmux.tar.gz ./"${INSTALL_DIR##*/}"
mv tmux.tar.gz $INSTALL_DIR

# Wait until the container is killed
while true; do
    sleep 2
done
