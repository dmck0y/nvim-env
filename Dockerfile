# Builder stage
FROM debian:buster-slim AS neovim
# Install the dependencies in one go
RUN apt update && \
    apt install -y git curl file cmake gettext unzip tmux

RUN useradd -u 8877 -m mckoy && \
    chown -R mckoy:mckoy /home/mckoy

USER mckoy

WORKDIR /home/mckoy

SHELL ["/bin/bash", "-lc"]

RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.12.0
RUN echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc
RUN echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc

# Clone and build neovim
RUN git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/mckoy" CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# Clone config
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim && \
    rm -rf ~/.config/nvim/.git

RUN chown -R mckoy:mckoy /home/mckoy
USER mckoy

WORKDIR /home/mckoy

RUN /bin/bash -lc "source ~/.asdf/asdf.sh && \
    asdf plugin add nodejs && \
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git && \
    asdf plugin add rust https://github.com/code-lever/asdf-rust.git"

RUN /bin/bash -lc "source ~/.asdf/asdf.sh && \
    asdf install nodejs 18.17.0 && \
    asdf install golang 1.18.2 && \
    asdf install rust latest"

RUN /bin/bash -lc "source ~/.asdf/asdf.sh && \
    asdf global nodejs 18.17.0 && \
    asdf global golang 1.18.2 && \
    asdf global rust latest"

# Setup path for nvim command
ENV PATH="${PATH}:/home/mckoy/bin"

CMD ["tail", "-f", "/dev/null"]

