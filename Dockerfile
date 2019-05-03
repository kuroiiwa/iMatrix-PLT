# Based on 18.04 LTS
FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=US/New
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -yq update && \
    apt-get -y upgrade && \
    apt-get -yq --no-install-suggests --no-install-recommends install \
    apt-utils \
    ocaml \
    menhir \
    llvm-6.0 \
    llvm-6.0-dev \
    m4 \
    git \
    aspcud \
    ca-certificates \
    python2.7 \
    pkg-config \
    cmake \
    opam \
    clang \
    libopencv-dev

RUN ln -s /usr/bin/lli-6.0 /usr/bin/lli
RUN ln -s /usr/bin/llc-6.0 /usr/bin/llc

RUN opam init
RUN opam install \
    llvm.6.0.0 \
    ocamlfind

WORKDIR /root

ENTRYPOINT ["opam", "config", "exec", "--"]

CMD ["bash"]
