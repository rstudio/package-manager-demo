# Build templates for Posit Package Manager Jenkins Builder

This directory contains build templates and repo lists for use with Posit Package Manager

- [r-repos.txt](r-repos.txt) - A plain text file containing Git repositories to build, one per line
- [r-builder.groovy](r-builder.groovy) - A Jenkins Pipeline Job definition used to build and publish a package.  The placeholder `!!!REPO_URL!!!` is replaced with a corresponding value from the `r-repos.txt` file when the job is created.
