FROM adoptopenjdk/openjdk11:debian

ARG JIRA_VERSION=8.12.0
ARG JIRA_PRODUCT=jira-software
# Permissions, set the linux user id and group id
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000
# Language Settings
ARG LANG_LANGUAGE=en
ARG LANG_COUNTRY=US

ENV JIRA_USER=jira \
    JIRA_GROUP=jira \
    JIRA_CONTEXT_PATH=ROOT \
    JIRA_HOME=/var/atlassian/jira \
    JIRA_INSTALL=/opt/jira \
    JIRA_SCRIPTS=/usr/local/share/atlassian \
    MYSQL_DRIVER_VERSION=5.1.48 \
    DOWNLOAD_URL=https://www.atlassian.com/software/jira/downloads/binary/atlassian-${JIRA_PRODUCT}-${JIRA_VERSION}-x64.bin

# needs to be seperated since we need to use JIRA_INSTALL and it would not be popuplated if merged in one ENV
ENV JAVA_HOME="$JIRA_INSTALL/jre"
# splitted due to $JAVA_HOME
ENV PATH=$PATH:$JAVA_HOME/bin \
    LANG=${LANG_LANGUAGE}_${LANG_COUNTRY}.UTF-8

COPY bin_atlassian ${JIRA_SCRIPTS}
COPY bin/custom_scripts.sh /usr/local/bin/custom_scripts.sh
COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY bin/wait-for-it.sh /usr/local/bin/wait-for-it

# basic layout
RUN apt-get update \
    && apt-get install -y \
    ca-certificates \
    bash \
    gzip \
    curl \
    tini \
    wget \
    xmlstarlet \
    ttf-dejavu \
    postgresql-client \
    && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
    && curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /usr/bin/wait-for-it \
    # Install Jira
    && mkdir -p ${JIRA_HOME} \
    && mkdir -p ${JIRA_INSTALL} \
    && mkdir -p /docker-entrypoint.d \
    # Add user
    && export CONTAINER_GROUP=jira \
    && addgroup --gid $CONTAINER_GID $CONTAINER_GROUP

# install jira
RUN wget -O /tmp/jira.bin ${DOWNLOAD_URL} \
    && chmod +x /tmp/jira.bin \
    && /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile

# must come after the install, which creates the group itself
RUN export CONTAINER_USER=jira \
    && adduser --uid $CONTAINER_UID \
    --gid $CONTAINER_GID \
    --home /home/$CONTAINER_USER \
    --shell /bin/bash \
    $CONTAINER_USER

# Install database drivers
RUN  rm -f ${JIRA_INSTALL}/lib/mysql-connector-java*.jar \
    && wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz" \
    && tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz --directory=/tmp \
    && cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar ${JIRA_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar

# Adding letsencrypt-ca to truststore # && \
# Install atlassian ssl tool, which is mainly need to be able to create application links with other atlassian tools, which run LE SSL certificates
RUN wget -O /home/${JIRA_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class \
    # Set permissions
    && chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_HOME} \
    && chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_INSTALL}\
    && chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_SCRIPTS} \
    && chown -R $JIRA_USER:$JIRA_GROUP /home/${JIRA_USER} \
    && chmod +x /usr/local/bin/custom_scripts.sh /usr/local/bin/docker-entrypoint.sh /usr/local/bin/wait-for-it \
    # Clean caches and tmps
    && apt-get -y autoremove \
    && rm -rf /tmp/* /var/tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -fr /tmp/*.deb \
    && rm -rf /usr/share/man/?? \
    && rm -rf /usr/share/man/??_*

# Image Metadata
LABEL com.atlassian.application.jira.version=$JIRA_PRODUCT-$JIRA_VERSION \
    com.atlassian.application.jira.userid=$CONTAINER_UID \
    com.atlassian.application.jira.groupid=$CONTAINER_GID 

# fix cache eviction issue by adding <Resources cacheMaxSize="90240" />
# see https://stackoverflow.com/questions/26893297/tomcat-8-throwing-org-apache-catalina-webresources-cache-getresource-unable-to
COPY tomcat/context.xml /opt/jira/conf/context.xml

USER jira
WORKDIR ${JIRA_HOME}
VOLUME ["/var/atlassian/jira"]
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/docker-entrypoint.sh"]
CMD ["jira"]
