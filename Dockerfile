FROM debian:buster-slim AS build

RUN apt update && \
    apt install -y git && \
    apt install -y curl && \
    apt install -y file && \
    apt install -y cmake && \
    apt install -y gettext && \
    apt install -y opam

FROM scratch as nvim
COPY --from=build . .

RUN useradd -u 8877 -m mckoy
USER mckoy

WORKDIR /home/mckoy

RUN git clone https://github.com/neovim/neovim
RUN cd neovim && make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/mckoy" CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

RUN git clone -b dm_config --single-branch https://github.com/dmck0y/kickstart.nvim.git ~/.config/nvim
RUN rm -rf ~/.config/nvim/.git

FROM scratch
COPY --from=nvim . .

RUN apt install -y opam

RUN mkdir -p /home/mckoy/.opam/opam-init/hooks && \
    chown -R mckoy:mckoy /home/mckoy

USER mckoy
WORKDIR /home/mckoy

RUN opam init -y --disable-sandboxing --bare
RUN eval $(opam env) && opam switch create 4.10.0 && opam update

# Install ocaml/opam packages
RUN eval $(opam env) && opam install -y dune merlin ocaml-lsp-server odoc ocamlformat utop dune-release
RUN echo "eval $(opam env)" >> .profile

# Setup path for nvim command
ENV PATH="${PATH}:/home/mckoy/bin"
RUN /bin/bash -c "source ~/.profile"

CMD ["tail", "-f", "/dev/null"]

