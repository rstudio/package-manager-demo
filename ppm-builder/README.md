# Posit Package Manager Jenkins Builder

This project defines a Docker image `ppm-builder` based on the standard Jenkins container images, with scripts and configuration to automatically build R and Python packages and publish those packages to a Posit Package Manager server.

### TODO:
- [ ] Improve secrets installation/handling
- [ ] Parameterize builder options better
- [ ] Improve docs for different Docker configs
- [ ] Document use with Dockerless (base OS-installed) Jenkins servers
- [ ] Figure out a better way to inject config into the builder jobs
- [ ] Add Python support

## Installation
1.

## Design

This project leverages the open-source [Jenkins](https://www.jenkins.io/) CI/CD system to manage the building and publishing of R and Python packages to Posit Package Manager.

The `ppm-builder` Docker image is built on top of the official [Jenkins LTS base image](https://hub.docker.com/r/jenkins/jenkins), with initial configuration bootstrapped via [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/) (JCasC).  The Jenkins [Job DSL plugin](https://plugins.jenkins.io/job-dsl/) is then used to automatically create build jobs.

1. The [Dockerfile](Dockerfile) is used to build an image `ppm-builder`, including:
    - Jenkins plugins defined via [plugins.txt](plugins.txt)
    - secrets such as credentials for accessing private Git repositories and API Tokens required to publish packages to Posit Package Manager
    - default configuration settings

        > Additional Jenkins configuration can be added through the [config.yaml](config.yaml) file, or manually configured via the Jenkins UI after deployment.
    - initial [seed job](builder-generator-r.groovy) injected into config at build time
1. Starting the `ppm-builder` container loads Jenkins with the configuration and `builder-generator-r` seed job installed.
1. The `builder-generator-r` runs and pulls builder job configuration from a Git repository, including:
    - `r-repos.txt`: a text file contining one Git repo URL per line
    - `r-builder.groovy`: a Jenkins Pipeline Job script template used to build and publish packages
1. The `builder-generator-r` job uses the Job DSL plugin to iterate over the repositories defined in `r-repos.txt` and create an associated build job in the `r-builders` folder for each Git URL, and queue them to run.
1. Each build job is queued to run and will continue to poll for repo changes according to the defined schedule.
1. Builder jobs run, build source and binary packages for the configured Git source, and publish those results to PPM using the remote publishing CLI.