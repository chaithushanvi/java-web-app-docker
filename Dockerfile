FROM tomcat:9.0-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/java-web-app.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8081
CMD ["catalina.sh", "run"]
