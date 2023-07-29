# Builder stage
FROM debian:buster-slim AS build

# Install the dependencies in one go
RUN apt update && \
    apt install -y git curl file cmake gettext golang tmux

FROM debian:buster-slim
COPY --from=build . .

RUN useradd -u 8877 -m mckoy && \
    chown -R mckoy:mckoy /home/mckoy

USER mckoy

WORKDIR /home/mckoy
COPY . .

# Clone and build neovim
RUN git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/mckoy" CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# Clone config
RUN git clone -b dm_config --single-branch https://github.com/dmck0y/kickstart.nvim.git ~/.config/nvim && \
    rm -rf ~/.config/nvim/.git

SHELL [ "/bin/bash", "-l", "-c" ]
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
#RUN nvm install && nvm use

# Setup path for nvim command
ENV PATH="${PATH}:/home/mckoy/bin"

CMD ["tail", "-f", "/dev/null"]

