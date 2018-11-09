FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

#ENV GOSU_VERSION 1.7
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
RUN apt-get -qq update && apt-get -qq install --yes --no-install-recommends software-properties-common
RUN apt-add-repository non-free
RUN apt-add-repository contrib
RUN apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales \
  && `#----- Install the dependencies -----` \
  && apt-get -qq install --yes --no-install-recommends fontconfig imagemagick \
  && `#----- Deal with ttf-mscorefonts-installer -----` \
  && apt-get -qq install --yes --no-install-recommends xfonts-utils ttf-mscorefonts-installer\
  && `#----- Install gosu -----` \
  && apt-get -qq install --yes --no-install-recommends gosu \
  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8



ENV PLATFORM_VERSION 83
ENV SERVER_VERSION 8.3.12-1595

ADD ./${SERVER_VERSION}/*.deb /tmp/

RUN dpkg --force-architecture --install /tmp/1c-enterprise${PLATFORM_VERSION}-common_${SERVER_VERSION}_i386.deb 
RUN dpkg --force-architecture --install /tmp/1c-enterprise${PLATFORM_VERSION}-server_${SERVER_VERSION}_i386.deb 
RUN rm /tmp/*.deb
RUN mkdir --parent /var/log/1C /home/usr1cv8/.1cv8/1C/1cv8/conf 
RUN chown --recursive usr1cv8:grp1cv8 /var/log/1C /home/usr1cv8

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -qq install --yes --no-install-recommends libc6:i386 libncurses5:i386 libstdc++6:i386

RUN chmod a+x /opt/1C/v8.3/i386/ragent

COPY container/docker-entrypoint.sh /
COPY container/logcfg.xml /home/usr1cv8/.1cv8/1C/1cv8/conf

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /home/usr1cv8
VOLUME /var/log/1C

EXPOSE 1540-1541 1560-1591

CMD ["ragent"]
