FROM jboss/keycloak:1.9.2.Final

ADD target/image /opt/jboss/keycloak

USER root
RUN rm /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml && \
	rm /opt/jboss/keycloak/setLogLevel.xsl && \
	chown jboss:jboss $({ find /opt/jboss/keycloak \! -user jboss ; find /opt/jboss/keycloak \! -group jboss ; } | sort -u)

USER jboss

# Override the base image entrypoint and arguments.
ENTRYPOINT [ "/opt/jboss/keycloak/bin/standalone.sh" ]
CMD [ ]
