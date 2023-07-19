FROM ubuntu:latest AS build

RUN apt update && \
    apt install -y git && \
    apt install -y curl && \
    apt install -y file && \
    apt install -y cmake && \
    apt install -y gettext && \
    apt install -y opam

FROM scratch
COPY --from=build . .

RUN useradd -u 8877 -m mckoy
RUN mkdir -p /home/mckoy/.opam/opam-init/hooks && \
    chown -R mckoy:mckoy /home/mckoy

USER mckoy

WORKDIR /home/mckoy

RUN opam -y init && \
    eval $(opam env)
RUN opam install -y dune merlin ocaml-lsp-server odoc ocamlformat utop dune-release
#RUN echo "eval $(opam env)" >> .bashrc

RUN git clone https://github.com/LazyVim/starter ~/.config/nvim
RUN rm -rf ~/.config/nvim/.git
COPY --chown=mckoy nvim ./.config/nvim

RUN git clone https://github.com/neovim/neovim
RUN cd neovim && make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/mckoy" CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

ENV PATH="${PATH}:/home/mckoy/bin"

CMD ["tail", "-f", "/dev/null"]
