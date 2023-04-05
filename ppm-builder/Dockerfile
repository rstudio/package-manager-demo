FROM jenkins/jenkins:lts-jdk11
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/config.yaml

# Set HTTP port to 8083
ENV JENKINS_OPTS --httpPort=8083
EXPOSE 8083

# Install Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Add secrets
COPY apitoken.txt /run/secrets/PPM_TOKEN
COPY gitsshkey /run/secrets/GIT_SSH_KEY

# Install configuration
COPY config.yaml /var/jenkins_home/config.yaml

