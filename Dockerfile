# Builder stage
FROM debian:buster-slim AS build

# Install the dependencies in one go
RUN apt update && \
    apt install -y git curl file cmake gettext golang tmux && \
    rm -rf /var/lib/apt/lists/* && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

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

# Opam setup
#RUN opam init -y --disable-sandboxing --bare && \
#    eval $(opam env) && \
#   opam switch create 4.10.0 && \
#   opam update && \
#   opam install -y dune merlin ocaml-lsp-server odoc ocamlformat utop dune-release && \

SHELL [ "/bin/bash", "-l", "-c" ]
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# Set Rust environment variables
ENV PATH="/home/mckoy/.cargo/bin:${PATH}"

# Setup path for nvim command
ENV PATH="${PATH}:/home/mckoy/bin"
RUN /bin/bash -c "source ~/.profile"

CMD ["tail", "-f", "/dev/null"]

