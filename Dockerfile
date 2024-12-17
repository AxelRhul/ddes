FROM ubuntu:latest

RUN apt update 

RUN apt install -y vim

RUN apt install -y shellcheck

RUN apt install -y curl

COPY ddes.sh /ddes.sh

RUN chmod +x /ddes.sh