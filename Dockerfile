FROM ubuntu:20.04

# Version
ENV version 3.10.13

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV PUID="99" PGID="100" UMASK="002"

# Add mongodb repo, key, update and install needed packages
RUN apt-get update && \
  apt-get install -y \
    apt-utils \
    jsvc \
    jq \
    moreutils \
    openjdk-8-jre-headless \
    patch \
    sudo \
    tzdata \
    gpg  \
    wget

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 20691eec35216c63caf66ce1656408e390cfb1f5 && \
  echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list && \
  apt-get update && \
  \
  # See https://github.com/docker-library/mongo/blob/3fecc7f8e812d9dc8b03e83f47bfe544442ad9a3/Dockerfile-linux.template#L91
  ln -s /bin/true /bin/systemctl && \
  env && \
  apt-get install -y \
    mongodb-org-server \
    mongodb-org-shell \
  && \
  rm -f /bin/systemctl

# Add needed patches and scripts
COPY unifi-video.patch /tmp/unifi-video.patch
COPY run.sh /usr/local/bin/run.sh

# Get, install and patch unifi-video
RUN wget -q -O /tmp/unifi-video.deb https://dl.ubnt.com/firmwares/ufv/v${version}/unifi-video.Ubuntu18.04_amd64.v${version}.deb && \
  apt install -y /tmp/unifi-video.deb && \
  patch -lN /usr/sbin/unifi-video /tmp/unifi-video.patch && \
  rm /tmp/unifi-video.deb && \
  rm /tmp/unifi-video.patch && \
  chmod 755 /usr/local/bin/run.sh

# RTMP, RTMPS & RTSP, Inbound Camera Streams & Camera Management (NVR Side), UVC-Micro Talkback (Camera Side)
# HTTP & HTTPS Web UI + API, Video over HTTP & HTTPS
EXPOSE 1935/tcp 7444/tcp 7447/tcp 6666/tcp 7442/tcp 7004/udp 7080/tcp 7443/tcp 7445/tcp 7446/tcp

# Run this potato
CMD ["/usr/local/bin/run.sh"]
