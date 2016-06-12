# Base Image
FROM debian:wheezy
MAINTAINER zdzhou@iflytek.com

RUN apt-get update \
        && apt-get install -y curl wget \
        && rm -rf /var/lib/apt/lists/*

# Install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.2.3.4 main" > /etc/apt/sources.list.d/mono-xamarin.list \
        && apt-get update \
        && apt-get install -y mono-devel ca-certificates-mono fsharp mono-vbnc nuget \
        && rm -rf /var/lib/apt/lists/*

# Install jexus
ENV JEXUS_VERSION 5.8.1
ENV JEXUS_INSTALL_PATH /usr/jexus

RUN cd /usr/local \
    && wget linuxdot.net/down/jexus-$JEXUS_VERSION.tar.gz \
    && tar -zxvf jexus-$JEXUS_VERSION.tar.gz \
    && rm -rf jexus-$JEXUS_VERSION.tar.gz \
    && cd jexus-$JEXUS_VERSION \
    && ./install

# Jexus configuration
# Next version

# Jexus website configuration 
WORKDIR $JEXUS_INSTALL_PATH

RUN ls /usr/jexus
RUN mv $JEXUS_INSTALL_PATH/siteconf/default  $JEXUS_INSTALL_PATH/siteconf/nlp \
    && echo "port=8082" > siteconf/nlp \
    && echo "root=/ /var/www/nlp" >> siteconf/nlp \
    && echo "hosts=*" >> siteconf/nlp \
    && echo "indexs=Default.aspx" >> siteconf/nlp \
    && echo "NoLog=true" >> siteconf/nlp


# Copy website to dest dir
ENV WEBROOT /var/www/nlp
RUN mkdir -p $WEBROOT
COPY . $WEBROOT

EXPOSE 8082
COPY ./start.sh /
#ENTRYPOINT ["./jws", "start"]
ENTRYPOINT ["/bin/sh", "/start.sh"]
