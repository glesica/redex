FROM ubuntu:16.04
MAINTAINER George Lesica
RUN apt-get -y update && apt-get install -y \
    redis-server
ENTRYPOINT ["runredis.sh"]
COPY runredis.sh /usr/bin/runredis.sh

