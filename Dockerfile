FROM ubuntu:latest

COPY ddes.sh /ddes.sh

RUN chmod +x /ddes.sh

ENTRYPOINT ["/ddes.sh"]