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
COPY builder-generator-r.groovy /var/jenkins_home/builder-generator-r.groovy
USER root
RUN curl -L -o yq https://github.com/mikefarah/yq/releases/download/v4.33.2/yq_linux_amd64 \
    && chmod +x yq \
    && ./yq -i '.jobs += [{"script":load_str("/var/jenkins_home/builder-generator-r.groovy")}]' /var/jenkins_home/config.yaml

USER jenkins
