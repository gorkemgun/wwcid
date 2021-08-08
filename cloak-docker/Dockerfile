FROM golang:1.16-buster

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends git jq qrencode

RUN git clone https://github.com/cbeuw/Cloak && \
	cd Cloak && \
	go get ./... && \
	make server && \
	make install

COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
