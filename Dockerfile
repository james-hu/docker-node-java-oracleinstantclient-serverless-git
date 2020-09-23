FROM node:10.22.1-buster-slim

# install serverless
RUN npm install -g serverless@1.83.0

# update sources list
RUN apt-get clean \
    && apt-get update \
    && apt-get dist-upgrade -y

# install openjdk
RUN apt-get install -y gnupg wget unzip software-properties-common
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt-get update
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y adoptopenjdk-8-hotspot
ENV JAVA_HOME /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64

# install locales
RUN apt-get install -y locales
RUN sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# install oracle
RUN apt-get install -y libaio1

RUN mkdir -p opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle

RUN unzip /opt/oracle/instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle \
 && mv /opt/oracle/instantclient_19_6 /opt/oracle/instantclient \
 && rm -rf /opt/oracle/*.zip

ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"
ENV OCI_HOME="/opt/oracle/instantclient"
ENV OCI_LIB_DIR="/opt/oracle/instantclient"
ENV OCI_VERSION=19

RUN echo '/opt/oracle/instantclient/' | tee -a /etc/ld.so.conf.d/oracle_instant_client.conf && ldconfig

# purge
RUN apt-get clean -y \
&& apt-get autoclean -y \
&& apt-get purge -y unzip gnupg wget curl make autoconf g++ python3 perl perl5

# install git
RUN apt-get install -y git

# install lsof
RUN apt-get install -y lsof

RUN apt-get -y autoremove \
&& rm -rf /usr/share/man \
&& rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

RUN node -v
RUN npm -version
RUN echo $JAVA_HOME
RUN java -version
RUN sls -version
RUN git --version