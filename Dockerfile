FROM ubuntu:latest

RUN apt update && apt install wget -y && apt install git -y

COPY ddes.sh ./ddes.sh

CMD ["tail", "-f", "/dev/null"]

