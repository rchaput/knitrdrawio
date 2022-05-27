FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# System dependencies:
#  - libgbm1 libasound2 xvfb: for knitrdrawio
#  - build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev: for devtools
ARG SYS_REQS="xvfb wget libgbm1 libasound2 build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev r-base pandoc"

# URL to the package repository. By default, we use RSPM for binary packages.
ARG CRAN="https://packagemanager.rstudio.com/cran/__linux__/focal/latest"

# Versions to install
ENV DRAWIO_VERSION="16.0.0"

# Install system requirements
RUN apt update && apt install -y ${SYS_REQS}

# Install draw.io
RUN wget -q -O drawio.deb https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb && \
    apt install -y ./drawio.deb && \
    rm -rf ./drawio.deb

# Configure R (repositories)
RUN echo >> /etc/Rprofile.site '\n\
# Set the repository\n\
options(repos = c(CRAN = "${CRAN}"))\n\
# Set the user agent for the repository\n\
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))\n\
'

# Install dependencies to build the package
RUN R -q -e 'install.packages("devtools"); devtools::install_dev_deps()'

# Build and install the package
RUN R -q -e 'devtools::build(); devtools::install()'
