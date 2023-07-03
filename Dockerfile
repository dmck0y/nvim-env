FROM ubuntu:latest AS build

RUN apt update && \
    apt install -y git && \
    apt install -y curl && \
    apt install -y file && \
    apt install -y cmake && \
    apt install -y gettext

RUN useradd -u 8877 -m mckoy
RUN mkdir -p /home/mckoy/.opam/opam-init/hooks && \
    chown -R mckoy:mckoy /home/mckoy

USER mckoy

WORKDIR /home/mckoy

RUN git clone https://github.com/neovim/neovim
RUN cd neovim && make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/mckoy" CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

RUN echo "export PATH=$PATH:/home/mckoy/bin" >> .bashrc

COPY . .

RUN git clone https://github.com/LazyVim/starter ~/.config/nvim

CMD ["tail", "-f", "/dev/null"]
