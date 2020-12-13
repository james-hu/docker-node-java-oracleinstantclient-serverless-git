FROM redis:6 as redis
FROM cypress/included:6.1.0

# copy redis files
COPY --from=redis /usr/local/bin/redis-* /usr/local/bin/

# update sources list
RUN apt-get clean \
    && apt-get update \
    && apt-get dist-upgrade -y

# install openjdk
RUN apt-get install -yq gnupg wget zip unzip software-properties-common python3
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt-get update
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -yq adoptopenjdk-8-hotspot
ENV JAVA_HOME /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64

# install locales
RUN apt-get install -yq locales
RUN sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# install oracle
RUN apt-get install -yq libaio1

RUN mkdir -p opt/oracle
RUN wget -q https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle

RUN unzip /opt/oracle/instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle \
 && mv /opt/oracle/instantclient_19_6 /opt/oracle/instantclient \
 && rm -rf /opt/oracle/*.zip

ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"
ENV OCI_HOME="/opt/oracle/instantclient"
ENV OCI_LIB_DIR="/opt/oracle/instantclient"
ENV OCI_VERSION=19

RUN echo '/opt/oracle/instantclient/' | tee -a /etc/ld.so.conf.d/oracle_instant_client.conf && ldconfig

# install serverless
RUN npm install -g serverless@2.15.0

# install python related
RUN apt-get -yq install python3-pip
RUN pip3 install greenlet gevent locust retrying 

# purge
RUN apt-get clean -yq \
&& apt-get autoclean -yq \
&& apt-get purge -yq make autoconf g++ perl perl5

# install git
RUN apt-get install -yq git

# install lsof and pgrep etc.
RUN apt-get install -yq lsof procps

# purge again
RUN apt-get -yq autoremove \
&& rm -rf /usr/share/man \
&& rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

ENTRYPOINT []

# show version info
RUN node -v
RUN npm -version
RUN sls -version
RUN cypress -v

RUN echo $JAVA_HOME
RUN java -version

RUN git --version
RUN redis-server --version
RUN redis-cli --version
