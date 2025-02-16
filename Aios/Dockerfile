FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y wget curl lsof && rm -rf /var/lib/apt/lists/*

WORKDIR /root

COPY install.sh /root/install.sh

RUN chmod +x /root/install.sh

RUN /root/install.sh

EXPOSE 8003

CMD ["/root/aios/pop", "--ram=4", "--pubKey=Bt3LA755h6XVZKdaJTASDzL1QxwonBCRKr13CKwcWDEw", "--max-disk=100", "--cache-dir=/root/pipe-hca/download_cache"]
