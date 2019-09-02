FROM debian:sid-slim

ENV JAVA_MAJOR 8
ENV JAVA_MINOR 0_221
ENV JAVA_HOME /opt/java

ENV CONF_HOME /var/atlassian/confluence
ENV CONF_INSTALL /opt/atlassian/confluence
ENV CONF_VERSION 6.15.8


COPY 	jdk1.${JAVA_MAJOR}.${JAVA_MINOR} /opt/jdk1.${JAVA_MAJOR}.${JAVA_MINOR}


RUN  ln -s /opt/jdk1.${JAVA_MAJOR}.${JAVA_MINOR} /opt/java
RUN  rm /opt/java/src.zip

RUN 	apt update \
	&& apt upgrade -y \
	&& apt install curl -y \
	&& mkdir -p ${CONF_HOME} \
	&& mkdir -p ${CONF_INSTALL} \
	&& curl -Ls "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
	&& curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz" | tar -xz --directory "${CONF_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar" \
	&& chown -R daemon:daemon ${CONF_HOME} \
	&& chown -R daemon:daemon ${CONF_INSTALL} \
	&& echo -e  "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" 

# copy 32 bit setenv
#RUN cp "${CONF_INSTALL}/bin/setenv32.sh" "${CONF_INSTALL}/bin/setenv.sh"

#increase timeout for starting plugin
#RUN sed --in-place  "s/JVM_SUPPORT_RECOMMENDED_ARGS=\"\"/JVM_SUPPORT_RECOMMENDED_ARGS=\"-Datlassian.plugins.enable.wait=300\"/g" "${CONF_INSTALL}/bin/setenv.sh"
	
#RUN echo "jira.index.batch.maxrambuffermb=256\njira.index.interactive.maxrambuffermb=256\n" >>${CONF_INSTALL}/conluence-config.properties

# run as daemon user
USER daemon:daemon

EXPOSE 8090 8091

VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

WORKDIR /var/atlassian/confluence

COPY "docker-entrypoint.sh" "/"
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]


