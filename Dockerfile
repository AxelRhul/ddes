FROM ubuntu:latest

RUN apt update 

RUN apt install -y vim shellcheck curl sudo

RUN useradd -m -s /bin/bash user

RUN echo 'user:user' | chpasswd

RUN usermod -aG sudo user

COPY ddes.sh /ddes.sh

COPY ddes.deb /ddes.deb

RUN chmod +x /ddes.sh